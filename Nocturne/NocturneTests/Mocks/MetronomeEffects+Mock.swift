@testable import Nocturne

extension Metronome.Effects {
    static let mock = Metronome.Effects(
        startEngine: { _, _, _, _ in AsyncStream { $0.finish() } },
        stopEngine: {},
        updateTempo: { _ in },
        updateAccentPattern: { _ in },
        updateBeatSound: { _ in },
        loadSettings: { (120, .fourFour, .simple) },
        saveSettings: { _, _, _ in },
        lifecycleEvents: { AsyncStream { $0.finish() } }
    )
}
