import 'package:ai_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:ai_project/presentation/controller/theme/theme_cubit.dart';
import 'package:ai_project/presentation/controller/locale/locale_cubit.dart';
import 'package:ai_project/presentation/controller/auth/auth_bloc.dart';
import 'package:ai_project/data/datasource/auth_service.dart';
import 'package:ai_project/domain/repository/auth_repository.dart';
import 'package:ai_project/domain/usecases/auth/get_auth_state_usecase.dart';
import 'package:ai_project/domain/usecases/auth/logout_usecase.dart';
import 'package:ai_project/domain/usecases/auth/login_usecase.dart';
import 'package:ai_project/domain/usecases/auth/signup_usecase.dart';
import 'package:ai_project/presentation/controller/path/paths_cubit.dart';
import 'package:ai_project/domain/repository/path_repository.dart';
import 'package:ai_project/data/repository/path_repository_impl.dart';
import 'package:ai_project/domain/usecases/path/get_user_paths_usecase.dart';
import 'package:ai_project/domain/usecases/path/save_generated_path_usecase.dart';
import 'package:ai_project/domain/usecases/path/get_path_stream_usecase.dart';
import 'package:ai_project/domain/usecases/path/delete_path_usecase.dart';
import 'package:ai_project/domain/usecases/path/update_task_status_usecase.dart';
import 'package:ai_project/core/router/app_router.dart';
import 'package:ai_project/core/utils/theme_manager.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    providerAndroid: AndroidDebugProvider(),
    providerApple: AppleDebugProvider(),
  );

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.message}');
  });

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthService(),
        ),
        RepositoryProvider<GetAuthStateUseCase>(
          create: (context) => GetAuthStateUseCase(context.read<AuthRepository>()),
        ),
        RepositoryProvider<LogoutUseCase>(
          create: (context) => LogoutUseCase(context.read<AuthRepository>()),
        ),
        RepositoryProvider<LoginUseCase>(
          create: (context) => LoginUseCase(context.read<AuthRepository>()),
        ),
        RepositoryProvider<SignupUseCase>(
          create: (context) => SignupUseCase(context.read<AuthRepository>()),
        ),
        RepositoryProvider<PathRepository>(
          create: (_) => PathRepositoryImpl(),
        ),
        RepositoryProvider<GetUserPathsUseCase>(
          create: (context) => GetUserPathsUseCase(context.read<PathRepository>()),
        ),
        RepositoryProvider<SaveGeneratedPathUseCase>(
          create: (context) => SaveGeneratedPathUseCase(context.read<PathRepository>()),
        ),
        RepositoryProvider<GetPathStreamUseCase>(
          create: (context) => GetPathStreamUseCase(context.read<PathRepository>()),
        ),
        RepositoryProvider<DeletePathUseCase>(
          create: (context) => DeletePathUseCase(context.read<PathRepository>()),
        ),
        RepositoryProvider<UpdateTaskStatusUseCase>(
          create: (context) => UpdateTaskStatusUseCase(context.read<PathRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(
          create: (_) => AuthBloc(
            getAuthStateUseCase: context.read<GetAuthStateUseCase>(),
            logoutUseCase: context.read<LogoutUseCase>(),
          ),
        ),
        BlocProvider(
          create: (context) => PathsCubit(
            context.read<GetUserPathsUseCase>(),
            context.read<GetAuthStateUseCase>(),
          ),
        ),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(context.read<AuthBloc>());
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      themeMode: themeMode,
      theme: ThemeManager.lightTheme,
      darkTheme: ThemeManager.darkTheme,
      routerConfig: _router,
    );
  }
}
