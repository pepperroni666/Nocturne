import AccessibilityIdentifiers
import XCTest

enum BPMEntryScreen {
    static let textField = UI.TextField(id: AccessibilityIds.Metronome.BPMEntry.textField)
    static let doneButton = UI.Button(id: AccessibilityIds.Metronome.BPMEntry.doneButton)
    static let errorLabel = UI.Label(id: AccessibilityIds.Metronome.BPMEntry.errorLabel)
}
