import SwiftUI

@MainActor
@Observable
final class AppCoordinator {
    private(set) var metronomeStore: Store<Metronome.State, Metronome.Action>
    private(set) var tunerStore: Store<Tuner.State, Tuner.Action>

    init(
        metronomeDependencies: Metronome.Effects? = nil,
        tunerDependencies: Tuner.Effects? = nil
    ) {
        let metronomeDeps = metronomeDependencies ?? Metronome.Effects.live(
            engine: AVAudioMetronomeEngine(),
            settings: UserDefaultsSettingsStore()
        )

        metronomeStore = Store(initial: Metronome.State()) { state, action in
            Metronome.Reducer.reduce(state: &state, action: action, dependencies: metronomeDeps)
        }

        let settings = UserDefaultsSettingsStore()
        let tunerDeps = tunerDependencies ?? Tuner.Effects.live(
            pitchDetector: AVAudioPitchDetector(),
            tonePlayer: TonePlayerEngine(),
            settings: settings
        )

        tunerStore = Store(initial: Tuner.State()) { state, action in
            Tuner.Reducer.reduce(state: &state, action: action, dependencies: tunerDeps)
        }
    }

    func start() {
        metronomeStore.send(.loadSettings)
        tunerStore.send(.loadSettings)
    }
}
