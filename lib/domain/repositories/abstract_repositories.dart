/// Abstract repository for commands
abstract class CommandRepository {
  /// Get all commands
  Future<List<dynamic>> getAllCommands();

  /// Get command by ID
  Future<dynamic?> getCommandById(String id);

  /// Save command
  Future<void> saveCommand(dynamic command);

  /// Delete command
  Future<void> deleteCommand(String id);

  /// Get recent commands (limit: last N commands)
  Future<List<dynamic>> getRecentCommands(int limit);

  /// Clear all commands
  Future<void> clearAllCommands();
}

/// Abstract repository for tasks
abstract class TaskRepository {
  /// Get all tasks
  Future<List<dynamic>> getAllTasks();

  /// Get tasks by status
  Future<List<dynamic>> getTasksByStatus(String status);

  /// Get active tasks
  Future<List<dynamic>> getActiveTasks();

  /// Save task
  Future<void> saveTask(dynamic task);

  /// Update task
  Future<void> updateTask(dynamic task);

  /// Delete task
  Future<void> deleteTask(String id);

  /// Get tasks due today
  Future<List<dynamic>> getTasksDueToday();
}

/// Abstract repository for context memory
abstract class ContextMemoryRepository {
  /// Get memory by key
  Future<dynamic?> getMemory(String key);

  /// Save memory
  Future<void> saveMemory(String key, dynamic value, {DateTime? expiresAt});

  /// Delete memory
  Future<void> deleteMemory(String key);

  /// Get all memories
  Future<Map<String, dynamic>> getAllMemories();

  /// Clear expired memories
  Future<void> clearExpiredMemories();

  /// Clear all memories
  Future<void> clearAllMemories();
}
