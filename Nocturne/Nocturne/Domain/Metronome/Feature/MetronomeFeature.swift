import Foundation

enum Metronome {}

extension Metronome {
    @MainActor
    static func makeStore(
        overrides: Metronome.Effects? = nil,
        storage: Settings.Storage
    ) -> Store<Metronome.State, Metronome.Action> {
        let dependencies = overrides ?? Metronome.Effects.live(
            engine: Audio.AVMetronomeEngine(),
            settings: storage
        )
        return Store(initial: Metronome.State(), reducer: Metronome.Reducer.self, dependencies: dependencies)
    }
}
