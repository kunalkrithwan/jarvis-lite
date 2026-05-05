import 'package:get_it/get_it.dart';
import 'package:jarvis_lite/core/services/voice_service.dart';
import 'package:jarvis_lite/core/services/intent_engine.dart';
import 'package:jarvis_lite/core/services/task_pipeline_service.dart';
import 'package:jarvis_lite/core/services/battery_optimization_service.dart';
import 'package:jarvis_lite/core/services/context_memory_service.dart';
import 'package:jarvis_lite/core/services/permission_service.dart';
import 'package:jarvis_lite/core/services/platform_channel_service.dart';
import 'package:jarvis_lite/core/services/background_task_service.dart';
import 'package:jarvis_lite/data/local/app_database.dart';
import 'package:jarvis_lite/features/tasks/task_manager_service.dart';
import 'package:jarvis_lite/features/commands/command_executor_service.dart';
import 'package:jarvis_lite/features/system_control/system_control_service.dart';
import 'package:jarvis_lite/features/voice/wake_word_detector.dart';

/// Service Locator - Centralized dependency injection
/// Using GetIt for easy access throughout the app
final getIt = GetIt.instance;

/// Initialize all services
/// Call this in main() before running the app
Future<void> setupServiceLocator() async {
  // Database
  await getIt.registerSingleton<AppDatabase>(AppDatabase());

  // Repositories
  final database = getIt<AppDatabase>();
  await getIt.registerSingleton<LocalCommandRepository>(
    LocalCommandRepository(database),
  );
  await getIt.registerSingleton<LocalTaskRepository>(
    LocalTaskRepository(database),
  );

  // Core Services
  await getIt.registerSingleton<VoiceService>(
    MockVoiceService(), // Using mock for now
  );

  getIt.registerSingleton<IntentEngineService>(HybridIntentEngine());

  getIt.registerSingleton<TaskPipelineService>(DefaultTaskPipelineService());

  getIt.registerSingleton<BatteryOptimizationService>(
    DefaultBatteryOptimizationService(),
  );

  getIt.registerSingleton<ContextMemoryService>(DefaultContextMemoryService());

  getIt.registerSingleton<PermissionService>(DefaultPermissionServiceImpl());

  getIt.registerSingleton<PlatformChannelService>(
    DefaultPlatformChannelService(),
  );

  // Feature Services
  await getIt.registerSingleton<TaskManagerService>(
    DefaultTaskManagerService(getIt<LocalTaskRepository>()),
  );

  // Command Executor Service
  getIt.registerSingleton<CommandExecutorService>(
    DefaultCommandExecutorService(
      platformService: getIt<PlatformChannelService>(),
      voiceService: getIt<VoiceService>(),
    ),
  );

  // System Control Service
  getIt.registerSingleton<SystemControlService>(
    DefaultSystemControlService(getIt<PlatformChannelService>()),
  );

  // Wake Word Detector
  getIt.registerSingleton<WakeWordDetector>(
    DefaultWakeWordDetector(),
  );

  // Background Task Service
  getIt.registerSingleton<BackgroundTaskService>(
    DefaultBackgroundTaskService(getIt<TaskManagerService>()),
  );

  // Initialize services that need async setup
  final intentEngine = getIt<IntentEngineService>();
  await (intentEngine as HybridIntentEngine).initialize();

  // Initialize wake word detector
  final wakeWordDetector = getIt<WakeWordDetector>();
  await (wakeWordDetector as DefaultWakeWordDetector).initialize();

  // Initialize background task service
  final backgroundTaskService = getIt<BackgroundTaskService>();
  await backgroundTaskService.initialize();
}

/// Mock Voice Service for development/testing
class MockVoiceService extends ChangeNotifier implements VoiceService {
  @override
  VoiceState state = VoiceState.idle;

  @override
  bool get isListening => false;

  @override
  Stream<VoiceRecognitionResult> get recognitionStream {
    return Stream.empty();
  }

  @override
  Stream<double> get voiceLevelStream {
    return Stream.empty();
  }

  @override
  Future<void> initialize() async {
    print('MockVoiceService initialized');
  }

  @override
  Future<void> dispose() async {
    print('MockVoiceService disposed');
  }

  @override
  Future<void> startListening() async {
    print('MockVoiceService: Start listening');
    state = VoiceState.listening;
    notifyListeners();
  }

  @override
  Future<void> stopListening() async {
    print('MockVoiceService: Stop listening');
    state = VoiceState.idle;
    notifyListeners();
  }

  @override
  Future<void> speak(
    String text, {
    double pitch = 1.0,
    double speed = 1.0,
  }) async {
    print('MockVoiceService: Speaking "$text" (pitch: $pitch, speed: $speed)');
  }

  @override
  Future<void> stopSpeaking() async {
    print('MockVoiceService: Stop speaking');
  }

  @override
  void setWakeWord(String word) {
    print('MockVoiceService: Wake word set to "$word"');
  }

  @override
  Future<bool> hasMicrophone() async {
    return true;
  }

  @override
  Future<bool> requestMicrophonePermission() async {
    return true;
  }
}
