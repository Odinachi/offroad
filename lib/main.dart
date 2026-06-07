import 'dart:math';

import 'package:flutter/material.dart';
import 'shared/navigator/app_route_string.dart';
import 'shared/navigator/app_router.dart';

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
      title: 'Jemenai AI',
      debugShowCheckedModeBanner: false,
      themeMode: Random().nextBool() ? ThemeMode.dark : ThemeMode.light,
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
      navigatorKey: AppRouter.navKey,
      initialRoute: AppRouteString.onboarding,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
