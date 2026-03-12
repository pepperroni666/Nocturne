import Foundation

extension Settings {
    struct Effects: Sendable {
        var loadBeatSound: @Sendable () -> Metronome.BeatSound
        var saveBeatSound: @Sendable (Metronome.BeatSound) -> Void
        var playPreview: @Sendable (Metronome.BeatSound) async throws -> Void
        /// Called after the user confirms a sound selection so other features can react.
        /// Always invoked on the MainActor (Store effects inherit MainActor isolation).
        var onSoundChanged: @Sendable (Metronome.BeatSound) async -> Void
    }
}

// MARK: - Live

extension Settings.Effects {
    static func live(
        storage: Settings.Storage = .live(),
        soundPlayer: Audio.SoundPlayerEngine,
        onSoundChanged: @escaping @Sendable (Metronome.BeatSound) async -> Void
    ) -> Settings.Effects {
        Settings.Effects(
            loadBeatSound: {
                Metronome.BeatSound(rawValue: storage.load("nocturne.beatSound") ?? "") ?? .simple
            },
            saveBeatSound: { sound in
                storage.save("nocturne.beatSound", sound.rawValue)
            },
            playPreview: { sound in
                try await soundPlayer.playBeatPreview(sound: sound)
            },
            onSoundChanged: onSoundChanged
        )
    }
}

// MARK: - Mock

#if DEBUG
extension Settings.Effects {
    static func mock(
        onSoundChanged: @escaping @Sendable (Metronome.BeatSound) async -> Void = { _ in }
    ) -> Settings.Effects {
        Settings.Effects(
            loadBeatSound: { .simple },
            saveBeatSound: { _ in },
            playPreview: { _ in },
            onSoundChanged: onSoundChanged
        )
    }
}
#endif
