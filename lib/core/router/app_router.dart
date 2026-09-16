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
import 'package:ai_project/data/models/learning_path.dart';
import 'package:ai_project/presentation/screens/path/path_screen.dart';
import 'package:ai_project/presentation/screens/prompt/creation_screen.dart';
import 'package:ai_project/presentation/screens/settings/settings_screen.dart';
import 'package:ai_project/data/datasource/auth_service.dart';
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
          create: (context) => LoginCubit(context.read<AuthService>()),
          child: const AuthScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => BlocProvider(
          create: (context) => SignupCubit(context.read<AuthService>()),
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
            ),
            child: const CreationScreen(),
          );
        },
      ),
      GoRoute(
        path: '/path/:pathId',
        builder: (context, state) {
          final pathId = state.pathParameters['pathId']!;
          return PathScreen(pathId: pathId);
        },
      ),
      GoRoute(
        path: '/day_details',
        builder: (context, state) {
          final day = state.extra as DayPlan;
          return DayDetailsScreen(day: day);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
