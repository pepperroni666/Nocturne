# ``AccessibilityIdentifiers``

Shared accessibility identifier constants used by the app and UI tests.

## Overview

This framework provides a single source of truth for all accessibility identifiers in Nocturne. It is imported by both the main app target and the UI test target so identifiers stay in sync.

Each screen has its own extension file. Sub-screens are nested inside their parent screen's namespace:

```swift
// Top-level screen
AccessibilityIds.Metronome.playButton

// Sub-screen nested under parent
AccessibilityIds.Metronome.BPMEntry.textField
```

### Adding identifiers for a new screen

1. Create `AccessibilityIds+ScreenName.swift`
2. Add a `public extension AccessibilityIds` with an enum for the screen
3. Apply identifiers in the view with `.accessibilityIdentifier(...)`
4. Reference them in UI test page objects

## Topics

### Screens

- ``AccessibilityIds/Metronome``
- ``AccessibilityIds/Settings``
