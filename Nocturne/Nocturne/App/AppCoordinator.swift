import SwiftUI

@MainActor
@Observable
final class AppCoordinator {
    private(set) var metronomeStore: Store<Metronome.State, Metronome.Action>
    private(set) var tunerStore: Store<Tuner.State, Tuner.Action>
    private(set) var settingsStore: Store<Settings.State, Settings.Action>

    init(
        metronomeDependencies: Metronome.Effects? = nil,
        tunerDependencies: Tuner.Effects? = nil,
        settingsDependencies: Settings.Effects? = nil
    ) {
        let sharedStorage = Settings.Storage.live()

        // Metronome
        let metronomeDeps = metronomeDependencies ?? Metronome.Effects.live(
            engine: Audio.AVMetronomeEngine(),
            settings: sharedStorage
        )
        let metronomeStore = Store(initial: Metronome.State()) { state, action in
            Metronome.Reducer.reduce(state: &state, action: action, dependencies: metronomeDeps)
        }
        self.metronomeStore = metronomeStore

        // Tuner
        let tunerDeps = tunerDependencies ?? Tuner.Effects.live(
            pitchDetector: Audio.AVPitchDetector(),
            tonePlayer: Audio.SoundPlayerEngine(),
            settings: sharedStorage
        )
        tunerStore = Store(initial: Tuner.State()) { state, action in
            Tuner.Reducer.reduce(state: &state, action: action, dependencies: tunerDeps)
        }

        // Settings — onSoundChanged forwards beat sound changes to the metronome store
        let settingsDeps = settingsDependencies ?? Settings.Effects.live(
            storage: sharedStorage,
            soundPlayer: Audio.SoundPlayerEngine(),
            onSoundChanged: { sound in
                metronomeStore.send(.beatSoundChanged(sound))
            }
        )
        settingsStore = Store(initial: Settings.State()) { state, action in
            Settings.Reducer.reduce(state: &state, action: action, dependencies: settingsDeps)
        }
    }

    func start() {
        metronomeStore.send(.loadSettings)
        tunerStore.send(.loadSettings)
        settingsStore.send(.loadSettings)
    }
}
