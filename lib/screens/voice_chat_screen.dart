import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';

class VoiceChatScreen extends StatefulWidget {
  final Function(String, [Map<String, dynamic>]) onNavigate;
  final bool isDark;

  const VoiceChatScreen({
    super.key,
    required this.onNavigate,
    required this.isDark,
  });

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> with TickerProviderStateMixin {
  String _state = "idle"; // 'idle' | 'listening' | 'thinking' | 'speaking'
  String _transcript = "";
  String _reply = "";
  bool _muted = false;
  String _mode = "continuous"; // 'continuous' | 'push'

  final List<Map<String, String>> _history = [];
  Timer? _chatTimer;
  Timer? _typeTimer;

  final List<String> _transcriptsList = [
    "Hey, what's quantum computing in simple terms?",
    "Write me a short poem about the stars.",
    "Can you explain what React hooks are?",
    "What's the best way to structure a REST API?",
  ];

  final List<String> _repliesList = [
    "Quantum computing harnesses superposition and entanglement to process information in ways classical computers fundamentally cannot. Instead of bits being zero or one, quantum bits exist in both states simultaneously — massively parallelizing computations.",
    "Here's a short poem:\n\nStarlight whispers ancient code,\nSilver data overflowed,\nGalaxies compile and run,\nEvery constellation spun.",
    "React hooks let you use state and lifecycle features in functional components. useState gives you reactive variables, useEffect runs side effects, and useCallback memoizes functions. They replaced class components almost entirely.",
    "Structure your API around resources, not actions. Use nouns for endpoints, HTTP methods for operations. Group related routes, version your API from day one, and always return consistent error shapes.",
  ];

  // Animation controllers for orb & particles
  late AnimationController _orbController;
  late AnimationController _waveController;

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
  }

  @override
  void dispose() {
    _orbController.dispose();
    _waveController.dispose();
    _chatTimer?.cancel();
    _typeTimer?.cancel();
    super.dispose();
  }

  void _speak() {
    if (_state != "idle") return;

    final randomIndex = math.Random().nextInt(_transcriptsList.length);
    final userQ = _transcriptsList[randomIndex];
    final aiA = _repliesList[randomIndex];

    setState(() {
      _state = "listening";
      _transcript = "";
      _reply = "";
    });

    // Simulate typing user question
    int pos = 0;
    _typeTimer = Timer.periodic(const Duration(milliseconds: 55), (timer) {
      pos++;
      if (pos >= userQ.length) {
        timer.cancel();
        setState(() {
          _transcript = userQ;
        });

        // Delay before transitioning to thinking
        _chatTimer = Timer(const Duration(milliseconds: 600), () {
          setState(() {
            _state = "thinking";
          });

          // Simulate AI thinking
          _chatTimer = Timer(const Duration(milliseconds: 1600), () {
            setState(() {
              _state = "speaking";
              _reply = aiA;
              _history.add({'who': 'user', 'text': userQ});
              _history.add({'who': 'ai', 'text': aiA});
            });

            // Speaking duration before going back to idle
            _chatTimer = Timer(const Duration(seconds: 5), () {
              setState(() {
                _state = "idle";
                _transcript = "";
                _reply = "";
              });
            });
          });
        });
      } else {
        setState(() {
          _transcript = userQ.substring(0, pos);
        });
      }
    });
  }

  String _getStateLabel() {
    switch (_state) {
      case 'listening':
        return 'Listening...';
      case 'thinking':
        return 'Thinking...';
      case 'speaking':
        return 'Speaking...';
      default:
        return 'Tap to speak';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // Ambient Orbs
            _buildAmbientOrbs(),

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader(),

                  // Mode Toggle
                  _buildModeToggle(),

                  // Center Orb & Waveform
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main Pulse Orb
                        GestureDetector(
                          onTap: _state == "idle" ? _speak : null,
                          child: AIOrbWidget(
                            state: _state,
                            orbController: _orbController,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // State Label
                        Text(
                          _getStateLabel(),
                          style: JemenaiTheme.fontBody(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Audio Waveform
                        SizedBox(
                          height: 40,
                          width: 200,
                          child: AudioWaveformWidget(
                            active: _state == "listening" || _state == "speaking",
                            waveController: _waveController,
                            color: _state == "listening"
                                ? const Color(0xFF818CF8)
                                : const Color(0xFFA78BFA),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Text Transcripts
                        _buildTranscriptsBox(),
                      ],
                    ),
                  ),

                  // History panel
                  if (_history.isNotEmpty) _buildHistoryPanel(),

                  // Footer End button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: InkWell(
                      onTap: () => widget.onNavigate('home', {}),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.12)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'End Session',
                          style: JemenaiTheme.fontBody(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientOrbs() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4F46E5).withOpacity(0.12),
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
              color: const Color(0xFF7C3AED).withOpacity(0.10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => widget.onNavigate('home', {}),
            icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(10),
            ),
          ),
          Column(
            children: [
              Text(
                'VOICE MODE',
                style: JemenaiTheme.fontBody(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.5),
                  lineHeight: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Llama 3.2 3B',
                style: JemenaiTheme.fontDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => setState(() => _muted = !_muted),
            icon: Icon(
              _muted ? LucideIcons.volumeX : LucideIcons.volume2,
              color: _muted ? const Color(0xFFF87171) : Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Center(
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModeTab('continuous', 'Continuous'),
            _buildModeTab('push', 'Push to Talk'),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab(String modeId, String label) {
    final active = _mode == modeId;
    return InkWell(
      onTap: () => setState(() => _mode = modeId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: JemenaiTheme.fontBody(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: active ? const Color(0xFF0F172A) : Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildTranscriptsBox() {
    return Container(
      width: 280,
      constraints: const BoxConstraints(minHeight: 80),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _transcript.isNotEmpty && _reply.isEmpty
            ? Container(
                key: const ValueKey('transcript'),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  _transcript,
                  textAlign: TextAlign.center,
                  style: JemenaiTheme.fontBody(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              )
            : _reply.isNotEmpty
                ? Container(
                    key: const ValueKey('reply'),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF312E81).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF818CF8).withOpacity(0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'JEMENAI AI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFA5B4FC),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _reply.length > 130 ? '${_reply.substring(0, 130)}...' : _reply,
                          style: JemenaiTheme.fontBody(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.88),
                            lineHeight: 1.4,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
      ),
    );
  }

  Widget _buildHistoryPanel() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 120),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Text(
            'HISTORY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.3),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                final isUser = item['who'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 2.0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.white.withOpacity(0.06)
                          : const Color(0xFF312E81).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.isDark
                            ? Colors.white.withOpacity(0.04)
                            : Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Text(
                      item['text']!.length > 60 ? '${item['text']!.substring(0, 60)}…' : item['text']!,
                      style: JemenaiTheme.fontBody(
                        fontSize: 11,
                        color: isUser ? Colors.white.withOpacity(0.7) : const Color(0xFFA5B4FC),
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
}

// Bouncing core orb component
class AIOrbWidget extends StatelessWidget {
  final String state;
  final AnimationController orbController;

  const AIOrbWidget({
    super.key,
    required this.state,
    required this.orbController,
  });

  @override
  Widget build(BuildContext context) {
    final active = state != "idle";

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Orbiting particles (16 items spaced at angles)
          if (active)
            ...List.generate(16, (index) {
              final double angle = index * (360 / 16);
              return OrbitalParticle(
                angle: angle,
                orbController: orbController,
              );
            }),

          // Outer glowing shadow (only when active)
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

          // Mid glowing ring
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

          // Core Orb Shape
          AnimatedScale(
            scale: active ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: 144,
              height: 144,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFA855F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withOpacity(active ? 0.6 : 0.3),
                    blurRadius: active ? 40 : 25,
                    spreadRadius: active ? 6 : 2,
                  ),
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(active ? 0.4 : 0.15),
                    blurRadius: active ? 60 : 40,
                    spreadRadius: active ? 10 : 4,
                  ),
                ],
              ),
              child: _buildCenterIcon(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterIcon() {
    // Show spinner inside orb during thinking state
    if (state == "thinking") {
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

    final IconData iconData;
    if (state == "speaking") {
      iconData = LucideIcons.volume2;
    } else {
      iconData = LucideIcons.mic;
    }

    return Icon(
      iconData,
      color: Colors.white,
      size: 36,
    );
  }
}

// Custom orbital particle widget
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
    final double radAngle = (angle * math.pi) / 180;
    const double radius = 96.0;

    return AnimatedBuilder(
      animation: orbController,
      builder: (context, child) {
        // Continuous scale and offset shift simulation
        final phase = orbController.value * 2 * math.pi + (angle / 360) * 8;
        final deltaRadius = 8 * math.sin(phase);
        final currentRadius = radius + deltaRadius;
        final double x = math.cos(radAngle) * currentRadius;
        final double y = math.sin(radAngle) * currentRadius;

        final scale = 1.0 + 0.4 * math.sin(phase);
        final opacity = 0.5 + 0.4 * math.sin(phase);

        return Transform.translate(
          offset: Offset(x, y),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x99818CF8),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Bouncing visualizer waveform
class AudioWaveformWidget extends StatelessWidget {
  final bool active;
  final AnimationController waveController;
  final Color color;

  const AudioWaveformWidget({
    super.key,
    required this.active,
    required this.waveController,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(28, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: AnimatedBuilder(
              animation: waveController,
              builder: (context, child) {
                double barHeight = 4.0;
                double opacity = 0.2;

                if (active) {
                  // Simulate wave animation depending on time and column index
                  final phase = waveController.value * 2 * math.pi + (index * 0.7);
                  barHeight = 12 + 18 * math.sin(phase).abs();
                  opacity = 0.5 + 0.5 * math.sin(phase).abs();
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 60),
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: color.withOpacity(opacity.clamp(0.0, 1.0)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
