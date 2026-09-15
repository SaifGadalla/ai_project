import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_screen.dart';
import '../auth/signup_screen.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/login_cubit.dart';
import '../blocs/auth/signup_cubit.dart';
import '../blocs/prompt/bloc.dart';
import '../details/day_details_screen.dart';
import '../home/home.dart';
import '../models/learning_path.dart';
import '../path/path_screen.dart';
import '../prompt/creation_screen.dart';
import '../settings/settings_screen.dart';
import '../services/auth_service.dart';
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
