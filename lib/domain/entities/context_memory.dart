/// Entity for storing context memory of user interactions
class ContextMemory {
  final String key;
  final dynamic value;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int accessCount;
  final DateTime? lastAccessedAt;

  ContextMemory({
    required this.key,
    required this.value,
    DateTime? createdAt,
    this.expiresAt,
    this.accessCount = 0,
    this.lastAccessedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  ContextMemory copyWith({
    String? key,
    dynamic value,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? accessCount,
    DateTime? lastAccessedAt,
  }) {
    return ContextMemory(
      key: key ?? this.key,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      accessCount: accessCount ?? this.accessCount,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }
}

/// User profile with personalization data
class UserProfile {
  final String id;
  final String nickname;
  final Map<String, dynamic> preferences;
  final List<String> favoriteApps;
  final List<String> favoriteContacts;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    this.nickname = 'User',
    this.preferences = const {},
    this.favoriteApps = const [],
    this.favoriteContacts = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  UserProfile copyWith({
    String? id,
    String? nickname,
    Map<String, dynamic>? preferences,
    List<String>? favoriteApps,
    List<String>? favoriteContacts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      preferences: preferences ?? this.preferences,
      favoriteApps: favoriteApps ?? this.favoriteApps,
      favoriteContacts: favoriteContacts ?? this.favoriteContacts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
