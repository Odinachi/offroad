import 'package:flutter/material.dart';
import 'package:jemenai/shared/assets.dart';
import 'package:jemenai/shared/navigator/app_route_string.dart';
import 'package:jemenai/shared/navigator/app_router.dart';
import '../../../shared/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _idx = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _idx);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': Icons.shield,
      'label': 'Privacy First',
      'title': 'Your AI.\nYour Device.\nYour Data.',
      'sub':
          'Conversations never leave your phone. No cloud, no surveillance, no compromise.',
      'colors': [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
      'accent': const Color(0xFF818CF8),
    },
    {
      'icon': Icons.wifi_off,
      'label': 'Offline Ready',
      'title': 'Works Without\nInternet.\nAlways.',
      'sub':
          'Download models once. Run them forever on a plane, in a tunnel, off the grid.',
      'colors': [const Color(0xFF0891B2), const Color(0xFF0E7490)],
      'accent': const Color(0xFF38BDF8),
    },
    {
      'icon': Icons.flash_on,
      'label': 'Instant Speed',
      'title': 'On-Device\nMeans Zero\nLatency.',
      'sub':
          'No round-trips to servers. Responses begin in milliseconds, not seconds.',
      'colors': [const Color(0xFF7C3AED), const Color(0xFFA855F7)],
      'accent': const Color(0xFFC084FC),
    },
    {
      'icon': Icons.memory,
      'label': 'Powerful Models',
      'title': 'State-of-Art AI\nFits in Your\nPocket.',
      'sub':
          "Llama, Mistral, Phi, Gemma the world's best open models, running locally.",
      'colors': [const Color(0xFF059669), const Color(0xFF0D9488)],
      'accent': const Color(0xFF34D399),
    },
  ];

  void _next() {
    if (_idx < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      AppRouter.push(AppRouteString.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_idx];
    final List<Color> colors = slide['colors'] as List<Color>;
    final accent = slide['accent'] as Color;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
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
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _idx == _slides.length - 1 ? 0.0 : 1.0,
                      child: IgnorePointer(
                        ignoring: _idx == _slides.length - 1,
                        child: InkWell(
                          onTap: () {
                            AppRouter.push(AppRouteString.auth);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? Colors.white.withOpacity(0.06)
                                      : Colors.black.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Skip',
                              style: JemenaiTheme.fontBody(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.jColors.mutedForeground,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Content Area
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() {
                        _idx = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final s = _slides[index];
                      final List<Color> sColors = s['colors'] as List<Color>;
                      final sAccent = s['accent'] as Color;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            // Premium Visual Graphics
                            OnboardingGraphics(
                              idx: index,
                              colors: sColors,
                              accent: sAccent,
                            ),
                            const SizedBox(height: 36),

                            // Title
                            Text(
                              s['title'] as String,
                              style: JemenaiTheme.fontDisplay(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                                lineHeight: 1.15,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Subtitle
                            Text(
                              s['sub'] as String,
                              style: JemenaiTheme.fontBody(
                                fontSize: 14,
                                color: theme.jColors.mutedForeground,
                                lineHeight: 1.45,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
                                      : theme.jColors.mutedForeground
                                          .withOpacity(0.3),
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
      ),
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

// Premium Custom Onboarding Graphics Widget
class OnboardingGraphics extends StatelessWidget {
  final int idx;
  final List<Color> colors;
  final Color accent;

  const OnboardingGraphics({
    super.key,
    required this.idx,
    required this.colors,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final jc = theme.jColors;

    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16161A) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(isDark ? 0.08 : 0.05),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative background patterns
            Positioned(
              top: -60,
              left: -60,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[0].withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              right: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[1].withOpacity(0.1),
                ),
              ),
            ),

            // Core Graphic depending on Slide Index
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: _buildGraphic(isDark, theme, jc),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphic(bool isDark, ThemeData theme, JemenaiColors jc) {
    switch (idx) {
      case 0:
        return _buildPrivacyGraphic(isDark, theme, jc);
      case 1:
        return _buildOfflineGraphic(isDark, theme, jc);
      case 2:
        return _buildSpeedGraphic(isDark, theme, jc);
      case 3:
        return _buildModelsGraphic(isDark, theme, jc);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPrivacyGraphic(bool isDark, ThemeData theme, JemenaiColors jc) {
    return Container(
      key: const ValueKey(0),
      width: 160,
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222227) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Simulated App Header
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const Spacer(),
              Icon(Icons.shield, color: accent, size: 14),
            ],
          ),
          const SizedBox(height: 12),

          // Simulated chat message 1
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF2E2E35) : const Color(0xFFF3F4F6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                'Where is my data?',
                style: JemenaiTheme.fontBody(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Simulated chat response
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: const BoxDecoration(
                gradient: JemenaiTheme.gradBrand,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Text(
                'Stored locally.',
                style: JemenaiTheme.fontBody(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Spacer(),

          // Glowing lock badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF022016),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4ADE80).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, color: Color(0xFF4ADE80), size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'ON-DEVICE ONLY',
                    style: JemenaiTheme.fontBody(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4ADE80),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineGraphic(bool isDark, ThemeData theme, JemenaiColors jc) {
    return Container(
      key: const ValueKey(1),
      width: 220,
      height: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222227) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNetworkStatusPill(
                icon: Icons.wifi_off,
                label: 'No Wi-Fi',
                color: Colors.redAccent,
              ),
              _buildNetworkStatusPill(
                icon: Icons.airplanemode_active,
                label: 'Airplane',
                color: Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF022016),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF4ADE80).withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Offroad AI Engine: ONLINE',
                  style: JemenaiTheme.fontBody(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4ADE80),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkStatusPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: JemenaiTheme.fontBody(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedGraphic(bool isDark, ThemeData theme, JemenaiColors jc) {
    return Container(
      key: const ValueKey(2),
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: CircularProgressIndicator(
              value: 0.85,
              strokeWidth: 6,
              color: accent,
              backgroundColor:
                  isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.08),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '0.8s',
                style: JemenaiTheme.fontDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'LATENCY',
                style: JemenaiTheme.fontBody(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: jc.mutedForeground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModelsGraphic(bool isDark, ThemeData theme, JemenaiColors jc) {
    return Container(
      key: const ValueKey(3),
      width: 240,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            top: 20,
            child: _buildModelCard('Llama 3.2', 'Meta', Colors.blue, isDark),
          ),
          Positioned(
            right: 0,
            top: 10,
            child: _buildModelCard(
              'Phi-3 Mini',
              'Microsoft',
              Colors.orange,
              isDark,
            ),
          ),
          Positioned(
            bottom: 10,
            child: _buildModelCard(
              'Mistral 7B',
              'Mistral AI',
              Colors.purple,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelCard(
    String name,
    String maker,
    Color brandColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222227) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: brandColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: JemenaiTheme.fontBody(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Text(
                maker,
                style: JemenaiTheme.fontBody(fontSize: 8, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Authentication Screen Widget
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _showPass = false;
  bool _loading = false;
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  final authType = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _submit() {
    setState(() {
      _loading = true;
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        AppRouter.pushReplacement(AppRouteString.dashboard);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = jc.card;
    final inputBg = jc.muted;
    final foreground = theme.colorScheme.onSurface;
    final mutedFore = jc.mutedForeground;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 72),

                // Sparkles App Logo
                Assets.svg.appLogo.svg(width: 64, height: 64),
                const SizedBox(height: 16),

                Text(
                  'OffRoad',
                  textAlign: TextAlign.center,
                  style: JemenaiTheme.fontDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PRIVATE AI  ·  ANYWHERE  ·  ANYTIME',
                  textAlign: TextAlign.center,
                  style: JemenaiTheme.fontBody(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: mutedFore,
                    lineHeight: 1.0,
                  ),
                ),
                const SizedBox(height: 36),

                Container(
                  height: 48,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: jc.secondaryFill,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TabBar(
                    splashFactory: NoSplash.splashFactory,
                    onTap: (value) => authType.value = value,
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelStyle: JemenaiTheme.fontBody(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: JemenaiTheme.fontBody(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    tabs: const [
                      Tab(text: 'Sign In'),
                      Tab(text: 'Create Account'),
                    ],
                  ),
                ),

                // Custom Switch Toggle (Sign in / Create Account)
                // Container(
                //   height: 48,
                //   decoration: BoxDecoration(
                //     color: jc.secondaryFill,
                //     borderRadius: BorderRadius.circular(16),
                //   ),
                //   padding: const EdgeInsets.all(4),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: InkWell(
                //           onTap: () => setState(() => _mode = 'in'),
                //           borderRadius: BorderRadius.circular(12),
                //           child: AnimatedContainer(
                //             duration: const Duration(milliseconds: 200),
                //             decoration: BoxDecoration(
                //               color:
                //                   _mode == 'in' ? cardBg : Colors.transparent,
                //               borderRadius: BorderRadius.circular(12),
                //               boxShadow:
                //                   _mode == 'in'
                //                       ? JemenaiTheme.shadowCard(isDark)
                //                       : [],
                //             ),
                //             alignment: Alignment.center,
                //             child: Text(
                //               'Sign In',
                //               style: JemenaiTheme.fontBody(
                //                 fontSize: 13,
                //                 fontWeight: FontWeight.bold,
                //                 color: _mode == 'in' ? foreground : mutedFore,
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //       Expanded(
                //         child: InkWell(
                //           onTap: () => setState(() => _mode = 'up'),
                //           borderRadius: BorderRadius.circular(12),
                //           child: AnimatedContainer(
                //             duration: const Duration(milliseconds: 200),
                //             decoration: BoxDecoration(
                //               color:
                //                   _mode == 'up' ? cardBg : Colors.transparent,
                //               borderRadius: BorderRadius.circular(12),
                //               boxShadow:
                //                   _mode == 'up'
                //                       ? JemenaiTheme.shadowCard(isDark)
                //                       : [],
                //             ),
                //             alignment: Alignment.center,
                //             child: Text(
                //               'Create Account',
                //               style: JemenaiTheme.fontBody(
                //                 fontSize: 13,
                //                 fontWeight: FontWeight.bold,
                //                 color: _mode == 'up' ? foreground : mutedFore,
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
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
                        color: theme.colorScheme.primary.withOpacity(0.25),
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
                        _showPass ? Icons.visibility_off : Icons.visibility,
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
                        color: theme.colorScheme.primary.withOpacity(0.25),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Action
                ValueListenableBuilder(
                  valueListenable: authType,
                  builder: (context, value, child) {
                    return InkWell(
                      onTap: _loading ? null : _submit,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: JemenaiTheme.gradBrand,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow:
                              _loading ? [] : JemenaiTheme.glowSm(isDark),
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
                                      value == 0 ? 'Sign In' : 'Create Account',
                                      style: JemenaiTheme.fontBody(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: jc.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'or',
                        style: JemenaiTheme.fontBody(
                          fontSize: 11,
                          color: mutedFore,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: jc.border)),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildSocialBtn(
                        label: 'Google',
                        icon: Assets.svg.google.svg(height: 18, width: 18),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Expanded(
                      child: _buildSocialBtn(
                        label: 'Apple',
                        textColor: Colors.white,
                        backgroundColor: Colors.black,
                        icon: Assets.svg.apple.svg(
                          height: 18,
                          width: 18,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtn({
    required String label,
    required Widget icon,
    Color? textColor,
    Color? backgroundColor,
  }) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        AppRouter.pushReplacement(AppRouteString.dashboard);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor ?? jc.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: jc.border),
          boxShadow: JemenaiTheme.shadowCard(isDark),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: JemenaiTheme.fontBody(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
