import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemma/core/api/flutter_gemma.dart';
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

  // Initialize flutter_gemma (optional HuggingFace token for gated models)
  await FlutterGemma.initialize(
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
        builder: (context, state) {
          final isDark = context.read<AppCubit>().isDarkTheme;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            theme: JemenaiTheme.lightTheme(),
            darkTheme: JemenaiTheme.darkTheme(),
            navigatorKey: AppRouter.navKey,
            initialRoute:
                cacheService.getSeenOnboarding()
                    ? AppRouteString.dashboard
                    : AppRouteString.onboarding,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
