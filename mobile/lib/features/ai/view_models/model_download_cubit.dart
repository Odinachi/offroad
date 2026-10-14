import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:jemenai/services/cache_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../model/ai_model.dart';

part 'model_download_state.dart';

/// Manages model downloads using flutter_edge_ai.
///
/// Supports multiple concurrent downloads, each with its own [CancelToken]
/// and progress tracking. The cubit re-checks installed status on [init].
class ModelDownloadCubit extends Cubit<ModelDownloadState> {
  ModelDownloadCubit({required this.cacheService})
    : super(ModelDownloadInitial());

  final CacheService cacheService;

  final Map<String, ModelDownloadStatus> _statuses = {};

  Future<void> init() async {
    for (final model in models) {
      try {
        final installed = await FlutterEdgeAi.isModelInstalled(model.fileName);
        _statuses[model.id] = ModelDownloadStatus(
          phase: installed ? DownloadPhase.installed : DownloadPhase.idle,
        );
      } catch (e) {
        // If checking fails, default to idle
        _statuses[model.id] = const ModelDownloadStatus();
      }
    }
    _emitSnapshot();
  }

  void startDownload(AIModel model) {
    final cancelToken = CancelToken();

    _statuses[model.id] = ModelDownloadStatus(
      phase: DownloadPhase.downloading,
      progress: 0,
      cancelToken: cancelToken,
    );
    _emitSnapshot();

    // Fire-and-forget — progress and completion update state via callbacks.
    _performDownload(model, cancelToken);
  }

  Future<void> _performDownload(AIModel model, CancelToken cancelToken) async {
    try {
      final token = cacheService.getHuggingFaceToken();
      await FlutterEdgeAi.installModel(
            modelType: model.modelType,
            fileType: model.fileType,
          )
          .fromNetwork(
            model.downloadUrl,
            token: token?.isNotEmpty == true ? token : null,
          )
          .withCancelToken(cancelToken)
          .withProgress((progress) {
            if (!isClosed) {
              _statuses[model.id] = ModelDownloadStatus(
                phase: DownloadPhase.downloading,
                progress: progress,
                cancelToken: cancelToken,
              );
              _emitSnapshot();
            }
          })
          .install();

      // Download succeeded
      if (!isClosed) {
        _statuses[model.id] = const ModelDownloadStatus(
          phase: DownloadPhase.installed,
          progress: 100,
        );
        _emitSnapshot();
      }
    } catch (e) {
      if (isClosed) return;

      if (CancelToken.isCancel(e)) {
        // User cancelled — reset to idle
        _statuses[model.id] = const ModelDownloadStatus(
          phase: DownloadPhase.idle,
        );
      } else {
        debugPrint('⚠️ Download failed for ${model.name}: $e');
        _statuses[model.id] = ModelDownloadStatus(
          phase: DownloadPhase.failed,
          error: describeDownloadError(e),
        );
      }
      _emitSnapshot();
    }
  }

  void cancelDownload(String modelId) {
    final status = _statuses[modelId];
    if (status != null && status.phase == DownloadPhase.downloading) {
      status.cancelToken?.cancel('User cancelled download');
    }
  }

  /// Removes the model file. Conversations are kept: reopening one offers
  /// to continue it with another downloaded model.
  Future<void> deleteModel(AIModel model) async {
    try {
      await FlutterEdgeAi.uninstallModel(model.fileName);
    } catch (e) {
      debugPrint('⚠️ Failed to uninstall ${model.name}: $e');
    }
    _statuses[model.id] = const ModelDownloadStatus(phase: DownloadPhase.idle);
    _emitSnapshot();
  }

  ModelDownloadStatus statusFor(String modelId) {
    return _statuses[modelId] ?? const ModelDownloadStatus();
  }

  bool _wakelockOn = false;

  void _emitSnapshot() {
    emit(ModelDownloadUpdated(statuses: Map.unmodifiable(_statuses)));
    _syncWakelock();
  }

  /// Keeps the screen awake while any download runs, wherever the user is in
  /// the app; a sleeping phone suspends multi-GB transfers.
  void _syncWakelock() {
    final downloading = _statuses.values.any(
      (s) => s.phase == DownloadPhase.downloading,
    );
    if (downloading == _wakelockOn) return;
    _wakelockOn = downloading;
    WakelockPlus.toggle(enable: downloading).catchError((Object e) {
      debugPrint('Wakelock unavailable: $e');
    });
  }

  @override
  Future<void> close() {
    if (_wakelockOn) WakelockPlus.disable().catchError((Object _) {});
    return super.close();
  }

  /// Maps download failures to an explanation the user can act on.
  static String describeDownloadError(Object error) {
    final text = error.toString();
    final lower = text.toLowerCase();
    if (lower.contains('401') ||
        lower.contains('403') ||
        lower.contains('unauthorized') ||
        lower.contains('forbidden')) {
      return 'Access denied. Accept the model\'s license on huggingface.co, '
          'then add your token in Settings → Hugging Face Token.';
    }
    if (lower.contains('404')) {
      return 'The model file is no longer available at its download link.';
    }
    if (lower.contains('no space') ||
        lower.contains('enospc') ||
        lower.contains('disk full') ||
        lower.contains('insufficient storage')) {
      return 'Not enough free storage. Free up space and try again.';
    }
    if (lower.contains('socket') ||
        lower.contains('network') ||
        lower.contains('connection') ||
        lower.contains('timed out') ||
        lower.contains('host lookup')) {
      return 'Network problem. Check your connection and tap Retry.';
    }
    return 'Download failed: $text';
  }
}
