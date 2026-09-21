import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_project/domain/usecases/auth/get_auth_state_usecase.dart';
import 'package:ai_project/domain/usecases/auth/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetAuthStateUseCase _getAuthStateUseCase;
  final LogoutUseCase _logoutUseCase;
  late final StreamSubscription _authSubscription;

  AuthBloc({
    required GetAuthStateUseCase getAuthStateUseCase,
    required this._logoutUseCase,
  }) : _getAuthStateUseCase = getAuthStateUseCase,
       super(
         getAuthStateUseCase.currentUser != null
             ? AuthState.authenticated(getAuthStateUseCase.currentUser!)
             : const AuthState.unauthenticated(),
       ) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);

    _authSubscription = _getAuthStateUseCase.authStateChanges.listen((user) {
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

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logoutUseCase();
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
