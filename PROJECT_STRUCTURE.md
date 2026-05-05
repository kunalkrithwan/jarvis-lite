# Project Structure

JARVIS Lite uses a clean, modular architecture optimized for maintainability and testability.

## Directory Structure

```
jarvis_lite/
│
├── lib/                           # Flutter Dart code
│   │
│   ├── main.dart                 # App entry point
│   │
│   ├── core/                     # Core services and utilities
│   │   ├── services/            # Abstract and concrete services
│   │   │   ├── voice_service.dart
│   │   │   ├── intent_engine.dart
│   │   │   ├── task_pipeline_service.dart
│   │   │   ├── battery_optimization_service.dart
│   │   │   ├── context_memory_service.dart
│   │   │   ├── permission_service.dart
│   │   │   └── platform_channel_service.dart
│   │   │
│   │   └── utils/
│   │       ├── service_locator.dart      # Dependency injection
│   │       └── examples.dart             # Usage examples
│   │
│   ├── features/                 # Feature modules (vertical slicing)
│   │   ├── voice/               # Voice recognition features
│   │   ├── commands/            # Command handling features
│   │   ├── tasks/               # Task management features
│   │   │   └── task_manager_service.dart
│   │   └── system_control/      # System control features
│   │
│   ├── data/                    # Data layer
│   │   ├── models/              # Data models (extend domain entities)
│   │   │   ├── command_model.dart
│   │   │   └── task_model.dart
│   │   │
│   │   ├── repositories/        # Repository implementations
│   │   │
│   │   └── local/               # Local data sources
│   │       └── app_database.dart       # SQLite + Repository impl
│   │
│   ├── domain/                  # Domain layer (pure business logic)
│   │   ├── entities/            # Business entities
│   │   │   ├── command_entity.dart
│   │   │   ├── task_entity.dart
│   │   │   ├── execution_pipeline.dart
│   │   │   ├── intent_entity.dart
│   │   │   └── context_memory.dart
│   │   │
│   │   └── repositories/        # Repository abstractions
│   │       └── abstract_repositories.dart
│   │
│   └── ui/                      # Presentation layer
│       ├── pages/               # Full page screens
│       │   └── home_page.dart
│       │
│       ├── widgets/             # Reusable components
│       │   ├── animated_widgets.dart    # Animations
│       │   └── task_widgets.dart        # Task UI
│       │
│       └── theme/
│           └── app_theme.dart          # Material theming
│
├── android/                       # Android native code
│   ├── app/
│   │   ├── build.gradle          # App-level build config
│   │   └── src/
│   │       └── main/
│   │           ├── AndroidManifest.xml
│   │           ├── kotlin/
│   │           │   └── com/jarvis/lite/
│   │           │       ├── MainActivity.kt      # Method channels
│   │           │       └── services/
│   │           │           └── BackgroundServices.kt
│   │           │
│   │           └── res/
│   │               ├── values/
│   │               │   ├── colors.xml
│   │               │   └── styles.xml
│   │               └── drawable/
│   │
│   ├── build.gradle              # Project-level build config
│   └── settings.gradle           # Gradle wrapper settings
│
├── assets/                        # App assets
│   ├── models/                   # ML models (TFLite)
│   │   └── intent_classifier.tflite
│   │
│   ├── sounds/                   # Audio files
│   │   ├── wake_word.mp3
│   │   └── notification.mp3
│   │
│   ├── icons/                    # App icons
│   │   ├── ic_launcher.png
│   │   ├── ic_mic.png
│   │   └── ic_task.png
│   │
│   └── fonts/                    # Custom fonts
│       └── Roboto/
│
├── test/                          # Unit tests
│   ├── services_test.dart
│   └── models_test.dart
│
├── integration_test/             # Integration tests
│   └── app_test.dart
│
├── pubspec.yaml                  # Flutter dependencies
├── analysis_options.yaml         # Linter rules
│
├── README.md                     # Project documentation
├── SETUP.md                      # Setup instructions
└── ARCHITECTURE.md               # Architecture guide
```

## Key Concepts

### 1. Service Layer (core/services/)
All business logic lives in abstract services:
- Implement once, test everywhere
- Easy to mock for testing
- No UI dependencies
- Pure Dart code

### 2. Feature Modules (features/)
Vertical slicing by feature:
- Voice recognition
- Command execution
- Task management
- System control

Each feature may contain services, UI, and models.

### 3. Domain Entities (domain/entities/)
Pure business objects:
- No framework dependencies
- Immutable design
- Copyable for state management
- Clear contracts

### 4. Data Models (data/models/)
Extend domain entities:
- Add serialization/deserialization
- Map to database schema
- Convert from/to JSON

### 5. Repositories (data/repositories/)
Data access abstraction:
- Implement multiple sources (DB, API, cache)
- Domain layers don't know implementation
- Testable with fakes

## Naming Conventions

### Classes
- Service abstraction: `abstract class XyzService`
- Service implementation: `class DefaultXyzService`
- Entity: `class XyzEntity`
- Model: `class XyzModel`
- Repository: `class LocalXyzRepository`
- Widget: `class XyzWidget` or `class XyzPage`

### Files
- Services: `xyz_service.dart`
- Entities: `xyz_entity.dart`
- Models: `xyz_model.dart`
- Pages: `xyz_page.dart`
- Widgets: `xyz_widgets.dart`

### Methods
- Getters: `bool get isPaused`
- Factories: `factory CommandModel.fromJson(Map json)`
- Async operations: `Future<void> startListening()`
- Stream operations: `Stream<double> get voiceLevelStream`

## Dependencies Overview

```yaml
UI & Animation:
  flutter_animate          # Smooth animations
  provider                 # State management
  get                      # Navigation/state

Audio & Voice:
  record                   # Audio recording
  player                   # Audio playback
  audio_service            # Background audio
  flutter_sound            # Advanced audio
  flutter_tts              # Text-to-speech

ML & Inference:
  tflite_flutter           # TensorFlow Lite

Storage:
  sqflite                  # SQLite database
  hive_flutter             # Fast key-value store
  shared_preferences       # Simple KV storage

System & Permissions:
  permission_handler       # Permission management
  battery_plus             # Battery info
  device_info_plus         # Device info
  wakelock_plus            # Wake lock control

Background Processing:
  workmanager              # Background jobs
  background_fetch         # Periodic fetch

Utilities:
  get_it                   # Service locator
  uuid                     # UUID generation
  intl                     # Internationalization
```

## Module Dependencies Graph

```
UI Layer
   │
   ├─→ Presentation Widgets
   │      │
   │      └─→ Theme
   │
   └─→ Page Presentations
       │
       └─→ Core Services

Core Services (Abstract)
   │
   ├─→ VoiceService
   ├─→ IntentEngineService
   ├─→ TaskPipelineService
   ├─→ BatteryOptimizationService
   ├─→ ContextMemoryService
   ├─→ PermissionService
   └─→ PlatformChannelService

Data Repositories
   │
   ├─→ LocalCommandRepository
   ├─→ LocalTaskRepository
   ├─→ ContextMemoryRepository
   │
   └─→ Local Data Sources
       │
       ├─→ SQLite Database
       ├─→ SharedPreferences
       └─→ Platform Channels (Android)

Feature Services
   │
   ├─→ TaskManagerService
   └─→ Uses Core Services + Repositories
```

## Adding New Features

1. **Create feature directory**
   ```
   lib/features/new_feature/
   ```

2. **Define entities** (if domain-specific)
   ```dart
   // lib/domain/entities/new_entity.dart
   class NewEntity { ... }
   ```

3. **Create service abstraction**
   ```dart
   // lib/core/services/new_service.dart
   abstract class NewService { ... }
   class DefaultNewService implements NewService { ... }
   ```

4. **Implement data layer**
   ```dart
   // lib/data/models/new_model.dart
   class NewModel extends NewEntity { ... }
   ```

5. **Create UI components**
   ```dart
   // lib/ui/widgets/new_widgets.dart
   class NewWidget extends StatelessWidget { ... }
   ```

6. **Register in service locator**
   ```dart
   // lib/core/utils/service_locator.dart
   getIt.registerSingleton<NewService>(DefaultNewService());
   ```

7. **Use in UI**
   ```dart
   final service = getIt<NewService>();
   ```

## Code Organization Principles

✅ **Do**:
- Keep services focused (Single Responsibility)
- Use immutable entities
- Make everything testable
- Document complex logic
- Use abstractions for dependencies
- Keep UI separated from business logic

❌ **Don't**:
- Put business logic in widgets
- Mix data and UI concerns
- Create circular dependencies
- Use global state for everything
- Hardcode values
- Ignore error handling

---

For more details, see [ARCHITECTURE.md](ARCHITECTURE.md)
