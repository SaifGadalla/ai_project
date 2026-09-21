import 'package:ai_project/domain/repository/path_repository.dart';

class UpdateTaskStatusUseCase {
  final PathRepository _repository;

  UpdateTaskStatusUseCase(this._repository);

  Future<void> call({
    required String userId,
    required String pathId,
    required int dayIndex,
    required int taskIndex,
    required bool isCompleted,
  }) {
    return _repository.updateTaskStatus(
      userId: userId,
      pathId: pathId,
      dayIndex: dayIndex,
      taskIndex: taskIndex,
      isCompleted: isCompleted,
    );
  }
}
