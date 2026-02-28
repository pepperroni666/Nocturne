import Foundation
import Testing
@testable import Nocturne

@Suite("TunerReducer")
@MainActor
struct TunerReducerTests {

    private func makeDependencies() -> Tuner.Effects {
        .mock
    }

    @Test("modeChanged stops all active audio")
    func modeChangedStopsAll() {
        var state = Tuner.State()
        state.isListening = true
        state.playingStringIndex = 2
        let _ = Tuner.Reducer.reduce(state: &state, action: .modeChanged(.referenceTone), dependencies: makeDependencies())
        #expect(state.mode == .referenceTone)
        #expect(state.isListening == false)
        #expect(state.playingStringIndex == nil)
    }

    @Test("modeChanged no-op for same mode")
    func modeChangedSame() {
        var state = Tuner.State()
        state.mode = .microphone
        let effect = Tuner.Reducer.reduce(state: &state, action: .modeChanged(.microphone), dependencies: makeDependencies())
        #expect(state.mode == .microphone)
        if case .none = effect {} else { Issue.record("Expected .none") }
    }

    @Test("startListening with authorized starts detection")
    func startListeningAuthorized() {
        var state = Tuner.State()
        state.micPermission = .authorized
        let _ = Tuner.Reducer.reduce(state: &state, action: .startListening, dependencies: makeDependencies())
        #expect(state.isListening == true)
    }

    @Test("startListening with denied does nothing")
    func startListeningDenied() {
        var state = Tuner.State()
        state.micPermission = .denied
        let effect = Tuner.Reducer.reduce(state: &state, action: .startListening, dependencies: makeDependencies())
        #expect(state.isListening == false)
        if case .none = effect {} else { Issue.record("Expected .none") }
    }

    @Test("startListening with notDetermined requests permission")
    func startListeningNotDetermined() {
        var state = Tuner.State()
        state.micPermission = .notDetermined
        let _ = Tuner.Reducer.reduce(state: &state, action: .startListening, dependencies: makeDependencies())
        #expect(state.isListening == false) // Not yet listening, waiting for permission
    }

    @Test("stopListening clears state")
    func stopListening() {
        var state = Tuner.State()
        state.isListening = true
        state.detectedPitch = Tuner.DetectedPitch(frequency: 440, noteName: .A, octave: 4, cents: 0, confidence: 0.9, midiNote: 69)
        state.pitchStability = 0.8
        let _ = Tuner.Reducer.reduce(state: &state, action: .stopListening, dependencies: makeDependencies())
        #expect(state.isListening == false)
        #expect(state.detectedPitch == nil)
        #expect(state.pitchStability == 0)
    }

    @Test("pitchDetected updates state correctly")
    func pitchDetected() {
        var state = Tuner.State()
        state.a4Calibration = 440.0
        let reading = Tuner.PitchReading(hz: 440.0, midi: 69, cents: 0.0, confidence: 0.95, stability: 0.85)
        let _ = Tuner.Reducer.reduce(state: &state, action: .pitchDetected(reading), dependencies: makeDependencies())
        #expect(state.detectedPitch != nil)
        #expect(state.detectedPitch?.noteName == .A)
        #expect(state.detectedPitch?.octave == 4)
        #expect(abs(state.detectedPitch?.cents ?? 100) < 1.0)
        #expect(state.detectedPitch?.confidence == 0.95)
        #expect(state.pitchStability == 0.85)
    }

    @Test("pitchDetected calculates cents for sharp pitch")
    func pitchDetectedSharp() {
        var state = Tuner.State()
        state.a4Calibration = 440.0
        // Slightly sharp A4 — C layer provides the cents
        let reading = Tuner.PitchReading(hz: 445.0, midi: 69, cents: 19.6, confidence: 0.9, stability: 0.7)
        let _ = Tuner.Reducer.reduce(state: &state, action: .pitchDetected(reading), dependencies: makeDependencies())
        #expect(state.detectedPitch != nil)
        #expect(state.detectedPitch?.noteName == .A)
        #expect(state.detectedPitch!.cents > 0)
    }

    @Test("pitchLost keeps last note, zeros stability")
    func pitchLost() {
        var state = Tuner.State()
        state.detectedPitch = Tuner.DetectedPitch(frequency: 440, noteName: .A, octave: 4, cents: 0, confidence: 0.9, midiNote: 69)
        state.pitchStability = 0.9
        let _ = Tuner.Reducer.reduce(state: &state, action: .pitchLost, dependencies: makeDependencies())
        #expect(state.detectedPitch != nil)
        #expect(state.detectedPitch?.noteName == .A)
        #expect(state.pitchStability == 0)
    }

    @Test("instrumentChanged resets tuning to default")
    func instrumentChanged() {
        var state = Tuner.State()
        state.selectedInstrument = .guitar
        state.selectedTuning = .guitarDropD
        state.playingStringIndex = 3
        let _ = Tuner.Reducer.reduce(state: &state, action: .instrumentChanged(.bass), dependencies: makeDependencies())
        #expect(state.selectedInstrument == .bass)
        #expect(state.selectedTuning == .bassStandard)
        #expect(state.playingStringIndex == nil)
    }

    @Test("instrumentChanged no-op for same instrument")
    func instrumentChangedSame() {
        var state = Tuner.State()
        state.selectedInstrument = .guitar
        let effect = Tuner.Reducer.reduce(state: &state, action: .instrumentChanged(.guitar), dependencies: makeDependencies())
        if case .none = effect {} else { Issue.record("Expected .none") }
    }

    @Test("tuningChanged stops tone")
    func tuningChanged() {
        var state = Tuner.State()
        state.selectedTuning = .guitarStandard
        state.playingStringIndex = 2
        let _ = Tuner.Reducer.reduce(state: &state, action: .tuningChanged(.guitarDropD), dependencies: makeDependencies())
        #expect(state.selectedTuning == .guitarDropD)
        #expect(state.playingStringIndex == nil)
    }

    @Test("stringTapped sets playing index")
    func stringTapped() {
        var state = Tuner.State()
        state.selectedTuning = .guitarStandard
        let _ = Tuner.Reducer.reduce(state: &state, action: .stringTapped(2), dependencies: makeDependencies())
        #expect(state.playingStringIndex == 2)
    }

    @Test("stringTapped same index stops tone")
    func stringTappedSameStops() {
        var state = Tuner.State()
        state.selectedTuning = .guitarStandard
        state.playingStringIndex = 2
        let _ = Tuner.Reducer.reduce(state: &state, action: .stringTapped(2), dependencies: makeDependencies())
        #expect(state.playingStringIndex == nil)
    }

    @Test("stopTone clears playing index")
    func stopTone() {
        var state = Tuner.State()
        state.playingStringIndex = 3
        let _ = Tuner.Reducer.reduce(state: &state, action: .stopTone, dependencies: makeDependencies())
        #expect(state.playingStringIndex == nil)
    }

    @Test("a4Calibration clamps to 430-450")
    func a4CalibrationClamped() {
        var state = Tuner.State()

        let _ = Tuner.Reducer.reduce(state: &state, action: .a4CalibrationChanged(420), dependencies: makeDependencies())
        #expect(state.a4Calibration == 430.0)

        let _ = Tuner.Reducer.reduce(state: &state, action: .a4CalibrationChanged(460), dependencies: makeDependencies())
        #expect(state.a4Calibration == 450.0)

        let _ = Tuner.Reducer.reduce(state: &state, action: .a4CalibrationChanged(442), dependencies: makeDependencies())
        #expect(state.a4Calibration == 442.0)
    }

    @Test("settingsLoaded restores state")
    func settingsLoaded() {
        var state = Tuner.State()
        let _ = Tuner.Reducer.reduce(
            state: &state,
            action: .settingsLoaded(instrument: .bass, tuning: .bassDropD, a4: 442),
            dependencies: makeDependencies()
        )
        #expect(state.selectedInstrument == .bass)
        #expect(state.selectedTuning == .bassDropD)
        #expect(state.a4Calibration == 442.0)
    }

    @Test("stopAll stops everything")
    func stopAll() {
        var state = Tuner.State()
        state.isListening = true
        state.playingStringIndex = 1
        state.detectedPitch = Tuner.DetectedPitch(frequency: 440, noteName: .A, octave: 4, cents: 0, confidence: 0.9, midiNote: 69)
        state.pitchStability = 0.5
        let _ = Tuner.Reducer.reduce(state: &state, action: .stopAll, dependencies: makeDependencies())
        #expect(state.isListening == false)
        #expect(state.playingStringIndex == nil)
        #expect(state.detectedPitch == nil)
        #expect(state.pitchStability == 0)
    }

    @Test("micPermissionUpdated with authorized starts listening")
    func micPermissionAuthorized() {
        var state = Tuner.State()
        let _ = Tuner.Reducer.reduce(state: &state, action: .micPermissionUpdated(.authorized), dependencies: makeDependencies())
        #expect(state.micPermission == .authorized)
        #expect(state.isListening == true)
    }

    @Test("micListenFailed resets listening state")
    func micListenFailed() {
        var state = Tuner.State()
        state.isListening = true
        let _ = Tuner.Reducer.reduce(state: &state, action: .micListenFailed, dependencies: makeDependencies())
        #expect(state.isListening == false)
        #expect(state.detectedPitch == nil)
    }

    @Test("tonePlaybackFailed clears playing index")
    func tonePlaybackFailed() {
        var state = Tuner.State()
        state.playingStringIndex = 2
        let _ = Tuner.Reducer.reduce(state: &state, action: .tonePlaybackFailed, dependencies: makeDependencies())
        #expect(state.playingStringIndex == nil)
    }
}
