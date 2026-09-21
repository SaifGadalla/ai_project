import 'package:ai_project/data/models/learning_path.dart';
import 'package:ai_project/domain/repository/path_repository.dart';

class GetPathStreamUseCase {
  final PathRepository _repository;

  GetPathStreamUseCase(this._repository);

  Stream<LearningPath?> call(String userId, String pathId) {
    return _repository.getPathStream(userId, pathId);
  }
}
