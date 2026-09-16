import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_project/data/datasource/auth_service.dart';

enum SignupStatus { initial, submitting, success, error }

class SignupState extends Equatable {
  final SignupStatus status;
  final String errorMessage;

  const SignupState({
    this.status = SignupStatus.initial,
    this.errorMessage = '',
  });

  SignupState copyWith({
    SignupStatus? status,
    String? errorMessage,
  }) {
    return SignupState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

class SignupCubit extends Cubit<SignupState> {
  final AuthService _authService;

  SignupCubit(this._authService) : super(const SignupState());

  Future<void> signupWithCredentials({
    required String name,
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) return;

    emit(state.copyWith(status: SignupStatus.submitting));
    try {
      await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );
      emit(state.copyWith(status: SignupStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: SignupStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
