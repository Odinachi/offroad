import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_litertlm/flutter_edge_ai_litertlm.dart';
import 'package:flutter_edge_ai_mediapipe/flutter_edge_ai_mediapipe.dart';
import 'package:jemenai/features/ai/view_models/model_download_cubit.dart';
import 'package:jemenai/features/dashboard/view_models/app_cubit.dart';
import 'package:jemenai/services/cache_service.dart';
import 'shared/navigator/app_route_string.dart';
import 'shared/navigator/app_router.dart';
import 'shared/theme.dart';

final cacheService = CacheService.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cacheService.init();

  // Initialize flutter_edge_ai (optional HuggingFace token for gated models)
  await FlutterEdgeAi.initialize(
    // .litertlm models run on LiteRT-LM, .task models on MediaPipe.
    inferenceEngines: const [LiteRtLmEngine(), MediaPipeEngine()],
    huggingFaceToken:
        const String.fromEnvironment('HUGGINGFACE_TOKEN').isEmpty
            ? null
            : const String.fromEnvironment('HUGGINGFACE_TOKEN'),
  );

  runApp(const JemenaiApp());
}

class JemenaiApp extends StatefulWidget {
  const JemenaiApp({super.key});

  @override
  State<JemenaiApp> createState() => _JemenaiAppState();
}

class _JemenaiAppState extends State<JemenaiApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppCubit>(
          create: (context) => AppCubit(cacheService: cacheService),
        ),
        BlocProvider<ModelDownloadCubit>(
          create:
              (context) =>
                  ModelDownloadCubit(cacheService: cacheService)..init(),
        ),
      ],
      child: BlocBuilder<AppCubit, AppState>(
        buildWhen: (prev, next) => prev.themeMode != next.themeMode,
        builder: (context, state) {
          return MaterialApp(
            title: 'OffRoad',
            debugShowCheckedModeBanner: false,
            themeMode: state.themeMode,
            theme: JemenaiTheme.lightTheme(),
            darkTheme: JemenaiTheme.darkTheme(),
            navigatorKey: AppRouter.navKey,
            initialRoute:
                cacheService.getSeenOnboarding()
                    ? AppRouteString.dashboard
                    : AppRouteString.onboarding,
            onGenerateRoute: AppRouter.generateRoute,
            // By default '/dashboard' expands to ['/', '/dashboard'], and '/'
            // is onboarding — so Back from the dashboard reopened onboarding.
            onGenerateInitialRoutes:
                (name) => [AppRouter.generateRoute(RouteSettings(name: name))],
          );
        },
      ),
    );
  }
}
