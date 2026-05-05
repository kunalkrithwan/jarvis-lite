# JARVIS Lite - Setup Guide

## Initial Setup on Linux

### Step 1: Install Flutter
```bash
# Download Flutter SDK
cd ~
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:~/flutter/bin"

# Verify installation
flutter --version
flutter doctor
```

### Step 2: Install Android SDK
```bash
# Install Android Studio or just the SDK
sudo apt-get install android-sdk

# Or use Android Studio
# Download from: https://developer.android.com/studio

# Set environment variables
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

### Step 3: Setup JARVIS Lite Project

```bash
cd /home/whoami/AI_phone_assistant/jarvis_lite

# Get dependencies
flutter pub get

# Run on emulator or device
flutter run -v
```

### Step 4: Create Android Emulator (if needed)

```bash
# Download a system image
sdkmanager "system-images;android-34;google_apis;arm64-v8a"

# Create AVD
avdmanager create avd -n "Pixel_5_API_34" -k "system-images;android-34;google_apis;arm64-v8a" -d pixel_5

# Launch emulator
emulator -avd Pixel_5_API_34
```

## Development Workflow

### Hot Reload During Development
```bash
flutter run
# Press 'r' to hot reload code changes
# Press 'R' to hot restart (with assets)
# Press 'q' to quit
```

### Build Debug APK
```bash
flutter build apk --debug
# Output: build/app/outputs/apk/debug/app-debug.apk
```

### Build Release APK
```bash
flutter build apk --release
# Output: build/app/outputs/apk/release/app-release.apk
```

### Install on Device
```bash
adb install -r build/app/outputs/apk/debug/app-debug.apk
```

## Project Structure Overview

```
jarvis_lite/
├── android/              # Android native code
├── lib/
│   ├── core/            # Services (voice, intent, pipeline, etc.)
│   ├── features/        # Feature modules
│   ├── data/            # Data layer (models, repos, DB)
│   ├── domain/          # Domain layer (entities)
│   ├── ui/              # User interface
│   └── main.dart        # App entry point
├── assets/              # Images, fonts, models
├── pubspec.yaml        # Dependencies
└── README.md
```

## Core Architecture: Clean Architecture + Domain-Driven Design

### Service Locator (GetIt)
All services are registered in `service_locator.dart` at app startup:
```dart
// In main.dart
await setupServiceLocator();
```

Access anywhere:
```dart
final voice = getIt<VoiceService>();
final taskManager = getIt<TaskManagerService>();
```

## Mock Implementations for Development

### Voice Service (Mock)
The `MockVoiceService` simulates voice recognition without actual audio processing:
```dart
// Automatically used in development
await voice.startListening();
// Simulates listening for 2 seconds
await voice.speak("Playing response");
```

### Intent Engine (Rule-Based)
Uses regex patterns for command matching. Add custom patterns:
```dart
final engine = getIt<IntentEngineService>();
engine.addIntentPattern(
  r'remind me to (.*)',
  'setReminder',
  parameters: {'action': 'schedule'},
);
```

### Platform Channels
Android method calls in `MainActivity.kt`:
```kotlin
"toggleWifi" -> result(toggleWifi(enable))
"launchApp" -> result(launchApp(packageName))
```

## Database Management

### SQLite Tables
- **commands**: Stores command history
- **tasks**: Stores task data

### Query Examples
```dart
final repo = getIt<LocalCommandRepository>();
final commands = await repo.getRecentCommands(10);
await repo.saveCommand(commandModel);
```

## Testing the App

### Run Unit Tests
```bash
flutter test
```

### Run Integration Tests
```bash
flutter test integration_test/
```

### Manual Testing Checklist
- [ ] App launches without errors
- [ ] Voice button animates
- [ ] Can create tasks
- [ ] Task list displays
- [ ] Can complete/delete tasks
- [ ] System info displays correctly
- [ ] Settings persist after restart

## Common Issues & Solutions

### Issue: "Flutter not found"
```bash
export PATH="$PATH:~/flutter/bin"
```

### Issue: Gradle build fails
```bash
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
```

### Issue: Microphone permission denied
- Grant in Android Settings > Apps > JARVIS Lite > Permissions
- Or rebuild after allowing permissions at startup

### Issue: Database file locked
```bash
adb shell pm clear com.jarvis.lite
flutter run
```

## Next Steps for Full Integration

1. **Replace Mock Voice Service**
   - Integrate Vosk or vosk-flutter package
   - Implement actual audio recording
   - Add wake word detection

2. **Add TensorFlow Lite**
   - Install tflite_flutter package
   - Add intent classification model
   - Implement model inference

3. **Implement Foreground Service**
   - Add notification for continuous listening
   - Implement proper battery handling
   - Add wake lock management

4. **Connect Reminder System**
   - Integrate alarm scheduling
   - Add notification display
   - Set up background tasks

## Useful Commands

```bash
# Clean everything
flutter clean

# Get latest packages
flutter pub get

# Upgrade packages
flutter pub upgrade

# Format code
dart format lib/

# Analyze code
dart analyze

# Generate documentation
dartdoc

# View logs
adb logcat -s flutter

# List connected devices
adb devices

# Kill server
adb kill-server
```

## Performance Profiling

### Check RAM usage
```bash
# In Android Studio
# Open Logcat and filter: memory
adb shell dumpsys meminfo com.jarvis.lite
```

### Frame rate monitoring
```dart
// In main.dart
debugPrintBeginFrameBanner = true;
debugPrintEndFrameBanner = true;
```

## References

- Service Implementation: `lib/core/services/`
- Domain Entities: `lib/domain/entities/`
- UI Components: `lib/ui/widgets/`
- Android Integration: `android/app/src/main/`

---

For latest updates, check the main README.md file.
