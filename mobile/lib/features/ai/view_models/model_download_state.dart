part of 'model_download_cubit.dart';

// ──────────────────────────────────────────────────
// Download status for a single model
// ──────────────────────────────────────────────────

enum DownloadPhase { idle, downloading, installed, failed }

class ModelDownloadStatus {
  final DownloadPhase phase;
  final int progress; // 0–100
  final String? error;
  final CancelToken? cancelToken;

  const ModelDownloadStatus({
    this.phase = DownloadPhase.idle,
    this.progress = 0,
    this.error,
    this.cancelToken,
  });

  ModelDownloadStatus copyWith({
    DownloadPhase? phase,
    int? progress,
    String? error,
    CancelToken? cancelToken,
  }) {
    return ModelDownloadStatus(
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }
}

// ──────────────────────────────────────────────────
// Cubit state
// ──────────────────────────────────────────────────

sealed class ModelDownloadState {}

class ModelDownloadInitial extends ModelDownloadState {}

class ModelDownloadUpdated extends ModelDownloadState {
  /// Maps model URL (== AIModel.id) → current download status.
  final Map<String, ModelDownloadStatus> statuses;

  ModelDownloadUpdated({required this.statuses});
}
