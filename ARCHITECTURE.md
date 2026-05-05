# JARVIS Lite - Architecture Guide

## Clean Architecture Overview

JARVIS Lite follows Clean Architecture principles with a 4-layer structure:

```
┌─────────────────────────────────┐
│     UI/Presentation Layer       │  (Widgets, Pages, Themes)
├─────────────────────────────────┤
│      Domain Layer               │  (Entities, Repositories)
├─────────────────────────────────┤
│     Application Services        │  (Use cases, Services)
├─────────────────────────────────┤
│      Data Layer                 │  (Repositories, DataSources)
└─────────────────────────────────┘
```

### Layer Responsibilities

#### 1. Presentation Layer (`/lib/ui`)
- **Widgets**: Reusable UI components (AnimatedWaveform, VoiceCommandButton)
- **Pages**: Full screens (HomePage)
- **Theme**: App styling and constants
- **Responsibility**: Display data and capture user input

#### 2. Domain Layer (`/lib/domain`)
- **Entities**: Business logic model (CommandEntity, TaskEntity)
- **Repositories**: Abstract contracts for data access
- **Responsibility**: Business rules independent of frameworks

#### 3. Application Services Layer (`/lib/core/services`)
All services are abstract and highly testable:
- **VoiceService**: Speech recognition and synthesis
- **IntentEngineService**: Command classification
- **TaskPipelineService**: Multi-step execution
- **BatteryOptimizationService**: Power management
- **ContextMemoryService**: State persistence
- **PermissionService**: Permission management
- **PlatformChannelService**: Android integration

#### 4. Data Layer (`/lib/data`)
- **Models**: Data structures (CommandModel extends CommandEntity)
- **Repositories**: Concrete implementations
- **Local**: SQLite and SharedPreferences repositories
- **Responsibility**: Fetch and persist data

## Service Architecture

### Service Locator Pattern (GetIt)

All services are registered globally in `setup_service_locator()`:

```dart
// Access anywhere in the app
final voice = getIt<VoiceService>();
final tasks = getIt<TaskManagerService>();
```

**Benefits**:
- No prop drilling
- Easy testing with mock implementations
- Lazy initialization
- Centralized dependency management

### Dependency Injection

Interfaces (abstract classes) are injected at startup:

```dart
// In service_locator.dart
getIt.registerSingleton<VoiceService>(MockVoiceService());
getIt.registerSingleton<IntentEngineService>(HybridIntentEngine());
```

## Core Services Deep Dive

### 1. Voice Service
**Responsibility**: Manage voice input and output

```dart
abstract class VoiceService {
  Future<void> startListening();
  Future<void> stopListening();
  Future<void> speak(String text);
  Stream<VoiceRecognitionResult> get recognitionStream;
}
```

**Implementation**: MockVoiceService (development), Vosk integration (production)

### 2. Intent Engine
**Responsibility**: Convert text to structured commands

```dart
abstract class IntentEngineService {
  Future<IntentEntity> recognizeIntent(String text);
  Future<List<IntentScore>> getPredictions(String text, {int topN = 5});
  void addIntentPattern(String pattern, String intent);
}
```

**Implementation**: HybridIntentEngine
- Fast regex-based pattern matching
- Extensible rule system
- TensorFlow Lite integration ready

### 3. Task Pipeline Service
**Responsibility**: Execute multi-step commands

**Architecture**:
```
User Input → Voice Service → Intent Engine → Pipeline Service
     ↓              ↓              ↓              ↓
  "Play music"   listening    setIntent      [Stage 1, Stage 2...]
                                            Execute sequentially
```

**Pipeline Execution Flow**:
1. Create pipeline with stages
2. Execute stage-by-stage
3. Handle retries on failure
4. Stream updates to UI
5. Persist history

### 4. Battery Optimization Service
**Responsibility**: Adaptive resource management

**Optimization Levels**:
- **Aggressive**: 2-minute listening intervals (< 15% battery)
- **Moderate**: 45-second intervals (15-40% battery)
- **Minimal**: 10-second intervals (> 40% battery)
- **Off**: Always listening (charging)

**Effects**:
```
Battery Level  → Optimization → Listening Interval → Wake Lock Duration
100%          → Off           → 2 seconds          → 10 seconds
50%           → Minimal       → 10 seconds         → 5 seconds
30%           → Moderate      → 45 seconds         → 2 seconds
10%           → Aggressive    → 120 seconds        → 0.5 seconds
```

### 5. Context Memory Service
**Responsibility**: Store and retrieve application state

**Storage Strategies**:
- **SharedPreferences**: Simple KV pairs (commands, preferences)
- **SQLite**: Structured data (tasks, command history)
- **Memory**: Runtime cache (session data)

**Expiry Management**:
```dart
// Automatic cleanup of expired memories
await memoryService.clearExpiredMemories();
```

### 6. Permission Service
**Responsibility**: Centralized permission handling

**Required Permissions**:
```
MICROPHONE              → Voice input
CONTACTS               → Contact access
PHONE                  → Call making
ACCESS_FINE_LOCATION  → Location commands
NOTIFICATION          → Reminders
BLUETOOTH             → Device control
```

### 7. Platform Channel Service
**Responsibility**: Android system integration

**Method Channel**: `com.jarvis.lite/system`

**Available Methods**:
```kotlin
launchApp(packageName)        → Open application
toggleWifi(enable)            → Control WiFi
toggleBluetooth(enable)       → Control Bluetooth
toggleFlashlight(enable)      → Flashlight control
setAlarm(hour, minute, label) → Set alarm
makeCall(phoneNumber)         → Initiate call
sendSms(phoneNumber, message) → Send text
getSystemInfo()               → Device information
```

## Data Flow Example: "Open YouTube and Play Music"

```
User Voice Input
      ↓
[VoiceService]
  "open youtube and play music"
      ↓
[Intent Engine]
  Recognize: appLaunch + playMedia
  Create intent slots
      ↓
[Task Pipeline Service]
  Create 5 stages:
  1. Open YouTube app
  2. Wait 2 seconds
  3. Search for music
  4. Play first result
  5. Verify playback
      ↓
Retry failed stages (max 3 times)
      ↓
Voice feedback: "Playing music on YouTube"
      ↓
[Context Memory]
  Store command in history
  Log execution metrics
      ↓
[UI Updates]
  Show waveform animation
  Display command status
```

## Memory Management Strategy

### For 2GB RAM Devices

1. **Lazy Loading**: Services initialized on demand
2. **Stream Disposal**: Cancel streams when not in use
3. **Image Optimization**: Use cached images only
4. **Database Limits**:
   - Commands: Last 100 only
   - Tasks: Active tasks only
   - Memory: 1 hour expiry by default
5. **Isolates**: Heavy computation in separate thread

### Memory Limits

```dart
// Total allocation should be < 300MB:
- App base: ~50MB (Flutter framework)
- Services: ~30MB (voice, ML, etc.)
- Database: ~20MB (SQLite buffer)
- UI/Widgets: ~40MB (cached widgets)
- Reserve: ~160MB (buffer for OS, safety)
```

## Testing Strategy

### Unit Testing
```dart
// Mock services for testing
test('intent engine recognizes app launch', () async {
  final engine = HybridIntentEngine();
  await engine.initialize();
  
  final intent = await engine.recognizeIntent('open youtube');
  expect(intent.primaryIntent, 'appLaunch');
  expect(intent.slots['app'], 'youtube');
});
```

### Integration Testing
- Test full pipeline execution
- Verify data persistence
- Check Android platform channels
- Performance benchmarking

### Mock Implementations
- MockVoiceService (simulates listening)
- Fake databases (in-memory)
- Stubbed platform channels

## Performance Metrics

**Target Performance**:
- App startup: < 3 seconds
- Intent recognition: < 100ms
- Pipeline stage execution: < 500ms
- Voice feedback latency: < 1 second
- Database query: < 50ms

**Profiling Tools**:
```bash
# Check frame rate
flutter run --profile

# Capture performance trace
flutter screenshot --type=extension
```

## Extension Points

### Adding Custom Intent Patterns
```dart
final engine = getIt<IntentEngineService>();
engine.addIntentPattern(
  r'show me (.*)',
  'customSearch',
  parameters: {'action': 'search'},
);
```

### Custom Pipeline Stages
```dart
final customStage = PipelineStage(
  id: 'custom_1',
  name: 'Custom Action',
  type: 'custom',
  order: 0,
  parameters: {'customParam': 'value'},
);
```

### Custom Services
Implement abstract service and register:
```dart
getIt.registerSingleton<CustomService>(CustomServiceImpl());
```

## Production Checklist

- [ ] Replace MockVoiceService with real Vosk
- [ ] Integrate TensorFlow Lite model
- [ ] Implement proper foreground service
- [ ] Add encrypted storage for sensitive data
- [ ] Implement error reporting
- [ ] Add analytics
- [ ] Optimize database queries
- [ ] Profile memory usage
- [ ] Test on low-end devices
- [ ] Prepare app signing
- [ ] Write privacy policy
- [ ] Create release notes

---

For code examples, see [examples.dart](../core/utils/examples.dart)
