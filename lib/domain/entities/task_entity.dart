/// Domain entity for a task in the task management system
class TaskEntity {
  final String id;
  final String title;
  final String? description;
  final List<String> subtasks;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? reminderTime;
  final bool isRecurring;
  final String? recurringPattern;
  final Map<String, dynamic> metadata;

  TaskEntity({
    required this.id,
    required this.title,
    this.description,
    this.subtasks = const [],
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    DateTime? createdAt,
    this.dueDate,
    this.reminderTime,
    this.isRecurring = false,
    this.recurringPattern,
    this.metadata = const {},
  }) : createdAt = createdAt ?? DateTime.now();

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? subtasks,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? reminderTime,
    bool? isRecurring,
    String? recurringPattern,
    Map<String, dynamic>? metadata,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subtasks: subtasks ?? this.subtasks,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum TaskPriority { low, medium, high, critical }

enum TaskStatus { pending, inProgress, completed, failed, archived }
