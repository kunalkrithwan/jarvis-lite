import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:jarvis_lite/core/utils/service_locator.dart';
import 'package:jarvis_lite/core/services/voice_service.dart';
import 'package:jarvis_lite/core/services/intent_engine.dart';
import 'package:jarvis_lite/features/tasks/task_manager_service.dart';
import 'package:jarvis_lite/ui/theme/app_theme.dart';
import 'package:jarvis_lite/ui/widgets/animated_widgets.dart';
import 'package:jarvis_lite/ui/widgets/task_widgets.dart';
import 'package:jarvis_lite/domain/entities/task_entity.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _voiceService = getIt<VoiceService>();
  final _intentEngine = getIt<IntentEngineService>();
  final _taskManager = getIt<TaskManagerService>();

  List<TaskEntity> _tasks = [];
  String? _lastCommand;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize voice service
    await _voiceService.initialize();

    // Load tasks
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _taskManager.getAllTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _startListening() async {
    if (_isListening) return;

    setState(() {
      _isListening = true;
      _lastCommand = null;
    });

    await _voiceService.startListening();

    // Simulate voice recognition (in real app, use recognized voice)
    await Future.delayed(Duration(seconds: 2));

    final simulatedText = 'Open YouTube';
    final intent = await _intentEngine.recognizeIntent(simulatedText);

    setState(() {
      _lastCommand = simulatedText;
      _isListening = false;
    });

    await _voiceService.stopListening();

    // Trigger feedback
    await _voiceService.speak('Recognized: ${intent.primaryIntent}');

    // Handle intent
    _handleIntent(intent.primaryIntent, simulatedText);
  }

  void _handleIntent(String intent, String command) {
    final feedback = _getIntentFeedback(intent);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(feedback),
        backgroundColor: AppTheme.primaryBlue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getIntentFeedback(String intent) {
    const feedbacks = {
      'appLaunch': 'Opening application...',
      'toggleWifi': 'Toggling WiFi...',
      'toggleBluetooth': 'Toggling Bluetooth...',
      'toggleFlashlight': 'Toggling flashlight...',
      'setAlarm': 'Setting alarm...',
      'setReminder': 'Setting reminder...',
      'playMedia': 'Playing media...',
      'callContact': 'Making call...',
      'sendMessage': 'Sending message...',
    };

    return feedbacks[intent] ?? 'Processing command...';
  }

  Future<void> _createNewTask() async {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: Text('New Task', style: TextStyle(color: AppTheme.accentCyan)),
        content: TextField(
          controller: titleController,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter task title',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await _taskManager.createTask(
                  title: titleController.text,
                  priority: TaskPriority.medium,
                );
                await _loadTasks();
                Navigator.pop(context);
              }
            },
            child: Text('Create', style: TextStyle(color: AppTheme.accentCyan)),
          ),
        ],
      ),
    );
  }

  Future<void> _completeTask(String taskId) async {
    await _taskManager.completeTask(taskId);
    await _loadTasks();
  }

  Future<void> _deleteTask(String taskId) async {
    await _taskManager.deleteTask(taskId);
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GlowingText(
          'JARVIS LITE',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // System status
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SYSTEM STATUS',
                    style: TextStyle(
                      color: AppTheme.accentCyan,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 12),
                  StatusIndicator(
                    label: 'Microphone Available',
                    isActive: true,
                  ),
                  SizedBox(height: 8),
                  StatusIndicator(
                    label: 'Battery Optimization',
                    isActive: true,
                    activeColor: AppTheme.warningOrange,
                  ),
                  SizedBox(height: 8),
                  StatusIndicator(label: 'Voice Assistant', isActive: true),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Voice control section
          Center(
            child: Column(
              children: [
                AnimatedWaveform(isListening: _isListening, barCount: 20),
                SizedBox(height: 24),
                VoiceCommandButton(
                  isListening: _isListening,
                  onPressed: _startListening,
                  label: 'SPEAK',
                ),
                SizedBox(height: 16),
                if (_lastCommand != null)
                  GlowingText(
                    '> $_lastCommand',
                    style: TextStyle(
                      color: AppTheme.accentCyan,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 32),

          // Task progress
          TaskProgressIndicator(tasks: _tasks),
          SizedBox(height: 24),

          // Tasks section
          Text(
            'ACTIVE TASKS',
            style: TextStyle(
              color: AppTheme.accentCyan,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8),
          if (_tasks.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'No tasks yet. Create one to get started!',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            ..._tasks
                .take(5)
                .map(
                  (task) => TaskTile(
                    task: task,
                    onComplete: () => _completeTask(task.id),
                    onDelete: () => _deleteTask(task.id),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewTask,
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}
