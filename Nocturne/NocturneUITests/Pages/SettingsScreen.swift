import AccessibilityIdentifiers
import XCTest

enum SettingsScreen {
    static let beatSoundRow = UI.Button("Beat Sound", query: UI.app.staticTexts["Beat Sound"])
    static let navigationTitle = UI.Label("Settings", query: UI.app.navigationBars["Settings"])
    static let beatSoundPickerTitle = UI.Label("Beat Sound", query: UI.app.navigationBars["Beat Sound"])
    static let backButton = UI.Button("Back", query: UI.app.navigationBars.buttons["Settings"])

    static func beatSoundOption(_ name: String) -> UI.Button {
        UI.Button(id: AccessibilityIds.Settings.beatSoundOption(name))
    }
}
