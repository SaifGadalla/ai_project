import 'package:ai_project/data/models/learning_path.dart';

abstract class PathRepository {
  Future<String> savePath({
    required String userId,
    required Map<String, dynamic> pathData,
    required String originalPrompt,
  });

  Stream<List<LearningPath>> getUserPathsStream(String userId);

  Stream<LearningPath?> getPathStream(String userId, String pathId);

  Future<void> deletePath(String userId, String pathId);

  Future<void> updateTaskStatus({
    required String userId,
    required String pathId,
    required int dayIndex,
    required int taskIndex,
    required bool isCompleted,
  });
}
