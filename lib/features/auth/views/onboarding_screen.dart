import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../shared/theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isDark;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
    required this.isDark,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _idx = 0;
  String _phase = 'slides'; // 'slides' or 'auth'

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': LucideIcons.shield,
      'label': 'Privacy First',
      'title': 'Your AI.\nYour Device.\nYour Data.',
      'sub':
          'Conversations never leave your phone. No cloud, no surveillance, no compromise.',
      'colors': [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
      'accent': const Color(0xFF818CF8),
    },
    {
      'icon': LucideIcons.wifiOff,
      'label': 'Offline Ready',
      'title': 'Works Without\nInternet.\nAlways.',
      'sub':
          'Download models once. Run them forever — on a plane, in a tunnel, off the grid.',
      'colors': [const Color(0xFF0891B2), const Color(0xFF0E7490)],
      'accent': const Color(0xFF38BDF8),
    },
    {
      'icon': LucideIcons.zap,
      'label': 'Instant Speed',
      'title': 'On-Device\nMeans Zero\nLatency.',
      'sub':
          'No round-trips to servers. Responses begin in milliseconds, not seconds.',
      'colors': [const Color(0xFF7C3AED), const Color(0xFFA855F7)],
      'accent': const Color(0xFFC084FC),
    },
    {
      'icon': LucideIcons.cpu,
      'label': 'Powerful Models',
      'title': 'State-of-Art AI\nFits in Your\nPocket.',
      'sub':
          "Llama, Mistral, Phi, Gemma — the world's best open models, running locally.",
      'colors': [const Color(0xFF059669), const Color(0xFF0D9488)],
      'accent': const Color(0xFF34D399),
    },
  ];

  void _next() {
    if (_idx < _slides.length - 1) {
      setState(() {
        _idx++;
      });
    } else {
      setState(() {
        _phase = 'auth';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == 'auth') {
      return AuthScreen(onComplete: widget.onComplete, isDark: widget.isDark);
    }

    final slide = _slides[_idx];
    final List<Color> colors = slide['colors'] as List<Color>;
    final accent = slide['accent'] as Color;

    return Stack(
      children: [
        // Background Orbs
        _buildBgOrbs(colors),

        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar (Skip Button)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _phase = 'auth';
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            widget.isDark
                                ? Colors.white.withOpacity(0.06)
                                : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Skip',
                        style: JemenaiTheme.fontBody(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: JemenaiTheme.mutedForeground(widget.isDark),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label Badge
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          key: ValueKey<int>(_idx),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors[0].withOpacity(0.12),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            slide['label'] as String,
                            style: JemenaiTheme.fontBody(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: accent,
                              lineHeight: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Animated Icon Block
                      Center(
                        child: SlideIconPulse(
                          icon: slide['icon'] as IconData,
                          gradientColors: colors,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Title
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: Text(
                          slide['title'] as String,
                          key: ValueKey<int>(_idx),
                          style: JemenaiTheme.fontDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: JemenaiTheme.foreground(widget.isDark),
                            lineHeight: 1.15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subtitle
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: Text(
                          slide['sub'] as String,
                          key: ValueKey<int>(_idx),
                          style: JemenaiTheme.fontBody(
                            fontSize: 14,
                            color: JemenaiTheme.mutedForeground(widget.isDark),
                            lineHeight: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom control bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 32.0,
                ),
                child: Column(
                  children: [
                    // Slide Indicators
                    Row(
                      children: List.generate(_slides.length, (index) {
                        final isActive = index == _idx;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: isActive ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color:
                                isActive
                                    ? accent
                                    : JemenaiTheme.mutedForeground(
                                      widget.isDark,
                                    ).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Navigation Action button
                    InkWell(
                      onTap: _next,
                      borderRadius: BorderRadius.circular(50),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: colors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: colors[0].withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _idx < _slides.length - 1
                                  ? 'Continue'
                                  : 'Get Started',
                              style: JemenaiTheme.fontBody(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              LucideIcons.arrowRight,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBgOrbs(List<Color> colors) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [colors[0].withOpacity(0.25), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [colors[1].withOpacity(0.18), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Stateful slide icon pulse component
class SlideIconPulse extends StatefulWidget {
  final IconData icon;
  final List<Color> gradientColors;

  const SlideIconPulse({
    super.key,
    required this.icon,
    required this.gradientColors,
  });

  @override
  State<SlideIconPulse> createState() => _SlideIconPulseState();
}

class _SlideIconPulseState extends State<SlideIconPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.16).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 0.75),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.75, end: 0.3),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse Shadow Outer
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      gradient: LinearGradient(
                        colors: [
                          widget.gradientColors[0].withOpacity(0.2),
                          widget.gradientColors[1].withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Core Icon Box
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: widget.gradientColors[0].withOpacity(0.4),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(widget.icon, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }
}

// Authentication Screen Widget
class AuthScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isDark;

  const AuthScreen({super.key, required this.onComplete, required this.isDark});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String _mode = 'in'; // 'in' (Sign In) or 'up' (Create Account)
  bool _showPass = false;
  bool _loading = false;
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  void _submit() {
    setState(() {
      _loading = true;
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        widget.onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = JemenaiTheme.card(widget.isDark);
    final inputBg = JemenaiTheme.muted(widget.isDark);
    final foreground = JemenaiTheme.foreground(widget.isDark);
    final mutedFore = JemenaiTheme.mutedForeground(widget.isDark);

    return Scaffold(
      backgroundColor: JemenaiTheme.background(widget.isDark),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 72),

              // Sparkles App Logo
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: JemenaiTheme.gradBrand,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: JemenaiTheme.glowMd(widget.isDark),
                  ),
                  child: const Icon(
                    LucideIcons.sparkles,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Jemenai AI',
                textAlign: TextAlign.center,
                style: JemenaiTheme.fontDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PRIVATE AI · ANYWHERE · ANYTIME',
                textAlign: TextAlign.center,
                style: JemenaiTheme.fontBody(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: mutedFore,
                  lineHeight: 1.0,
                ),
              ),
              const SizedBox(height: 36),

              // Custom Switch Toggle (Sign in / Create Account)
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: JemenaiTheme.secondary(widget.isDark),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _mode = 'in'),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _mode == 'in' ? cardBg : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow:
                                _mode == 'in'
                                    ? JemenaiTheme.shadowCard(widget.isDark)
                                    : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Sign In',
                            style: JemenaiTheme.fontBody(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _mode == 'in' ? foreground : mutedFore,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _mode = 'up'),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _mode == 'up' ? cardBg : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow:
                                _mode == 'up'
                                    ? JemenaiTheme.shadowCard(widget.isDark)
                                    : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Create Account',
                            style: JemenaiTheme.fontBody(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _mode == 'up' ? foreground : mutedFore,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Social logins
              Row(
                children: [
                  Expanded(
                    child: _buildSocialBtn(
                      label: 'Google',
                      icon: Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                        width: 16,
                        height: 16,
                        //errorBuilder: (context, error, stackTrace) =>  Icon(LucideIcons.chrome, size: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSocialBtn(
                      label: 'Apple',
                      icon: Icon(Icons.apple, size: 18, color: foreground),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(color: JemenaiTheme.border(widget.isDark)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'or continue with email',
                      style: JemenaiTheme.fontBody(
                        fontSize: 11,
                        color: mutedFore,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: JemenaiTheme.border(widget.isDark)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Email Input
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: JemenaiTheme.fontBody(fontSize: 14, color: foreground),
                decoration: InputDecoration(
                  hintText: 'Email address',
                  hintStyle: JemenaiTheme.fontBody(
                    fontSize: 14,
                    color: mutedFore,
                  ),
                  filled: true,
                  fillColor: inputBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: JemenaiTheme.primary(
                        widget.isDark,
                      ).withOpacity(0.25),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Password Input
              TextField(
                controller: _passController,
                obscureText: !_showPass,
                style: JemenaiTheme.fontBody(fontSize: 14, color: foreground),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: JemenaiTheme.fontBody(
                    fontSize: 14,
                    color: mutedFore,
                  ),
                  filled: true,
                  fillColor: inputBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _showPass = !_showPass),
                    icon: Icon(
                      _showPass ? LucideIcons.eyeOff : LucideIcons.eye,
                      size: 18,
                      color: mutedFore,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: JemenaiTheme.primary(
                        widget.isDark,
                      ).withOpacity(0.25),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Action
              InkWell(
                onTap: _loading ? null : _submit,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: JemenaiTheme.gradBrand,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow:
                        _loading ? [] : JemenaiTheme.glowSm(widget.isDark),
                  ),
                  alignment: Alignment.center,
                  child:
                      _loading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _mode == 'in' ? 'Sign In' : 'Create Account',
                                style: JemenaiTheme.fontBody(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                LucideIcons.arrowRight,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 24),

              // Footer notes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.lock, size: 12, color: mutedFore),
                  const SizedBox(width: 6),
                  Text(
                    'End-to-end encrypted · GDPR compliant',
                    style: JemenaiTheme.fontBody(
                      fontSize: 10,
                      color: mutedFore,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtn({required String label, required Widget icon}) {
    return InkWell(
      onTap: widget.onComplete,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: JemenaiTheme.card(widget.isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: JemenaiTheme.border(widget.isDark)),
          boxShadow: JemenaiTheme.shadowCard(widget.isDark),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: JemenaiTheme.fontBody(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: JemenaiTheme.foreground(widget.isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
