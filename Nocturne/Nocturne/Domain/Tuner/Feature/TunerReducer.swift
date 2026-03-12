import Foundation

extension Tuner {
    enum Reducer: ReducerProtocol {
        typealias State = Tuner.State
        typealias Action = Tuner.Action
        typealias Dependencies = Tuner.Effects

        static func reduce(
            state: inout State,
            action: Action,
            dependencies: Dependencies
        ) -> Effect<Action> {
            switch action {

            case let .modeChanged(mode):
                guard mode != state.mode else { return .none }
                state.mode = mode
                return stopAllEffect(state: &state, dependencies: dependencies)

            case .startListening:
                switch state.micPermission {
                case .authorized:
                    state.isListening = true
                    return dependencies.startPitchDetectionEffect()
                case .denied:
                    return .none
                case .notDetermined:
                    return dependencies.requestMicPermissionEffect()
                }

            case .stopListening:
                state.isListening = false
                state.detectedPitch = nil
                state.pitchStability = 0
                return dependencies.stopPitchDetectionEffect()

            case let .pitchDetected(reading):
                guard reading.midi >= 0, reading.midi <= 127 else { return .none }
                state.detectedPitch = DetectedPitch(
                    frequency: reading.hz,
                    noteName: MusicMath.noteName(midi: reading.midi),
                    octave: MusicMath.octave(midi: reading.midi),
                    cents: reading.cents,
                    confidence: reading.confidence,
                    midiNote: reading.midi
                )
                state.pitchStability = reading.stability
                return .none

            case .pitchLost:
                state.pitchStability = 0
                return .none

            case let .micPermissionUpdated(status):
                state.micPermission = status
                if status == .authorized {
                    state.isListening = true
                    return dependencies.startPitchDetectionEffect()
                }
                return .none

            case .micListenFailed:
                state.isListening = false
                state.detectedPitch = nil
                state.pitchStability = 0
                return .none

            case let .instrumentChanged(instrument):
                guard instrument != state.selectedInstrument else { return .none }
                state.selectedInstrument = instrument
                state.selectedTuning = TuningDatabase.defaultTuning(for: instrument)
                state.playingStringIndex = nil
                return .merge([
                    dependencies.stopToneEffect(),
                    dependencies.debouncedPersist()
                ])

            case let .tuningChanged(tuning):
                guard tuning != state.selectedTuning else { return .none }
                state.selectedTuning = tuning
                state.playingStringIndex = nil
                return .merge([
                    dependencies.stopToneEffect(),
                    dependencies.debouncedPersist()
                ])

            case let .stringTapped(index):
                let strings = state.currentStrings
                guard index >= 0, index < strings.count else { return .none }
                if state.playingStringIndex == index {
                    state.playingStringIndex = nil
                    return dependencies.stopToneEffect()
                }
                state.playingStringIndex = index
                let frequency = strings[index].frequency
                return dependencies.playToneEffect(frequency: frequency)

            case .stopTone:
                state.playingStringIndex = nil
                return dependencies.stopToneEffect()

            case .toneStarted:
                return .none

            case .toneStopped:
                state.playingStringIndex = nil
                return .none

            case .tonePlaybackFailed:
                state.playingStringIndex = nil
                return .none

            case let .a4CalibrationChanged(value):
                let clamped = value.clamped(to: State.a4Range)
                guard clamped != state.a4Calibration else { return .none }
                state.a4Calibration = clamped
                return dependencies.debouncedPersist()

            case .loadSettings:
                return dependencies.loadSettingsEffect()

            case let .settingsLoaded(instrument, tuning, a4):
                state.selectedInstrument = instrument
                state.selectedTuning = tuning
                state.a4Calibration = a4.clamped(to: State.a4Range)
                return .none

            case .persistRequested:
                return dependencies.persist(
                    instrument: state.selectedInstrument,
                    tuning: state.selectedTuning,
                    a4: state.a4Calibration
                )

            case .stopAll:
                return stopAllEffect(state: &state, dependencies: dependencies)
            }
        }

        private static func stopAllEffect(
            state: inout State,
            dependencies: Dependencies
        ) -> Effect<Action> {
            var effects: [Effect<Action>] = []
            if state.isListening {
                state.isListening = false
                state.detectedPitch = nil
                state.pitchStability = 0
                effects.append(dependencies.stopPitchDetectionEffect())
            }
            if state.playingStringIndex != nil {
                state.playingStringIndex = nil
                effects.append(dependencies.stopToneEffect())
            }
            return effects.isEmpty ? .none : .merge(effects)
        }
    }
}
