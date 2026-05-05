import 'package:uuid/uuid.dart';
import 'package:jarvis_lite/domain/entities/task_entity.dart';
import 'package:jarvis_lite/data/local/app_database.dart';
import 'package:jarvis_lite/data/models/task_model.dart';

/// Task Manager Service
/// Handles:
/// - Task creation and management
/// - Task scheduling
/// - Task execution
/// - Reminder management
/// - Background task processing
abstract class TaskManagerService {
  /// Create a new task
  Future<TaskEntity> createTask({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    List<String> subtasks = const [],
    bool isRecurring = false,
    String? recurringPattern,
  });

  /// Get all tasks
  Future<List<TaskEntity>> getAllTasks();

  /// Get active tasks
  Future<List<TaskEntity>> getActiveTasks();

  /// Get tasks for today
  Future<List<TaskEntity>> getTasksForToday();

  /// Get task by ID
  Future<TaskEntity?> getTaskById(String id);

  /// Update task
  Future<void> updateTask(TaskEntity task);

  /// Complete task
  Future<void> completeTask(String id);

  /// Delete task
  Future<void> deleteTask(String id);

  /// Set task reminder
  Future<void> setTaskReminder(String id, DateTime reminderTime);

  /// Mark task as started
  Future<void> markTaskAsStarted(String id);

  /// Get upcoming tasks
  Future<List<TaskEntity>> getUpcomingTasks({int days = 7});
}

/// Default implementation
class DefaultTaskManagerService implements TaskManagerService {
  final LocalTaskRepository _repository;

  const DefaultTaskManagerService(this._repository);

  @override
  Future<TaskEntity> createTask({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    List<String> subtasks = const [],
    bool isRecurring = false,
    String? recurringPattern,
  }) async {
    const uuid = Uuid();
    final task = TaskModel(
      id: uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      subtasks: subtasks,
      isRecurring: isRecurring,
      recurringPattern: recurringPattern,
    );

    await _repository.saveTask(task);
    return task;
  }

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    return _repository.getAllTasks();
  }

  @override
  Future<List<TaskEntity>> getActiveTasks() async {
    return _repository.getActiveTasks();
  }

  @override
  Future<List<TaskEntity>> getTasksForToday() async {
    return _repository.getTasksDueToday();
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    // Fetch from repository
    final tasks = await _repository.getAllTasks();
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    if (task is TaskModel) {
      await _repository.updateTask(task);
    }
  }

  @override
  Future<void> completeTask(String id) async {
    final task = await getTaskById(id);
    if (task != null) {
      final updatedTask = task.copyWith(status: TaskStatus.completed);
      if (updatedTask is TaskModel) {
        await _repository.updateTask(updatedTask);
      }
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
  }

  @override
  Future<void> setTaskReminder(String id, DateTime reminderTime) async {
    final task = await getTaskById(id);
    if (task != null) {
      final updatedTask = task.copyWith(reminderTime: reminderTime);
      if (updatedTask is TaskModel) {
        await _repository.updateTask(updatedTask);
      }
    }
  }

  @override
  Future<void> markTaskAsStarted(String id) async {
    final task = await getTaskById(id);
    if (task != null) {
      final updatedTask = task.copyWith(status: TaskStatus.inProgress);
      if (updatedTask is TaskModel) {
        await _repository.updateTask(updatedTask);
      }
    }
  }

  @override
  Future<List<TaskEntity>> getUpcomingTasks({int days = 7}) async {
    final allTasks = await getActiveTasks();
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    return allTasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.isAfter(now) && task.dueDate!.isBefore(futureDate);
    }).toList()..sort(
      (a, b) =>
          (a.dueDate ?? DateTime.now()).compareTo(b.dueDate ?? DateTime.now()),
    );
  }
}
