import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String title;
  final bool isCompleted;

  Task({required this.title, required this.isCompleted});

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class DayPlan {
  final int dayNumber;
  final String title;
  final List<Task> tasks;

  DayPlan({required this.dayNumber, required this.title, required this.tasks});

  factory DayPlan.fromMap(Map<String, dynamic> map) {
    return DayPlan(
      dayNumber: map['dayNumber'] ?? 1,
      title: map['title'] ?? '',
      tasks: (map['tasks'] as List<dynamic>?)
              ?.map((t) => Task.fromMap(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LearningPath {
  final String id;
  final String title;
  final String description;
  final DateTime? createdAt;
  final List<DayPlan> days;

  LearningPath({
    required this.id,
    required this.title,
    required this.description,
    this.createdAt,
    required this.days,
  });

  factory LearningPath.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LearningPath(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      days: (data['days'] as List<dynamic>?)
              ?.map((d) => DayPlan.fromMap(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
