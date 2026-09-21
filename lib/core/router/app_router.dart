import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_project/presentation/screens/auth/auth_screen.dart';
import 'package:ai_project/presentation/screens/auth/signup_screen.dart';
import 'package:ai_project/presentation/controller/auth/auth_bloc.dart';
import 'package:ai_project/presentation/controller/auth/login_cubit.dart';
import 'package:ai_project/presentation/controller/auth/signup_cubit.dart';
import 'package:ai_project/presentation/controller/prompt/bloc.dart';
import 'package:ai_project/presentation/screens/details/day_details_screen.dart';
import 'package:ai_project/presentation/screens/home/home.dart';
import 'package:ai_project/presentation/screens/path/path_screen.dart';
import 'package:ai_project/presentation/screens/prompt/creation_screen.dart';
import 'package:ai_project/presentation/screens/settings/settings_screen.dart';
import 'package:ai_project/domain/usecases/auth/login_usecase.dart';
import 'package:ai_project/domain/usecases/auth/signup_usecase.dart';
import 'package:ai_project/domain/usecases/auth/get_auth_state_usecase.dart';
import 'package:ai_project/domain/usecases/path/save_generated_path_usecase.dart';
import 'package:ai_project/domain/usecases/path/get_path_stream_usecase.dart';
import 'package:ai_project/domain/usecases/path/delete_path_usecase.dart';
import 'package:ai_project/presentation/controller/path/path_cubit.dart';
import 'package:ai_project/data/datasource/firebase_ai_repository.dart';
import 'package:ai_project/l10n/app_localizations.dart';
import 'go_router_refresh_stream.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final isAuthenticated = authBloc.state.status == AuthStatus.authenticated;
      final isGoingToAuth =
          state.matchedLocation == '/auth' ||
          state.matchedLocation == '/signup';

      if (!isAuthenticated && !isGoingToAuth) {
        return '/auth';
      }

      if (isAuthenticated && isGoingToAuth) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => BlocProvider(
          create: (context) => LoginCubit(context.read<LoginUseCase>()),
          child: const AuthScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => BlocProvider(
          create: (context) => SignupCubit(context.read<SignupUseCase>()),
          child: const SignupScreen(),
        ),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/creation',
        builder: (context, state) {
          final localizations = AppLocalizations.of(context)!;
          return BlocProvider(
            create: (context) => CreationBloc(
              localizations: localizations,
              aiRepository: FirebaseAiRepository(),
              saveGeneratedPathUseCase: context
                  .read<SaveGeneratedPathUseCase>(),
              getAuthStateUseCase: context.read<GetAuthStateUseCase>(),
            ),
            child: const CreationScreen(),
          );
        },
      ),
      GoRoute(
        path: '/path/:pathId',
        builder: (context, state) {
          final pathId = state.pathParameters['pathId']!;
          return BlocProvider(
            create: (context) => PathCubit(
              pathId: pathId,
              getPathStreamUseCase: context.read<GetPathStreamUseCase>(),
              deletePathUseCase: context.read<DeletePathUseCase>(),
              getAuthStateUseCase: context.read<GetAuthStateUseCase>(),
            ),
            child: PathScreen(pathId: pathId),
          );
        },
      ),
      GoRoute(
        path: '/day_details',
        builder: (context, state) {
          final args = state.extra as DayDetailsArgs;
          return DayDetailsScreen(
            day: args.dayPlan,
            pathId: args.pathId,
            dayIndex: args.dayIndex,
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
