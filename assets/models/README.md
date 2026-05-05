# ML Models Directory

This directory contains TensorFlow Lite models for offline inference.

## Models to include (production):

1. **Intent Classification Model** (`intent_classifier.tflite`)
   - Lightweight model for classifying voice commands
   - Input: Text/audio features
   - Output: Intent classes with confidence scores

2. **Wake Word Detection Model** (`wake_word_detector.tflite`)
   - Keyword spotting model for "Hey Jarvis"
   - Input: Audio spectrogram
   - Output: Wake word detection probability

3. **Speech Recognition Model** (Optional - Vosk models)
   - Offline speech-to-text model
   - Small model for English language
   - ~50MB size

## Placeholder files:
- `.gitkeep` - Keep this directory in version control

## Note:
For production, download and place the actual TFLite models here.
The app is designed to work with mock implementations during development.
