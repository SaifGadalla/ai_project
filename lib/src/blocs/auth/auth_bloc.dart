import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  late final StreamSubscription _authSubscription;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(
          authService.currentUser != null
              ? AuthState.authenticated(authService.currentUser!)
              : const AuthState.unauthenticated(),
        ) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);

    _authSubscription = _authService.authStateChanges.listen((user) {
      add(AuthUserChanged(user));
    });
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthState.authenticated(event.user!));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  void _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) {
    _authService.signOut();
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
