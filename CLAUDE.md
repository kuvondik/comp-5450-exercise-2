# CLAUDE.md

Guidance for working with the COMP-5450 Mobile Programming Exercise 2 project.

## Project Overview

**Memory Match Game** — A Flutter-based mobile memory card matching game for COMP 5450 Exercise 2.

Players find matching pairs of cards within a 6×4 grid (24 cards / 12 pairs) using a 3D-flip animation, with persistent best-time tracking and save/resume functionality. Built with **Clean Architecture + MVVM**, dependency injection via GetIt, and SharedPreferences for persistence.

## Project Structure

```text
comp-5450-exercise-2/
├── README.md                                # User-facing documentation
├── CLAUDE.md                                # This file
├── docs/screenshots/                        # App screenshots (splash, menu, game, etc.)
└── memory_match/                            # Flutter project root
    ├── lib/
    │   ├── main.dart                        # App entry point with theme config
    │   └── layers/
    │       ├── domain/                      # Business Logic Layer (pure Dart)
    │       │   ├── entity/                  # MemoryCard, GameSession
    │       │   ├── constants/               # CardConstants (icon definitions)
    │       │   ├── repository/              # GameRepository (abstract interface)
    │       │   └── usecase/                 # GenerateNewGame, Get/Save/ClearBestTime,
    │       │                                # Get/Save/DeleteHighScore,
    │       │                                # Has/Load/Save/DeleteSavedGame
    │       ├── data/                        # Data Layer
    │       │   ├── source/local/            # LocalStorage (SharedPreferences wrapper)
    │       │   ├── dto/                     # GameSessionDto (serialization)
    │       │   └── game_repository_impl.dart
    │       └── presentation/                # UI Layer (MVVM)
    │           ├── injector.dart            # GetIt dependency injection setup
    │           ├── splash/view/             # SplashPage (3-sec animated intro)
    │           ├── main_menu/
    │           │   ├── viewmodel/           # MainMenuViewModel
    │           │   └── view/                # MainMenuPage
    │           ├── game/
    │           │   ├── viewmodel/           # GameViewModel
    │           │   └── view/                # GamePage (board, pause, victory dialogs)
    │           └── shared/                  # CardWidget, GameTimerNotifier,
    │                                        # MenuButton, HudBar
    ├── pubspec.yaml                         # Dart/Flutter dependencies
    ├── test/                                # Widget tests
    ├── ios/                                 # iOS build files
    └── android/                             # Android build files
```

## Architecture

### Clean Architecture + MVVM (presentation layer only)

- **Domain Layer** — Pure Dart business logic. No Flutter imports outside `material.dart` for `IconData` in `CardConstants`. Defines entities, repository interfaces, and use cases.
- **Data Layer** — Implements repositories, handles persistence (SharedPreferences), DTO serialization.
- **Presentation Layer (MVVM)** — ViewModels extend `ChangeNotifier`; Views use `ListenableBuilder` for reactive rebuilds.

### Key Architectural Decisions

- **No external state management framework** — uses Flutter's built-in `ChangeNotifier` + `ListenableBuilder`.
- **Dependency Injection** — All dependencies registered in `injector.dart` via GetIt (singletons for repositories/storage, factories for use cases and ViewModels).
- **Timer is a separate `ChangeNotifier`** (`GameTimerNotifier`) wrapped in its own `ListenableBuilder` so per-second timer ticks do not rebuild the 24-card grid.
- **Card icons live in `domain/constants/card_constants.dart`** as a single source of truth — both `GenerateNewGame` and `GameSessionDto` consume them.

## Key Files & Responsibilities

### Domain

- **`entity/memory_card.dart`** — Card model: `value`, `icon`, `isFlipped`, `isMatched`
- **`entity/game_session.dart`** — Session state: cards, moves, matchedPairs, elapsedSeconds
- **`constants/card_constants.dart`** — Shared `IconData` list + `getIconForValue(int)`
- **`repository/game_repository.dart`** — Abstract interface for all storage operations
- **`usecase/*.dart`** — 11 use cases, one per file: GenerateNewGame; GetBestTime, SaveBestTime, ClearBestTime; HasSavedGame, LoadSavedGame, SaveCurrentGame, DeleteSavedGame; **(unused/dead)** GetHighScore, SaveHighScore, DeleteHighScore — leftover from an earlier "high score" concept that was replaced by best-time tracking; not registered in `injector.dart`, safe to delete

### Data

- **`source/local/local_storage.dart`** — SharedPreferences wrapper; keys for high score, best time, saved game
- **`dto/game_session_dto.dart`** — Pipe-delimited serialization (`matchedPairs|moves|elapsedSeconds|cardStates`)
- **`game_repository_impl.dart`** — Bridges domain repository ↔ LocalStorage + DTO

### Presentation

- **`injector.dart`** — GetIt configuration; register here when adding new use cases or ViewModels
- **`game/viewmodel/game_view_model.dart`** — Holds cards, moves, match logic, owns `GameTimerNotifier`
- **`shared/game_timer_notifier.dart`** — Independent timer state; `start/pause/resume/reset/stop`
- **`shared/card_widget.dart`** — 3D flip animation via `Matrix4.rotateY`; wrapped in `RepaintBoundary`; explicit `CurvedAnimation` disposal
- **`game/view/game_page.dart`** — HudBar wrapped in separate `ListenableBuilder` listening to `timerNotifier`; game-over detected via `addPostFrameCallback` inside main `ListenableBuilder`

## Development Workflow

### Setup

```bash
cd memory_match
flutter pub get          # Install dependencies
flutter doctor           # Verify Flutter/Xcode/Android setup
```

### Running

```bash
flutter run              # Run on default device/emulator
flutter run -d <device>  # Run on specific device
flutter devices          # List available devices
```

### Testing & Analysis

```bash
flutter test                        # Run all widget tests
flutter test test/widget_test.dart  # Run specific test file
flutter analyze                     # Static analysis (flutter_lints) — must show 0 issues
```

### Building for Release

```bash
flutter build ios --release    # iOS → build/ios/iphoneos/Runner.app
flutter build apk --release    # Android → build/app/outputs/flutter-apk/app-release.apk
```

## Dependencies

- **`get_it`** — Service locator for dependency injection
- **`shared_preferences`** — Local persistent storage
- **`flutter_lints`** — Default Flutter lint rules (no custom overrides)

## Dart/Flutter Conventions

- **Dart SDK:** `^3.11.5`
- **Linting:** `package:flutter_lints/flutter.yaml` — must pass `flutter analyze` with 0 issues
- **State Management:** `ChangeNotifier` + `ListenableBuilder` (no Provider/Riverpod/Bloc)
- **Theme:** Material 3 (`useMaterial3: true`) with teal seed color

## Game Configuration

### Grid Size

Edit `lib/layers/presentation/game/viewmodel/game_view_model.dart`:

```dart
final int _gridRows = 6;
final int _gridCols = 4;
```

Total cards must be even (each card needs a pair).

### Card Icons

Edit `lib/layers/domain/constants/card_constants.dart` — single source of truth for both new-game generation and saved-game deserialization. The list length must be ≥ `(rows * cols) / 2`.

### Theme Colors

Edit `lib/main.dart`:

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
  useMaterial3: true,
)
```

## Game Mechanics

- **Match window**: 400ms delay after second card flips before match check (matches the 400ms flip animation duration in `CardWidget`, so the check fires as the flip completes)
- **Match**: Both cards stay open with green border + green icon tint
- **No match**: Both cards flip back automatically
- **Win condition**: `matchedPairs == totalPairs` (12 for 6×4 grid)
- **Timer**: Starts on game load, pauses when pause menu opens (resumes on Resume), stops on victory
- **Best time**: Auto-saved on victory if `elapsedSeconds < currentBestTime` (or no record exists)
- **Time format**: `45s` (<1m), `02m:30s` (<1h), `01h:23m:45s` (≥1h)

## Performance Notes

When modifying presentation code, preserve these optimizations:

- **`HudBar` lives in its own `ListenableBuilder`** listening to `_viewModel.timerNotifier`, not `_viewModel` — prevents the 24-card grid from rebuilding every second.
- **`CardWidget` is wrapped in `RepaintBoundary`** — isolates GPU repaints during flip animation.
- **`CurvedAnimation` is explicitly disposed** in `CardWidget` alongside the `AnimationController`.
- **`_perspective = 0.001`** is cached as a static const in `CardWidget` rather than allocated per frame.
- **`GameViewModel.dispose()` is called** from `GamePage.dispose()` — without this the timer leaks across navigations.

## Debugging

- `debugPrint()` for console output (preferred over `print()`)
- Hot reload: press `r` during `flutter run`; `R` for hot restart; `q` to quit
- DevTools: `flutter pub global activate devtools && devtools`

## Notes

- Exercise is self-contained in `memory_match/`
- No external APIs or network calls
- All persistence via SharedPreferences (no SQLite, no remote backend)
- Screenshots live in `docs/screenshots/` and are referenced from `README.md`
