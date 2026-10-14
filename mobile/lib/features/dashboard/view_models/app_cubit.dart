import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jemenai/services/cache_service.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit({required this.cacheService})
    : super(
        AppState(
          themeMode: switch (cacheService.getIsDarkMode()) {
            true => ThemeMode.dark,
            false => ThemeMode.light,
            null => ThemeMode.system,
          },
          inferenceEngine: cacheService.getInferenceEngine() ?? 'cpu',
        ),
      );

  final CacheService cacheService;

  bool get isDarkTheme => switch (state.themeMode) {
    ThemeMode.dark => true,
    ThemeMode.light => false,
    ThemeMode.system =>
      PlatformDispatcher.instance.platformBrightness == Brightness.dark,
  };

  String get inferenceEngine => state.inferenceEngine;

  void toggleTheme() {
    final dark = !isDarkTheme;
    cacheService.saveIsDarkMode(dark);
    emit(state.copyWith(themeMode: dark ? ThemeMode.dark : ThemeMode.light));
  }

  Future<void> seenOnboarding() => cacheService.saveSeenOnboarding();

  Future<void> saveInferenceEngine(String engine) async {
    emit(state.copyWith(inferenceEngine: engine));
    await cacheService.saveInferenceEngine(engine);
  }
}
