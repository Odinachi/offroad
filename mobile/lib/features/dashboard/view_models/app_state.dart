part of 'app_cubit.dart';

class AppState extends Equatable {
  const AppState({required this.themeMode, required this.inferenceEngine});

  /// [ThemeMode.system] until the user explicitly picks light or dark.
  final ThemeMode themeMode;

  /// `"cpu"` or `"gpu"`.
  final String inferenceEngine;

  AppState copyWith({ThemeMode? themeMode, String? inferenceEngine}) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      inferenceEngine: inferenceEngine ?? this.inferenceEngine,
    );
  }

  @override
  List<Object?> get props => [themeMode, inferenceEngine];
}
