import 'dart:ui';
import 'package:flutter/material.dart';
import 'theme.dart';

class PhoneFrame extends StatelessWidget {
  final Widget child;
  final String activeTab;
  final Function(String) onTabChanged;
  final bool isDark;
  final VoidCallback onToggleDark;

  const PhoneFrame({
    super.key,
    required this.child,
    required this.activeTab,
    required this.onTabChanged,
    required this.isDark,
    required this.onToggleDark,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    if (!isDesktop) {
      // Full screen mobile rendering
      return Scaffold(
        backgroundColor: JemenaiTheme.background(isDark),
        body: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  bottom: 84,
                ),
                child: child,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: _buildBottomNav(context, false),
              ),
            ),
          ],
        ),
      );
    }

    // Centered mockup frame for desktop
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Hardware buttons - Left Side (Volume controls / Mute)
          Positioned(
            left: -3,
            top: 88,
            child: Container(
              width: 3,
              height: 30,
              decoration: BoxDecoration(
                color:
                    isDark
                        ? JemenaiTheme.hardwareButtonDark
                        : JemenaiTheme.hardwareButtonLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  bottomLeft: Radius.circular(3),
                ),
              ),
            ),
          ),
          Positioned(
            left: -3,
            top: 130,
            child: Container(
              width: 3,
              height: 60,
              decoration: BoxDecoration(
                color:
                    isDark
                        ? JemenaiTheme.hardwareButtonDark
                        : JemenaiTheme.hardwareButtonLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  bottomLeft: Radius.circular(3),
                ),
              ),
            ),
          ),
          Positioned(
            left: -3,
            top: 200,
            child: Container(
              width: 3,
              height: 60,
              decoration: BoxDecoration(
                color:
                    isDark
                        ? JemenaiTheme.hardwareButtonDark
                        : JemenaiTheme.hardwareButtonLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  bottomLeft: Radius.circular(3),
                ),
              ),
            ),
          ),

          // Hardware buttons - Right Side (Power Button)
          Positioned(
            right: -3,
            top: 148,
            child: Container(
              width: 3,
              height: 82,
              decoration: BoxDecoration(
                color:
                    isDark
                        ? JemenaiTheme.hardwareButtonDark
                        : JemenaiTheme.hardwareButtonLight,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
              ),
            ),
          ),

          // Main Mockup Container
          Container(
            width: 390,
            height: 844,
            decoration: BoxDecoration(
              color: JemenaiTheme.background(isDark),
              borderRadius: BorderRadius.circular(44),
              boxShadow: JemenaiTheme.shadowCard(isDark),
              border: Border.all(
                color:
                    isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                43,
              ), // Slightly smaller to hide boundaries
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 48,
                        bottom: 80,
                      ),
                      child: child,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _buildStatusBar(context),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildBottomNav(context, true),
                  ),

                  // Notch overlay
                  Positioned(
                    top: 1,
                    left: (390 - 112) / 2, // Centered
                    child: Container(
                      width: 112,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
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

  Widget _buildStatusBar(BuildContext context) {
    final fg = isDark ? Colors.white : Colors.black;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time
          Text(
            '9:41',
            style: JemenaiTheme.fontDisplay(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),

          // Icons
          Row(
            children: [
              // Signal bars
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(4, (index) {
                  final h = [3.0, 5.0, 7.0, 9.0][index];
                  return Container(
                    width: 3,
                    height: h,
                    margin: const EdgeInsets.only(left: 1.5),
                    decoration: BoxDecoration(
                      color: fg.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 6),

              // WiFi
              Icon(Icons.wifi, size: 14, color: fg.withOpacity(0.8)),
              const SizedBox(width: 6),

              // Battery
              Container(
                width: 28,
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: fg.withOpacity(0.6), width: 1),
                ),
                padding: const EdgeInsets.all(1),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      decoration: BoxDecoration(
                        color: fg.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isMock) {
    final navItems = [
      {'id': 'home', 'icon': Icons.home, 'label': 'Home'},
      {'id': 'models', 'icon': Icons.store, 'label': 'Models'},
      {'id': 'chat', 'icon': Icons.chat_bubble_outline, 'label': 'Chat'},
      {'id': 'storage', 'icon': Icons.storage, 'label': 'Storage'},
      {'id': 'settings', 'icon': Icons.settings, 'label': 'Settings'},
    ];

    // Determine normalized active tab (for items mapping to a parent tab)
    String normalizedActive = activeTab;
    if (activeTab == 'quickaction') {
      normalizedActive = 'home';
    } else if (activeTab == 'chats') {
      normalizedActive = 'chat';
    }

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, isMock ? 16 : 10),
      height: 64,
      decoration: BoxDecoration(
        color: JemenaiTheme.navBackground(isDark).withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : const Color(0xFF4F46E5).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Stack(
            children: [
              // Sliding active background capsule
              AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                alignment: Alignment(
                  -1.0 + (navItems.indexWhere((item) => item['id'] == normalizedActive) * (2.0 / (navItems.length - 1))),
                  0.0,
                ),
                child: FractionallySizedBox(
                  widthFactor: 1.0 / navItems.length,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      color: JemenaiTheme.primary(isDark).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              // Navbar items
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:
                      navItems.map((item) {
                        final id = item['id'] as String;
                        final icon = item['icon'] as IconData;
                        final label = item['label'] as String;
                        final isActive = normalizedActive == id;

                        return Expanded(
                          child: InkWell(
                            onTap: () => onTabChanged(id),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  duration: const Duration(milliseconds: 200),
                                  scale: isActive ? 1.18 : 1.0,
                                  curve: Curves.easeOutBack,
                                  child: Icon(
                                    icon,
                                    size: 18,
                                    color:
                                        isActive
                                            ? JemenaiTheme.primary(isDark)
                                            : JemenaiTheme.mutedForeground(isDark),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  label,
                                  style: JemenaiTheme.fontBody(
                                    fontSize: 9,
                                    fontWeight:
                                        isActive ? FontWeight.bold : FontWeight.w500,
                                    color:
                                        isActive
                                            ? JemenaiTheme.primary(isDark)
                                            : JemenaiTheme.mutedForeground(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
