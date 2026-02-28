import Foundation

extension Metronome {
    struct Effects: Sendable {
        // Engine
        var startEngine: @Sendable (Int, Int, [Bool], BeatSound) async throws -> AsyncStream<Tick>
        var stopEngine: @Sendable () async -> Void
        var updateTempo: @Sendable (Int) async -> Void
        var updateAccentPattern: @Sendable ([Bool]) async -> Void
        var updateBeatSound: @Sendable (BeatSound) async -> Void

        // Settings
        var loadSettings: @Sendable () -> (bpm: Int, timeSignature: TimeSignature, beatSound: BeatSound)
        var saveSettings: @Sendable (Int, TimeSignature, BeatSound) -> Void

        // Stream IDs
        static let tickStreamID = UUID()
        static let persistDebounceID = UUID()
    }
}

// MARK: - Effect Builders

extension Metronome.Effects {
    func startEngineEffect(bpm: Int, beatsPerMeasure: Int, accentPattern: [Bool], beatSound: Metronome.BeatSound) -> Effect<Metronome.Action> {
        let start = startEngine
        return .stream(id: Self.tickStreamID) { send in
            do {
                let stream = try await start(bpm, beatsPerMeasure, accentPattern, beatSound)
                for await tick in stream {
                    await send(.engineTick(beat: tick.beat))
                }
            } catch {
                await send(.engineStartFailed)
            }
        }
    }

    func stopEngineEffect() -> Effect<Metronome.Action> {
        let stop = stopEngine
        return .merge([
            .cancel(Self.tickStreamID),
            .fireAndForget { await stop() }
        ])
    }

    func updateTempoEffect(bpm: Int) -> Effect<Metronome.Action> {
        let update = updateTempo
        return .fireAndForget { await update(bpm) }
    }

    func updateAccentPatternEffect(_ pattern: [Bool]) -> Effect<Metronome.Action> {
        let update = updateAccentPattern
        return .fireAndForget { await update(pattern) }
    }

    func updateBeatSoundEffect(_ beatSound: Metronome.BeatSound) -> Effect<Metronome.Action> {
        let update = updateBeatSound
        return .fireAndForget { await update(beatSound) }
    }

    func debouncedPersist(bpm: Int, timeSignature: Metronome.TimeSignature, beatSound: Metronome.BeatSound) -> Effect<Metronome.Action> {
        .merge([
            .cancel(Self.persistDebounceID),
            .run(id: Self.persistDebounceID) {
                try? await Task.sleep(for: .milliseconds(500))
                return .persistRequested
            }
        ])
    }

    func persist(bpm: Int, timeSignature: Metronome.TimeSignature, beatSound: Metronome.BeatSound) -> Effect<Metronome.Action> {
        let save = saveSettings
        return .fireAndForget { save(bpm, timeSignature, beatSound) }
    }

    func loadSettingsEffect() -> Effect<Metronome.Action> {
        let load = loadSettings
        return .run {
            let result = load()
            return .settingsLoaded(bpm: result.bpm, timeSignature: result.timeSignature, beatSound: result.beatSound)
        }
    }
}

// MARK: - Live

extension Metronome.Effects {
    static func live(
        engine: Audio.AVMetronomeEngine,
        settings: UserDefaultsSettingsStore
    ) -> Metronome.Effects {
        Metronome.Effects(
            startEngine: { bpm, beats, pattern, sound in
                try await engine.start(bpm: bpm, beatsPerMeasure: beats, accentPattern: pattern, beatSound: sound)
            },
            stopEngine: { await engine.stop() },
            updateTempo: { await engine.updateTempo(bpm: $0) },
            updateAccentPattern: { await engine.updateAccentPattern($0) },
            updateBeatSound: { await engine.updateBeatSound($0) },
            loadSettings: { settings.load() },
            saveSettings: { settings.save(bpm: $0, timeSignature: $1, beatSound: $2) }
        )
    }
}
