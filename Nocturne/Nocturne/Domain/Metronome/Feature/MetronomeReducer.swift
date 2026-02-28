import Foundation

extension Metronome {
    enum Reducer: ReducerProtocol {
        typealias State = Metronome.State
        typealias Action = Metronome.Action
        typealias Dependencies = Metronome.Effects

        static func reduce(
            state: inout State,
            action: Action,
            dependencies: Dependencies
        ) -> Effect<Action> {
            switch action {

            case .playTapped:
                state.isPlaying = true
                state.currentBeat = 0
                return dependencies.startEngineEffect(bpm: state.bpm, beatsPerMeasure: state.timeSignature.beats, accentPattern: state.accentPattern.pattern, beatSound: state.beatSound)

            case .stopTapped:
                state.isPlaying = false
                state.currentBeat = 0
                return dependencies.stopEngineEffect()

            case .bpmPlus:
                let oldBPM = state.bpm
                state.bpm = (state.bpm + 1).clamped(to: Metronome.State.bpmRange)
                guard state.bpm != oldBPM else { return .none }
                return bpmDidChange(state: state, dependencies: dependencies)

            case .bpmMinus:
                let oldBPM = state.bpm
                state.bpm = (state.bpm - 1).clamped(to: Metronome.State.bpmRange)
                guard state.bpm != oldBPM else { return .none }
                return bpmDidChange(state: state, dependencies: dependencies)

            case let .bpmSet(newBPM):
                let clamped = newBPM.clamped(to: Metronome.State.bpmRange)
                guard clamped != state.bpm else { return .none }
                state.bpm = clamped
                return bpmDidChange(state: state, dependencies: dependencies)

            case .dialDragStarted:
                state.isDragging = true
                return .none

            case let .dialDragged(angle):
                let normalized = angle / (2.0 * .pi)
                let newBPM = Metronome.State.bpmRange.lowerBound + Int(normalized * Double(Metronome.State.bpmRange.upperBound - Metronome.State.bpmRange.lowerBound))
                let clamped = newBPM.clamped(to: Metronome.State.bpmRange)
                state.bpm = clamped
                state.dialAngle = angle
                if state.isPlaying {
                    return dependencies.updateTempoEffect(bpm: state.bpm)
                }
                return .none

            case .dialDragEnded:
                state.isDragging = false
                return dependencies.debouncedPersist(bpm: state.bpm, timeSignature: state.timeSignature, beatSound: state.beatSound)

            case let .tapTempoPressed(date):
                if let last = state.tapTimestamps.last, date.timeIntervalSince(last) > 2.0 {
                    state.tapTimestamps = [date]
                    return .none
                }
                state.tapTimestamps.append(date)
                if state.tapTimestamps.count > 8 {
                    state.tapTimestamps.removeFirst(state.tapTimestamps.count - 8)
                }
                guard state.tapTimestamps.count >= 2 else { return .none }
                let intervals = zip(state.tapTimestamps, state.tapTimestamps.dropFirst())
                    .map { $1.timeIntervalSince($0) }
                let avgInterval = intervals.reduce(0, +) / Double(intervals.count)
                guard avgInterval > 0 else { return .none }
                let newBPM = Int((60.0 / avgInterval).rounded())
                state.bpm = newBPM.clamped(to: Metronome.State.bpmRange)
                return bpmDidChange(state: state, dependencies: dependencies)

            case let .timeSignatureChanged(ts):
                guard ts != state.timeSignature else { return .none }
                state.timeSignature = ts
                state.currentBeat = 0
                state.accentPatternIndex = 0
                if state.isPlaying {
                    return .merge([
                        dependencies.stopEngineEffect(),
                        dependencies.startEngineEffect(bpm: state.bpm, beatsPerMeasure: ts.beats, accentPattern: state.accentPattern.pattern, beatSound: state.beatSound),
                        dependencies.debouncedPersist(bpm: state.bpm, timeSignature: ts, beatSound: state.beatSound)
                    ])
                }
                return dependencies.debouncedPersist(bpm: state.bpm, timeSignature: ts, beatSound: state.beatSound)

            case .accentPatternCycled:
                let patternCount = AccentPatternRegistry.patterns(for: state.timeSignature).count
                guard patternCount > 1 else { return .none }
                state.accentPatternIndex = (state.accentPatternIndex + 1) % patternCount
                if state.isPlaying {
                    return dependencies.updateAccentPatternEffect(state.accentPattern.pattern)
                }
                return .none

            case let .beatSoundChanged(sound):
                guard sound != state.beatSound else { return .none }
                state.beatSound = sound
                if state.isPlaying {
                    return .merge([
                        dependencies.updateBeatSoundEffect(sound),
                        dependencies.debouncedPersist(bpm: state.bpm, timeSignature: state.timeSignature, beatSound: sound)
                    ])
                }
                return dependencies.debouncedPersist(bpm: state.bpm, timeSignature: state.timeSignature, beatSound: sound)

            case .bpmEntryTapped:
                state.showBPMEntry = true
                return .none

            case .bpmEntryDismissed:
                state.showBPMEntry = false
                return .none

            case let .bpmEntryConfirmed(newBPM):
                state.showBPMEntry = false
                let clamped = newBPM.clamped(to: Metronome.State.bpmRange)
                guard clamped != state.bpm else { return .none }
                state.bpm = clamped
                return bpmDidChange(state: state, dependencies: dependencies)

            case .toggleTimeSignaturePicker:
                state.showTimeSignaturePicker.toggle()
                return .none

            case let .engineTick(beat):
                state.currentBeat = beat % state.timeSignature.beats
                return .none

            case .appBecameInactive:
                guard state.isPlaying else { return .none }
                state.isPlaying = false
                state.currentBeat = 0
                return dependencies.stopEngineEffect()

            case .persistRequested:
                return dependencies.persist(bpm: state.bpm, timeSignature: state.timeSignature, beatSound: state.beatSound)

            case let .settingsLoaded(bpm, ts, beatSound):
                state.bpm = bpm.clamped(to: Metronome.State.bpmRange)
                state.timeSignature = ts
                state.beatSound = beatSound
                return .none

            case .loadSettings:
                return dependencies.loadSettingsEffect()

            case .engineStartFailed:
                state.isPlaying = false
                state.currentBeat = 0
                return .none
            }
        }

        private static func bpmDidChange(
            state: State,
            dependencies: Dependencies
        ) -> Effect<Action> {
            if state.isPlaying {
                return .merge([
                    dependencies.updateTempoEffect(bpm: state.bpm),
                    dependencies.debouncedPersist(bpm: state.bpm, timeSignature: state.timeSignature, beatSound: state.beatSound)
                ])
            }
            return dependencies.debouncedPersist(bpm: state.bpm, timeSignature: state.timeSignature, beatSound: state.beatSound)
        }
    }
}
