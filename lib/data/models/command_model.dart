import 'package:jarvis_lite/domain/entities/command_entity.dart';

/// Data model for Command (maps to database)
class CommandModel extends CommandEntity {
  CommandModel({
    required super.id,
    required super.text,
    super.transcribedText,
    required super.type,
    super.parameters,
    super.createdAt,
    super.status,
    super.result,
    super.executionTime,
  });

  /// Convert from JSON (from database)
  factory CommandModel.fromJson(Map<String, dynamic> json) {
    return CommandModel(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      transcribedText: json['transcribedText'],
      type: CommandType.values.firstWhere(
        (e) => e.toString() == 'CommandType.${json['type']}',
        orElse: () => CommandType.unknown,
      ),
      parameters: List<String>.from(json['parameters'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      status: CommandStatus.values.firstWhere(
        (e) => e.toString() == 'CommandStatus.${json['status']}',
        orElse: () => CommandStatus.pending,
      ),
      result: json['result'],
      executionTime: json['executionTime'] != null
          ? Duration(milliseconds: json['executionTime'])
          : null,
    );
  }

  /// Convert to JSON (to save in database)
  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'transcribedText': transcribedText,
    'type': type.toString().split('.').last,
    'parameters': parameters,
    'createdAt': createdAt.toIso8601String(),
    'status': status.toString().split('.').last,
    'result': result,
    'executionTime': executionTime?.inMilliseconds,
  };
}
