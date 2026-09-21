import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_project/domain/repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<User?> call({required String email, required String password}) {
    return _repository.signIn(email: email, password: password);
  }
}
