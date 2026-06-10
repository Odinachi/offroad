import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:jemenai/services/cache_service.dart';

import '../model/ai_model.dart';

part 'model_download_state.dart';

/// Manages model downloads using flutter_gemma's Modern API.
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
        final installed = await FlutterGemma.isModelInstalled(model.fileName);
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
      await FlutterGemma.installModel(
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
          error: e.toString(),
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

  Future<void> deleteModel(AIModel model) async {
    try {
      await FlutterGemma.uninstallModel(model.fileName);
    } catch (e) {
      debugPrint('⚠️ Failed to uninstall ${model.name}: $e');
    }
    _statuses[model.id] = const ModelDownloadStatus(phase: DownloadPhase.idle);
    _emitSnapshot();
  }

  ModelDownloadStatus statusFor(String modelId) {
    return _statuses[modelId] ?? const ModelDownloadStatus();
  }

  void _emitSnapshot() {
    emit(ModelDownloadUpdated(statuses: Map.unmodifiable(_statuses)));
  }
}
