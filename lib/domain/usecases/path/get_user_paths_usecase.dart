import 'package:ai_project/data/models/learning_path.dart';
import 'package:ai_project/domain/repository/path_repository.dart';

class GetUserPathsUseCase {
  final PathRepository _repository;

  GetUserPathsUseCase(this._repository);

  Stream<List<LearningPath>> call(String userId) {
    return _repository.getUserPathsStream(userId);
  }
}
