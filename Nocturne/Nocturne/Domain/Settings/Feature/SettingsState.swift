import Foundation

extension Settings {
    struct State: Sendable, Equatable {
        var beatSound: Metronome.BeatSound = .simple
        var isPreviewPlaying: Bool = false
    }
}
