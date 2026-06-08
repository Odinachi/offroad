import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jemenai/features/ai/views/chat_screen.dart';
import 'package:jemenai/features/ai/views/models_store_screen.dart';
import 'package:jemenai/features/dashboard/views/storage_dashboard_screen.dart';
import 'package:jemenai/features/home/views/home_screen.dart';
import 'package:jemenai/features/settings/views/settings_screen.dart';
import 'package:jemenai/shared/theme.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  late final PageController _pageController;
  int _currentIndex = 0;

  void switchTab(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: const [
            HomeScreen(),
            ModelsStoreScreen(),
            ChatScreen(isTab: true),
            StorageDashboardScreen(),
            SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              boxShadow: JemenaiTheme.shadowFloat(isDark),
              border: Border.all(color: jc.border, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  color: jc.navBackground,
                  child: Stack(
                    children: [
                      // Sliding Active Pill Background
                      Positioned.fill(
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOutCubic,
                          alignment: Alignment(
                            -1.0 + (_currentIndex * 0.5),
                            0.0,
                          ),
                          child: FractionallySizedBox(
                            widthFactor: 0.2,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: jc.accent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Tab Interactive Items
                      Positioned.fill(
                        child: Row(
                          children: List.generate(5, (index) {
                            final isSelected = _currentIndex == index;
                            return Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  _pageController.jumpToPage(index);
                                },
                                child: _buildNavItem(index, isSelected, jc),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, bool isSelected, JemenaiColors jc) {
    final IconData activeIcon;
    final IconData inactiveIcon;
    final String label;

    switch (index) {
      case 0:
        activeIcon = Icons.home_rounded;
        inactiveIcon = Icons.home_outlined;
        label = 'Home';
        break;
      case 1:
        activeIcon = Icons.explore_rounded;
        inactiveIcon = Icons.explore_outlined;
        label = 'Store';
        break;
      case 2:
        activeIcon = Icons.chat_bubble_rounded;
        inactiveIcon = Icons.chat_bubble_outline_rounded;
        label = 'AI Chat';
        break;
      case 3:
        activeIcon = Icons.folder_rounded;
        inactiveIcon = Icons.folder_outlined;
        label = 'Storage';
        break;
      case 4:
        activeIcon = Icons.settings_rounded;
        inactiveIcon = Icons.settings_outlined;
        label = 'Settings';
        break;
      default:
        activeIcon = Icons.home_rounded;
        inactiveIcon = Icons.home_outlined;
        label = '';
    }

    final iconColor = isSelected ? jc.accentForeground : jc.mutedForeground;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          scale: isSelected ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Icon(
            isSelected ? activeIcon : inactiveIcon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: JemenaiTheme.fontBody(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: iconColor,
          ),
          child: Text(label),
        ),
      ],
    );
  }
}
