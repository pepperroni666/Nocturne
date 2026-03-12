import Foundation

extension Settings {
    struct State: Sendable {
        var beatSound: Metronome.BeatSound = .simple
        var isPreviewPlaying: Bool = false
    }
}

extension Settings.State: Equatable {}
