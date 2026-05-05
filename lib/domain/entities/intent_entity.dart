/// Entity representing a recognized intent from voice input
class IntentEntity {
  final String id;
  final String text;
  final String primaryIntent;
  final List<String> secondaryIntents;
  final double confidence; // 0.0 to 1.0
  final Map<String, dynamic> slots; // Extracted parameters
  final DateTime recognizedAt;
  final List<String> requiredPermissions;

  IntentEntity({
    required this.id,
    required this.text,
    required this.primaryIntent,
    this.secondaryIntents = const [],
    this.confidence = 0.0,
    this.slots = const {},
    DateTime? recognizedAt,
    this.requiredPermissions = const [],
  }) : recognizedAt = recognizedAt ?? DateTime.now();

  bool get isHighConfidence => confidence >= 0.75;

  IntentEntity copyWith({
    String? id,
    String? text,
    String? primaryIntent,
    List<String>? secondaryIntents,
    double? confidence,
    Map<String, dynamic>? slots,
    DateTime? recognizedAt,
    List<String>? requiredPermissions,
  }) {
    return IntentEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      primaryIntent: primaryIntent ?? this.primaryIntent,
      secondaryIntents: secondaryIntents ?? this.secondaryIntents,
      confidence: confidence ?? this.confidence,
      slots: slots ?? this.slots,
      recognizedAt: recognizedAt ?? this.recognizedAt,
      requiredPermissions: requiredPermissions ?? this.requiredPermissions,
    );
  }
}
