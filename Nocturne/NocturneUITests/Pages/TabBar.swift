import XCTest

enum TabBar {
    static let metronome = UI.Tab("Metronome", query: UI.app.tabBars.buttons["Metronome"])
    static let tuner = UI.Tab("Tuner", query: UI.app.tabBars.buttons["Tuner"])
    static let theory = UI.Tab("Theory", query: UI.app.tabBars.buttons["Theory"])
    static let settings = UI.Tab("Settings", query: UI.app.tabBars.buttons["Settings"])
}
