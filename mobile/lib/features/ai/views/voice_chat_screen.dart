import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:jemenai/features/ai/model/ai_model.dart';
import 'package:jemenai/features/ai/model/chat_message.dart';
import 'package:jemenai/features/ai/view_models/model_download_cubit.dart';
import 'package:jemenai/features/ai/views/chat_screen.dart';
import 'package:jemenai/features/dashboard/view_models/app_cubit.dart';
import 'package:jemenai/services/chat_engine.dart';
import 'package:jemenai/services/db_service.dart';
import 'package:jemenai/shared/navigator/app_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/theme.dart';

enum VoiceState { loading, noModel, idle, listening, thinking, speaking }

/// Hands-free conversation: speak, the on-device model transcribes and
/// answers, and the reply is read aloud with the system's offline voice.
/// Each session is saved as a regular chat so it shows up in history.
class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key, this.modelName});

  /// Preferred model; falls back to any downloaded audio-capable model.
  final String? modelName;

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen>
    with TickerProviderStateMixin {
  static const _uuid = Uuid();
  static const _voiceInstruction =
      'You are OffRoad, a friendly voice assistant running privately on the '
      'user\'s phone. Answer in one to three short, natural spoken sentences. '
      'Never use markdown, bullet points, code blocks or emojis.';

  VoiceState _state = VoiceState.loading;
  AIModel? _model;
  ChatEngine? _engine;
  String? _sessionId;

  final List<ChatMessage> _history = [];
  String _transcript = '';
  String _reply = '';
  bool _muted = false;

  final _recorder = AudioRecorder();
  StreamSubscription<Amplitude>? _amplitudeSub;
  final _level = ValueNotifier<double>(0);

  final _tts = FlutterTts();
  final List<String> _speechQueue = [];
  bool _ttsBusy = false;
  bool _generating = false;

  /// Bumped on interrupt so in-flight work from the old turn bails out.
  int _turn = 0;

  late final AnimationController _orbController;
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _setUpTts();
    _start();
  }

  @override
  void dispose() {
    _amplitudeSub?.cancel();
    _recorder.dispose();
    _stopTts();
    _engine?.dispose();
    _level.dispose();
    _orbController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  // ── Setup ────────────────────────────────────────────────────────────────

  Future<void> _setUpTts() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await _tts.setSharedInstance(true);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playAndRecord,
          [
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }
      await _tts.setSpeechRate(0.5);
      _tts.setCompletionHandler(_onUtteranceDone);
      _tts.setCancelHandler(_onUtteranceDone);
      _tts.setErrorHandler((_) => _onUtteranceDone());
    } catch (e) {
      debugPrint('TTS setup failed: $e');
    }
  }

  Future<void> _start() async {
    final cubit = context.read<ModelDownloadCubit>();
    final audioModels =
        models
            .where((m) => m.supportsAudio)
            .where(
              (m) => cubit.statusFor(m.id).phase == DownloadPhase.installed,
            )
            .toList();
    final model =
        audioModels.where((m) => m.name == widget.modelName).firstOrNull ??
        audioModels.firstOrNull;

    if (model == null) {
      setState(() => _state = VoiceState.noModel);
      return;
    }

    setState(() {
      _model = model;
      _state = VoiceState.loading;
    });

    final engine = ChatEngine(model, systemInstruction: _voiceInstruction);
    final backend =
        context.read<AppCubit>().inferenceEngine == 'gpu'
            ? PreferredBackend.gpu
            : PreferredBackend.cpu;
    try {
      await engine.load(backend: backend);
      if (!mounted) {
        await engine.dispose();
        return;
      }
      setState(() {
        _engine = engine;
        _state = VoiceState.idle;
      });
    } catch (e) {
      await engine.dispose();
      if (!mounted) return;
      AppRouter.showMessage(ChatEngine.describeError(e));
      setState(() => _state = VoiceState.noModel);
    }
  }

  // ── Conversation loop ────────────────────────────────────────────────────

  Future<void> _onOrbTap() async {
    switch (_state) {
      case VoiceState.idle:
        await _startListening();
      case VoiceState.listening:
        await _stopListening();
      case VoiceState.thinking:
      case VoiceState.speaking:
        await _interrupt();
      case VoiceState.loading:
      case VoiceState.noModel:
        break;
    }
  }

  Future<void> _startListening() async {
    if (!await ensureMicrophonePermission()) return;
    try {
      final dir = await getTemporaryDirectory();
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.wav',
      );
      _amplitudeSub = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 80))
          .listen((a) {
            // dBFS → 0..1, treating -50 dB as silence.
            _level.value = ((a.current + 50) / 50).clamp(0.0, 1.0);
          });
      HapticFeedback.mediumImpact();
      setState(() {
        _state = VoiceState.listening;
        _transcript = '';
        _reply = '';
      });
    } catch (e) {
      AppRouter.showMessage('Couldn\'t start recording: $e');
    }
  }

  Future<void> _stopListening() async {
    final turn = _turn;
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;
    _level.value = 0;
    HapticFeedback.lightImpact();
    setState(() => _state = VoiceState.thinking);

    final wav = await stopRecordingAndRead(_recorder);
    final engine = _engine;
    if (wav == null || engine == null || !mounted) {
      setState(() => _state = VoiceState.idle);
      return;
    }

    try {
      final heard = await engine.transcribe(wav, _history);
      if (!mounted || turn != _turn) return;
      if (heard.isEmpty) {
        AppRouter.showMessage('Didn\'t catch that. Tap and try again.');
        setState(() => _state = VoiceState.idle);
        return;
      }
      setState(() => _transcript = heard);
      await _answer(engine, heard);
    } catch (e) {
      if (!mounted) return;
      AppRouter.showMessage(ChatEngine.describeError(e));
      setState(() => _state = VoiceState.idle);
    }
  }

  Future<void> _answer(ChatEngine engine, String question) async {
    final prompt = ChatMessage(
      id: _uuid.v4(),
      role: 'user',
      content: question,
      ts: DateTime.now(),
    );
    _history.add(prompt);
    await _save(prompt);

    final reply = StringBuffer();
    var spokenUpTo = 0;
    _generating = true;
    try {
      await for (final response in engine.send(prompt)) {
        if (!mounted || !_generating) break;
        if (response is! TextResponse) continue;
        reply.write(response.token);
        final text = ChatEngine.normalizeReply(reply.toString());
        setState(() => _reply = text);

        // Speak finished sentences while the rest is still generating.
        final boundary = _lastSentenceEnd(text, spokenUpTo);
        if (boundary > spokenUpTo) {
          _enqueueSpeech(text.substring(spokenUpTo, boundary));
          spokenUpTo = boundary;
        }
      }
    } catch (e) {
      AppRouter.showMessage(ChatEngine.describeError(e));
    }
    final wasInterrupted = !_generating;
    _generating = false;
    if (!mounted) return;

    final text = ChatEngine.normalizeReply(reply.toString()).trim();
    if (!wasInterrupted && spokenUpTo < text.length) {
      _enqueueSpeech(text.substring(spokenUpTo));
    }
    if (text.isNotEmpty) {
      final answer = ChatMessage(
        id: _uuid.v4(),
        role: 'assistant',
        content: text,
        ts: DateTime.now(),
      );
      _history.add(answer);
      await _save(answer);
    }
    if (mounted) _settle();
  }

  Future<void> _interrupt() async {
    _turn++;
    _generating = false;
    _speechQueue.clear();
    await _engine?.stop();
    await _stopTts();
    _ttsBusy = false;
    if (mounted) setState(() => _state = VoiceState.idle);
  }

  // ── Speech output ────────────────────────────────────────────────────────

  Future<void> _stopTts() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('TTS stop failed: $e');
    }
  }

  static final _sentenceEnd = RegExp(r'[.!?…](?=\s)|\n');

  /// Index just past the last complete sentence after [from], or [from].
  int _lastSentenceEnd(String text, int from) {
    var end = from;
    for (final m in _sentenceEnd.allMatches(text, from)) {
      end = m.end;
    }
    return end;
  }

  void _enqueueSpeech(String text) {
    final clean = _speakable(text);
    if (clean.isEmpty || _muted) {
      _settle();
      return;
    }
    _speechQueue.add(clean);
    if (_state != VoiceState.speaking) {
      setState(() => _state = VoiceState.speaking);
    }
    _pumpSpeech();
  }

  Future<void> _pumpSpeech() async {
    if (_ttsBusy || _speechQueue.isEmpty) return;
    _ttsBusy = true;
    final next = _speechQueue.removeAt(0);
    try {
      await _tts.speak(next);
    } catch (e) {
      debugPrint('TTS failed: $e');
      _onUtteranceDone();
    }
  }

  void _onUtteranceDone() {
    _ttsBusy = false;
    if (!mounted) return;
    if (_speechQueue.isNotEmpty) {
      _pumpSpeech();
    } else {
      _settle();
    }
  }

  /// Returns to idle once nothing is generating or waiting to be spoken.
  void _settle() {
    if (!mounted || _generating || _ttsBusy || _speechQueue.isNotEmpty) return;
    if (_state == VoiceState.thinking || _state == VoiceState.speaking) {
      setState(() => _state = VoiceState.idle);
    }
  }

  /// Strips markdown the model may still emit so it isn't read aloud.
  static String _speakable(String text) {
    return text
        .replaceAll(RegExp(r'```[\s\S]*?```'), ' ')
        .replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m.group(1)!)
        .replaceAll(RegExp(r'[*_`#>|]'), '')
        .replaceAll(RegExp(r'^\s*[-•]\s+', multiLine: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    if (_muted) {
      _speechQueue.clear();
      _stopTts();
      _ttsBusy = false;
      _settle();
    }
  }

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<void> _save(ChatMessage message) async {
    try {
      final db = DatabaseService();
      if (_sessionId == null) {
        _sessionId = _uuid.v4();
        await db.createSession(
          id: _sessionId!,
          title: chatTitleFor(message.content),
          modelName: _model!.name,
        );
      }
      await db.addMessage(
        id: message.id,
        sessionId: _sessionId!,
        role: message.role,
        content: message.content,
      );
    } catch (e) {
      debugPrint('Failed to save voice message: $e');
    }
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  String get _stateLabel => switch (_state) {
    VoiceState.loading => 'Loading ${_model?.name ?? 'model'}…',
    VoiceState.noModel => 'Voice needs an audio-capable model',
    VoiceState.idle => 'Tap to speak',
    VoiceState.listening => 'Listening… tap when you\'re done',
    VoiceState.thinking => 'Thinking… tap to cancel',
    VoiceState.speaking => 'Speaking… tap to stop',
  };

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF09090B),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF07071A), Color(0xFF0D0D24), Color(0xFF09090B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              _buildAmbientOrbs(),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    Expanded(
                      child:
                          _state == VoiceState.noModel
                              ? _buildNoModel()
                              : _buildConversation(),
                    ),
                    if (_history.length > 2) _buildHistoryPanel(),
                    _buildEndButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversation() {
    final active =
        _state == VoiceState.listening || _state == VoiceState.speaking;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Semantics(
            button: true,
            label: _stateLabel,
            child: GestureDetector(
              onTap: _onOrbTap,
              child: AIOrbWidget(state: _state, orbController: _orbController),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _stateLabel,
            textAlign: TextAlign.center,
            style: JemenaiTheme.fontBody(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 40,
            width: 200,
            child: AudioWaveformWidget(
              active: active,
              level: _state == VoiceState.listening ? _level : null,
              waveController: _waveController,
              color:
                  _state == VoiceState.listening
                      ? const Color(0xFF818CF8)
                      : const Color(0xFFA78BFA),
            ),
          ),
          const SizedBox(height: 24),
          _buildTranscriptBox(),
        ],
      ),
    );
  }

  Widget _buildNoModel() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.graphic_eq,
              size: 48,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Download a voice-capable model',
              textAlign: TextAlign.center,
              style: JemenaiTheme.fontDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Voice mode listens with models that understand audio, '
              'such as Gemma 4 E2B. Everything stays on your device.',
              textAlign: TextAlign.center,
              style: JemenaiTheme.fontBody(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.6),
                lineHeight: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => AppRouter.openDashboardTab(AppRouter.modelsTab),
              child: const Text('Open Model Store'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientOrbs() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C3AED).withValues(alpha: 0.10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final buttonStyle = IconButton.styleFrom(
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(10),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => AppRouter.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            style: buttonStyle,
          ),
          Flexible(
            child: Column(
              children: [
                Text(
                  'VOICE MODE',
                  style: JemenaiTheme.fontBody(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.5),
                    lineHeight: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _model?.name ?? 'No model',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: JemenaiTheme.fontDisplay(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: _muted ? 'Unmute voice replies' : 'Mute voice replies',
            onPressed: _toggleMute,
            icon: Icon(
              _muted ? Icons.volume_off : Icons.volume_up,
              color: _muted ? const Color(0xFFF87171) : Colors.white,
            ),
            style: buttonStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptBox() {
    Widget bubble(String label, String text, {required bool ai}) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              ai
                  ? const Color(0xFF312E81).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                ai
                    ? const Color(0xFF818CF8).withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color:
                    ai
                        ? const Color(0xFFA5B4FC)
                        : Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: JemenaiTheme.fontBody(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
                lineHeight: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        child: Column(
          children: [
            if (_transcript.isNotEmpty) bubble('YOU', _transcript, ai: false),
            if (_reply.isNotEmpty) bubble('OFFROAD', _reply, ai: true),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryPanel() {
    // The latest exchange is already shown above; list the earlier ones.
    final earlier = _history.sublist(0, _history.length - 2);
    return Container(
      constraints: const BoxConstraints(maxHeight: 120),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            'EARLIER',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.3),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.builder(
              reverse: true,
              shrinkWrap: true,
              itemCount: earlier.length,
              itemBuilder: (context, index) {
                final item = earlier[earlier.length - 1 - index];
                return Align(
                  alignment:
                      item.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          item.isUser
                              ? Colors.white.withValues(alpha: 0.06)
                              : const Color(0xFF312E81).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: JemenaiTheme.fontBody(
                        fontSize: 11,
                        color:
                            item.isUser
                                ? Colors.white.withValues(alpha: 0.7)
                                : const Color(0xFFA5B4FC),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: InkWell(
        onTap: () => AppRouter.pop(),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          alignment: Alignment.center,
          child: Text(
            'End Session',
            style: JemenaiTheme.fontBody(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

/// The glowing orb at the centre of voice mode.
class AIOrbWidget extends StatelessWidget {
  final VoiceState state;
  final AnimationController orbController;

  const AIOrbWidget({
    super.key,
    required this.state,
    required this.orbController,
  });

  bool get _active =>
      state == VoiceState.listening ||
      state == VoiceState.thinking ||
      state == VoiceState.speaking;

  @override
  Widget build(BuildContext context) {
    final active = _active;
    final dim = state == VoiceState.loading;

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (active)
            ...List.generate(16, (index) {
              return OrbitalParticle(
                angle: index * (360 / 16),
                orbController: orbController,
              );
            }),
          AnimatedScale(
            scale: active ? 1.14 : 1.0,
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: active ? 0.35 : 0.0,
              duration: const Duration(seconds: 1),
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xFF818CF8), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          AnimatedScale(
            scale: active ? 1.06 : 1.0,
            duration: const Duration(seconds: 1),
            child: AnimatedOpacity(
              opacity: active ? 0.25 : 0.05,
              duration: const Duration(seconds: 1),
              child: Container(
                width: 176,
                height: 176,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xFF7C3AED), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: dim ? 0.5 : 1,
            duration: const Duration(milliseconds: 300),
            child: AnimatedScale(
              scale: active ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 144,
                height: 144,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4F46E5),
                      Color(0xFF7C3AED),
                      Color(0xFFA855F7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF4F46E5,
                      ).withValues(alpha: active ? 0.6 : 0.3),
                      blurRadius: active ? 40 : 25,
                      spreadRadius: active ? 6 : 2,
                    ),
                    BoxShadow(
                      color: const Color(
                        0xFF7C3AED,
                      ).withValues(alpha: active ? 0.4 : 0.15),
                      blurRadius: active ? 60 : 40,
                      spreadRadius: active ? 10 : 4,
                    ),
                  ],
                ),
                child: _buildCenterIcon(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterIcon() {
    if (state == VoiceState.thinking || state == VoiceState.loading) {
      return const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3.5,
          ),
        ),
      );
    }
    final icon = switch (state) {
      VoiceState.speaking => Icons.volume_up,
      VoiceState.listening => Icons.stop_rounded,
      VoiceState.noModel => Icons.mic_off,
      _ => Icons.mic,
    };
    return Icon(icon, color: Colors.white, size: 36);
  }
}

class OrbitalParticle extends StatelessWidget {
  final double angle;
  final AnimationController orbController;

  const OrbitalParticle({
    super.key,
    required this.angle,
    required this.orbController,
  });

  @override
  Widget build(BuildContext context) {
    final radAngle = (angle * math.pi) / 180;
    const radius = 96.0;

    return AnimatedBuilder(
      animation: orbController,
      builder: (context, child) {
        final phase = orbController.value * 2 * math.pi + (angle / 360) * 8;
        final currentRadius = radius + 8 * math.sin(phase);
        final scale = 1.0 + 0.4 * math.sin(phase);
        final opacity = 0.5 + 0.4 * math.sin(phase);

        return Transform.translate(
          offset: Offset(
            math.cos(radAngle) * currentRadius,
            math.sin(radAngle) * currentRadius,
          ),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0x99818CF8),
        ),
      ),
    );
  }
}

/// Animated bars. Driven by the live microphone [level] while listening,
/// otherwise by a synthetic wave.
class AudioWaveformWidget extends StatelessWidget {
  final bool active;
  final ValueListenable<double>? level;
  final AnimationController waveController;
  final Color color;

  const AudioWaveformWidget({
    super.key,
    required this.active,
    required this.waveController,
    required this.color,
    this.level,
  });

  @override
  Widget build(BuildContext context) {
    final listenables = <Listenable>[waveController, if (level != null) level!];
    return AnimatedBuilder(
      animation: Listenable.merge(listenables),
      builder: (context, _) {
        return Row(
          children: List.generate(28, (index) {
            var barHeight = 4.0;
            var opacity = 0.2;
            if (active) {
              final wave =
                  math
                      .sin(waveController.value * 2 * math.pi + index * 0.7)
                      .abs();
              final gain = level == null ? 1.0 : 0.15 + 0.85 * level!.value;
              barHeight = 4 + 26 * wave * gain;
              opacity = 0.4 + 0.6 * wave * gain;
            }
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Align(
                  child: Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: opacity.clamp(0.0, 1.0)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
