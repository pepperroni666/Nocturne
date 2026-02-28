# Nocturne — Claude Code Instructions

## Architecture

Nocturne is an iOS metronome app using **unidirectional data flow** (Redux/Elm-style):

- **State** — plain `Equatable`/`Sendable` struct (e.g. `MetronomeState`)
- **Action** — `Sendable` enum describing events, user + system (e.g. `MetronomeAction`)
- **Reducer** — conforms to `ReducerProtocol`: `static func reduce(state:action:dependencies:) -> Effect<Action>`
- **Dependencies** — closure-based struct injected into reducer (e.g. `MetronomeEffects`)
- **Store** (`Store<State, Action>`) — `@Observable @MainActor` orchestrator. Holds state, dispatches actions through reducer, executes effects

### Core protocols

- `ReducerProtocol` — defines `State`, `Action`, `Dependencies` associated types and a static `reduce` function
- `Effect<Action>` — enum describing side effects (`.none`, `.task`, `.stream`, `.merge`, `.cancel`)
- `Store<State, Action>` — generic store with convenience init accepting `ReducerProtocol` conformance

### Closure-based dependencies

Dependencies use **closures instead of protocols** for testability and flexibility:

```swift
struct MetronomeEffects: Sendable {
    var startEngine: @Sendable (Int, Int, [Bool], BeatSound) async throws -> AsyncStream<Tick>
    var stopEngine: @Sendable () async -> Void
    // ...
}
```

Each dependency struct provides:
- **`.live(...)`** — production implementation wiring to real services
- **`.mock`** — no-op implementation for tests (behind `#if DEBUG`)
- **Effect builder methods** — convenience methods that wrap closures into `Effect<Action>` values

Tests use `.mock` directly or override individual closures:
```swift
var deps = MetronomeEffects.mock
deps.loadSettings = { (88, .sixEight, .classic) }
```

### Adding a new feature

1. Create `Domain/{Feature}/` with `{Feature}State.swift`, `{Feature}Action.swift`, `{Feature}Reducer.swift`, `{Feature}Effects.swift`
2. Make reducer conform to `ReducerProtocol`
3. Define `{Feature}Effects` as a closure-based struct with `.live(...)` and `.mock` factories
4. Create `UI/{Feature}/` with SwiftUI views
5. Wire up in `AppCoordinator` using `Store(initial:reducer:dependencies:)`

### Folder structure

```
Core/                          — Generic TCA primitives
  Effect.swift
  Store.swift
  ReducerProtocol.swift
Domain/                        — Business logic (no UI imports)
  Metronome/                   — Metronome feature
    MetronomeState.swift
    MetronomeAction.swift
    MetronomeReducer.swift
    MetronomeEffects.swift
  Shared/                      — Shared domain models
    TimeSignature.swift
    AccentPattern.swift
    BeatSound.swift
Engine/                        — Audio engine
  MetronomeEngineProtocol.swift
  AVAudioMetronomeEngine.swift
Services/                      — Service implementations
  SettingsStoreProtocol.swift
  AppLifecycleProtocol.swift
Helpers/                       — Utilities
  Clamped.swift
UI/                            — SwiftUI views
  Metronome/                   — Metronome screen views
  Settings/                    — Settings screen views
  Shared/                      — Reusable components (Theme, BackgroundGradient)
  MainTabView.swift
App/                           — Composition root
  AppCoordinator.swift
Resources/                     — Assets (sounds, etc.)
```

### Key conventions

- All domain types are `Sendable`
- Engine is an `actor`
- Audio state uses `@unchecked Sendable` class shared with render callback (real-time audio thread)
- Effects use `Effect.stream` for long-running async sequences, `Effect.fireAndForget` for one-shot side effects
- Streams are identified by static `UUID`s for cancellation
- Reducer parameter is named `dependencies` (not `effects`)
- Dependencies are closure-based structs (not protocols) — see "Closure-based dependencies" above
- Tests use Swift Testing (`@Test`, `#expect`) with `.mock` dependency factories

## Workflow rules

### Do NOT build or run tests automatically
When making code changes, do NOT run `xcodebuild build` or `xcodebuild test`. Instead, after finishing the changes, write a short report:

1. **Files changed** — list each file and what was modified
2. **Files created** — list any new files and their purpose
3. **What to verify** — describe what the user should build/test and what behavior to check

### Do NOT run tests automatically
Same as above — describe which tests were added/modified and what they cover, but do not execute them.
