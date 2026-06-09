import 'package:flutter/material.dart';
import 'shared/navigator/app_route_string.dart';
import 'shared/navigator/app_router.dart';
import 'shared/theme.dart';

void main() {
  runApp(const JemenaiApp());
}

class JemenaiApp extends StatefulWidget {
  const JemenaiApp({super.key});

  @override
  State<JemenaiApp> createState() => _JemenaiAppState();
}

class _JemenaiAppState extends State<JemenaiApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: JemenaiTheme.lightTheme(),
      darkTheme: JemenaiTheme.darkTheme(),
      navigatorKey: AppRouter.navKey,
      initialRoute: AppRouteString.onboarding,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
