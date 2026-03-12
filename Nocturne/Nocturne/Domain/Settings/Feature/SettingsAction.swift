import Foundation

extension Settings {
    enum Action: Sendable {
        // User selects a beat sound in the picker
        case soundSelected(Metronome.BeatSound)
        // Preview playback finished naturally (not cancelled)
        case previewFinished
        // Settings loaded from storage on app start
        case loadSettings
        case settingsLoaded(beatSound: Metronome.BeatSound)
    }
}
