import Foundation

enum Tuner {}

extension Tuner {
    static func makeStore(
        overrides: Tuner.Effects? = nil,
        storage: Settings.Storage,
        soundPlayer: Audio.SoundPlayerEngine
    ) -> Store<Tuner.State, Tuner.Action> {
        let dependencies = overrides ?? Tuner.Effects.live(
            pitchDetector: Audio.AVPitchDetector(),
            tonePlayer: soundPlayer,
            settings: storage
        )
        return Store(initial: Tuner.State(), reducer: Tuner.Reducer.self, dependencies: dependencies)
    }
}
