import 'package:ai_project/domain/repository/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<void> call() {
    return _repository.signOut();
  }
}
