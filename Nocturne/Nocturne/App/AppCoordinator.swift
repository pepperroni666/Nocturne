import SwiftUI

@MainActor
@Observable
final class AppCoordinator {
    private(set) var metronomeStore: Store<Metronome.State, Metronome.Action>
    private(set) var tunerStore: Store<Tuner.State, Tuner.Action>
    private(set) var settingsStore: Store<Settings.State, Settings.Action>

    private var hasStarted = false

    init(
        metronomeDependencies: Metronome.Effects? = nil,
        tunerDependencies: Tuner.Effects? = nil,
        settingsDependencies: Settings.Effects? = nil
    ) {
        let sharedStorage = Settings.Storage.live()
        let sharedSoundPlayer = Audio.SoundPlayerEngine()

        self.metronomeStore = Self.makeMetronomeStore(
            deps: metronomeDependencies,
            storage: sharedStorage
        )
        self.tunerStore = Self.makeTunerStore(
            deps: tunerDependencies,
            storage: sharedStorage,
            soundPlayer: sharedSoundPlayer
        )

        // Placeholder completes two-phase init so [weak self] is available below.
        self.settingsStore = Store(initial: Settings.State()) { _, _ in .none }

        // Settings routes beat-sound changes through the coordinator to the metronome.
        self.settingsStore = Self.makeSettingsStore(
            deps: settingsDependencies,
            storage: sharedStorage,
            soundPlayer: sharedSoundPlayer,
            onSoundChanged: { [weak self] sound in self?.onBeatSoundChanged(sound) }
        )
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        metronomeStore.send(.loadSettings)
        tunerStore.send(.loadSettings)
        settingsStore.send(.loadSettings)
    }

    // MARK: - Routing

    private func onBeatSoundChanged(_ sound: Metronome.BeatSound) {
        metronomeStore.send(.beatSoundChanged(sound))
    }

    // MARK: - Store Factories

    private static func makeMetronomeStore(
        deps: Metronome.Effects?,
        storage: Settings.Storage
    ) -> Store<Metronome.State, Metronome.Action> {
        let d = deps ?? Metronome.Effects.live(engine: Audio.AVMetronomeEngine(), settings: storage)
        return Store(initial: Metronome.State()) { state, action in
            Metronome.Reducer.reduce(state: &state, action: action, dependencies: d)
        }
    }

    private static func makeTunerStore(
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

    private static func makeSettingsStore(
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
