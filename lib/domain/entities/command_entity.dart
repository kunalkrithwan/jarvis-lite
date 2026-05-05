/// Domain entity for a voice command
class CommandEntity {
  final String id;
  final String text;
  final String? transcribedText;
  final CommandType type;
  final List<String> parameters;
  final DateTime createdAt;
  final CommandStatus status;
  final String? result;
  final Duration? executionTime;

  CommandEntity({
    required this.id,
    required this.text,
    this.transcribedText,
    required this.type,
    this.parameters = const [],
    DateTime? createdAt,
    this.status = CommandStatus.pending,
    this.result,
    this.executionTime,
  }) : createdAt = createdAt ?? DateTime.now();

  CommandEntity copyWith({
    String? id,
    String? text,
    String? transcribedText,
    CommandType? type,
    List<String>? parameters,
    DateTime? createdAt,
    CommandStatus? status,
    String? result,
    Duration? executionTime,
  }) {
    return CommandEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      transcribedText: transcribedText ?? this.transcribedText,
      type: type ?? this.type,
      parameters: parameters ?? this.parameters,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      result: result ?? this.result,
      executionTime: executionTime ?? this.executionTime,
    );
  }
}

enum CommandType {
  appLaunch,
  callContact,
  sendMessage,
  toggleWifi,
  toggleBluetooth,
  toggleFlashlight,
  setAlarm,
  setReminder,
  playMedia,
  volumeControl,
  screenControl,
  systemInfo,
  custom,
  unknown,
}

enum CommandStatus {
  pending,
  recognized,
  executing,
  completed,
  failed,
  cancelled,
}
