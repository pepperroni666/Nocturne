import AccessibilityIdentifiers
import XCTest

enum MetronomeScreen {
    static let playButton = UI.Button(id: AccessibilityIds.Metronome.playButton)
    static let stopButton = UI.Button(id: AccessibilityIds.Metronome.stopButton)
    static let bpmDisplay = UI.Label(id: AccessibilityIds.Metronome.bpmDisplay)
    static let bpmMinus = UI.Button(id: AccessibilityIds.Metronome.bpmMinus)
    static let bpmPlus = UI.Button(id: AccessibilityIds.Metronome.bpmPlus)
    static let tapTempo = UI.Button(id: AccessibilityIds.Metronome.tapTempo)
    static let dial = UI.View(id: AccessibilityIds.Metronome.dial)
    static let beatDots = UI.View(id: AccessibilityIds.Metronome.beatDots)

    static func timeSignatureButton(_ ts: String) -> UI.Button {
        UI.Button(id: AccessibilityIds.Metronome.TimeSignature.button(ts))
    }
}
