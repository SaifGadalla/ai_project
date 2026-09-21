import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_project/domain/repository/auth_repository.dart';

class GetAuthStateUseCase {
  final AuthRepository _repository;

  GetAuthStateUseCase(this._repository);

  Stream<User?> get authStateChanges => _repository.authStateChanges;
  User? get currentUser => _repository.currentUser;
}
