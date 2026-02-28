import Foundation

extension Tuner {
    struct Effects: Sendable {
        // Microphone
        var requestMicPermission: @Sendable () async -> MicPermissionStatus
        var startPitchDetection: @Sendable () async throws -> AsyncStream<PitchDetectionEvent>
        var stopPitchDetection: @Sendable () async -> Void

        // Tone
        var playTone: @Sendable (Double) async throws -> AsyncStream<ToneEvent>
        var stopTone: @Sendable () async -> Void

        // Settings
        var loadSettings: @Sendable () -> (instrument: Instrument, tuning: TuningPreset, a4: Double)
        var saveSettings: @Sendable (Instrument, TuningPreset, Double) -> Void

        // Stream IDs
        static let pitchStreamID = UUID()
        static let toneStreamID = UUID()
        static let persistDebounceID = UUID()
    }
}

// MARK: - Effect Builders

extension Tuner.Effects {
    func requestMicPermissionEffect() -> Effect<Tuner.Action> {
        let request = requestMicPermission
        return .run {
            let status = await request()
            return .micPermissionUpdated(status)
        }
    }

    func startPitchDetectionEffect() -> Effect<Tuner.Action> {
        let start = startPitchDetection
        return .stream(id: Self.pitchStreamID) { send in
            do {
                let stream = try await start()
                for await event in stream {
                    switch event {
                    case let .pitched(reading):
                        await send(.pitchDetected(reading))
                    case .lost:
                        await send(.pitchLost)
                    }
                }
            } catch {
                await send(.micListenFailed)
            }
        }
    }

    func stopPitchDetectionEffect() -> Effect<Tuner.Action> {
        let stop = stopPitchDetection
        return .merge([
            .cancel(Self.pitchStreamID),
            .fireAndForget { await stop() }
        ])
    }

    func playToneEffect(frequency: Double) -> Effect<Tuner.Action> {
        let play = playTone
        return .stream(id: Self.toneStreamID) { send in
            do {
                let stream = try await play(frequency)
                await send(.toneStarted)
                for await event in stream {
                    switch event {
                    case .started: break
                    case .stopped: await send(.toneStopped)
                    case .failed: await send(.tonePlaybackFailed)
                    }
                }
            } catch {
                await send(.tonePlaybackFailed)
            }
        }
    }

    func stopToneEffect() -> Effect<Tuner.Action> {
        let stop = stopTone
        return .merge([
            .cancel(Self.toneStreamID),
            .fireAndForget { await stop() }
        ])
    }

    func debouncedPersist() -> Effect<Tuner.Action> {
        .merge([
            .cancel(Self.persistDebounceID),
            .run(id: Self.persistDebounceID) {
                try? await Task.sleep(for: .milliseconds(500))
                return .persistRequested
            }
        ])
    }

    func persist(instrument: Tuner.Instrument, tuning: Tuner.TuningPreset, a4: Double) -> Effect<Tuner.Action> {
        let save = saveSettings
        return .fireAndForget { save(instrument, tuning, a4) }
    }

    func loadSettingsEffect() -> Effect<Tuner.Action> {
        let load = loadSettings
        return .run {
            let result = load()
            return .settingsLoaded(instrument: result.instrument, tuning: result.tuning, a4: result.a4)
        }
    }
}

// MARK: - Live

extension Tuner.Effects {

    static func live(
        pitchDetector: AVAudioPitchDetector,
        tonePlayer: TonePlayerEngine,
        settings: UserDefaultsSettingsStore
    ) -> Tuner.Effects {
        Tuner.Effects(
            requestMicPermission: { await pitchDetector.requestPermission() },
            startPitchDetection: {
                let raw = try await pitchDetector.start()
                return AsyncStream<Tuner.PitchDetectionEvent> { continuation in
                    Task {
                        for await reading in raw {
                            if reading.hz > 0 {
                                continuation.yield(.pitched(reading))
                            } else {
                                continuation.yield(.lost)
                            }
                        }
                        continuation.finish()
                    }
                }
            },
            stopPitchDetection: { await pitchDetector.stop() },
            playTone: { frequency in try await tonePlayer.play(frequency: frequency) },
            stopTone: { await tonePlayer.stop() },
            loadSettings: { settings.loadTuner() },
            saveSettings: { settings.saveTuner(instrument: $0, tuning: $1, a4: $2) }
        )
    }
}
