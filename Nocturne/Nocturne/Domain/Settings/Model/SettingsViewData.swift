import Foundation

extension Settings {
    struct RootViewData: Sendable, Equatable {
        let navigationTitle: String
        let metronomeSectionHeader: String
        let beatSoundLabel: String
        let beatSoundValue: String
        let beatSoundNavigationTitle: String
    }
}

extension Metronome.State {
    var settingsViewData: Settings.RootViewData {
        .init(
            navigationTitle: "Settings",
            metronomeSectionHeader: "Metronome",
            beatSoundLabel: "Beat Sound",
            beatSoundValue: beatSound.displayName,
            beatSoundNavigationTitle: "Beat Sound"
        )
    }
}
