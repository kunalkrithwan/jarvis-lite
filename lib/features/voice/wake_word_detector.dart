import 'dart:async';
import 'package:flutter/foundation.dart';

/// Wake Word Detection Service
/// Detects wake words like "Hey Jarvis" from audio stream
/// Uses lightweight keyword spotting optimized for low-end devices
abstract class WakeWordDetector {
  /// Initialize the detector with wake word model
  Future<void> initialize({String wakeWord = 'hey jarvis'});

  /// Start detecting wake words
  /// Returns stream of detection events
  Stream<WakeWordEvent> startDetection();

  /// Stop detection
  Future<void> stopDetection();

  /// Set wake word
  void setWakeWord(String word);

  /// Get current wake word
  String get wakeWord;

  /// Check if detection is active
  bool get isDetecting;

  /// Get detection confidence threshold
  double get confidenceThreshold;

  /// Set detection confidence threshold
  void setConfidenceThreshold(double threshold);

  /// Cleanup resources
  Future<void> dispose();
}

/// Wake word detection event
class WakeWordEvent {
  final String detectedWord;
  final double confidence;
  final DateTime detectedAt;

  WakeWordEvent({
    required this.detectedWord,
    required this.confidence,
    DateTime? detectedAt,
  }) : detectedAt = detectedAt ?? DateTime.now();
}

/// Default implementation using lightweight keyword spotting
class DefaultWakeWordDetector implements WakeWordDetector {
  String _wakeWord = 'hey jarvis';
  bool _isDetecting = false;
  double _confidenceThreshold = 0.7;
  late StreamController<WakeWordEvent> _eventController;
  Timer? _detectionTimer;

  @override
  String get wakeWord => _wakeWord;

  @override
  bool get isDetecting => _isDetecting;

  @override
  double get confidenceThreshold => _confidenceThreshold;

  @override
  Future<void> initialize({String wakeWord = 'hey jarvis'}) async {
    _wakeWord = wakeWord.toLowerCase();
    _eventController = StreamController<WakeWordEvent>.broadcast();

    // In production, load TFLite model for keyword spotting
    // For now, using mock implementation
    print('WakeWordDetector initialized with word: $_wakeWord');
  }

  @override
  Stream<WakeWordEvent> startDetection() {
    if (_isDetecting) {
      return _eventController.stream;
    }

    _isDetecting = true;

    // Simulate wake word detection with periodic checks
    _detectionTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      // Mock detection - in production, this would process audio
      // For demonstration, randomly trigger detection
      if (DateTime.now().millisecond % 10 == 0) {
        _eventController.add(
          WakeWordEvent(
            detectedWord: _wakeWord,
            confidence: 0.85 + (DateTime.now().millisecond % 10) / 100.0,
          ),
        );
      }
    });

    return _eventController.stream;
  }

  @override
  Future<void> stopDetection() async {
    if (!_isDetecting) return;

    _isDetecting = false;
    _detectionTimer?.cancel();
    _detectionTimer = null;
  }

  @override
  void setWakeWord(String word) {
    _wakeWord = word.toLowerCase();
  }

  @override
  void setConfidenceThreshold(double threshold) {
    if (threshold >= 0.0 && threshold <= 1.0) {
      _confidenceThreshold = threshold;
    }
  }

  @override
  Future<void> dispose() async {
    await stopDetection();
    await _eventController.close();
  }
}

/// Simple pattern-based wake word detector
/// Uses string matching for wake word detection (fallback for low-end devices)
class PatternBasedWakeWordDetector implements WakeWordDetector {
  String _wakeWord = 'hey jarvis';
  bool _isDetecting = false;
  double _confidenceThreshold = 0.7;
  late StreamController<WakeWordEvent> _eventController;

  @override
  String get wakeWord => _wakeWord;

  @override
  bool get isDetecting => _isDetecting;

  @override
  double get confidenceThreshold => _confidenceThreshold;

  @override
  Future<void> initialize({String wakeWord = 'hey jarvis'}) async {
    _wakeWord = wakeWord.toLowerCase();
    _eventController = StreamController<WakeWordEvent>.broadcast();
  }

  @override
  Stream<WakeWordEvent> startDetection() {
    _isDetecting = true;
    return _eventController.stream;
  }

  /// Process text and check for wake word
  /// This is used when STT is available but wake word detection is not
  void processText(String text) {
    if (!_isDetecting) return;

    final normalizedText = text.toLowerCase();
    final words = _wakeWord.split(' ');

    // Check if all wake word parts are present in the text
    bool allWordsPresent = words.every((word) => normalizedText.contains(word));

    if (allWordsPresent) {
      // Calculate simple confidence based on word proximity
      double confidence = 0.8;
      if (normalizedText.contains(_wakeWord)) {
        confidence = 0.95;
      }

      if (confidence >= _confidenceThreshold) {
        _eventController.add(
          WakeWordEvent(
            detectedWord: _wakeWord,
            confidence: confidence,
          ),
        );
      }
    }
  }

  @override
  Future<void> stopDetection() async {
    _isDetecting = false;
  }

  @override
  void setWakeWord(String word) {
    _wakeWord = word.toLowerCase();
  }

  @override
  void setConfidenceThreshold(double threshold) {
    if (threshold >= 0.0 && threshold <= 1.0) {
      _confidenceThreshold = threshold;
    }
  }

  @override
  Future<void> dispose() async {
    await stopDetection();
    await _eventController.close();
  }
}
