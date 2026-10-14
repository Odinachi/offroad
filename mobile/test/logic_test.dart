import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jemenai/features/ai/model/ai_model.dart';
import 'package:jemenai/features/ai/model/chat_message.dart';
import 'package:jemenai/features/ai/view_models/model_download_cubit.dart';
import 'package:jemenai/features/ai/views/chat_screen.dart';
import 'package:jemenai/features/dashboard/view_models/app_cubit.dart';
import 'package:jemenai/services/cache_service.dart';
import 'package:jemenai/services/chat_engine.dart';
import 'package:jemenai/shared/ui_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AIModel', () {
    test('contextTokens follows the compiled KV-cache size when named', () {
      final gemma3 = findModelByName('Gemma3 1B')!;
      expect(gemma3.fileName, contains('ekv1280'));
      expect(gemma3.contextTokens, 1280);

      final phi = findModelByName('Phi-4-mini-instruct')!;
      expect(phi.contextTokens, 4096);

      final gemma4 = findModelByName('Gemma 4 E2B')!;
      expect(gemma4.contextTokens, 2048);
    });

    test('capability helpers reflect modalities', () {
      final gemma4 = findModelByName('Gemma 4 E2B')!;
      expect(gemma4.supportsImage, isTrue);
      expect(gemma4.supportsAudio, isTrue);
      expect(gemma4.canThink, isTrue);

      final smol = findModelByName('SmolLM 135M Instruct')!;
      expect(smol.supportsImage, isFalse);
      expect(smol.supportsAudio, isFalse);
      expect(smol.canThink, isFalse);
    });

    test('findModelByName returns null for unknown or null names', () {
      expect(findModelByName('Llama 3.2 3B'), isNull);
      expect(findModelByName(null), isNull);
    });

    test(
      'gated Hugging Face repos are flagged so the store asks for a token',
      () {
        // Verified 2026-10-10: these return HTTP 401 without a token.
        final gated =
            models
                .where((m) => m.requiresAuth == true)
                .map((m) => m.name)
                .toSet();
        expect(gated, {
          'Gemma 3n E2B',
          'Gemma 3n E4B',
          'Gemma3 1B',
          'Gemma3 270M',
        });
      },
    );

    test('model ids are unique', () {
      final ids = models.map((m) => m.id).toSet();
      expect(ids.length, models.length);
    });
  });

  group('ChatMessage.fromRow', () {
    test('maps database rows including reasoning', () {
      final message = ChatMessage.fromRow({
        'id': 'a',
        'role': 'assistant',
        'content': 'Hi',
        'thinking': 'Greet them.',
        'createdAt': 0,
      });
      expect(message.isUser, isFalse);
      expect(message.thinking, 'Greet them.');
      expect(message.ts, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('tolerates a null content column', () {
      final message = ChatMessage.fromRow({
        'id': 'b',
        'role': 'user',
        'content': null,
        'createdAt': 0,
      });
      expect(message.content, '');
      expect(message.isUser, isTrue);
    });
  });

  group('chatTitleFor', () {
    test('uses "Image" for image-only messages', () {
      expect(chatTitleFor('   '), 'Image');
    });

    test('collapses whitespace and keeps short titles intact', () {
      expect(chatTitleFor('Hello\n  there'), 'Hello there');
    });

    test('cuts long titles at a word boundary', () {
      final title = chatTitleFor(
        'Explain how transformers use attention to model long sequences',
      );
      expect(title.endsWith('…'), isTrue);
      expect(title.length, lessThanOrEqualTo(41));
      expect(title, 'Explain how transformers use attention…');
    });
  });

  group('timeAgo', () {
    final now = DateTime(2026, 10, 7, 12);

    test('recent times', () {
      expect(
        timeAgo(now.subtract(const Duration(seconds: 20)), now: now),
        'Just now',
      );
      expect(
        timeAgo(now.subtract(const Duration(minutes: 5)), now: now),
        '5m ago',
      );
      expect(
        timeAgo(now.subtract(const Duration(hours: 3)), now: now),
        '3h ago',
      );
      expect(
        timeAgo(now.subtract(const Duration(days: 2)), now: now),
        '2d ago',
      );
    });

    test('older dates show the date', () {
      expect(timeAgo(DateTime(2026, 9, 1), now: now), 'Sep 1');
      expect(timeAgo(DateTime(2025, 12, 25), now: now), 'Dec 25, 2025');
    });
  });

  group('error messages', () {
    test('download errors are actionable', () {
      expect(
        ModelDownloadCubit.describeDownloadError(Exception('HTTP 401')),
        contains('Hugging Face Token'),
      );
      expect(
        ModelDownloadCubit.describeDownloadError(
          Exception('SocketException: Failed host lookup'),
        ),
        contains('Network problem'),
      );
      expect(
        ModelDownloadCubit.describeDownloadError(Exception('ENOSPC')),
        contains('storage'),
      );
    });

    test('engine errors are actionable', () {
      final model = models.first;
      expect(
        ChatEngine.describeError(ModelNotInstalledException(model)),
        contains('Models tab'),
      );
      expect(
        ChatEngine.describeError(Exception('Not supported on Simulator')),
        contains('physical device'),
      );
    });
  });

  group('Hugging Face token storage', () {
    test(
      'moves a plaintext token from older versions into secure storage',
      () async {
        SharedPreferences.setMockInitialValues({
          'huggingFaceToken': 'hf_legacy',
        });
        FlutterSecureStorage.setMockInitialValues({});
        await CacheService.instance.init();

        expect(CacheService.instance.getHuggingFaceToken(), 'hf_legacy');
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('huggingFaceToken'), isNull);
        expect(
          await const FlutterSecureStorage().read(key: 'huggingFaceToken'),
          'hf_legacy',
        );
      },
    );

    test('saves to secure storage only, and empty removes it', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final cache = CacheService.instance;
      await cache.init();

      await cache.saveHuggingFaceToken('hf_new');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('huggingFaceToken'), isNull);
      expect(
        await const FlutterSecureStorage().read(key: 'huggingFaceToken'),
        'hf_new',
      );

      await cache.saveHuggingFaceToken('');
      expect(cache.getHuggingFaceToken(), isNull);
      expect(
        await const FlutterSecureStorage().read(key: 'huggingFaceToken'),
        isNull,
      );
    });

    test('an existing secure token wins over a stale legacy copy', () async {
      SharedPreferences.setMockInitialValues({'huggingFaceToken': 'hf_old'});
      FlutterSecureStorage.setMockInitialValues({
        'huggingFaceToken': 'hf_current',
      });
      await CacheService.instance.init();

      expect(CacheService.instance.getHuggingFaceToken(), 'hf_current');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('huggingFaceToken'), isNull);
    });
  });

  group('ChatEngine.normalizeReply', () {
    test('turns literal \\n in prose into line breaks', () {
      expect(ChatEngine.normalizeReply(r'First.\nSecond.'), 'First.\nSecond.');
    });

    test('leaves code blocks and inline code alone', () {
      const reply = 'Use `printf("\\n")`.\\n```c\nputs("a\\nb");\n```';
      final out = ChatEngine.normalizeReply(reply);
      expect(out, contains('`printf("\\n")`'));
      expect(out, contains('puts("a\\nb");'));
      expect(out, contains('.\n```c'));
    });

    test('repairs UTF-8 that arrived as Latin-1 characters', () {
      expect(ChatEngine.normalizeReply('CafÃ© da Lua'), 'Café da Lua');
      expect(ChatEngine.normalizeReply('naÃ¯ve Ã¼ber'), 'naïve über');
      // A 4-byte emoji (🌈 = F0 9F 8C 88).
      expect(
        ChatEngine.normalizeReply('Rainbow \u00F0\u009F\u008C\u0088'),
        'Rainbow 🌈',
      );
    });

    test('leaves correctly decoded accents alone', () {
      const text = 'Café, São Paulo, Zürich — déjà vu';
      expect(ChatEngine.normalizeReply(text), text);
    });

    test('returns text without escapes unchanged', () {
      const reply = 'Plain reply.\nWith a real break.';
      expect(ChatEngine.normalizeReply(reply), same(reply));
    });
  });

  group('AppCubit theme', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await CacheService.instance.init();
    });

    test('follows the system until the user chooses', () {
      final cubit = AppCubit(cacheService: CacheService.instance);
      expect(cubit.state.themeMode, ThemeMode.system);
      expect(CacheService.instance.getIsDarkMode(), isNull);
    });

    test('every toggle emits a new state', () async {
      // The old state used a random prop, so ~1 in 10 toggles produced an
      // "equal" state that bloc swallowed and the theme didn't change.
      final cubit = AppCubit(cacheService: CacheService.instance);
      final emitted = <AppState>[];
      final sub = cubit.stream.listen(emitted.add);
      for (var i = 0; i < 20; i++) {
        cubit.toggleTheme();
      }
      await Future<void>.delayed(Duration.zero);
      expect(emitted, hasLength(20));
      await sub.cancel();
    });

    test('engine changes are part of state', () async {
      final cubit = AppCubit(cacheService: CacheService.instance);
      await cubit.saveInferenceEngine('gpu');
      expect(cubit.state.inferenceEngine, 'gpu');
      expect(
        cubit.state,
        isNot(
          AppState(themeMode: cubit.state.themeMode, inferenceEngine: 'cpu'),
        ),
      );
    });
  });
}
