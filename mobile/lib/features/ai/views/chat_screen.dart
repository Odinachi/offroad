import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jemenai/features/ai/model/chat_message.dart';
import 'package:jemenai/services/chat_engine.dart';
import 'package:jemenai/services/db_service.dart';
import 'package:jemenai/shared/navigator/app_router.dart';
import 'package:jemenai/shared/widgets/markdown_text.dart';
import 'package:jemenai/shared/widgets/model_avatar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/theme.dart';
import '../../dashboard/view_models/app_cubit.dart';
import '../model/ai_model.dart';
import '../view_models/model_download_cubit.dart';

class ChatScreenArg {
  final String? modelName;

  /// Sent automatically once the model is ready.
  final String? initialPrompt;

  /// Placed in the input box for the user to review/complete, not sent.
  final String? draft;

  /// Opens the photo picker once the model is ready (Pic-to-Text).
  final bool pickImage;

  final String? sessionId;
  final bool isTab;

  const ChatScreenArg({
    this.modelName,
    this.initialPrompt,
    this.draft,
    this.pickImage = false,
    this.sessionId,
    this.isTab = false,
  });
}

enum _ModelStatus { loading, ready, notInstalled, failed }

class ChatScreen extends StatefulWidget {
  final ChatScreenArg? args;

  const ChatScreen({super.key, this.args});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _pageSize = 20;
  static const _uuid = Uuid();

  late AIModel _model;
  ChatEngine? _engine;
  _ModelStatus _status = _ModelStatus.loading;
  String? _loadError;

  String? _sessionId;
  final List<ChatMessage> _messages = [];
  int _messageOffset = 0;
  bool _hasMoreMessages = true;
  bool _isLoadingMore = false;

  bool _awaitingReply = false;
  String _streamText = '';
  String _streamThinking = '';
  bool _thinking = false;

  bool _showModels = false;
  bool _showAttachments = false;
  Uint8List? _attachedImage;

  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isTranscribing = false;

  final _inputController = TextEditingController();
  final _inputFocus = FocusNode();
  final _scrollController = ScrollController();

  bool get _ready => _status == _ModelStatus.ready && _engine?.isReady == true;
  bool get _busy => _awaitingReply || _isRecording || _isTranscribing;
  bool get _canSend =>
      _ready &&
      !_busy &&
      (_inputController.text.trim().isNotEmpty || _attachedImage != null);

  List<AIModel> get _installedModels {
    final cubit = context.read<ModelDownloadCubit>();
    return models
        .where((m) => cubit.statusFor(m.id).phase == DownloadPhase.installed)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _model = findModelByName(widget.args?.modelName) ?? models.first;
    _sessionId = widget.args?.sessionId;
    if (widget.args?.draft case final draft?) _inputController.text = draft;
    _scrollController.addListener(_onScroll);
    _start();
  }

  @override
  void dispose() {
    _engine?.dispose();
    _audioRecorder.dispose();
    _inputController.dispose();
    _inputFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  Future<void> _start() async {
    if (_sessionId != null) await _loadMessagesPage();
    await _loadModel();
    if (!mounted || !_ready) return;

    final prompt = widget.args?.initialPrompt?.trim();
    if (prompt != null && prompt.isNotEmpty) {
      await _send(prompt);
    } else if (widget.args?.pickImage == true && _model.supportsImage) {
      await _pickImage(ImageSource.gallery);
    }
  }

  Future<void> _loadModel() async {
    final previous = _engine;
    _engine = null;
    await previous?.dispose();
    if (!mounted) return;

    final engine = ChatEngine(_model);
    setState(() {
      _status = _ModelStatus.loading;
      _loadError = null;
      _thinking = false;
    });

    final backend =
        context.read<AppCubit>().inferenceEngine == 'gpu'
            ? PreferredBackend.gpu
            : PreferredBackend.cpu;

    try {
      await engine.load(backend: backend, history: _messages);
      if (!mounted) {
        await engine.dispose();
        return;
      }
      setState(() {
        _engine = engine;
        _status = _ModelStatus.ready;
      });
    } on ModelNotInstalledException {
      await engine.dispose();
      if (mounted) setState(() => _status = _ModelStatus.notInstalled);
    } catch (e) {
      debugPrint('Failed to load ${_model.name}: $e');
      await engine.dispose();
      if (mounted) {
        setState(() {
          _status = _ModelStatus.failed;
          _loadError = ChatEngine.describeError(e);
        });
      }
    }
  }

  Future<void> _loadMessagesPage() async {
    final sessionId = _sessionId;
    if (sessionId == null || _isLoadingMore || !_hasMoreMessages) return;
    setState(() => _isLoadingMore = true);
    var loaded = false;
    try {
      final rows = await DatabaseService().getMessages(
        sessionId,
        limit: _pageSize,
        offset: _messageOffset,
      );
      if (!mounted) return;
      setState(() {
        _messages.insertAll(0, rows.reversed.map(ChatMessage.fromRow));
        _messageOffset += rows.length;
        _hasMoreMessages = rows.length == _pageSize;
      });
      loaded = rows.isNotEmpty;
    } catch (e) {
      debugPrint('Failed to load messages: $e');
      if (mounted) setState(() => _hasMoreMessages = false);
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
    // Older turns arriving after the model loaded must reach its context too.
    if (loaded && _ready && !_busy) await _engine?.replay(_messages);
  }

  void _onScroll() {
    // The list is reversed, so older messages live at the max extent.
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMessagesPage();
    }
  }

  void _scrollToLatest() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  // ── Sending ──────────────────────────────────────────────────────────────

  Future<void> _send([String? overrideText]) async {
    final engine = _engine;
    final text = (overrideText ?? _inputController.text).trim();
    final image = _attachedImage;
    if (engine == null || !_ready || _busy || (text.isEmpty && image == null)) {
      return;
    }

    final message = ChatMessage(
      id: _uuid.v4(),
      role: 'user',
      content: text,
      ts: DateTime.now(),
      imageBytes: image,
    );
    final isFirstMessage = _sessionId == null;
    final sessionId = _sessionId ??= _uuid.v4();

    setState(() {
      _inputController.clear();
      _attachedImage = null;
      _showAttachments = false;
      _messages.add(message);
    });
    _scrollToLatest();

    try {
      if (isFirstMessage) {
        await DatabaseService().createSession(
          id: sessionId,
          title: chatTitleFor(text),
          modelName: _model.name,
        );
      }
      await DatabaseService().addMessage(
        id: message.id,
        sessionId: sessionId,
        role: 'user',
        content: text,
        hasImage: image != null,
      );
    } catch (e) {
      debugPrint('Failed to save message: $e');
    }

    await _respond(engine, message);
  }

  /// Streams the model's reply to [prompt] and persists whatever was produced,
  /// including a partial reply if the user pressed stop.
  Future<void> _respond(ChatEngine engine, ChatMessage prompt) async {
    setState(() {
      _awaitingReply = true;
      _streamText = '';
      _streamThinking = '';
    });

    final text = StringBuffer();
    final thinking = StringBuffer();
    final throttle = Stopwatch()..start();
    Object? error;

    try {
      await for (final response in engine.send(prompt)) {
        if (!mounted) return;
        switch (response) {
          case TextResponse(:final token):
            text.write(token);
          case ThinkingResponse(:final content):
            thinking.write(content);
          default:
            continue;
        }
        // Rebuilding (and re-parsing markdown) on every token is wasteful;
        // ~20 fps is indistinguishable while streaming.
        if (throttle.elapsedMilliseconds > 50) {
          throttle.reset();
          setState(() {
            _streamText = ChatEngine.normalizeReply(text.toString());
            _streamThinking = thinking.toString();
          });
        }
      }
    } catch (e) {
      debugPrint('Generation failed: $e');
      error = e;
    }

    if (!mounted) return;

    final reply = ChatEngine.normalizeReply(text.toString()).trim();
    final reasoning = thinking.toString().trim();
    ChatMessage? answer;
    if (reply.isNotEmpty) {
      answer = ChatMessage(
        id: _uuid.v4(),
        role: 'assistant',
        content: reply,
        ts: DateTime.now(),
        thinking: reasoning.isEmpty ? null : reasoning,
      );
      try {
        await DatabaseService().addMessage(
          id: answer.id,
          sessionId: _sessionId!,
          role: 'assistant',
          content: answer.content,
          thinking: answer.thinking,
        );
      } catch (e) {
        debugPrint('Failed to save reply: $e');
      }
    }

    if (!mounted) return;
    setState(() {
      if (answer != null) _messages.add(answer);
      _awaitingReply = false;
      _streamText = '';
      _streamThinking = '';
    });

    if (error != null) {
      AppRouter.showMessage(ChatEngine.describeError(error));
    } else if (answer == null) {
      AppRouter.showMessage('The model returned an empty reply. Try again.');
    }
  }

  Future<void> _stop() => _engine?.stop() ?? Future.value();

  // ── Message actions ──────────────────────────────────────────────────────

  Future<void> _deleteMessage(ChatMessage message) async {
    setState(() => _messages.removeWhere((m) => m.id == message.id));
    try {
      await DatabaseService().deleteMessage(message.id);
      if (_messageOffset > 0) _messageOffset--;
      await _engine?.replay(_messages);
    } catch (e) {
      debugPrint('Failed to delete message: $e');
    }
  }

  /// Drops the last reply and asks again with the same prompt.
  Future<void> _regenerate() async {
    final engine = _engine;
    if (engine == null || _busy || _messages.length < 2) return;
    final last = _messages.last;
    final prompt = _messages[_messages.length - 2];
    if (last.isUser || !prompt.isUser) return;

    setState(() => _messages.removeLast());
    try {
      await DatabaseService().deleteMessage(last.id);
      // Rebuild the session without the old exchange; [_respond] re-adds
      // the prompt as it sends it.
      await engine.replay(_messages.sublist(0, _messages.length - 1));
    } catch (e) {
      debugPrint('Failed to reset for regeneration: $e');
    }
    if (mounted) await _respond(engine, prompt);
  }

  Future<void> _toggleThinking() async {
    final engine = _engine;
    if (engine == null || _busy) return;
    final enable = !_thinking;
    setState(() => _thinking = enable);
    try {
      await engine.setThinking(enable, _messages);
    } catch (e) {
      debugPrint('Failed to switch reasoning mode: $e');
      if (mounted) setState(() => _thinking = !enable);
      AppRouter.showMessage(ChatEngine.describeError(e));
    }
  }

  Future<void> _switchModel(AIModel model) async {
    setState(() => _showModels = false);
    if (model.id == _model.id && _status == _ModelStatus.ready) return;

    // A conversation whose model went missing continues with the new one;
    // otherwise switching models starts a fresh chat.
    final continueSession = _sessionId != null && _status != _ModelStatus.ready;
    if (continueSession) {
      await DatabaseService().updateSessionModel(_sessionId!, model.name);
    } else {
      _resetConversation();
    }
    setState(() => _model = model);
    await _loadModel();
  }

  void _resetConversation() {
    setState(() {
      _sessionId = null;
      _messages.clear();
      _messageOffset = 0;
      _hasMoreMessages = true;
    });
  }

  Future<void> _newChat() async {
    if (_busy) return;
    _resetConversation();
    await _engine?.replay(const []);
  }

  Future<void> _deleteChat() async {
    final sessionId = _sessionId;
    if (sessionId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete chat?'),
            content: const Text(
              'This conversation will be permanently removed from this device.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    await DatabaseService().deleteSession(sessionId);
    if (!mounted) return;
    if (widget.args?.isTab ?? false) {
      await _newChat();
    } else {
      AppRouter.pop();
    }
  }

  // ── Attachments & audio ──────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        // Vision encoders downscale anyway; this keeps memory and prefill low.
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _attachedImage = bytes;
        _showAttachments = false;
      });
      _inputFocus.requestFocus();
    } on PlatformException catch (e) {
      debugPrint('Image picker failed: $e');
      AppRouter.showMessage(
        source == ImageSource.camera
            ? 'Camera access is needed to take a photo. Enable it in Settings.'
            : 'Photo access is needed to attach an image. Enable it in Settings.',
      );
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (!await ensureMicrophonePermission()) return;
    try {
      final dir = await getTemporaryDirectory();
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path:
            '${dir.path}/offroad_${DateTime.now().millisecondsSinceEpoch}.wav',
      );
      HapticFeedback.mediumImpact();
      if (mounted) setState(() => _isRecording = true);
    } catch (e) {
      AppRouter.showMessage('Couldn\'t start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    final wav = await stopRecordingAndRead(_audioRecorder);
    if (!mounted) return;
    setState(() => _isRecording = false);
    if (wav != null) await _transcribe(wav);
  }

  /// Transcribes into the input box so the user can fix mistakes before
  /// sending — on-device speech recognition isn't perfect.
  Future<void> _transcribe(Uint8List wav) async {
    final engine = _engine;
    if (engine == null) return;
    setState(() => _isTranscribing = true);
    try {
      final transcript = await engine.transcribe(wav, _messages);
      if (!mounted) return;
      if (transcript.isEmpty) {
        AppRouter.showMessage('Couldn\'t make out any speech. Try again.');
      } else {
        final existing = _inputController.text.trim();
        _inputController.text =
            existing.isEmpty ? transcript : '$existing $transcript';
        _inputController.selection = TextSelection.collapsed(
          offset: _inputController.text.length,
        );
        _inputFocus.requestFocus();
      }
    } catch (e) {
      debugPrint('Transcription failed: $e');
      AppRouter.showMessage(ChatEngine.describeError(e));
    } finally {
      if (mounted) setState(() => _isTranscribing = false);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_showModels,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _showModels = false);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _buildHeader(theme),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: _buildBody(theme),
                  ),
                ),
                _buildInputBar(theme),
              ],
            ),
            if (_showModels) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showModels = false),
                  child: ColoredBox(color: Colors.black.withValues(alpha: 0.2)),
                ),
              ),
              _buildModelsPicker(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final jc = theme.jColors;
    final fore = theme.colorScheme.onSurface;
    final subtitle = switch (_status) {
      _ModelStatus.loading => 'Loading model…',
      _ModelStatus.ready => 'On-device · Private',
      _ModelStatus.notInstalled => 'Not downloaded',
      _ModelStatus.failed => 'Failed to load',
    };

    return Container(
      decoration: BoxDecoration(
        color: jc.card,
        border: Border(bottom: BorderSide(color: jc.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (!(widget.args?.isTab ?? false))
              IconButton(
                tooltip: 'Back',
                onPressed: () => AppRouter.pop(),
                icon: Icon(Icons.arrow_back_ios_new, color: fore),
              )
            else
              const SizedBox(width: 16),
            Expanded(
              child: Semantics(
                button: true,
                label: 'Change model. Current model: ${_model.name}',
                excludeSemantics: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap:
                      _busy
                          ? null
                          : () => setState(() => _showModels = !_showModels),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        ModelAvatar(model: _model, size: 32),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _model.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: JemenaiTheme.fontDisplay(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: fore,
                                ),
                              ),
                              Text(
                                subtitle,
                                style: JemenaiTheme.fontBody(
                                  fontSize: 10,
                                  color:
                                      _status == _ModelStatus.failed
                                          ? theme.colorScheme.error
                                          : jc.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _showModels
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 16,
                          color: jc.mutedForeground,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'More',
              icon: Icon(Icons.more_horiz, size: 20, color: fore),
              onSelected: (value) {
                switch (value) {
                  case 'new':
                    _newChat();
                  case 'delete':
                    _deleteChat();
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'new',
                      enabled: !_busy && _messages.isNotEmpty,
                      child: const ListTile(
                        leading: Icon(Icons.add_comment_outlined),
                        title: Text('New chat'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      enabled: !_busy && _sessionId != null,
                      child: ListTile(
                        leading: Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error,
                        ),
                        title: const Text('Delete chat'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_messages.isEmpty && !_awaitingReply) {
      return _buildEmptyState(theme);
    }

    final showPending = _awaitingReply;
    final showOlderLoader = _isLoadingMore;
    final count =
        _messages.length + (showPending ? 1 : 0) + (showOlderLoader ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      // Newest at the bottom without scroll juggling; older pages append at
      // the far end so loading them never makes the view jump.
      reverse: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(16),
      itemCount: count,
      itemBuilder: (context, index) {
        if (showPending) {
          if (index == 0) return _buildPendingReply(theme);
          index--;
        }
        if (index >= _messages.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final message = _messages[_messages.length - 1 - index];
        final isLatestReply = index == 0 && !message.isUser && !showPending;
        return _MessageBubble(
          key: ValueKey(message.id),
          message: message,
          model: _model,
          onDelete: _busy ? null : () => _deleteMessage(message),
          onRegenerate: isLatestReply && !_busy && _ready ? _regenerate : null,
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final jc = theme.jColors;
    final fore = theme.colorScheme.onSurface;

    final Widget content = switch (_status) {
      _ModelStatus.loading => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox.square(
            dimension: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading ${_model.name}…',
            textAlign: TextAlign.center,
            style: JemenaiTheme.fontBody(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: fore,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Larger models can take a few seconds.',
            style: JemenaiTheme.fontBody(
              fontSize: 12,
              color: jc.mutedForeground,
            ),
          ),
        ],
      ),
      _ModelStatus.notInstalled => _StatusCard(
        icon: Icons.cloud_download_outlined,
        title: '${_model.name} isn\'t downloaded',
        message:
            _installedModels.isEmpty
                ? 'Download a model from the store to start chatting.'
                : 'Download it from the store, or pick another model above.',
        actionLabel: 'Open Model Store',
        onAction: () => AppRouter.openDashboardTab(AppRouter.modelsTab),
      ),
      _ModelStatus.failed => _StatusCard(
        icon: Icons.error_outline,
        title: 'Couldn\'t load ${_model.name}',
        message: _loadError ?? 'Unknown error.',
        actionLabel: 'Try again',
        onAction: _loadModel,
      ),
      _ModelStatus.ready => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ModelAvatar(model: _model, size: 56, radius: 18),
          const SizedBox(height: 16),
          Text(
            'Chat with ${_model.name}',
            textAlign: TextAlign.center,
            style: JemenaiTheme.fontDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: fore,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Runs entirely on this device. Nothing you type leaves your phone.',
            textAlign: TextAlign.center,
            style: JemenaiTheme.fontBody(
              fontSize: 12.5,
              color: jc.mutedForeground,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final prompt in _starterPrompts())
                ActionChip(
                  label: Text(prompt),
                  labelStyle: JemenaiTheme.fontBody(fontSize: 12, color: fore),
                  backgroundColor: jc.card,
                  side: BorderSide(color: jc.border),
                  shape: const StadiumBorder(),
                  onPressed: () => _send(prompt),
                ),
            ],
          ),
        ],
      ),
    };

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: content,
      ),
    );
  }

  List<String> _starterPrompts() {
    if (_model.category == 'Coding') {
      return const [
        'Explain recursion with an example',
        'Write a Python function to dedupe a list',
      ];
    }
    return const [
      'Explain quantum computing simply',
      'Give me 3 ideas for a weekend project',
      'Write a short, friendly email',
    ];
  }

  Widget _buildPendingReply(ThemeData theme) {
    final jc = theme.jColors;
    final hasText = _streamText.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 4),
            child: ModelAvatar(model: _model, size: 28, circle: true),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: jc.secondaryFill,
                borderRadius: BorderRadius.circular(
                  20,
                ).copyWith(bottomLeft: const Radius.circular(4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_streamThinking.isNotEmpty)
                    _ThinkingPanel(text: _streamThinking, live: !hasText),
                  if (hasText)
                    MarkdownText(content: _streamText)
                  else if (_streamThinking.isEmpty)
                    const SizedBox(
                      width: 36,
                      height: 12,
                      child: TypingBouncingDots(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelsPicker(ThemeData theme) {
    final jc = theme.jColors;
    final installed = _installedModels;
    final fore = theme.colorScheme.onSurface;

    return Positioned(
      top: 4,
      left: 16,
      right: 16,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: jc.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: jc.border),
          boxShadow: JemenaiTheme.shadowFloat(
            theme.brightness == Brightness.dark,
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.45,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 6),
            children: [
              for (final m in installed)
                ListTile(
                  onTap: () => _switchModel(m),
                  leading: ModelAvatar(model: m, size: 32),
                  title: Text(
                    m.name,
                    style: JemenaiTheme.fontBody(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: fore,
                    ),
                  ),
                  subtitle: Text(
                    '${m.specialty} · ${m.size}',
                    style: JemenaiTheme.fontBody(
                      fontSize: 10.5,
                      color: jc.mutedForeground,
                    ),
                  ),
                  trailing:
                      m.id == _model.id
                          ? Icon(
                            Icons.check_circle,
                            size: 18,
                            color: theme.colorScheme.primary,
                          )
                          : null,
                ),
              if (installed.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No models downloaded yet.',
                    style: JemenaiTheme.fontBody(
                      fontSize: 13,
                      color: jc.mutedForeground,
                    ),
                  ),
                ),
              Divider(height: 1, color: jc.border),
              ListTile(
                onTap: () => AppRouter.openDashboardTab(AppRouter.modelsTab),
                leading: Icon(
                  Icons.cloud_download_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  'Get more models',
                  style: JemenaiTheme.fontBody(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    final jc = theme.jColors;
    final muted = jc.mutedForeground;
    final fore = theme.colorScheme.onSurface;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final extraPadding =
        ((widget.args?.isTab ?? false) && !keyboardOpen) ? 80.0 : 0.0;
    final canAttach = _ready && !_busy;
    final canRecord = _ready && !_awaitingReply && !_isTranscribing;

    final hint = switch (_status) {
      _ when _isRecording => 'Listening… tap stop when done',
      _ when _isTranscribing => 'Transcribing…',
      _ModelStatus.loading => 'Loading model…',
      _ModelStatus.ready => 'Message ${_model.name}…',
      _ => 'Model unavailable',
    };

    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + extraPadding),
      decoration: BoxDecoration(
        color: jc.card,
        border: Border(top: BorderSide(color: jc.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_attachedImage != null) _buildAttachmentPreview(),
            if (_model.canThink && _ready) _buildThinkingToggle(theme),
            Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color:
                      _isRecording
                          ? Colors.red.withValues(alpha: 0.6)
                          : jc.border,
                ),
              ),
              padding: const EdgeInsets.all(6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_model.supportsImage) ...[
                    _InputIconButton(
                      icon: _showAttachments ? Icons.close : Icons.add,
                      tooltip: _showAttachments ? 'Close' : 'Attach image',
                      color: muted,
                      onTap:
                          canAttach
                              ? () => setState(
                                () => _showAttachments = !_showAttachments,
                              )
                              : null,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            _showAttachments
                                ? [
                                  _InputIconButton(
                                    icon: Icons.photo_outlined,
                                    tooltip: 'Photo library',
                                    color: muted,
                                    onTap:
                                        () => _pickImage(ImageSource.gallery),
                                  ),
                                  _InputIconButton(
                                    icon: Icons.camera_alt_outlined,
                                    tooltip: 'Camera',
                                    color: muted,
                                    onTap: () => _pickImage(ImageSource.camera),
                                  ),
                                ]
                                : const [],
                      ),
                    ),
                  ] else
                    const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      focusNode: _inputFocus,
                      readOnly: _isRecording || _isTranscribing,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      style: JemenaiTheme.fontBody(fontSize: 14, color: fore),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: JemenaiTheme.fontBody(
                          fontSize: 14,
                          color: muted,
                        ),
                        filled: false,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_model.supportsAudio)
                    _InputIconButton(
                      icon: _isRecording ? Icons.stop_rounded : Icons.mic_none,
                      tooltip: _isRecording ? 'Stop recording' : 'Dictate',
                      color: _isRecording ? Colors.red : muted,
                      busy: _isTranscribing,
                      onTap: canRecord ? _toggleRecording : null,
                    ),
                  const SizedBox(width: 4),
                  _buildSendButton(theme),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'On-device · Private · No internet required',
              style: JemenaiTheme.fontBody(
                fontSize: 10,
                color: muted.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(ThemeData theme) {
    final jc = theme.jColors;
    if (_awaitingReply) {
      return Tooltip(
        message: 'Stop generating',
        child: InkWell(
          onTap: _stop,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              Icons.stop_rounded,
              size: 18,
              color: theme.scaffoldBackgroundColor,
            ),
          ),
        ),
      );
    }

    final enabled = _canSend;
    return Tooltip(
      message: 'Send',
      child: InkWell(
        onTap: enabled ? () => _send() : null,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: enabled ? JemenaiTheme.gradBrand : null,
            color: enabled ? null : jc.secondaryFill,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Icon(
            Icons.arrow_upward,
            size: 18,
            color: enabled ? Colors.white : jc.mutedForeground,
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentPreview() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                _attachedImage!,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: -8,
              top: -8,
              child: Semantics(
                button: true,
                label: 'Remove image',
                child: GestureDetector(
                  onTap: () => setState(() => _attachedImage = null),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThinkingToggle(ThemeData theme) {
    final jc = theme.jColors;
    final primary = theme.colorScheme.primary;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: FilterChip(
          selected: _thinking,
          onSelected: _busy ? null : (_) => _toggleThinking(),
          showCheckmark: false,
          avatar: Icon(
            Icons.psychology_alt,
            size: 16,
            color: _thinking ? primary : jc.mutedForeground,
          ),
          label: Text(
            'Reasoning',
            style: JemenaiTheme.fontBody(
              fontSize: 12,
              fontWeight: _thinking ? FontWeight.bold : FontWeight.normal,
              color: _thinking ? primary : jc.mutedForeground,
            ),
          ),
          tooltip: 'Think step by step before answering (slower)',
          backgroundColor: jc.card,
          selectedColor: primary.withValues(alpha: 0.15),
          side: BorderSide(
            color: _thinking ? primary.withValues(alpha: 0.5) : jc.border,
          ),
          shape: const StadiumBorder(),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

/// A short, single-line session title derived from the first message.
String chatTitleFor(String text) {
  final oneLine = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (oneLine.isEmpty) return 'Image';
  if (oneLine.length <= 40) return oneLine;
  final cut = oneLine.substring(0, 40);
  final space = cut.lastIndexOf(' ');
  return '${space > 20 ? cut.substring(0, space) : cut}…';
}

/// Asks for microphone access, sending the user to Settings if they
/// previously chose "Don't allow". Returns whether recording may start.
Future<bool> ensureMicrophonePermission() async {
  if (kIsWeb || !(io.Platform.isAndroid || io.Platform.isIOS)) return true;
  final status = await Permission.microphone.request();
  if (status.isGranted) return true;
  if (status.isPermanentlyDenied) {
    AppRouter.showMessage('Enable microphone access in Settings to record.');
    await openAppSettings();
  } else {
    AppRouter.showMessage('Microphone access is needed to record audio.');
  }
  return false;
}

/// Stops [recorder] and returns the WAV bytes, deleting the temp file.
Future<Uint8List?> stopRecordingAndRead(AudioRecorder recorder) async {
  try {
    final path = await recorder.stop();
    if (path == null) return null;
    final file = io.File(path);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    await file.delete();
    return bytes;
  } catch (e) {
    debugPrint('Failed to stop recording: $e');
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pieces
// ─────────────────────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 40, color: theme.colorScheme.primary),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: JemenaiTheme.fontDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: JemenaiTheme.fontBody(
            fontSize: 12.5,
            color: theme.jColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    super.key,
    required this.message,
    required this.model,
    this.onDelete,
    this.onRegenerate,
  });

  final ChatMessage message;
  final AIModel model;
  final VoidCallback? onDelete;
  final VoidCallback? onRegenerate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isUser = message.isUser;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.78;
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(message.ts),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser ? theme.colorScheme.primary : jc.secondaryFill,
        borderRadius: BorderRadius.circular(20).copyWith(
          bottomLeft: Radius.circular(isUser ? 20 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.imageBytes != null)
            Padding(
              padding: EdgeInsets.only(bottom: message.content.isEmpty ? 0 : 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  message.imageBytes!,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (message.thinking != null)
            _ThinkingPanel(text: message.thinking!, live: false),
          if (message.content.isNotEmpty)
            isUser
                ? Text(
                  message.content,
                  style: JemenaiTheme.fontBody(
                    fontSize: 14,
                    color: Colors.white,
                    lineHeight: 1.45,
                  ),
                )
                : MarkdownText(content: message.content),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 4),
                  child: ModelAvatar(model: model, size: 28, circle: true),
                ),
              Flexible(child: SelectionArea(child: bubble)),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 2,
              left: isUser ? 0 : 36,
              right: isUser ? 4 : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: JemenaiTheme.fontBody(
                    fontSize: 10,
                    color: jc.mutedForeground,
                  ),
                ),
                const SizedBox(width: 4),
                if (message.content.isNotEmpty)
                  _BubbleAction(
                    icon: Icons.content_copy,
                    tooltip: 'Copy',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: message.content));
                      AppRouter.showMessage('Copied to clipboard');
                    },
                  ),
                if (onRegenerate != null)
                  _BubbleAction(
                    icon: Icons.refresh,
                    tooltip: 'Regenerate',
                    onTap: onRegenerate!,
                  ),
                if (onDelete != null)
                  _BubbleAction(
                    icon: Icons.delete_outline,
                    tooltip: 'Delete message',
                    onTap: onDelete!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleAction extends StatelessWidget {
  const _BubbleAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      iconSize: 14,
      color: Theme.of(context).jColors.mutedForeground,
      icon: Icon(icon),
    );
  }
}

/// Collapsible reasoning trace shown above a reply.
class _ThinkingPanel extends StatefulWidget {
  const _ThinkingPanel({required this.text, required this.live});

  final String text;

  /// True while the model is still reasoning (auto-expanded).
  final bool live;

  @override
  State<_ThinkingPanel> createState() => _ThinkingPanelState();
}

class _ThinkingPanelState extends State<_ThinkingPanel> {
  bool? _expanded;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).jColors.mutedForeground;
    final expanded = _expanded ?? widget.live;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !expanded),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.psychology_alt, size: 14, color: muted),
                const SizedBox(width: 4),
                Text(
                  widget.live ? 'Reasoning…' : 'Reasoning',
                  style: JemenaiTheme.fontBody(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: muted,
                  ),
                ),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: muted,
                ),
              ],
            ),
          ),
          if (expanded)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: muted.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                widget.text,
                style: JemenaiTheme.fontBody(
                  fontSize: 12,
                  color: muted,
                  lineHeight: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InputIconButton extends StatelessWidget {
  const _InputIconButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    this.onTap,
    this.busy = false,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: SizedBox(
          width: 34,
          height: 34,
          child:
              busy
                  ? const Padding(
                    padding: EdgeInsets.all(9),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Icon(
                    icon,
                    size: 19,
                    color: onTap == null ? color.withValues(alpha: 0.4) : color,
                  ),
        ),
      ),
    );
  }
}

/// Three dots bouncing in sequence while waiting for the first token.
class TypingBouncingDots extends StatefulWidget {
  const TypingBouncingDots({super.key});

  @override
  State<TypingBouncingDots> createState() => _TypingBouncingDotsState();
}

class _TypingBouncingDotsState extends State<TypingBouncingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Semantics(
      label: 'Thinking',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) {
              // Same bounce per dot, offset in phase.
              final t = (_controller.value - i * 0.16) % 1.0;
              final lift = Curves.easeInOut.transform(
                t < 0.5 ? t * 2 : 2 - t * 2,
              );
              return Transform.translate(
                offset: Offset(0, -5 * lift),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
