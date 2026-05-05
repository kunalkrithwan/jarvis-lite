import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jarvis_lite/domain/entities/context_memory.dart';

/// Context Memory Service
/// Stores:
/// - Last commands
/// - User preferences
/// - Personalization data
/// - Application state
abstract class ContextMemoryService {
  /// Get memory value by key
  Future<dynamic> getMemory(String key);

  /// Store memory value
  Future<void> setMemory(String key, dynamic value, {DateTime? expiresAt});

  /// Delete memory
  Future<void> deleteMemory(String key);

  /// Get all memories
  Future<Map<String, dynamic>> getAllMemories();

  /// Get user profile
  Future<UserProfile?> getUserProfile();

  /// Save user profile
  Future<void> saveUserProfile(UserProfile profile);

  /// Get recent commands
  Future<List<String>> getRecentCommands(int limit);

  /// Add command to history
  Future<void> addCommandToHistory(String command);

  /// Clear expired memories
  Future<void> clearExpiredMemories();

  /// Clear all memories
  Future<void> clearAllMemories();
}

/// Default implementation using SharedPreferences
class DefaultContextMemoryService implements ContextMemoryService {
  late SharedPreferences _prefs;

  static const String _memoryPrefix = 'memory_';
  static const String _expiryPrefix = 'expiry_';
  static const String _userProfileKey = 'user_profile';
  static const String _commandHistoryKey = 'command_history';

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<dynamic> getMemory(String key) async {
    await _init();

    final fullKey = '$_memoryPrefix$key';
    final expiryKey = '$_expiryPrefix$key';

    // Check if expired
    if (_prefs.containsKey(expiryKey)) {
      final expiryStr = _prefs.getString(expiryKey);
      if (expiryStr != null) {
        final expiry = DateTime.parse(expiryStr);
        if (DateTime.now().isAfter(expiry)) {
          await deleteMemory(key);
          return null;
        }
      }
    }

    final value = _prefs.get(fullKey);
    return value;
  }

  @override
  Future<void> setMemory(
    String key,
    dynamic value, {
    DateTime? expiresAt,
  }) async {
    await _init();

    final fullKey = '$_memoryPrefix$key';

    if (value is String) {
      await _prefs.setString(fullKey, value);
    } else if (value is int) {
      await _prefs.setInt(fullKey, value);
    } else if (value is double) {
      await _prefs.setDouble(fullKey, value);
    } else if (value is bool) {
      await _prefs.setBool(fullKey, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(fullKey, value);
    } else {
      // Serialize as JSON
      await _prefs.setString(fullKey, jsonEncode(value));
    }

    if (expiresAt != null) {
      final expiryKey = '$_expiryPrefix$key';
      await _prefs.setString(expiryKey, expiresAt.toIso8601String());
    }
  }

  @override
  Future<void> deleteMemory(String key) async {
    await _init();

    final fullKey = '$_memoryPrefix$key';
    final expiryKey = '$_expiryPrefix$key';

    await _prefs.remove(fullKey);
    await _prefs.remove(expiryKey);
  }

  @override
  Future<Map<String, dynamic>> getAllMemories() async {
    await _init();

    final result = <String, dynamic>{};
    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_memoryPrefix)) {
        final cleanKey = key.replaceFirst(_memoryPrefix, '');
        final value = await getMemory(cleanKey);
        if (value != null) {
          result[cleanKey] = value;
        }
      }
    }
    return result;
  }

  @override
  Future<UserProfile?> getUserProfile() async {
    await _init();

    final profileJson = _prefs.getString(_userProfileKey);
    if (profileJson != null) {
      try {
        final json = jsonDecode(profileJson) as Map<String, dynamic>;
        return UserProfile(
          id: json['id'] ?? 'default',
          nickname: json['nickname'] ?? 'User',
          preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
          favoriteApps: List<String>.from(json['favoriteApps'] ?? []),
          favoriteContacts: List<String>.from(json['favoriteContacts'] ?? []),
        );
      } catch (e) {
        return null;
      }
    }
    return UserProfile(id: 'default');
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    await _init();

    final json = {
      'id': profile.id,
      'nickname': profile.nickname,
      'preferences': profile.preferences,
      'favoriteApps': profile.favoriteApps,
      'favoriteContacts': profile.favoriteContacts,
    };
    await _prefs.setString(_userProfileKey, jsonEncode(json));
  }

  @override
  Future<List<String>> getRecentCommands(int limit) async {
    await _init();

    final history = _prefs.getStringList(_commandHistoryKey) ?? [];
    return history.take(limit).toList();
  }

  @override
  Future<void> addCommandToHistory(String command) async {
    await _init();

    final history = _prefs.getStringList(_commandHistoryKey) ?? [];
    history.insert(0, command);

    // Keep only last 100 commands
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }

    await _prefs.setStringList(_commandHistoryKey, history);
  }

  @override
  Future<void> clearExpiredMemories() async {
    await _init();

    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_expiryPrefix)) {
        final expiryStr = _prefs.getString(key);
        if (expiryStr != null) {
          try {
            final expiry = DateTime.parse(expiryStr);
            if (now.isAfter(expiry)) {
              final memoryKey = key.replaceFirst(_expiryPrefix, '');
              keysToRemove.add(memoryKey);
            }
          } catch (e) {
            // Invalid date, remove
            keysToRemove.add(key.replaceFirst(_expiryPrefix, ''));
          }
        }
      }
    }

    for (final key in keysToRemove) {
      await deleteMemory(key);
    }
  }

  @override
  Future<void> clearAllMemories() async {
    await _init();

    final keysToRemove = <String>[];
    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_memoryPrefix) || key.startsWith(_expiryPrefix)) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      await _prefs.remove(key);
    }
  }
}
