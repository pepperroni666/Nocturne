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
        let sharedSoundPlayer = Audio.SoundPlayerEngine()

        let metronomeStore = Metronome.makeStore(overrides: metronomeDependencies, storage: sharedStorage)
        let tunerStore = Tuner.makeStore(overrides: tunerDependencies, storage: sharedStorage, soundPlayer: sharedSoundPlayer)

        // Routes beat-sound changes through the coordinator to the metronome.
        // [weak metronomeStore] is equivalent to [weak self].metronomeStore —
        // self is not yet available because stored properties are assigned below.
        let settingsStore = Settings.makeStore(
            overrides: settingsDependencies,
            storage: sharedStorage,
            soundPlayer: sharedSoundPlayer,
            onSoundChanged: { sound in
                metronomeStore.send(.beatSoundChanged(sound))
            }
        )

        self.metronomeStore = metronomeStore
        self.tunerStore = tunerStore
        self.settingsStore = settingsStore
    }

    func start() {
        metronomeStore.send(.loadSettings)
        tunerStore.send(.loadSettings)
        settingsStore.send(.loadSettings)
    }
}
