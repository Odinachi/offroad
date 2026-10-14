import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jemenai/features/ai/view_models/model_download_cubit.dart';
import 'package:jemenai/features/ai/views/models_store_screen.dart';
import 'package:jemenai/features/dashboard/views/dashboard.dart';
import 'package:jemenai/features/ai/views/chat_screen.dart';
import 'package:jemenai/features/ai/views/voice_chat_screen.dart';
import 'package:jemenai/features/dashboard/view_models/app_cubit.dart';
import 'package:jemenai/main.dart';
import 'package:jemenai/services/cache_service.dart';
import 'package:jemenai/shared/navigator/app_router.dart';
import 'package:jemenai/shared/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// No plugins exist under `flutter test`; answer their channels so screens
/// behave as on a device with nothing downloaded and an empty database.
void _mockPlatform() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (_) async => '.',
  );
  messenger.setMockMethodCallHandler(
    const MethodChannel('com.tekartik.sqflite'),
    (call) async {
      if (call.method == 'getDatabasesPath') return '.';
      if (call.method == 'openDatabase') return 1;
      return <dynamic>[];
    },
  );
}

Future<void> _setUp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1200, 2400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  SharedPreferences.setMockInitialValues({'seenOnboarding': true});
  FlutterSecureStorage.setMockInitialValues({});
  await CacheService.instance.init();
}

Widget _wrap(Widget child) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => AppCubit(cacheService: CacheService.instance),
      ),
      BlocProvider(
        create:
            (_) =>
                ModelDownloadCubit(cacheService: CacheService.instance)..init(),
      ),
    ],
    child: MaterialApp(
      navigatorKey: AppRouter.navKey,
      theme: JemenaiTheme.lightTheme(),
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_mockPlatform);

  testWidgets('Home nudges first-time users to download a model', (
    tester,
  ) async {
    await _setUp(tester);
    await tester.pumpWidget(const JemenaiApp());
    await tester.pumpAndSettle();

    expect(find.text('Download your first model'), findsOneWidget);
    expect(
      find.textContaining('Your conversations will appear here'),
      findsOneWidget,
    );
  });

  testWidgets('Quick action without a suitable model explains what to do', (
    tester,
  ) async {
    await _setUp(tester);
    await tester.pumpWidget(const JemenaiApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pic-to-Text'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Pic-to-Text needs an image-capable model. Download one first.',
      ),
      findsOneWidget,
    );

    // "Store" switches tabs in place instead of stacking a second dashboard.
    await tester.tap(find.text('Store'));
    await tester.pumpAndSettle();
    expect(AppRouter.dashboardTab.value, AppRouter.modelsTab);
    expect(find.byType(Dashboard), findsOneWidget);
    expect(find.byType(ModelsStoreScreen), findsOneWidget);
  });

  testWidgets('Settings shows the privacy summary and real controls', (
    tester,
  ) async {
    await _setUp(tester);
    await tester.pumpWidget(const JemenaiApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text('Settings')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Delete All Conversations'), findsOneWidget);
    expect(find.textContaining('iPhone 15 Pro'), findsNothing);

    await tester.tap(find.text('Privacy Controls'));
    await tester.pumpAndSettle();
    expect(find.text('Your privacy'), findsOneWidget);
    expect(find.text('No accounts, analytics or tracking'), findsOneWidget);
  });

  testWidgets('Storage breakdown is never a blank bar', (tester) async {
    await _setUp(tester);
    await tester.pumpWidget(const JemenaiApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text('Storage')),
    );
    // The measuring indicator animates indefinitely; don't wait to settle.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Either still measuring (with a label) or the explicit empty state —
    // previously this card rendered an empty grey bar indefinitely.
    final measuring = find.text('Measuring what OffRoad stores…');
    final empty = find.text('No models downloaded yet');
    expect(
      measuring.evaluate().isNotEmpty || empty.evaluate().isNotEmpty,
      isTrue,
    );
  });

  testWidgets('Chat with a model that is not downloaded never downloads it', (
    tester,
  ) async {
    await _setUp(tester);
    await tester.pumpWidget(
      _wrap(const ChatScreen(args: ChatScreenArg(modelName: 'Gemma3 270M'))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gemma3 270M isn\'t downloaded'), findsOneWidget);
    expect(find.text('Open Model Store'), findsOneWidget);
    expect(find.text('Not downloaded'), findsOneWidget);
  });

  testWidgets('Chat pre-fills a draft without sending it', (tester) async {
    await _setUp(tester);
    await tester.pumpWidget(
      _wrap(
        const ChatScreen(
          args: ChatScreenArg(
            modelName: 'Gemma3 270M',
            draft: 'Brainstorm 10 creative ideas for ',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'Brainstorm 10 creative ideas for ');
  });

  testWidgets('Voice mode asks for an audio model instead of faking replies', (
    tester,
  ) async {
    await _setUp(tester);
    await tester.pumpWidget(_wrap(const VoiceChatScreen()));
    // The orb animates continuously, so pump a fixed time instead of settling.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Download a voice-capable model'), findsOneWidget);
    expect(find.text('Llama 3.2 3B'), findsNothing);
  });
}
