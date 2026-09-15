import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';

enum LoginStatus { initial, submitting, success, error }

class LoginState extends Equatable {
  final LoginStatus status;
  final String errorMessage;

  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage = '',
  });

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService;

  LoginCubit(this._authService) : super(const LoginState());

  Future<void> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) return;

    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      await _authService.signIn(email: email, password: password);
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
