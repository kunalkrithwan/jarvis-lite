import 'package:jarvis_lite/domain/entities/intent_entity.dart';
import 'package:jarvis_lite/domain/entities/command_entity.dart';

/// Intent classification confidence scores
class IntentScore {
  final String intent;
  final double score;

  IntentScore({required this.intent, required this.score});
}

/// Abstract Intent Engine Service
/// Hybrid system combining:
/// - Rule-based pattern matching (fast, deterministic)
/// - TensorFlow Lite model for classification (accurate)
abstract class IntentEngineService {
  /// Initialize the intent engine with models
  Future<void> initialize();

  /// Recognize intent from text
  /// Returns [IntentEntity] with recognized intent, slots, and confidence
  Future<IntentEntity> recognizeIntent(String text);

  /// Get top N intent predictions with confidence scores
  Future<List<IntentScore>> getPredictions(String text, {int topN = 5});

  /// Add custom rule-based intent pattern
  /// Example: "open {app}" -> appLaunch
  void addIntentPattern(
    String pattern,
    String intent, {
    Map<String, dynamic> parameters = const {},
  });

  /// Cache parsed model for quick inference
  Future<void> loadModel();

  /// Cleanup resources
  Future<void> dispose();

  /// Get all registered intents
  List<String> get registeredIntents;
}

/// Implementation using hybrid approach
class HybridIntentEngine implements IntentEngineService {
  /// Rule-based patterns for fast intent matching
  final Map<RegExp, Map<String, dynamic>> _rulePatterns = {};

  /// Confidence threshold for TFLite predictions
  static const double _confidenceThreshold = 0.6;

  /// Known command patterns for rule-based matching
  static const Map<String, List<RegExp>> _builtInPatterns = {
    'appLaunch': [
      RegExp(r'open\s+(\w+)', caseSensitive: false),
      RegExp(r'launch\s+(\w+)', caseSensitive: false),
      RegExp(r'start\s+(\w+)', caseSensitive: false),
    ],
    'toggleWifi': [
      RegExp(r'wifi\s+(on|off|toggle)', caseSensitive: false),
      RegExp(r'enable\s+wifi', caseSensitive: false),
      RegExp(r'disable\s+wifi', caseSensitive: false),
    ],
    'toggleBluetooth': [
      RegExp(r'bluetooth\s+(on|off|toggle)', caseSensitive: false),
      RegExp(r'enable\s+bluetooth', caseSensitive: false),
    ],
    'toggleFlashlight': [
      RegExp(r'flashlight\s+(on|off|toggle)', caseSensitive: false),
      RegExp(r'torch\s+(on|off)', caseSensitive: false),
    ],
    'setAlarm': [
      RegExp(
        r'set\s+alarm\s+(?:at\s+)?(\d{1,2}:\d{2}(?:\s*(?:am|pm))?)',
        caseSensitive: false,
      ),
      RegExp(r'alarm\s+(?:at\s+)?(\d{1,2}:\d{2})', caseSensitive: false),
    ],
    'setReminder': [
      RegExp(
        r'remind\s+(?:me\s+)?(?:to\s+)?(.*?)(?:\s+(?:at|in)\s+(.*))?$',
        caseSensitive: false,
      ),
      RegExp(r'set\s+reminder\s+(?:to\s+)?(.*)', caseSensitive: false),
    ],
    'playMedia': [
      RegExp(r'play\s+(.*?)(?:\s+on\s+(\w+))?$', caseSensitive: false),
      RegExp(r'music\s+(.*)', caseSensitive: false),
    ],
    'callContact': [
      RegExp(r'call\s+(\w+)', caseSensitive: false),
      RegExp(r'ring\s+(\w+)', caseSensitive: false),
    ],
    'sendMessage': [
      RegExp(
        r'(?:send|message)\s+(?:to\s+)?(\w+)\s+(?:message\s+)?(?:saying\s+)?(.*)',
        caseSensitive: false,
      ),
      RegExp(r'text\s+(\w+)\s+(.*)', caseSensitive: false),
    ],
  };

  @override
  Future<void> initialize() async {
    // Initialize TFLite model for intent classification
    // In production, load the actual TFLite model
    // For now, we use rule-based matching
    _initializeRulePatterns();
  }

  void _initializeRulePatterns() {
    _builtInPatterns.forEach((intent, patterns) {
      for (var pattern in patterns) {
        _rulePatterns[pattern] = {'intent': intent};
      }
    });
  }

  @override
  Future<IntentEntity> recognizeIntent(String text) async {
    // First, try rule-based matching (fast)
    final ruleResult = _matchRulePattern(text);
    if (ruleResult != null && ruleResult.confidence > _confidenceThreshold) {
      return ruleResult;
    }

    // Fallback: return generic intent with lower confidence
    return IntentEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      primaryIntent: CommandType.custom.toString(),
      confidence: 0.5,
      slots: {'rawText': text},
    );
  }

  IntentEntity? _matchRulePattern(String text) {
    for (var entry in _rulePatterns.entries) {
      final match = entry.key.firstMatch(text);
      if (match != null) {
        final intentName = entry.value['intent'] ?? 'custom';
        final slots = <String, dynamic>{'command': match.group(0)};

        // Extract parameters from regex groups
        for (int i = 0; i <= match.groupCount; i++) {
          if (match.group(i) != null) {
            slots['param_$i'] = match.group(i);
          }
        }

        return IntentEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          primaryIntent: intentName,
          confidence: 0.85,
          slots: slots,
        );
      }
    }
    return null;
  }

  @override
  Future<List<IntentScore>> getPredictions(String text, {int topN = 5}) async {
    final predictions = <IntentScore>[];

    // Score all patterns
    for (var entry in _rulePatterns.entries) {
      final match = entry.key.firstMatch(text);
      if (match != null) {
        final intent = entry.value['intent'] ?? 'custom';
        predictions.add(IntentScore(intent: intent, score: 0.85));
      }
    }

    // Sort by score and return top N
    predictions.sort((a, b) => b.score.compareTo(a.score));
    return predictions.take(topN).toList();
  }

  @override
  void addIntentPattern(
    String pattern,
    String intent, {
    Map<String, dynamic> parameters = const {},
  }) {
    _rulePatterns[RegExp(pattern, caseSensitive: false)] = {
      'intent': intent,
      ...parameters,
    };
  }

  @override
  Future<void> loadModel() async {
    // Load TFLite model asynchronously
    // This is called during app initialization
  }

  @override
  Future<void> dispose() async {
    // Cleanup resources
  }

  @override
  List<String> get registeredIntents {
    return _rulePatterns.values
        .map((e) => e['intent'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
  }
}
