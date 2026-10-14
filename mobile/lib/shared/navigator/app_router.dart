import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jemenai/features/dashboard/views/dashboard.dart';
import 'app_route_string.dart';
import '../../features/auth/views/onboarding_screen.dart';
import '../../features/ai/views/voice_chat_screen.dart';
import '../../features/ai/views/ai_chat_list_screen.dart';
import '../../features/ai/views/chat_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  /// Selected tab of the root [Dashboard]. Write through [openDashboardTab].
  static final ValueNotifier<int> dashboardTab = ValueNotifier(0);

  static const int homeTab = 0;
  static const int modelsTab = 1;
  static const int storageTab = 2;
  static const int settingsTab = 3;

  /// Returns to the root dashboard (closing any pushed screens and sheets)
  /// and selects [index].
  static void openDashboardTab(int index) {
    navKey.currentState?.popUntil(
      (route) =>
          route.settings.name == AppRouteString.dashboard || route.isFirst,
    );
    dashboardTab.value = index;
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final Widget page = switch (settings.name) {
      AppRouteString.onboarding => const OnboardingScreen(),
      AppRouteString.chat => () {
        return ChatScreen(args: args as ChatScreenArg?);
      }(),
      AppRouteString.chatsList => const ChatsListScreen(),
      AppRouteString.voice => VoiceChatScreen(modelName: args as String?),
      AppRouteString.dashboard => const Dashboard(),
      _ => const OnboardingScreen(),
    };
    return CupertinoPageRoute<void>(builder: (_) => page, settings: settings);
  }

  static Future<T?> push<T>(String routeName, {dynamic args}) {
    return navKey.currentState!.pushNamed<T>(routeName, arguments: args);
  }

  static Future<T?> pushReplacement<T, TO>(
    String routeName, {
    Map<String, dynamic>? args,
  }) {
    return navKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: args,
    );
  }

  static Future<T?> pushAndRemoveUntil<T>(
    String routeName, {
    Map<String, dynamic>? args,
  }) {
    return navKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: args,
    );
  }

  static void pop<T>([T? arg]) {
    navKey.currentState!.pop<T>(arg);
  }

  static void showMessage(String text) {
    final context = navKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text, maxLines: 3, overflow: TextOverflow.ellipsis),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static void showModal({
    required String title,
    required WidgetBuilder builder,
  }) {
    final context = navKey.currentContext;
    if (context != null) {
      showModalBottomSheet(
        context: context,
        builder:
            (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Expanded(child: builder(context)),
              ],
            ),
      );
    }
  }
}
