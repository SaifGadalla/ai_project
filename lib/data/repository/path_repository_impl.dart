import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_project/domain/repository/path_repository.dart';
import 'package:ai_project/data/models/learning_path.dart';

class PathRepositoryImpl implements PathRepository {
  final FirebaseFirestore _firestore;

  PathRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> savePath({
    required String userId,
    required Map<String, dynamic> pathData,
    required String originalPrompt,
  }) async {
    pathData['createdAt'] = FieldValue.serverTimestamp();
    pathData['userId'] = userId;
    pathData['originalPrompt'] = originalPrompt;

    final docRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('paths')
        .add(pathData);

    return docRef.id;
  }

  @override
  Stream<List<LearningPath>> getUserPathsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('paths')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LearningPath.fromDocument(doc))
            .toList());
  }

  @override
  Stream<LearningPath?> getPathStream(String userId, String pathId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('paths')
        .doc(pathId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return LearningPath.fromDocument(snapshot);
      }
      return null;
    });
  }

  @override
  Future<void> deletePath(String userId, String pathId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('paths')
        .doc(pathId)
        .delete();
  }

  @override
  Future<void> updateTaskStatus({
    required String userId,
    required String pathId,
    required int dayIndex,
    required int taskIndex,
    required bool isCompleted,
  }) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('paths')
        .doc(pathId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      final days = data['days'] as List<dynamic>?;
      if (days == null) return;

      if (dayIndex >= 0 && dayIndex < days.length) {
        final day = days[dayIndex] as Map<String, dynamic>;
        final tasks = day['tasks'] as List<dynamic>?;
        if (tasks != null && taskIndex >= 0 && taskIndex < tasks.length) {
          final task = tasks[taskIndex] as Map<String, dynamic>;
          task['isCompleted'] = isCompleted;

          transaction.update(docRef, {'days': days});
        }
      }
    });
  }
}
