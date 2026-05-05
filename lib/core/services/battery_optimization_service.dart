import 'package:battery_plus/battery_plus.dart';
import 'dart:async';

/// Battery optimization levels
enum BatteryOptimizationLevel { aggressive, moderate, minimal, off }

/// Battery status
class BatteryStatus {
  final int level; // 0-100
  final bool isCharging;
  final BatteryOptimizationLevel optimizationLevel;

  BatteryStatus({
    required this.level,
    required this.isCharging,
    this.optimizationLevel = BatteryOptimizationLevel.moderate,
  });
}

/// Battery Optimization Service
/// Implements adaptive power-saving strategies:
/// - Reduce voice listening frequency when battery low
/// - Optimize background processes
/// - Manage wake locks efficiently
abstract class BatteryOptimizationService {
  /// Get current battery status
  Future<BatteryStatus> getBatteryStatus();

  /// Stream battery level changes
  Stream<int> get batteryLevelStream;

  /// Set optimization level
  void setOptimizationLevel(BatteryOptimizationLevel level);

  /// Get current optimization level
  BatteryOptimizationLevel get optimizationLevel;

  /// Get recommended listening interval based on battery
  Duration getListeningInterval();

  /// Check if background processing should be active
  bool shouldRunBackgroundProcessing();

  /// Get maximum background wake lock duration
  Duration getMaxWakeLockDuration();

  /// Start power saving mode
  Future<void> enablePowerSavingMode();

  /// Stop power saving mode
  Future<void> disablePowerSavingMode();
}

/// Default implementation
class DefaultBatteryOptimizationService implements BatteryOptimizationService {
  final Battery _battery = Battery();
  BatteryOptimizationLevel _optimizationLevel =
      BatteryOptimizationLevel.moderate;
  int _lastBatteryLevel = 100;

  @override
  Future<BatteryStatus> getBatteryStatus() async {
    final level = await _battery.batteryLevel;
    final isCharging = await _battery.isInBatterySaverMode.then(
      (value) => !value,
    );

    _lastBatteryLevel = level;

    // Determine optimization level based on battery
    BatteryOptimizationLevel level_;
    if (level < 15) {
      level_ = BatteryOptimizationLevel.aggressive;
    } else if (level < 40) {
      level_ = BatteryOptimizationLevel.moderate;
    } else {
      level_ = BatteryOptimizationLevel.minimal;
    }

    return BatteryStatus(
      level: level,
      isCharging: isCharging,
      optimizationLevel: level_,
    );
  }

  @override
  Stream<int> get batteryLevelStream {
    return _battery.batteryStateChanged
        .asyncMap((_) => _battery.batteryLevel)
        .distinct();
  }

  @override
  void setOptimizationLevel(BatteryOptimizationLevel level) {
    _optimizationLevel = level;
  }

  @override
  BatteryOptimizationLevel get optimizationLevel => _optimizationLevel;

  @override
  Duration getListeningInterval() {
    switch (_optimizationLevel) {
      case BatteryOptimizationLevel.aggressive:
        return Duration(seconds: 30);
      case BatteryOptimizationLevel.moderate:
        return Duration(seconds: 10);
      case BatteryOptimizationLevel.minimal:
        return Duration(seconds: 3);
      case BatteryOptimizationLevel.off:
        return Duration(milliseconds: 500);
    }
  }

  @override
  bool shouldRunBackgroundProcessing() {
    return _optimizationLevel != BatteryOptimizationLevel.aggressive;
  }

  @override
  Duration getMaxWakeLockDuration() {
    switch (_optimizationLevel) {
      case BatteryOptimizationLevel.aggressive:
        return Duration(seconds: 30);
      case BatteryOptimizationLevel.moderate:
        return Duration(minutes: 5);
      case BatteryOptimizationLevel.minimal:
        return Duration(minutes: 30);
      case BatteryOptimizationLevel.off:
        return Duration(hours: 1);
    }
  }

  @override
  Future<void> enablePowerSavingMode() async {
    _optimizationLevel = BatteryOptimizationLevel.aggressive;
  }

  @override
  Future<void> disablePowerSavingMode() async {
    _optimizationLevel = BatteryOptimizationLevel.minimal;
  }
}
