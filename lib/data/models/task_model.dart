import 'package:jarvis_lite/domain/entities/task_entity.dart';

/// Data model for Task (maps to database)
class TaskModel extends TaskEntity {
  TaskModel({
    required super.id,
    required super.title,
    super.description,
    super.subtasks,
    super.priority,
    super.status,
    super.createdAt,
    super.dueDate,
    super.reminderTime,
    super.isRecurring,
    super.recurringPattern,
    super.metadata,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      subtasks: List<String>.from(json['subtasks'] ?? []),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == 'TaskPriority.${json['priority']}',
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == 'TaskStatus.${json['status']}',
        orElse: () => TaskStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      reminderTime: json['reminderTime'] != null
          ? DateTime.parse(json['reminderTime'])
          : null,
      isRecurring: json['isRecurring'] ?? false,
      recurringPattern: json['recurringPattern'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'subtasks': subtasks,
    'priority': priority.toString().split('.').last,
    'status': status.toString().split('.').last,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'reminderTime': reminderTime?.toIso8601String(),
    'isRecurring': isRecurring,
    'recurringPattern': recurringPattern,
    'metadata': metadata,
  };
}
