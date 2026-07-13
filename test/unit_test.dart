import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jemenai/services/cache_service.dart';
import 'package:jemenai/features/dashboard/view_models/app_cubit.dart';
import 'package:jemenai/features/ai/model/ai_model.dart';
import 'package:jemenai/features/ai/model/chat_message.dart';
import 'package:jemenai/features/ai/view_models/model_download_cubit.dart';

void main() {
  group('AIModel Unit Tests', () {
    test('downloadUrl translates blob viewer to resolve direct-download link', () {
      final model = AIModel(
        url: 'https://huggingface.co/google/gemma-2b-it/blob/main/gemma-2b-it.bin',
        name: 'Gemma 2B IT',
        maker: 'Google',
        specialty: 'Chat',
        description: 'Test model description',
        sizeMb: 2600.0,
        ramGB: 4,
        modelType: ModelType.gemmaIt,
        inputModalities: [AIModality.text],
        outputModalities: [AIModality.text],
        compactibility: ['low'],
      );

      expect(model.downloadUrl, equals('https://huggingface.co/google/gemma-2b-it/resolve/main/gemma-2b-it.bin'));
    });

    test('sizeGB correctly converts sizeMb to GB', () {
      final model = AIModel(
        url: 'https://example.com/model',
        name: 'Test Model',
        maker: 'Test Maker',
        specialty: 'Test specialty',
        description: 'Test description',
        sizeMb: 2048.0,
        ramGB: 4,
        modelType: ModelType.gemmaIt,
        inputModalities: [AIModality.text],
        outputModalities: [AIModality.text],
        compactibility: ['medium'],
      );

      expect(model.sizeGB, equals(2.0));
    });

    test('popular getter matches expected name patterns', () {
      final popularModel1 = AIModel(
        url: 'https://example.com/gemma4',
        name: 'Gemma 4 Chat',
        maker: 'Google',
        specialty: 'Chat',
        description: 'Test description',
        sizeMb: 1000.0,
        ramGB: 4,
        modelType: ModelType.gemmaIt,
        inputModalities: [AIModality.text],
        outputModalities: [AIModality.text],
        compactibility: ['high'],
      );

      final popularModel2 = AIModel(
        url: 'https://example.com/r1',
        name: 'DeepSeek R1',
        maker: 'DeepSeek',
        specialty: 'Reasoning',
        description: 'Test description',
        sizeMb: 1000.0,
        ramGB: 4,
        modelType: ModelType.gemmaIt,
        inputModalities: [AIModality.text],
        outputModalities: [AIModality.text],
        compactibility: ['high'],
      );

      final nonPopularModel = AIModel(
        url: 'https://example.com/phi3',
        name: 'Phi-3 Mini',
        maker: 'Microsoft',
        specialty: 'Chat',
        description: 'Test description',
        sizeMb: 1000.0,
        ramGB: 4,
        modelType: ModelType.gemmaIt,
        inputModalities: [AIModality.text],
        outputModalities: [AIModality.text],
        compactibility: ['high'],
      );

      expect(popularModel1.popular, isTrue);
      expect(popularModel2.popular, isTrue);
      expect(nonPopularModel.popular, isFalse);
    });

    test('iq score calculated correctly based on model size', () {
      final largeModel = AIModel(
        url: 'https://example.com/1',
        name: 'Large Model',
        maker: 'Maker',
        specialty: 'Specialty',
        description: 'Description',
        sizeMb: 4000.0,
        ramGB: 8,
        modelType: ModelType.gemmaIt,
        inputModalities: [AIModality.text],
        outputModalities: [AIModality.text],
        compactibility: ['high'],
      );

      final mediumModel = AIModel(
        url: 'https://example.com/2',
        name: 'Medium Model',
        maker: 'Maker',
        specialty: 'Specialty',
        description: 'Description',
        sizeMb: 2000.0,
        ramGB: 4,
        modelType: ModelType.gemmaIt,
        inputModalities: [AIModality.text],
        outputModalities: [AIModality.text],
        compactibility: ['high'],
      );

      final smallModel = AIModel(
        url: 'https://example.com/3',
        name: 'Small Model',
        maker: 'Maker',
        specialty: 'Specialty',
        description: 'Description',
        sizeMb: 500.0,
        ramGB: 2,
        modelType: ModelType.gemmaIt,
        inputModalities: [AIModality.text],
        outputModalities: [AIModality.text],
        compactibility: ['high'],
      );

      expect(largeModel.iq, equals(90));
      expect(mediumModel.iq, equals(80));
      expect(smallModel.iq, equals(70));
    });

    test('models list is populated with valid model configurations', () {
      expect(models, isNotEmpty);
      for (final model in models) {
        expect(model.name, isNotEmpty);
        expect(model.maker, isNotEmpty);
        expect(model.specialty, isNotEmpty);
        expect(model.url, isNotEmpty);
        expect(model.downloadUrl, isNotEmpty);
        expect(model.sizeMb, isPositive);
        expect(model.ramGB, isPositive);
      }
    });
  });

  group('ChatMessage Unit Tests', () {
    test('default properties are set correctly', () {
      final msg = ChatMessage(
        id: 'msg-1',
        role: 'user',
        content: 'Hello local AI',
        ts: DateTime.now(),
      );

      expect(msg.pinned, isFalse);
      expect(msg.liked, isFalse);
      expect(msg.imageBytes, isNull);
    });

    test('updating mutable values updates instances correctly', () {
      final msg = ChatMessage(
        id: 'msg-2',
        role: 'assistant',
        content: 'Response content',
        ts: DateTime.now(),
      );

      msg.pinned = true;
      msg.liked = true;
      msg.content = 'Updated response';

      expect(msg.pinned, isTrue);
      expect(msg.liked, isTrue);
      expect(msg.content, equals('Updated response'));
    });
  });

  group('CacheService Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'isDarkMode': true,
        'seenOnboarding': true,
        'huggingFaceToken': 'hf_test_token_123',
        'inferenceEngine': 'gpu',
      });
    });

    test('initializes and reads stored values correctly', () async {
      final service = CacheService.instance;
      await service.init();

      expect(service.getIsDarkMode(), isTrue);
      expect(service.getSeenOnboarding(), isTrue);
      expect(service.getHuggingFaceToken(), equals('hf_test_token_123'));
      expect(service.getInferenceEngine(), equals('gpu'));
    });

    test('writes and updates values correctly', () async {
      final service = CacheService.instance;
      await service.init();

      await service.saveIsDarkMode(false);
      await service.saveSeenOnboarding(); // saves seenOnboarding to true
      await service.saveHuggingFaceToken('new_token');
      await service.saveInferenceEngine('cpu');

      expect(service.getIsDarkMode(), isFalse);
      expect(service.getSeenOnboarding(), isTrue);
      expect(service.getHuggingFaceToken(), equals('new_token'));
      expect(service.getInferenceEngine(), equals('cpu'));
    });

    test('clearAll clears preferences cache', () async {
      final service = CacheService.instance;
      await service.init();

      service.clearAll();

      // SharedPreferences clear() is async, wait a moment or check
      // since the native shared preferences mock clears synchronously
      expect(service.getIsDarkMode(), isNull);
      expect(service.getSeenOnboarding(), isFalse); // defaults to false in getter if null
      expect(service.getHuggingFaceToken(), isNull);
      expect(service.getInferenceEngine(), isNull);
    });
  });

  group('AppCubit Unit Tests', () {
    late CacheService cache;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      cache = CacheService.instance;
      await cache.init();
    });

    test('loads default values on initialization when cache is empty', () {
      final cubit = AppCubit(cacheService: cache);
      
      expect(cubit.isDarkTheme, isFalse); // defaults to system/false if empty mock
      expect(cubit.inferenceEngine, equals('cpu')); // default fallback
    });

    test('loads existing cache values on initialization', () async {
      await cache.saveIsDarkMode(true);
      await cache.saveInferenceEngine('gpu');

      final cubit = AppCubit(cacheService: cache);
      expect(cubit.isDarkTheme, isTrue);
      expect(cubit.inferenceEngine, equals('gpu'));
    });

    test('toggleTheme toggles theme state and saves it', () {
      final cubit = AppCubit(cacheService: cache);
      expect(cubit.isDarkTheme, isFalse);

      cubit.toggleTheme();
      expect(cubit.isDarkTheme, isTrue);
      expect(cache.getIsDarkMode(), isTrue);

      cubit.toggleTheme();
      expect(cubit.isDarkTheme, isFalse);
      expect(cache.getIsDarkMode(), isFalse);
    });

    test('seenOnboarding sets onboarding seen in cache', () {
      final cubit = AppCubit(cacheService: cache);
      expect(cache.getSeenOnboarding(), isFalse);

      cubit.seenOnboarding();
      expect(cache.getSeenOnboarding(), isTrue);
    });

    test('saveInferenceEngine updates engine and cache', () {
      final cubit = AppCubit(cacheService: cache);
      expect(cubit.inferenceEngine, equals('cpu'));

      cubit.saveInferenceEngine('metal');
      expect(cubit.inferenceEngine, equals('metal'));
      expect(cache.getInferenceEngine(), equals('metal'));
    });
  });

  group('ModelDownloadStatus Unit Tests', () {
    test('default status initialization', () {
      const status = ModelDownloadStatus();
      expect(status.phase, equals(DownloadPhase.idle));
      expect(status.progress, equals(0));
      expect(status.error, isNull);
      expect(status.cancelToken, isNull);
    });

    test('copyWith correctly updates properties', () {
      const status = ModelDownloadStatus();
      final updated = status.copyWith(
        phase: DownloadPhase.downloading,
        progress: 45,
        error: 'Slow connection',
      );

      expect(updated.phase, equals(DownloadPhase.downloading));
      expect(updated.progress, equals(45));
      expect(updated.error, equals('Slow connection'));
      expect(updated.cancelToken, isNull);
    });
  });

  group('ModelDownloadCubit Unit Tests', () {
    late CacheService cache;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      cache = CacheService.instance;
      await cache.init();
    });

    test('initial state is ModelDownloadInitial', () {
      final cubit = ModelDownloadCubit(cacheService: cache);
      expect(cubit.state, isA<ModelDownloadInitial>());
    });

    test('statusFor returns default idle status when not initialized/downloading', () {
      final cubit = ModelDownloadCubit(cacheService: cache);
      final status = cubit.statusFor('non-existent-url');
      expect(status.phase, equals(DownloadPhase.idle));
      expect(status.progress, equals(0));
    });

    test('startDownload handles install failure gracefully', () async {
      final cubit = ModelDownloadCubit(cacheService: cache);
      final testModel = models.first;

      // Because FlutterGemma is uninitialized in unit test, installing will fail.
      // We expect the cubit to capture this failure and transition to DownloadPhase.failed state.
      cubit.startDownload(testModel);

      // Give it a moment to run the async _performDownload
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state, isA<ModelDownloadUpdated>());
      final status = cubit.statusFor(testModel.id);
      expect(status.phase, equals(DownloadPhase.failed));
      expect(status.error, isNotNull);
    });
  });
}
