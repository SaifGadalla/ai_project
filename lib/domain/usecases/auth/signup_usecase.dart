import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_project/domain/repository/auth_repository.dart';

class SignupUseCase {
  final AuthRepository _repository;

  SignupUseCase(this._repository);

  Future<User?> call({required String email, required String password, String? name}) {
    return _repository.signUp(email: email, password: password, name: name);
  }
}
