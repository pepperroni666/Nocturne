import Foundation
import Testing
@testable import Nocturne

@Suite("MetronomeReducer")
@MainActor
struct MetronomeReducerTests {

    private func makeDependencies() -> Metronome.Effects {
        .mock
    }

    @Test("playTapped sets isPlaying and resets beat")
    func playTapped() {
        var state = Metronome.State()
        state.currentBeat = 3
        let _ = Metronome.Reducer.reduce(state: &state, action: .playTapped, dependencies: makeDependencies())
        #expect(state.isPlaying == true)
        #expect(state.currentBeat == 0)
    }

    @Test("stopTapped clears playing state")
    func stopTapped() {
        var state = Metronome.State()
        state.isPlaying = true
        state.currentBeat = 2
        let _ = Metronome.Reducer.reduce(state: &state, action: .stopTapped, dependencies: makeDependencies())
        #expect(state.isPlaying == false)
        #expect(state.currentBeat == 0)
    }

    @Test("bpmPlus increments BPM")
    func bpmPlus() {
        var state = Metronome.State()
        state.bpm = 120
        let _ = Metronome.Reducer.reduce(state: &state, action: .bpmPlus, dependencies: makeDependencies())
        #expect(state.bpm == 121)
    }

    @Test("bpmPlus clamps at 240")
    func bpmPlusClamped() {
        var state = Metronome.State()
        state.bpm = 240
        let _ = Metronome.Reducer.reduce(state: &state, action: .bpmPlus, dependencies: makeDependencies())
        #expect(state.bpm == 240)
    }

    @Test("bpmMinus decrements BPM")
    func bpmMinus() {
        var state = Metronome.State()
        state.bpm = 120
        let _ = Metronome.Reducer.reduce(state: &state, action: .bpmMinus, dependencies: makeDependencies())
        #expect(state.bpm == 119)
    }

    @Test("bpmMinus clamps at 30")
    func bpmMinusClamped() {
        var state = Metronome.State()
        state.bpm = 30
        let _ = Metronome.Reducer.reduce(state: &state, action: .bpmMinus, dependencies: makeDependencies())
        #expect(state.bpm == 30)
    }

    @Test("bpmSet clamps to valid range")
    func bpmSet() {
        var state = Metronome.State()
        let _ = Metronome.Reducer.reduce(state: &state, action: .bpmSet(300), dependencies: makeDependencies())
        #expect(state.bpm == 240)

        let _ = Metronome.Reducer.reduce(state: &state, action: .bpmSet(10), dependencies: makeDependencies())
        #expect(state.bpm == 30)

        let _ = Metronome.Reducer.reduce(state: &state, action: .bpmSet(100), dependencies: makeDependencies())
        #expect(state.bpm == 100)
    }

    @Test("engineTick updates currentBeat with wrapping")
    func engineTick() {
        var state = Metronome.State()
        state.timeSignature = .fourFour
        let _ = Metronome.Reducer.reduce(state: &state, action: .engineTick(beat: 2), dependencies: makeDependencies())
        #expect(state.currentBeat == 2)

        let _ = Metronome.Reducer.reduce(state: &state, action: .engineTick(beat: 5), dependencies: makeDependencies())
        #expect(state.currentBeat == 1) // 5 % 4
    }

    @Test("tapTempo calculates BPM from intervals")
    func tapTempo() {
        var state = Metronome.State()
        let dependencies = makeDependencies()
        let base = Date()

        // 500ms intervals = 120 BPM
        let _ = Metronome.Reducer.reduce(state: &state, action: .tapTempoPressed(base), dependencies: dependencies)
        let _ = Metronome.Reducer.reduce(state: &state, action: .tapTempoPressed(base.addingTimeInterval(0.5)), dependencies: dependencies)
        #expect(state.bpm == 120)

        let _ = Metronome.Reducer.reduce(state: &state, action: .tapTempoPressed(base.addingTimeInterval(1.0)), dependencies: dependencies)
        #expect(state.bpm == 120)
    }

    @Test("tapTempo resets after 2s gap")
    func tapTempoReset() {
        var state = Metronome.State()
        let dependencies = makeDependencies()
        let base = Date()

        let _ = Metronome.Reducer.reduce(state: &state, action: .tapTempoPressed(base), dependencies: dependencies)
        let _ = Metronome.Reducer.reduce(state: &state, action: .tapTempoPressed(base.addingTimeInterval(0.5)), dependencies: dependencies)
        #expect(state.bpm == 120)

        // Gap > 2s resets
        let _ = Metronome.Reducer.reduce(state: &state, action: .tapTempoPressed(base.addingTimeInterval(3.0)), dependencies: dependencies)
        #expect(state.tapTimestamps.count == 1)
    }

    @Test("tapTempo keeps max 8 timestamps")
    func tapTempoMaxWindow() {
        var state = Metronome.State()
        let dependencies = makeDependencies()
        let base = Date()

        for i in 0..<12 {
            let _ = Metronome.Reducer.reduce(
                state: &state,
                action: .tapTempoPressed(base.addingTimeInterval(Double(i) * 0.5)),
                dependencies: dependencies
            )
        }
        #expect(state.tapTimestamps.count == 8)
    }

    @Test("appBecameInactive stops playback")
    func appInactive() {
        var state = Metronome.State()
        state.isPlaying = true
        state.currentBeat = 3
        let _ = Metronome.Reducer.reduce(state: &state, action: .appBecameInactive, dependencies: makeDependencies())
        #expect(state.isPlaying == false)
        #expect(state.currentBeat == 0)
    }

    @Test("appBecameInactive does nothing if not playing")
    func appInactiveNotPlaying() {
        var state = Metronome.State()
        let _ = Metronome.Reducer.reduce(state: &state, action: .appBecameInactive, dependencies: makeDependencies())
        #expect(state.isPlaying == false)
    }

    @Test("timeSignatureChanged updates state and resets beat")
    func timeSignatureChanged() {
        var state = Metronome.State()
        state.currentBeat = 2
        let _ = Metronome.Reducer.reduce(state: &state, action: .timeSignatureChanged(.threeFour), dependencies: makeDependencies())
        #expect(state.timeSignature == .threeFour)
        #expect(state.currentBeat == 0)
    }

    @Test("settingsLoaded restores state")
    func settingsLoaded() {
        var state = Metronome.State()
        let _ = Metronome.Reducer.reduce(
            state: &state,
            action: .settingsLoaded(bpm: 88, timeSignature: .sixEight, beatSound: .classic),
            dependencies: makeDependencies()
        )
        #expect(state.bpm == 88)
        #expect(state.timeSignature == .sixEight)
        #expect(state.beatSound == .classic)
    }

    @Test("engineStartFailed resets playing state")
    func engineStartFailed() {
        var state = Metronome.State()
        state.isPlaying = true
        let _ = Metronome.Reducer.reduce(state: &state, action: .engineStartFailed, dependencies: makeDependencies())
        #expect(state.isPlaying == false)
        #expect(state.currentBeat == 0)
    }

    @Test("accentPatternCycled increments index")
    func accentPatternCycled() {
        var state = Metronome.State()
        state.timeSignature = .fourFour // 3 patterns
        #expect(state.accentPatternIndex == 0)
        let _ = Metronome.Reducer.reduce(state: &state, action: .accentPatternCycled, dependencies: makeDependencies())
        #expect(state.accentPatternIndex == 1)
        let _ = Metronome.Reducer.reduce(state: &state, action: .accentPatternCycled, dependencies: makeDependencies())
        #expect(state.accentPatternIndex == 2)
    }

    @Test("accentPatternCycled wraps around")
    func accentPatternWraps() {
        var state = Metronome.State()
        state.timeSignature = .fourFour // 3 patterns
        state.accentPatternIndex = 2
        let _ = Metronome.Reducer.reduce(state: &state, action: .accentPatternCycled, dependencies: makeDependencies())
        #expect(state.accentPatternIndex == 0)
    }

    @Test("accentPatternCycled no-op for single pattern")
    func accentPatternSingleNoOp() {
        var state = Metronome.State()
        state.timeSignature = .twoFour // 1 pattern
        let _ = Metronome.Reducer.reduce(state: &state, action: .accentPatternCycled, dependencies: makeDependencies())
        #expect(state.accentPatternIndex == 0)
    }

    @Test("timeSignatureChanged resets accentPatternIndex")
    func timeSignatureResetsAccentPattern() {
        var state = Metronome.State()
        state.timeSignature = .fourFour
        state.accentPatternIndex = 2
        let _ = Metronome.Reducer.reduce(state: &state, action: .timeSignatureChanged(.threeFour), dependencies: makeDependencies())
        #expect(state.accentPatternIndex == 0)
        #expect(state.timeSignature == .threeFour)
    }

    @Test("beatSoundChanged updates state")
    func beatSoundChanged() {
        var state = Metronome.State()
        #expect(state.beatSound == .simple)
        let _ = Metronome.Reducer.reduce(state: &state, action: .beatSoundChanged(.digitalSoft), dependencies: makeDependencies())
        #expect(state.beatSound == .digitalSoft)
    }

    @Test("beatSoundChanged no-op for same sound")
    func beatSoundChangedSame() {
        var state = Metronome.State()
        state.beatSound = .classic
        let _ = Metronome.Reducer.reduce(state: &state, action: .beatSoundChanged(.classic), dependencies: makeDependencies())
        #expect(state.beatSound == .classic)
    }

    @Test("dialDrag maps angle to BPM")
    func dialDrag() {
        var state = Metronome.State()
        let dependencies = makeDependencies()

        // Angle 0 → 30 BPM (min)
        let _ = Metronome.Reducer.reduce(state: &state, action: .dialDragged(angle: 0), dependencies: dependencies)
        #expect(state.bpm == 30)

        // Half rotation → ~135 BPM
        let _ = Metronome.Reducer.reduce(state: &state, action: .dialDragged(angle: .pi), dependencies: dependencies)
        #expect(state.bpm == 135)
    }

    @Test("bpmEntryTapped shows sheet")
    func bpmEntryTapped() {
        var state = Metronome.State()
        #expect(state.showBPMEntry == false)
        let _ = Metronome.Reducer.reduce(state: &state, action: .bpmEntryTapped, dependencies: makeDependencies())
        #expect(state.showBPMEntry == true)
    }

    @Test("bpmEntryDismissed hides sheet")
    func bpmEntryDismissed() {
        var state = Metronome.State()
        state.showBPMEntry = true
        let _ = Metronome.Reducer.reduce(state: &state, action: .bpmEntryDismissed, dependencies: makeDependencies())
        #expect(state.showBPMEntry == false)
    }

    @Test("bpmEntryConfirmed sets BPM and dismisses")
    func bpmEntryConfirmed() {
        var state = Metronome.State()
        state.showBPMEntry = true
        let _ = Metronome.Reducer.reduce(state: &state, action: .bpmEntryConfirmed(180), dependencies: makeDependencies())
        #expect(state.bpm == 180)
        #expect(state.showBPMEntry == false)
    }

    @Test("bpmEntryConfirmed clamps to valid range")
    func bpmEntryConfirmedClamped() {
        var state = Metronome.State()
        state.showBPMEntry = true
        let _ = Metronome.Reducer.reduce(state: &state, action: .bpmEntryConfirmed(999), dependencies: makeDependencies())
        #expect(state.bpm == 240)
        #expect(state.showBPMEntry == false)
    }
}
