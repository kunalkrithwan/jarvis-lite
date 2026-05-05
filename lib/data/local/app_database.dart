import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:jarvis_lite/data/models/command_model.dart';
import 'package:jarvis_lite/data/models/task_model.dart';
import 'package:jarvis_lite/domain/repositories/abstract_repositories.dart';

/// SQLite Database initialization and management
class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  factory AppDatabase() {
    return _instance;
  }

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'jarvis_lite.db');

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create commands table
    await db.execute('''
      CREATE TABLE commands (
        id TEXT PRIMARY KEY,
        text TEXT NOT NULL,
        transcribedText TEXT,
        type TEXT NOT NULL,
        parameters TEXT,
        createdAt TEXT NOT NULL,
        status TEXT NOT NULL,
        result TEXT,
        executionTime INTEGER
      )
    ''');

    // Create tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        subtasks TEXT,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        dueDate TEXT,
        reminderTime TEXT,
        isRecurring INTEGER NOT NULL,
        recurringPattern TEXT,
        metadata TEXT
      )
    ''');

    // Create indexes for faster queries
    await db.execute('CREATE INDEX idx_commands_date ON commands(createdAt)');
    await db.execute('CREATE INDEX idx_commands_status ON commands(status)');
    await db.execute('CREATE INDEX idx_tasks_status ON tasks(status)');
    await db.execute('CREATE INDEX idx_tasks_date ON tasks(createdAt)');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

/// Local Command Repository Implementation
class LocalCommandRepository implements CommandRepository {
  final AppDatabase _database;

  LocalCommandRepository(this._database);

  @override
  Future<List<CommandModel>> getAllCommands() async {
    final db = await _database.database;
    final maps = await db.query('commands', orderBy: 'createdAt DESC');
    return maps.map((map) => CommandModel.fromJson(map)).toList();
  }

  @override
  Future<CommandModel?> getCommandById(String id) async {
    final db = await _database.database;
    final maps = await db.query('commands', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return CommandModel.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<void> saveCommand(CommandModel command) async {
    final db = await _database.database;
    await db.insert(
      'commands',
      command.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteCommand(String id) async {
    final db = await _database.database;
    await db.delete('commands', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<CommandModel>> getRecentCommands(int limit) async {
    final db = await _database.database;
    final maps = await db.query(
      'commands',
      orderBy: 'createdAt DESC',
      limit: limit,
    );
    return maps.map((map) => CommandModel.fromJson(map)).toList();
  }

  @override
  Future<void> clearAllCommands() async {
    final db = await _database.database;
    await db.delete('commands');
  }
}

/// Local Task Repository Implementation
class LocalTaskRepository implements TaskRepository {
  final AppDatabase _database;

  LocalTaskRepository(this._database);

  @override
  Future<List<TaskModel>> getAllTasks() async {
    final db = await _database.database;
    final maps = await db.query('tasks', orderBy: 'createdAt DESC');
    return maps.map((map) => TaskModel.fromJson(map)).toList();
  }

  @override
  Future<List<TaskModel>> getTasksByStatus(String status) async {
    final db = await _database.database;
    final maps = await db.query(
      'tasks',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => TaskModel.fromJson(map)).toList();
  }

  @override
  Future<List<TaskModel>> getActiveTasks() async {
    return getTasksByStatus('pending');
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    final db = await _database.database;
    await db.insert(
      'tasks',
      task.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final db = await _database.database;
    await db.update(
      'tasks',
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    final db = await _database.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<TaskModel>> getTasksDueToday() async {
    final db = await _database.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final maps = await db.query(
      'tasks',
      where: 'dueDate >= ? AND dueDate < ? AND status != ?',
      whereArgs: [
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
        'completed',
      ],
      orderBy: 'dueDate ASC',
    );

    return maps.map((map) => TaskModel.fromJson(map)).toList();
  }
}
