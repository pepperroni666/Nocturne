import Foundation

extension AppCoordinator {
    static func makeMetronomeStore(
        deps: Metronome.Effects?,
        storage: Settings.Storage
    ) -> Store<Metronome.State, Metronome.Action> {
        let d = deps ?? Metronome.Effects.live(engine: Audio.AVMetronomeEngine(), settings: storage)
        return Store(initial: Metronome.State()) { state, action in
            Metronome.Reducer.reduce(state: &state, action: action, dependencies: d)
        }
    }

    static func makeTunerStore(
        deps: Tuner.Effects?,
        storage: Settings.Storage,
        soundPlayer: Audio.SoundPlayerEngine
    ) -> Store<Tuner.State, Tuner.Action> {
        let d = deps ?? Tuner.Effects.live(
            pitchDetector: Audio.AVPitchDetector(),
            tonePlayer: soundPlayer,
            settings: storage
        )
        return Store(initial: Tuner.State()) { state, action in
            Tuner.Reducer.reduce(state: &state, action: action, dependencies: d)
        }
    }

    static func makeSettingsStore(
        deps: Settings.Effects?,
        storage: Settings.Storage,
        soundPlayer: Audio.SoundPlayerEngine,
        onSoundChanged: @escaping @Sendable (Metronome.BeatSound) async -> Void
    ) -> Store<Settings.State, Settings.Action> {
        let d = deps ?? Settings.Effects.live(
            storage: storage,
            soundPlayer: soundPlayer,
            onSoundChanged: onSoundChanged
        )
        return Store(initial: Settings.State()) { state, action in
            Settings.Reducer.reduce(state: &state, action: action, dependencies: d)
        }
    }
}
