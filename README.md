# Nocturne

An iOS metronome and tuner app.

## Features

- **Metronome** — tap tempo, time signature, accent patterns, beat sounds
- **Tuner** — chromatic pitch detection with cents display and reference tone

## Architecture

Unidirectional data flow (TCA-inspired):

```
Action → Reducer → State + Effect
                         ↓
                    Store executes
                    Effect → Action
```

- `Store<State, Action>` — `@Observable @MainActor` orchestrator
- `ReducerProtocol` — static `reduce(state:action:dependencies:)` returning `Effect<Action>`
- `Effect<Action>` — `.task`, `.stream`, `.merge`, `.cancel`, `.none`
- Closure-based dependency structs (`.live(...)` / `.mock`) — no protocols

## Dependencies

- [PitchDSP](https://github.com/peppperrroni/PitchDSP) — Harmonic Product Spectrum pitch detector (C library)

## Requirements

- iOS 18+
- Xcode 16+
