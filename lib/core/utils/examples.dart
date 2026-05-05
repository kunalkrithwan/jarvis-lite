import 'package:flutter/material.dart';
import 'package:jarvis_lite/core/utils/service_locator.dart';
import 'package:jarvis_lite/core/services/voice_service.dart';
import 'package:jarvis_lite/core/services/intent_engine.dart';
import 'package:jarvis_lite/core/services/battery_optimization_service.dart';
import 'package:jarvis_lite/core/services/context_memory_service.dart';
import 'package:jarvis_lite/core/services/permission_service.dart';
import 'package:jarvis_lite/core/services/platform_channel_service.dart';
import 'package:jarvis_lite/core/services/background_task_service.dart';
import 'package:jarvis_lite/features/tasks/task_manager_service.dart';
import 'package:jarvis_lite/features/commands/command_executor_service.dart';
import 'package:jarvis_lite/features/system_control/system_control_service.dart';
import 'package:jarvis_lite/features/voice/wake_word_detector.dart';
import 'package:jarvis_lite/domain/entities/task_entity.dart';
import 'package:jarvis_lite/domain/entities/execution_pipeline.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

/// Example usage of JARVIS Lite services
void demonstrateServices() async {
  // Initialize services
  await setupServiceLocator();

  // ============ Voice Service Demo ============
  final voiceService = getIt<VoiceService>();
  await voiceService.initialize();

  // Listen for voice input
  await voiceService.startListening();
  await Future.delayed(Duration(seconds: 3)); // Simulate listening
  await voiceService.stopListening();

  // Provide voice feedback
  await voiceService.speak(
    'Hello! How can I assist you?',
    pitch: 1.0,
    speed: 0.9,
  );

  // ============ Intent Engine Demo ============
  final intentEngine = getIt<IntentEngineService>();

  // Recognize intent from text
  final intent1 = await intentEngine.recognizeIntent('open YouTube');
  print('Intent: ${intent1.primaryIntent}, Confidence: ${intent1.confidence}');

  final intent2 = await intentEngine.recognizeIntent('set alarm at 7 am');
  print('Intent: ${intent2.primaryIntent}, Slots: ${intent2.slots}');

  // Get top predictions
  final predictions = await intentEngine.getPredictions(
    'play music on speaker',
  );
  for (final pred in predictions) {
    print('${pred.intent}: ${pred.score}');
  }

  // ============ Task Manager Demo ============
  final taskManager = getIt<TaskManagerService>();

  // Create a task
  final task = await taskManager.createTask(
    title: 'Buy groceries',
    description: 'Milk, eggs, bread',
    priority: TaskPriority.high,
    dueDate: DateTime.now().add(Duration(days: 1)),
    subtasks: ['Check shopping list', 'Go to store', 'Unpack items'],
  );
  print('Created task: ${task.title}');

  // Get today's tasks
  final todayTasks = await taskManager.getTasksForToday();
  print('Tasks today: ${todayTasks.length}');

  // Mark task as started
  await taskManager.markTaskAsStarted(task.id);

  // Complete task
  await taskManager.completeTask(task.id);

  // ============ Task Pipeline Demo ============
  final pipelineService = getIt<TaskPipelineService>();

  // Build a multi-step pipeline: "Open YouTube and play music"
  final stages = [
    PipelineStage(
      id: '1',
      name: 'Detect Intent',
      type: 'command',
      order: 0,
      parameters: {'text': 'Play music on YouTube'},
    ),
    PipelineStage(
      id: '2',
      name: 'Open YouTube',
      type: 'command',
      order: 1,
      parameters: {'app': 'YouTube'},
    ),
    PipelineStage(
      id: '3',
      name: 'Wait for App Load',
      type: 'delay',
      order: 2,
      parameters: {'duration': 2000}, // 2 seconds
      required: false,
    ),
    PipelineStage(
      id: '4',
      name: 'Search for Music',
      type: 'command',
      order: 3,
      parameters: {'query': 'music'},
    ),
    PipelineStage(
      id: '5',
      name: 'Play First Result',
      type: 'command',
      order: 4,
      parameters: {},
    ),
  ];

  final pipeline = pipelineService.createPipeline(
    name: 'Play YouTube Music',
    stages: stages,
    input: {'user_command': 'Play music on YouTube'},
  );

  // Execute pipeline and listen to updates
  await for (final update in pipelineService.executePipeline(pipeline)) {
    print('Pipeline Status: ${update.status}');
    for (final stage in update.stages) {
      print('  - ${stage.name}: ${stage.status}');
    }

    if (update.status == PipelineStatus.completed) {
      print('Pipeline completed successfully!');
      print('Execution time: ${update.executionTime?.inMilliseconds}ms');
    }
  }

  // ============ Context Memory Demo ============
  final memoryService = getIt<ContextMemoryService>();

  // Store command in history
  await memoryService.addCommandToHistory('open youtube');

  // Store user preferences
  await memoryService.setMemory(
    'user_preference_tts_speed',
    0.9,
    expiresAt: DateTime.now().add(Duration(days: 30)),
  );

  // Retrieve stored value
  final ttsSpeed = await memoryService.getMemory('user_preference_tts_speed');
  print('TTS Speed: $ttsSpeed');

  // Get user profile
  var profile = await memoryService.getUserProfile();
  if (profile == null) {
    // Create new profile
    profile = UserProfile(
      id: 'user_1',
      nickname: 'Alex',
      preferences: {'language': 'en', 'theme': 'dark'},
      favoriteApps: ['YouTube', 'Spotify'],
    );
    await memoryService.saveUserProfile(profile);
  }

  // ============ Battery Optimization Demo ============
  final batteryService = getIt<BatteryOptimizationService>();

  final batteryStatus = await batteryService.getBatteryStatus();
  print(
    'Battery: ${batteryStatus.level}%, Charging: ${batteryStatus.isCharging}',
  );

  // Get adaptive listening interval based on battery
  final listeningInterval = batteryService.getListeningInterval();
  print('Listening interval: ${listeningInterval.inSeconds}s');

  // Enable power saving for low battery
  if (batteryStatus.level < 20) {
    await batteryService.enablePowerSavingMode();
  }

  // ============ Platform Channel Demo ============
  final platformService = getIt<PlatformChannelService>();

  // Check if apps are installed
  final youtubeInstalled = await platformService.isApplicationInstalled(
    'com.google.android.youtube',
  );
  print('YouTube installed: $youtubeInstalled');

  // Toggle system features
  if (youtubeInstalled) {
    await platformService.launchApplication(
      'com.google.android.youtube',
      'YouTube',
    );
  }

  // Get system info
  final systemInfo = await platformService.getSystemInfo();
  print('Device: ${systemInfo['model']} (${systemInfo['brand']})');
  print('Android Version: ${systemInfo['version']}');

  // ============ Permission Handling Demo ============
  final permissionService = getIt<PermissionService>();

  // Check if permissions are granted
  final micGranted = await permissionService.checkPermission(
    permission_handler.Permission.microphone,
  );
  print('Microphone permission: $micGranted');

  // Request permissions if needed
  if (!micGranted) {
    final granted = await permissionService.requestPermission(
      permission_handler.Permission.microphone,
    );
    print('Microphone permission granted: $granted');
  }

  // ============ Command Executor Demo ============
  final commandExecutor = getIt<CommandExecutorService>();

  // Execute a command via intent
  final intent = await intentEngine.recognizeIntent('open youtube');
  final result = await commandExecutor.executeCommand(intent);
  print('Command executed: ${result.command}, Success: ${result.success}');

  // ============ System Control Demo ============
  final systemControl = getIt<SystemControlService>();

  // Check WiFi status
  final wifiStatus = await systemControl.getWiFiStatus();
  print('WiFi enabled: $wifiStatus');

  // Get system info
  final systemInfo = await systemControl.getSystemInfo();
  print('System: ${systemInfo['brand']} ${systemInfo['model']}');

  // ============ Wake Word Detector Demo ============
  final wakeWordDetector = getIt<WakeWordDetector>();

  // Initialize and start detection
  await wakeWordDetector.initialize(wakeWord: 'hey jarvis');
  wakeWordDetector.startDetection().listen((event) {
    print('Wake word detected: ${event.detectedWord}, Confidence: ${event.confidence}');
  });

  // ============ Background Task Service Demo ============
  final backgroundTaskService = getIt<BackgroundTaskService>();

  // Register daily task planning
  await backgroundTaskService.registerDailyTaskPlanning();
  print('Daily task planning registered');

  // Register a reminder for a task
  final task = await taskManager.createTask(
    title: 'Meeting',
    description: 'Team sync',
    priority: TaskPriority.high,
    dueDate: DateTime.now().add(Duration(hours: 2)),
  );
  await backgroundTaskService.registerReminder(
    task.id,
    DateTime.now().add(Duration(minutes: 30)),
  );
  print('Reminder registered for task: ${task.id}');

  print('\n✅ All demonstrations completed!');
}

/// Import these in your test files
void main() {
  demonstrateServices();
}
