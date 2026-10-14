import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jemenai/services/cache_service.dart';
import 'package:jemenai/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // No keychain under `flutter test`; the plugin's own in-memory mock.
    FlutterSecureStorage.setMockInitialValues({});

    // Mock path_provider and sqflite method channels
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return '.';
          },
        );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('com.tekartik.sqflite'), (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'getDatabasesPath') {
            return '.';
          }
          if (methodCall.method == 'openDatabase') {
            return 1; // Mock database ID
          }
          return <dynamic>[];
        });
  });

  testWidgets('Onboarding Skip to Dashboard navigation smoke test', (
    WidgetTester tester,
  ) async {
    // Override FlutterError.onError to ignore layout overflows in tests
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('overflowed')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() {
      FlutterError.onError = originalOnError;
    });

    // Set a large screen size to avoid layout overflows in test environment
    await tester.binding.setSurfaceSize(const Size(1200, 1920));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    SharedPreferences.setMockInitialValues({});
    await CacheService.instance.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const JemenaiApp());
    await tester.pumpAndSettle();

    // Verify that our onboarding screen starts and shows the first slide title.
    expect(find.textContaining('Your AI.'), findsOneWidget);

    // Tap on the Skip button (which should mark onboarding seen and route directly to dashboard)
    final skipButton = find.text('Skip');
    expect(skipButton, findsOneWidget);
    await tester.tap(skipButton);
    await tester.pumpAndSettle();

    // Verify that we are on the dashboard/home screen by checking for Home elements
    expect(find.text('AI Text Assistant'), findsOneWidget);
  });

  testWidgets('Onboarding step-by-step navigation test', (
    WidgetTester tester,
  ) async {
    // Ignore layout overflows
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('overflowed')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() {
      FlutterError.onError = originalOnError;
    });

    await tester.binding.setSurfaceSize(const Size(1200, 1920));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    SharedPreferences.setMockInitialValues({});
    await CacheService.instance.init();

    // Build our app
    await tester.pumpWidget(const JemenaiApp());
    await tester.pumpAndSettle();

    // Slide 1: Verify first title is visible
    expect(find.textContaining('Your AI.'), findsOneWidget);

    // Click "Continue" to slide 2
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Works Without'), findsOneWidget);

    // Click "Continue" to slide 3
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('On-Device'), findsOneWidget);

    // Click "Continue" to slide 4 (last slide)
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('State-of-Art'), findsOneWidget);

    // Slide 4: Verify navigation button changes to "Get Started"
    final getStartedBtn = find.text('Get Started');
    expect(getStartedBtn, findsOneWidget);

    // Click "Get Started" to go to dashboard
    await tester.tap(getStartedBtn);
    await tester.pumpAndSettle();

    // Verify we arrived at the dashboard
    expect(find.text('AI Text Assistant'), findsOneWidget);
  });

  testWidgets(
    'Dashboard tab navigation to Settings (verifies no Sign Out button)',
    (WidgetTester tester) async {
      // Ignore layout overflows
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exception.toString().contains('overflowed')) {
          return;
        }
        originalOnError?.call(details);
      };
      addTearDown(() {
        FlutterError.onError = originalOnError;
      });

      await tester.binding.setSurfaceSize(const Size(1200, 1920));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      SharedPreferences.setMockInitialValues({});
      await CacheService.instance.init();

      // Build app and skip directly to dashboard
      await tester.pumpWidget(const JemenaiApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Find the Settings tab button in bottom nav and tap it
      final settingsTab = find.descendant(
        of: find.byType(TabBar),
        matching: find.text('Settings'),
      );
      expect(settingsTab, findsOneWidget);
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();

      // Verify settings screen sections are displayed
      expect(find.text('Privacy Controls'), findsOneWidget);
      expect(find.text('Terms & Privacy Policy'), findsOneWidget);

      // Assert that the Sign Out button is NOT rendered
      expect(find.text('Sign Out'), findsNothing);
    },
  );
}
