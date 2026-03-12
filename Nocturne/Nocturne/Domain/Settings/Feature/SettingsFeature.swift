import Foundation

enum Settings {}

extension Settings {
    @MainActor
    static func makeStore(
        overrides: Settings.Effects? = nil,
        storage: Settings.Storage,
        soundPlayer: Audio.SoundPlayerEngine,
        onSoundChanged: @escaping @Sendable (Metronome.BeatSound) -> Void
    ) -> Store<Settings.State, Settings.Action> {
        let dependencies = overrides ?? Settings.Effects.live(
            storage: storage,
            soundPlayer: soundPlayer,
            onSoundChanged: onSoundChanged
        )
        return Store(initial: Settings.State(), reducer: Settings.Reducer.self, dependencies: dependencies)
    }
}
