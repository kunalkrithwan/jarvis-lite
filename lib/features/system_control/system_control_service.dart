import 'package:jarvis_lite/core/services/platform_channel_service.dart';

/// System Control Service
/// Provides high-level interface for controlling device system features
/// Wraps platform channel calls with additional logic and error handling
abstract class SystemControlService {
  /// Toggle WiFi
  Future<bool> toggleWiFi({required bool enable});

  /// Get WiFi status
  Future<bool> getWiFiStatus();

  /// Toggle Bluetooth
  Future<bool> toggleBluetooth({required bool enable});

  /// Get Bluetooth status
  Future<bool> getBluetoothStatus();

  /// Toggle flashlight
  Future<bool> toggleFlashlight({required bool enable});

  /// Get flashlight status
  Future<bool> getFlashlightStatus();

  /// Launch application
  Future<bool> launchApplication({required String packageName, required String appName});

  /// Check if app is installed
  Future<bool> isAppInstalled({required String packageName});

  /// Get list of installed apps
  Future<List<String>> getInstalledApps();

  /// Set alarm
  Future<bool> setAlarm({required int hour, required int minute, required String label});

  /// Make phone call
  Future<bool> makeCall({required String phoneNumber});

  /// Send SMS
  Future<bool> sendSMS({required String phoneNumber, required String message});

  /// Get system information
  Future<Map<String, dynamic>> getSystemInfo();
}

/// Default implementation
class DefaultSystemControlService implements SystemControlService {
  final PlatformChannelService _platformService;

  DefaultSystemControlService(this._platformService);

  @override
  Future<bool> toggleWiFi({required bool enable}) async {
    try {
      return await _platformService.toggleWifi(enable);
    } catch (e) {
      print('Error toggling WiFi: $e');
      return false;
    }
  }

  @override
  Future<bool> getWiFiStatus() async {
    try {
      return await _platformService.isWifiEnabled();
    } catch (e) {
      print('Error getting WiFi status: $e');
      return false;
    }
  }

  @override
  Future<bool> toggleBluetooth({required bool enable}) async {
    try {
      return await _platformService.toggleBluetooth(enable);
    } catch (e) {
      print('Error toggling Bluetooth: $e');
      return false;
    }
  }

  @override
  Future<bool> getBluetoothStatus() async {
    try {
      return await _platformService.isBluetoothEnabled();
    } catch (e) {
      print('Error getting Bluetooth status: $e');
      return false;
    }
  }

  @override
  Future<bool> toggleFlashlight({required bool enable}) async {
    try {
      return await _platformService.toggleFlashlight(enable);
    } catch (e) {
      print('Error toggling flashlight: $e');
      return false;
    }
  }

  @override
  Future<bool> getFlashlightStatus() async {
    try {
      return await _platformService.isFlashlightOn();
    } catch (e) {
      print('Error getting flashlight status: $e');
      return false;
    }
  }

  @override
  Future<bool> launchApplication({
    required String packageName,
    required String appName,
  }) async {
    try {
      return await _platformService.launchApplication(packageName, appName);
    } catch (e) {
      print('Error launching app: $e');
      return false;
    }
  }

  @override
  Future<bool> isAppInstalled({required String packageName}) async {
    try {
      return await _platformService.isApplicationInstalled(packageName);
    } catch (e) {
      print('Error checking app installation: $e');
      return false;
    }
  }

  @override
  Future<List<String>> getInstalledApps() async {
    try {
      return await _platformService.getInstalledApps();
    } catch (e) {
      print('Error getting installed apps: $e');
      return [];
    }
  }

  @override
  Future<bool> setAlarm({
    required int hour,
    required int minute,
    required String label,
  }) async {
    try {
      return await _platformService.setAlarm(hour, minute, label);
    } catch (e) {
      print('Error setting alarm: $e');
      return false;
    }
  }

  @override
  Future<bool> makeCall({required String phoneNumber}) async {
    try {
      return await _platformService.makeCall(phoneNumber);
    } catch (e) {
      print('Error making call: $e');
      return false;
    }
  }

  @override
  Future<bool> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      return await _platformService.sendSms(phoneNumber, message);
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      return await _platformService.getSystemInfo();
    } catch (e) {
      print('Error getting system info: $e');
      return {};
    }
  }
}
