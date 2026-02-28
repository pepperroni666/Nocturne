@testable import Nocturne

extension Tuner.Effects {
    static let mock = Tuner.Effects(
        requestMicPermission: { .authorized },
        startPitchDetection: { AsyncStream { $0.finish() } },
        stopPitchDetection: {},
        playTone: { _ in AsyncStream { $0.finish() } },
        stopTone: {},
        loadSettings: { (.guitar, .guitarStandard, 440.0) },
        saveSettings: { _, _, _ in }
    )
}
