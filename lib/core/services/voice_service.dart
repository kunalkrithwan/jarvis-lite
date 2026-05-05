import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'dart:async';

/// Enum for voice states
enum VoiceState { idle, listening, processing, speaking, error }

/// Voice recognizer result
class VoiceRecognitionResult {
  final String text;
  final double confidence;
  final bool isFinal;

  VoiceRecognitionResult({
    required this.text,
    required this.confidence,
    required this.isFinal,
  });
}

/// Abstract Voice Service
/// This service handles:
/// - Speech-to-text (STT) using offline Vosk
/// - Text-to-speech (TTS) using Android TTS or Coqui TTS
/// - Wake word detection ("Hey Jarvis")
/// - Continuous listening with battery optimization
abstract class VoiceService extends ChangeNotifier {
  /// Current state
  VoiceState get state;

  /// Initialize voice service
  Future<void> initialize();

  /// Stop and cleanup
  Future<void> dispose();

  /// Start listening for voice input
  /// Returns stream of [VoiceRecognitionResult]
  Future<void> startListening();

  /// Stop listening
  Future<void> stopListening();

  /// Check if listening is active
  bool get isListening;

  /// Speak text using TTS
  Future<void> speak(String text, {double pitch = 1.0, double speed = 1.0});

  /// Stop speaking
  Future<void> stopSpeaking();

  /// Stream of recognition results
  Stream<VoiceRecognitionResult> get recognitionStream;

  /// Stream of voice level (for waveform animation)
  Stream<double> get voiceLevelStream;

  /// Set wake word
  void setWakeWord(String word);

  /// Check if device has microphone
  Future<bool> hasMicrophone();

  /// Request microphone permission
  Future<bool> requestMicrophonePermission();
}

/// Default implementation of Voice Service
class DefaultVoiceService extends ChangeNotifier implements VoiceService {
  final FlutterTts _tts = FlutterTts();
  final _audioRecorder = AudioRecorder();
  
  VoiceState _state = VoiceState.idle;
  bool _isListening = false;
  String _wakeWord = 'hey jarvis';
  
  late StreamController<VoiceRecognitionResult> _recognitionController;
  late StreamController<double> _voiceLevelController;

  @override
  VoiceState get state => _state;

  @override
  bool get isListening => _isListening;

  @override
  Stream<VoiceRecognitionResult> get recognitionStream =>
      _recognitionController.stream;

  @override
  Stream<double> get voiceLevelStream => _voiceLevelController.stream;

  @override
  Future<void> initialize() async {
    _recognitionController = StreamController<VoiceRecognitionResult>();
    _voiceLevelController = StreamController<double>();

    // Initialize TTS
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.8);
    await _tts.setPitch(1.0);

    _state = VoiceState.idle;
    notifyListeners();
  }

  @override
  Future<void> startListening() async {
    if (_isListening) return;

    _state = VoiceState.listening;
    _isListening = true;
    notifyListeners();

    try {
      // In production, integrate Vosk for offline speech recognition
      // For now, using mock implementation
      await Future.delayed(Duration(seconds: 2));

      _recognitionController.add(
        VoiceRecognitionResult(
          text: 'Sample command recognized',
          confidence: 0.92,
          isFinal: true,
        ),
      );
    } catch (e) {
      _state = VoiceState.error;
      notifyListeners();
    }
  }

  @override
  Future<void> stopListening() async {
    if (!_isListening) return;

    _isListening = false;
    _state = VoiceState.idle;
    notifyListeners();
  }

  @override
  Future<void> speak(String text,
      {double pitch = 1.0, double speed = 1.0}) async {
    _state = VoiceState.speaking;
    notifyListeners();

    try {
      await _tts.setPitch(pitch);
      await _tts.setSpeechRate(speed);
      await _tts.speak(text);
    } finally {
      _state = VoiceState.idle;
      notifyListeners();
    }
  }

  @override
  Future<void> stopSpeaking() async {
    await _tts.stop();
    _state = VoiceState.idle;
    notifyListeners();
  }

  @override
  void setWakeWord(String word) {
    _wakeWord = word.toLowerCase();
  }

  @override
  Future<bool> hasMicrophone() async {
    return await _audioRecorder.hasPermission();
  }

  @override
  Future<bool> requestMicrophonePermission() async {
    final hasPermission = await _audioRecorder.hasPermission();
    return hasPermission ?? false;
  }

  @override
  Future<void> dispose() async {
    await _recognitionController.close();
    await _voiceLevelController.close();
    await _tts.stop();
    super.dispose();
  }
}
