import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';

import '../features/ai/model/ai_model.dart';
import '../features/ai/model/chat_message.dart';

/// Thrown by [ChatEngine.load] when the model file is not on the device.
class ModelNotInstalledException implements Exception {
  const ModelNotInstalledException(this.model);
  final AIModel model;

  @override
  String toString() => '${model.name} is not downloaded.';
}

/// Owns one on-device conversation: model activation, the native chat
/// session, history replay, streaming, cancellation and audio transcription.
///
/// flutter_edge_ai keeps a single native model alive per model *name*, so a
/// change of backend or context size would otherwise be silently ignored
/// until a different model was opened. [load] tracks the configuration the
/// cached instance was built with and recycles it when that changes.
class ChatEngine {
  ChatEngine(this.model, {this.systemInstruction});

  final AIModel model;

  /// Optional persona/format guidance applied to every turn.
  final String? systemInstruction;

  static InferenceModel? _loadedModel;
  static String? _loadedConfig;

  /// How many recent messages are replayed into a fresh session. Older turns
  /// stay in the database but would not fit a phone-sized context window.
  static const maxReplayMessages = 20;

  static const _transcribePrompt =
      'Transcribe the audio. Output only the transcript, nothing else. '
      'Do not summarize or respond to it.';

  InferenceChat? _chat;
  bool _thinking = false;
  bool _disposed = false;

  bool get isReady => _chat != null;
  bool get thinking => _thinking;

  static Future<bool> isInstalled(AIModel model) async {
    try {
      return await FlutterEdgeAi.isModelInstalled(model.fileName);
    } catch (_) {
      return false;
    }
  }

  /// Activates [model], builds a chat session and replays [history] into it.
  ///
  /// Never downloads: if the file is missing this throws
  /// [ModelNotInstalledException] so the UI can send the user to the store,
  /// where progress, cancellation and gated-model tokens are handled.
  Future<void> load({
    required PreferredBackend backend,
    List<ChatMessage> history = const [],
  }) async {
    if (!await isInstalled(model)) throw ModelNotInstalledException(model);

    // For an installed file this only marks it as the active model.
    await FlutterEdgeAi.installModel(
      modelType: model.modelType,
      fileType: model.fileType,
    ).fromNetwork(model.downloadUrl).install();

    final config = '${model.id}|${backend.name}|${model.contextTokens}';
    if (_loadedModel != null && _loadedConfig != config) {
      await _closeQuietly(_loadedModel!.close);
      _loadedModel = null;
    }

    _loadedModel = await FlutterEdgeAi.getActiveModel(
      maxTokens: model.contextTokens,
      preferredBackend: backend,
      supportImage: model.supportsImage,
      supportAudio: model.supportsAudio,
    );
    _loadedConfig = config;

    await _createChat(history);
  }

  /// Rebuilds the session with reasoning on or off, keeping the conversation.
  Future<void> setThinking(bool value, List<ChatMessage> history) async {
    _thinking = value && model.canThink;
    if (_loadedModel != null) await _createChat(history);
  }

  /// Resets the native session so it mirrors [history] exactly, e.g. after
  /// the user deletes a message or older pages are loaded.
  Future<void> replay(List<ChatMessage> history) async {
    final chat = _chat;
    if (chat == null) return;
    final recent =
        history.length > maxReplayMessages
            ? history.sublist(history.length - maxReplayMessages)
            : history;
    await chat.clearHistory(
      replayHistory: recent.where(_hasPayload).map(_toMessage).toList(),
    );
  }

  /// Sends [message] and streams the reply. Yields [TextResponse] tokens and,
  /// in reasoning mode, [ThinkingResponse] chunks.
  Stream<ModelResponse> send(ChatMessage message) async* {
    final chat = _requireChat();
    await chat.addQueryChunk(_toMessage(message));
    yield* chat.generateChatResponseAsync();
  }

  Future<void> stop() async {
    final chat = _chat;
    if (chat != null) await _closeQuietly(chat.stopGeneration);
  }

  /// Transcribes 16 kHz mono WAV audio, then restores [history] so the
  /// transcription request never becomes part of the conversation.
  Future<String> transcribe(Uint8List wav, List<ChatMessage> history) async {
    final chat = _requireChat();
    final buffer = StringBuffer();
    try {
      await chat.addQueryChunk(
        Message.withAudio(
          text: _transcribePrompt,
          audioBytes: wav,
          isUser: true,
        ),
      );
      await for (final response in chat.generateChatResponseAsync()) {
        if (response is TextResponse) buffer.write(response.token);
      }
    } finally {
      await _closeQuietly(() => replay(history));
    }
    return buffer.toString().trim();
  }

  Future<void> dispose() async {
    _disposed = true;
    final chat = _chat;
    _chat = null;
    if (chat != null) {
      await _closeQuietly(chat.stopGeneration);
      await _closeQuietly(chat.close);
    }
  }

  /// Some small model conversions (e.g. Qwen2.5 0.5B `.task`) emit the two
  /// characters `\` `n` instead of a line break. Converts those in prose while
  /// leaving fenced and inline code untouched, where `\n` can be meant.
  static String normalizeReply(String text) {
    text = _repairMojibake(text);
    if (!text.contains(r'\n')) return text;
    final out = StringBuffer();
    final fences = text.split('```');
    for (var i = 0; i < fences.length; i++) {
      if (i > 0) out.write('```');
      if (i.isOdd) {
        out.write(fences[i]); // inside a code fence
        continue;
      }
      final inline = fences[i].split('`');
      for (var j = 0; j < inline.length; j++) {
        if (j > 0) out.write('`');
        out.write(j.isOdd ? inline[j] : inline[j].replaceAll(r'\n', '\n'));
      }
    }
    return out.toString();
  }

  // A UTF-8 lead byte (C2–F4) followed by 1–3 continuation bytes (80–BF),
  // each decoded as its own Latin-1 character: "é" arrives as "Ã©".
  static final _mojibake = RegExp('[\u00C2-\u00F4][\u0080-\u00BF]{1,3}');

  /// MediaPipe streams some models' multi-byte UTF-8 one byte per character,
  /// so "Café" shows as "CafÃ©". Re-decodes only runs that form valid UTF-8;
  /// real Latin-1 text (a lone "é") doesn't match and is left as is.
  static String _repairMojibake(String text) {
    if (!_mojibake.hasMatch(text)) return text;
    return text.replaceAllMapped(_mojibake, (m) {
      try {
        return utf8.decode(latin1.encode(m[0]!));
      } on FormatException {
        return m[0]!;
      }
    });
  }

  /// Turns engine failures into something a person can act on.
  static String describeError(Object error) {
    final text = error.toString();
    if (error is ModelNotInstalledException) {
      return '${error.model.name} isn\'t downloaded. Get it from the Models tab.';
    }
    if (text.toLowerCase().contains('simulator') ||
        text.contains('llm_litert_compiled_model_executor') ||
        text.contains('Failed to invoke the compiled model')) {
      return 'On-device AI needs a physical device; the iOS Simulator '
          'can\'t run these models.';
    }
    if (text.contains('OUT_OF_MEMORY') ||
        text.toLowerCase().contains('out of memory')) {
      return 'Not enough free memory to run this model. Close other apps '
          'or pick a smaller model.';
    }
    return 'Something went wrong running the model: $text';
  }

  Future<void> _createChat(List<ChatMessage> history) async {
    final old = _chat;
    _chat = null;
    if (old != null) await _closeQuietly(old.close);
    if (_disposed) return;

    _chat = await _loadedModel!.createChat(
      // The plugin default (topK 1) is greedy decoding, which makes small
      // models loop on the same phrase. These match common chat defaults.
      temperature: 0.8,
      topK: 40,
      topP: 0.95,
      randomSeed: Random().nextInt(1 << 31),
      enableThinking: _thinking,
      supportImage: model.supportsImage,
      supportAudio: model.supportsAudio,
      systemInstruction: systemInstruction,
    );
    await replay(history);
  }

  InferenceChat _requireChat() {
    final chat = _chat;
    if (chat == null) throw StateError('${model.name} is not loaded yet.');
    return chat;
  }

  static bool _hasPayload(ChatMessage m) =>
      m.content.trim().isNotEmpty || m.imageBytes != null;

  Message _toMessage(ChatMessage m) {
    final image = m.imageBytes;
    if (image != null && model.supportsImage) {
      return Message.withImage(
        text: m.content,
        imageBytes: image,
        isUser: m.isUser,
      );
    }
    return Message.text(text: m.content, isUser: m.isUser);
  }

  static Future<void> _closeQuietly(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      debugPrint('ChatEngine cleanup failed: $e');
    }
  }
}
