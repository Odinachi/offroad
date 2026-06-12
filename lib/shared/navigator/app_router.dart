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

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final Widget page = switch (settings.name) {
      AppRouteString.onboarding => const OnboardingScreen(),
      AppRouteString.chat => () {
        return ChatScreen(args: args as ChatScreenArg?);
      }(),
      AppRouteString.chatsList => ChatsListScreen(),
      AppRouteString.voice => const VoiceChatScreen(),
      AppRouteString.auth => const AuthScreen(),
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
