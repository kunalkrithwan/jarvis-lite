import 'package:jarvis_lite/domain/entities/command_entity.dart';
import 'package:jarvis_lite/core/services/platform_channel_service.dart';
import 'package:jarvis_lite/core/services/voice_service.dart';
import 'package:jarvis_lite/core/services/intent_engine.dart';
import 'package:jarvis_lite/domain/entities/intent_entity.dart';

/// Command Executor Service
/// Executes recognized commands by delegating to appropriate handlers
/// Provides voice feedback for each action
abstract class CommandExecutorService {
  /// Execute a command based on intent
  Future<CommandResult> executeCommand(IntentEntity intent);

  /// Execute a command entity directly
  Future<CommandResult> executeCommandEntity(CommandEntity command);

  /// Get execution history
  Future<List<CommandResult>> getExecutionHistory();

  /// Clear history
  Future<void> clearHistory();
}

/// Result of command execution
class CommandResult {
  final String command;
  final bool success;
  final String message;
  final DateTime executedAt;
  final Duration? executionTime;
  final Map<String, dynamic> metadata;

  CommandResult({
    required this.command,
    required this.success,
    required this.message,
    DateTime? executedAt,
    this.executionTime,
    this.metadata = const {},
  }) : executedAt = executedAt ?? DateTime.now();
}

/// Default implementation
class DefaultCommandExecutorService implements CommandExecutorService {
  final PlatformChannelService _platformService;
  final VoiceService _voiceService;
  final List<CommandResult> _history = [];

  DefaultCommandExecutorService({
    required PlatformChannelService platformService,
    required VoiceService voiceService,
  })  : _platformService = platformService,
        _voiceService = voiceService;

  @override
  Future<CommandResult> executeCommand(IntentEntity intent) async {
    final startTime = DateTime.now();
    final command = intent.primaryIntent;

    try {
      String resultMessage;
      bool success = true;

      switch (command) {
        case 'appLaunch':
          success = await _handleAppLaunch(intent.slots);
          resultMessage = success ? 'Application opened' : 'Failed to open application';
          break;

        case 'toggleWifi':
          success = await _handleWifiToggle(intent.slots);
          resultMessage = success ? 'WiFi toggled' : 'Failed to toggle WiFi';
          break;

        case 'toggleBluetooth':
          success = await _handleBluetoothToggle(intent.slots);
          resultMessage = success ? 'Bluetooth toggled' : 'Failed to toggle Bluetooth';
          break;

        case 'toggleFlashlight':
          success = await _handleFlashlightToggle(intent.slots);
          resultMessage = success ? 'Flashlight toggled' : 'Failed to toggle flashlight';
          break;

        case 'setAlarm':
          success = await _handleSetAlarm(intent.slots);
          resultMessage = success ? 'Alarm set' : 'Failed to set alarm';
          break;

        case 'setReminder':
          success = await _handleSetReminder(intent.slots);
          resultMessage = success ? 'Reminder set' : 'Failed to set reminder';
          break;

        case 'playMedia':
          success = await _handlePlayMedia(intent.slots);
          resultMessage = success ? 'Media playing' : 'Failed to play media';
          break;

        case 'callContact':
          success = await _handleCallContact(intent.slots);
          resultMessage = success ? 'Calling contact' : 'Failed to call contact';
          break;

        case 'sendMessage':
          success = await _handleSendMessage(intent.slots);
          resultMessage = success ? 'Message sent' : 'Failed to send message';
          break;

        default:
          resultMessage = 'Unknown command: $command';
          success = false;
      }

      final executionTime = DateTime.now().difference(startTime);
      final result = CommandResult(
        command: command,
        success: success,
        message: resultMessage,
        executionTime: executionTime,
        metadata: intent.slots,
      );

      _history.add(result);
      if (_history.length > 100) _history.removeAt(0);

      // Provide voice feedback
      await _voiceService.speak(resultMessage);

      return result;
    } catch (e) {
      final result = CommandResult(
        command: command,
        success: false,
        message: 'Error executing command: ${e.toString()}',
        executionTime: DateTime.now().difference(startTime),
      );
      _history.add(result);
      return result;
    }
  }

  @override
  Future<CommandResult> executeCommandEntity(CommandEntity command) async {
    // Convert entity to intent and execute
    final intent = IntentEntity(
      id: command.id,
      text: command.text,
      primaryIntent: command.type.toString(),
      slots: {'parameters': command.parameters},
    );
    return await executeCommand(intent);
  }

  Future<bool> _handleAppLaunch(Map<String, dynamic> slots) async {
    final appName = slots['param_0']?.toString() ?? slots['app']?.toString();
    if (appName == null) return false;

    // Common app package names
    final packageNames = {
      'youtube': 'com.google.android.youtube',
      'spotify': 'com.spotify.music',
      'netflix': 'com.netflix.mediaclient',
      'chrome': 'com.android.chrome',
      'maps': 'com.google.android.apps.maps',
      'gmail': 'com.google.android.gm',
      'whatsapp': 'com.whatsapp',
      'telegram': 'org.telegram.messenger',
    };

    final packageName = packageNames[appName.toLowerCase()] ?? 'com.$appName';
    return await _platformService.launchApplication(packageName, appName);
  }

  Future<bool> _handleWifiToggle(Map<String, dynamic> slots) async {
    final param = slots['param_0']?.toString()?.toLowerCase();
    if (param == null) return false;

    final enable = param == 'on' || param == 'enable' || param == 'true';
    return await _platformService.toggleWifi(enable);
  }

  Future<bool> _handleBluetoothToggle(Map<String, dynamic> slots) async {
    final param = slots['param_0']?.toString()?.toLowerCase();
    if (param == null) return false;

    final enable = param == 'on' || param == 'enable' || param == 'true';
    return await _platformService.toggleBluetooth(enable);
  }

  Future<bool> _handleFlashlightToggle(Map<String, dynamic> slots) async {
    final param = slots['param_0']?.toString()?.toLowerCase();
    if (param == null) return false;

    final enable = param == 'on' || param == 'enable' || param == 'true';
    return await _platformService.toggleFlashlight(enable);
  }

  Future<bool> _handleSetAlarm(Map<String, dynamic> slots) async {
    final timeStr = slots['param_0']?.toString() ?? slots['time']?.toString();
    if (timeStr == null) return false;

    // Parse time string (e.g., "7:30", "7:30am")
    final parts = timeStr.toLowerCase().replaceAll(':', '').split('am');
    final time = parts[0];
    
    // Simple parsing for "HH:MM" format
    final timeParts = timeStr.split(':');
    if (timeParts.length != 2) return false;

    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;

    return await _platformService.setAlarm(hour, minute, 'JARVIS Alarm');
  }

  Future<bool> _handleSetReminder(Map<String, dynamic> slots) async {
    // Placeholder for reminder handling
    // In production, this would integrate with task manager
    return true;
  }

  Future<bool> _handlePlayMedia(Map<String, dynamic> slots) async {
    final query = slots['param_0']?.toString() ?? slots['query']?.toString();
    if (query == null) return false;

    // Try to launch YouTube with search
    return await _platformService.launchApplication(
      'com.google.android.youtube',
      'YouTube',
    );
  }

  Future<bool> _handleCallContact(Map<String, dynamic> slots) async {
    final contact = slots['param_0']?.toString() ?? slots['contact']?.toString();
    if (contact == null) return false;

    return await _platformService.makeCall(contact);
  }

  Future<bool> _handleSendMessage(Map<String, dynamic> slots) async {
    final contact = slots['param_0']?.toString() ?? slots['contact']?.toString();
    final message = slots['param_1']?.toString() ?? slots['message']?.toString();
    
    if (contact == null || message == null) return false;

    return await _platformService.sendSms(contact, message);
  }

  @override
  Future<List<CommandResult>> getExecutionHistory() async {
    return List.from(_history);
  }

  @override
  Future<void> clearHistory() async {
    _history.clear();
  }
}
