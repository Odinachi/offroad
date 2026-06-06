import 'package:flutter/material.dart';
import 'shared/theme.dart';
import 'shared/phone_frame.dart';
import 'shared/desktop_sidebar.dart';
import 'features/auth/views/onboarding_screen.dart';
import 'features/home/views/home_screen.dart';
import 'features/ai/views/models_store_screen.dart';
import 'features/ai/views/chat_screen.dart';
import 'features/ai/views/voice_chat_screen.dart';
import 'features/dashboard/views/storage_dashboard_screen.dart';
import 'features/settings/views/settings_screen.dart';
import 'features/ai/views/quick_action_screen.dart';
import 'features/ai/views/ai_chat_list_screen.dart';

void main() {
  runApp(const JemenaiApp());
}

class JemenaiApp extends StatefulWidget {
  const JemenaiApp({super.key});

  @override
  State<JemenaiApp> createState() => _JemenaiAppState();
}

class _JemenaiAppState extends State<JemenaiApp> {
  bool _isDark = false;

  void _toggleDark() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jemenai AI',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF09090B),
        useMaterial3: true,
      ),
      home: JemenaiAppShell(
        isDark: _isDark,
        onToggleDark: _toggleDark,
      ),
    );
  }
}

class JemenaiAppShell extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleDark;

  const JemenaiAppShell({
    super.key,
    required this.isDark,
    required this.onToggleDark,
  });

  @override
  State<JemenaiAppShell> createState() => _JemenaiAppShellState();
}

class _JemenaiAppShellState extends State<JemenaiAppShell> {
  String _screen = 'onboarding';
  Map<String, dynamic> _params = {};

  void _navigate(String screen, [Map<String, dynamic>? params]) {
    setState(() {
      _screen = screen;
      _params = params ?? {};
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    // Full-bleed layout screens
    if (_screen == 'onboarding') {
      return Scaffold(
        backgroundColor: JemenaiTheme.background(isDark),
        body: OnboardingScreen(
          onComplete: () => _navigate('home'),
          isDark: isDark,
        ),
      );
    }

    if (_screen == 'voice') {
      return Scaffold(
        body: VoiceChatScreen(
          onNavigate: _navigate,
          isDark: isDark,
        ),
      );
    }

    // Standard tabbed screen or sub-screens with frame layout
    final Widget pageContent;
    switch (_screen) {
      case 'home':
        pageContent = HomeScreen(onNavigate: _navigate, isDark: isDark);
        break;
      case 'models':
        pageContent = ModelsStoreScreen(onNavigate: _navigate, isDark: isDark);
        break;
      case 'chat':
        pageContent = ChatScreen(
          onNavigate: _navigate,
          isDark: isDark,
          initialPrompt: _params['prompt'] as String?,
          modelName: _params['model'] as String?,
        );
        break;
      case 'storage':
        pageContent = StorageDashboardScreen(onNavigate: _navigate, isDark: isDark);
        break;
      case 'settings':
        pageContent = SettingsScreen(
          onNavigate: _navigate,
          isDark: isDark,
          onToggleDark: widget.onToggleDark,
        );
        break;
      case 'quickaction':
        pageContent = QuickActionScreen(
          onNavigate: _navigate,
          isDark: isDark,
          action: _params['action'] as String? ?? 'text-assistant',
          label: _params['label'] as String? ?? 'AI Assistant',
        );
        break;
      case 'chats':
        pageContent = ChatsListScreen(onNavigate: _navigate, isDark: isDark);
        break;
      default:
        pageContent = HomeScreen(onNavigate: _navigate, isDark: isDark);
    }

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    if (!isDesktop) {
      return PhoneFrame(
        activeTab: _screen,
        onTabChanged: (tabId) => _navigate(tabId),
        isDark: isDark,
        onToggleDark: widget.onToggleDark,
        child: pageContent,
      );
    }

    // Responsive Desktop Frame + Sidebar
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF050508), Color(0xFF0D0D18), Color(0xFF080810)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFE8E8F4), Color(0xFFF0EFF8), Color(0xFFE4E4F0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Centered Mockup
            PhoneFrame(
              activeTab: _screen,
              onTabChanged: (tabId) => _navigate(tabId),
              isDark: isDark,
              onToggleDark: widget.onToggleDark,
              child: pageContent,
            ),

            // Sidebar details for wide screen
            DesktopSidebar(
              isDark: isDark,
              onToggleDark: widget.onToggleDark,
            ),
          ],
        ),
      ),
    );
  }
}
