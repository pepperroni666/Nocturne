import Foundation

extension AppCoordinator {

    @MainActor
    static func makeMetronomeStore(
        overrides: Metronome.Effects?,
        storage: Settings.Storage
    ) -> Store<Metronome.State, Metronome.Action> {
        let dependencies = overrides ?? Metronome.Effects.live(
            engine: Audio.AVMetronomeEngine(),
            settings: storage
        )
        return Store(initial: Metronome.State()) { state, action in
            Metronome.Reducer.reduce(state: &state, action: action, dependencies: dependencies)
        }
    }

    @MainActor
    static func makeTunerStore(
        overrides: Tuner.Effects?,
        storage: Settings.Storage,
        soundPlayer: Audio.SoundPlayerEngine
    ) -> Store<Tuner.State, Tuner.Action> {
        let dependencies = overrides ?? Tuner.Effects.live(
            pitchDetector: Audio.AVPitchDetector(),
            tonePlayer: soundPlayer,
            settings: storage
        )
        return Store(initial: Tuner.State()) { state, action in
            Tuner.Reducer.reduce(state: &state, action: action, dependencies: dependencies)
        }
    }

    @MainActor
    static func makeSettingsStore(
        overrides: Settings.Effects?,
        storage: Settings.Storage,
        soundPlayer: Audio.SoundPlayerEngine,
        onSoundChanged: @escaping @Sendable (Metronome.BeatSound) async -> Void
    ) -> Store<Settings.State, Settings.Action> {
        let dependencies = overrides ?? Settings.Effects.live(
            storage: storage,
            soundPlayer: soundPlayer,
            onSoundChanged: onSoundChanged
        )
        return Store(initial: Settings.State()) { state, action in
            Settings.Reducer.reduce(state: &state, action: action, dependencies: dependencies)
        }
    }
}
