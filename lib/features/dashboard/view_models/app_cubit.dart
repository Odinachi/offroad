import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jemenai/services/cache_service.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit({required this.cacheService}) : super(AppInitial()) {
    if (cacheService.getIsDarkMode() is bool) {
      isDarkTheme = cacheService.getIsDarkMode()!;
    } else {
      final Brightness brightness =
          PlatformDispatcher.instance.platformBrightness;
      final themeMode = brightness == Brightness.dark;
      cacheService.saveIsDarkMode(themeMode);
      isDarkTheme = themeMode;
    }

    if (cacheService.getInferenceEngine() is String) {
      inferenceEngine = cacheService.getInferenceEngine()!;
    } else {
      inferenceEngine = "cpu";
      cacheService.saveInferenceEngine(inferenceEngine);
    }
  }

  final CacheService cacheService;

  bool isDarkTheme = false;

  String inferenceEngine = "cpu";

  void toggleTheme() {
    isDarkTheme = !isDarkTheme;
    cacheService.saveIsDarkMode(isDarkTheme);
    emit(AppUpdated());
  }

  void seenOnboarding() async {
    cacheService.saveSeenOnboarding();
  }

  void saveInferenceEngine(String engine) async {
    inferenceEngine = engine;
    await cacheService.saveInferenceEngine(engine);
    emit(AppUpdated());
  }
}
