import 'package:ai_project/domain/repository/path_repository.dart';

class DeletePathUseCase {
  final PathRepository _repository;

  DeletePathUseCase(this._repository);

  Future<void> call(String userId, String pathId) {
    return _repository.deletePath(userId, pathId);
  }
}
