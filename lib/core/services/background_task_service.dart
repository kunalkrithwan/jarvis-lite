import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:jarvis_lite/features/tasks/task_manager_service.dart';

/// Background Task Service
/// Handles scheduled background tasks using WorkManager
/// - Task reminders
/// - Daily task planning
/// - Battery-optimized background processing
abstract class BackgroundTaskService {
  /// Initialize background task scheduler
  Future<void> initialize();

  /// Register periodic task for daily task planning
  Future<void> registerDailyTaskPlanning();

  /// Register one-time task for reminder
  Future<void> registerReminder(String taskId, DateTime reminderTime);

  /// Cancel specific task
  Future<void> cancelTask(String taskName);

  /// Cancel all tasks
  Future<void> cancelAllTasks();

  /// Check if task is scheduled
  Future<bool> isTaskScheduled(String taskName);
}

/// Task names for WorkManager
class TaskNames {
  static const String dailyTaskPlanning = 'dailyTaskPlanning';
  static const String taskReminderPrefix = 'taskReminder_';
  static const String batteryOptimization = 'batteryOptimization';
}

/// Default implementation using WorkManager
class DefaultBackgroundTaskService implements BackgroundTaskService {
  final TaskManagerService _taskManager;
  bool _isInitialized = false;

  DefaultBackgroundTaskService(this._taskManager);

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Workmanager().initialize(
        _callbackDispatcher,
        isInDebugMode: kDebugMode,
      );
      _isInitialized = true;
    } catch (e) {
      print('Error initializing WorkManager: $e');
    }
  }

  @override
  Future<void> registerDailyTaskPlanning() async {
    if (!_isInitialized) await initialize();

    try {
      await Workmanager().registerPeriodicTask(
        TaskNames.dailyTaskPlanning,
        TaskNames.dailyTaskPlanning,
        frequency: const Duration(hours: 24),
        initialDelay: const Duration(minutes: 5),
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
    } catch (e) {
      print('Error registering daily task planning: $e');
    }
  }

  @override
  Future<void> registerReminder(String taskId, DateTime reminderTime) async {
    if (!_isInitialized) await initialize();

    try {
      final taskName = '${TaskNames.taskReminderPrefix}$taskId';
      final delay = reminderTime.difference(DateTime.now());

      if (delay.isNegative) {
        print('Reminder time is in the past, skipping');
        return;
      }

      await Workmanager().registerOneOffTask(
        taskName,
        taskName,
        initialDelay: delay,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        inputData: {'taskId': taskId},
      );
    } catch (e) {
      print('Error registering reminder: $e');
    }
  }

  @override
  Future<void> cancelTask(String taskName) async {
    try {
      await Workmanager().cancelTaskByName(taskName);
    } catch (e) {
      print('Error canceling task: $e');
    }
  }

  @override
  Future<void> cancelAllTasks() async {
    try {
      await Workmanager().cancelAll();
    } catch (e) {
      print('Error canceling all tasks: $e');
    }
  }

  @override
  Future<bool> isTaskScheduled(String taskName) async {
    // WorkManager doesn't provide a direct way to check scheduled tasks
    // This is a placeholder implementation
    return false;
  }
}

/// Callback dispatcher for WorkManager
/// This function is called by WorkManager when a task is triggered
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case TaskNames.dailyTaskPlanning:
        return _handleDailyTaskPlanning();
      case String when task.startsWith(TaskNames.taskReminderPrefix):
        return _handleTaskReminder(inputData);
      default:
        return false;
    }
  });
}

/// Handle daily task planning
Future<bool> _handleDailyTaskPlanning() async {
  try {
    // In production, this would:
    // 1. Check tasks due today
    // 2. Send notifications for reminders
    // 3. Update task priorities based on due dates
    // 4. Clean up completed tasks
    
    print('Daily task planning executed');
    return true;
  } catch (e) {
    print('Error in daily task planning: $e');
    return false;
  }
}

/// Handle task reminder
Future<bool> _handleTaskReminder(Map<dynamic, dynamic>? inputData) async {
  try {
    final taskId = inputData?['taskId'] as String?;
    if (taskId == null) return false;

    // In production, this would:
    // 1. Show notification for the task
    // 2. Play sound if enabled
    // 3. Update task status if needed
    
    print('Task reminder executed for task: $taskId');
    return true;
  } catch (e) {
    print('Error in task reminder: $e');
    return false;
  }
}
