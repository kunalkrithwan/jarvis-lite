import 'package:flutter/services.dart';

/// Platform Channel Service
/// Handles Android integration for:
/// - App launching
/// - System toggles (WiFi, Bluetooth, Flashlight)
/// - Background services
/// - System info retrieval
abstract class PlatformChannelService {
  /// Launch application by package name
  Future<bool> launchApplication(String packageName, String appName);

  /// Check if app is installed
  Future<bool> isApplicationInstalled(String packageName);

  /// Toggle WiFi
  Future<bool> toggleWifi(bool enable);

  /// Get WiFi status
  Future<bool> isWifiEnabled();

  /// Toggle Bluetooth
  Future<bool> toggleBluetooth(bool enable);

  /// Get Bluetooth status
  Future<bool> isBluetoothEnabled();

  /// Toggle flashlight
  Future<bool> toggleFlashlight(bool enable);

  /// Get flashlight status
  Future<bool> isFlashlightOn();

  /// Get system information
  Future<Map<String, dynamic>> getSystemInfo();

  /// Set alarm
  Future<bool> setAlarm(int hour, int minute, String label);

  /// Make phone call
  Future<bool> makeCall(String phoneNumber);

  /// Send SMS
  Future<bool> sendSms(String phoneNumber, String message);

  /// Get installed apps
  Future<List<String>> getInstalledApps();
}

/// Default implementation using Method Channels
class DefaultPlatformChannelService implements PlatformChannelService {
  static const platform = MethodChannel('com.jarvis.lite/system');

  @override
  Future<bool> launchApplication(String packageName, String appName) async {
    try {
      final result = await platform.invokeMethod<bool>('launchApp', {
        'packageName': packageName,
        'appName': appName,
      });
      return result ?? false;
    } catch (e) {
      print('Error launching app: $e');
      return false;
    }
  }

  @override
  Future<bool> isApplicationInstalled(String packageName) async {
    try {
      final result = await platform.invokeMethod<bool>('isAppInstalled', {
        'packageName': packageName,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> toggleWifi(bool enable) async {
    try {
      final result = await platform.invokeMethod<bool>('toggleWifi', {
        'enable': enable,
      });
      return result ?? false;
    } catch (e) {
      print('Error toggling WiFi: $e');
      return false;
    }
  }

  @override
  Future<bool> isWifiEnabled() async {
    try {
      final result = await platform.invokeMethod<bool>('isWifiEnabled');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> toggleBluetooth(bool enable) async {
    try {
      final result = await platform.invokeMethod<bool>('toggleBluetooth', {
        'enable': enable,
      });
      return result ?? false;
    } catch (e) {
      print('Error toggling Bluetooth: $e');
      return false;
    }
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    try {
      final result = await platform.invokeMethod<bool>('isBluetoothEnabled');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> toggleFlashlight(bool enable) async {
    try {
      final result = await platform.invokeMethod<bool>('toggleFlashlight', {
        'enable': enable,
      });
      return result ?? false;
    } catch (e) {
      print('Error toggling flashlight: $e');
      return false;
    }
  }

  @override
  Future<bool> isFlashlightOn() async {
    try {
      final result = await platform.invokeMethod<bool>('isFlashlightOn');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      final result = await platform.invokeMethod<Map>('getSystemInfo');
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      return {};
    }
  }

  @override
  Future<bool> setAlarm(int hour, int minute, String label) async {
    try {
      final result = await platform.invokeMethod<bool>('setAlarm', {
        'hour': hour,
        'minute': minute,
        'label': label,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> makeCall(String phoneNumber) async {
    try {
      final result = await platform.invokeMethod<bool>('makeCall', {
        'phoneNumber': phoneNumber,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> sendSms(String phoneNumber, String message) async {
    try {
      final result = await platform.invokeMethod<bool>('sendSms', {
        'phoneNumber': phoneNumber,
        'message': message,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getInstalledApps() async {
    try {
      final result = await platform.invokeMethod<List>('getInstalledApps');
      return List<String>.from(result ?? []);
    } catch (e) {
      return [];
    }
  }
}
