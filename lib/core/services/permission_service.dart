import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:flutter/foundation.dart';

/// Permission status with explanation
class PermissionInfo {
  final permission_handler.Permission permission;
  final permission_handler.PermissionStatus status;
  final String description;

  PermissionInfo({
    required this.permission,
    required this.status,
    required this.description,
  });

  bool get isGranted => status.isGranted;
  bool get isDenied => status.isDenied;
  bool get isPermanentlyDenied => status.isPermanentlyDenied;
}

/// Permission Management Service
/// Handles all permission requests and checks
abstract class PermissionService extends ChangeNotifier {
  /// Check single permission
  Future<bool> checkPermission(permission_handler.Permission permission);

  /// Request single permission
  Future<bool> requestPermission(permission_handler.Permission permission);

  /// Check multiple permissions
  Future<Map<permission_handler.Permission, bool>> checkPermissions(List<permission_handler.Permission> permissions);

  /// Request multiple permissions
  Future<Map<permission_handler.Permission, bool>> requestPermissions(
    List<permission_handler.Permission> permissions,
  );

  /// Get all required permissions
  List<permission_handler.Permission> get requiredPermissions;

  /// Check if all required permissions are granted
  Future<bool> areAllPermissionsGranted();

  /// Request all required permissions
  Future<bool> requestAllPermissions();

  /// Get permission details
  Future<PermissionInfo> getPermissionInfo(permission_handler.Permission permission);

  /// Open app settings to grant permissions
  Future<void> openAppSettings();
}

/// Default implementation
class DefaultPermissionService implements PermissionService {
  @override
  List<permission_handler.Permission> get requiredPermissions => [
    permission_handler.Permission.microphone, // For voice input
    permission_handler.Permission.contacts, // For calling/messaging
    permission_handler.Permission.phone, // For phone calls
    permission_handler.Permission.location, // For location-based commands
    permission_handler.Permission.notification, // For reminders
    permission_handler.Permission.bluetooth, // For Bluetooth control
    permission_handler.Permission.bluetoothScan, // Android 12+
    permission_handler.Permission.bluetoothConnect, // Android 12+
  ];

  @override
  Future<bool> checkPermission(permission_handler.Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestPermission(permission_handler.Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  @override
  Future<Map<permission_handler.Permission, bool>> checkPermissions(
    List<permission_handler.Permission> permissions,
  ) async {
    final result = <permission_handler.Permission, bool>{};
    for (final permission in permissions) {
      result[permission] = await checkPermission(permission);
    }
    return result;
  }

  @override
  Future<Map<permission_handler.Permission, bool>> requestPermissions(
    List<permission_handler.Permission> permissions,
  ) async {
    final statuses = await permissions.request();
    final result = <permission_handler.Permission, bool>{};
    for (final permission in permissions) {
      result[permission] = statuses[permission]?.isGranted ?? false;
    }
    return result;
  }

  @override
  Future<bool> areAllPermissionsGranted() async {
    final statuses = await requiredPermissions.request();
    return statuses.values.every((status) => status.isGranted);
  }

  @override
  Future<bool> requestAllPermissions() async {
    final statuses = await requiredPermissions.request();
    return statuses.values.every((status) => status.isGranted);
  }

  @override
  Future<PermissionInfo> getPermissionInfo(permission_handler.Permission permission) async {
    final status = await permission.status;
    final descriptions = {
      permission_handler.Permission.microphone: 'Microphone access for voice commands',
      permission_handler.Permission.contacts: 'Contact access for calling and messaging',
      permission_handler.Permission.phone: 'Phone call permissions',
      permission_handler.Permission.location: 'Location for location-based commands',
      permission_handler.Permission.notification: 'Notifications for reminders and alerts',
      permission_handler.Permission.bluetooth: 'Bluetooth device control',
      permission_handler.Permission.bluetoothScan: 'Bluetooth scanning',
      permission_handler.Permission.bluetoothConnect: 'Bluetooth connection',
    };

    return PermissionInfo(
      permission: permission,
      status: status,
      description: descriptions[permission] ?? 'Unknown permission',
    );
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

// Proper implementation extending ChangeNotifier
class DefaultPermissionServiceImpl extends ChangeNotifier
    implements PermissionService {
  @override
  List<permission_handler.Permission> get requiredPermissions => [
        permission_handler.Permission.microphone,
        permission_handler.Permission.contacts,
        permission_handler.Permission.phone,
        permission_handler.Permission.location,
        permission_handler.Permission.notification,
        permission_handler.Permission.bluetooth,
        permission_handler.Permission.bluetoothScan,
        permission_handler.Permission.bluetoothConnect,
      ];

  @override
  Future<bool> checkPermission(permission_handler.Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestPermission(permission_handler.Permission permission) async {
    final status = await permission.request();
    notifyListeners();
    return status.isGranted;
  }

  @override
  Future<Map<permission_handler.Permission, bool>> checkPermissions(
      List<permission_handler.Permission> permissions) async {
    final result = <permission_handler.Permission, bool>{};
    for (final permission in permissions) {
      result[permission] = await checkPermission(permission);
    }
    return result;
  }

  @override
  Future<Map<permission_handler.Permission, bool>> requestPermissions(
      List<permission_handler.Permission> permissions) async {
    final statuses = await permissions.request();
    final result = <permission_handler.Permission, bool>{};
    for (final permission in permissions) {
      result[permission] = statuses[permission]?.isGranted ?? false;
    }
    notifyListeners();
    return result;
  }

  @override
  Future<bool> areAllPermissionsGranted() async {
    final statuses = await requiredPermissions.request();
    return statuses.values.every((status) => status.isGranted);
  }

  @override
  Future<bool> requestAllPermissions() async {
    final statuses = await requiredPermissions.request();
    notifyListeners();
    return statuses.values.every((status) => status.isGranted);
  }

  @override
  Future<PermissionInfo> getPermissionInfo(permission_handler.Permission permission) async {
    final status = await permission.status;
    final descriptions = {
      permission_handler.Permission.microphone: 'Microphone access for voice commands',
      permission_handler.Permission.contacts: 'Contact access for calling and messaging',
      permission_handler.Permission.phone: 'Phone call permissions',
      permission_handler.Permission.location: 'Location for location-based commands',
      permission_handler.Permission.notification: 'Notifications for reminders and alerts',
      permission_handler.Permission.bluetooth: 'Bluetooth device control',
      permission_handler.Permission.bluetoothScan: 'Bluetooth scanning',
      permission_handler.Permission.bluetoothConnect: 'Bluetooth connection',
    };

    return PermissionInfo(
      permission: permission,
      status: status,
      description: descriptions[permission] ?? 'Unknown permission',
    );
  }

  @override
  Future<void> openAppSettings() async {
    await permission_handler.openAppSettings();
  }
}
