import Foundation
import Testing
@testable import Nocturne

@Suite("TuningDatabase")
struct TuningDatabaseTests {

    @Test("Guitar standard has 6 strings")
    func guitarStandardStringCount() {
        let strings = Tuner.TuningDatabase.strings(for: .guitarStandard)
        #expect(strings.count == 6)
    }

    @Test("Guitar standard has correct note names")
    func guitarStandardNoteNames() {
        let strings = Tuner.TuningDatabase.strings(for: .guitarStandard)
        let names = strings.map(\.noteName)
        #expect(names == ["E2", "A2", "D3", "G3", "B3", "E4"])
    }

    @Test("E4 frequency is approximately 329.6 Hz at A4=440")
    func e4Frequency() {
        let strings = Tuner.TuningDatabase.strings(for: .guitarStandard, a4: 440.0)
        guard let e4 = strings.last else {
            Issue.record("No strings found")
            return
        }
        #expect(e4.noteName == "E4")
        // E4 MIDI 64: 440 * 2^((64-69)/12) ≈ 329.63 Hz
        #expect(abs(e4.frequency - 329.63) < 0.1)
    }

    @Test("A4 calibration shifts frequencies")
    func a4CalibrationShift() {
        let strings440 = Tuner.TuningDatabase.strings(for: .guitarStandard, a4: 440.0)
        let strings442 = Tuner.TuningDatabase.strings(for: .guitarStandard, a4: 442.0)

        for (s440, s442) in zip(strings440, strings442) {
            #expect(s442.frequency > s440.frequency)
        }
    }

    @Test("Bass standard has 4 strings")
    func bassStandardStringCount() {
        let strings = Tuner.TuningDatabase.strings(for: .bassStandard)
        #expect(strings.count == 4)
    }

    @Test("Ukulele standard C has 4 strings")
    func ukuleleStandardCStringCount() {
        let strings = Tuner.TuningDatabase.strings(for: .ukuleleStandardC)
        #expect(strings.count == 4)
    }

    @Test("defaultTuning returns correct preset per instrument")
    func defaultTuningPerInstrument() {
        #expect(Tuner.TuningDatabase.defaultTuning(for: .guitar) == .guitarStandard)
        #expect(Tuner.TuningDatabase.defaultTuning(for: .bass) == .bassStandard)
        #expect(Tuner.TuningDatabase.defaultTuning(for: .ukulele) == .ukuleleStandardC)
    }

    @Test("Presets for guitar returns guitar tunings only")
    func presetsForGuitar() {
        let presets = Tuner.TuningDatabase.presets(for: .guitar)
        #expect(presets.count == 3)
        for preset in presets {
            #expect(preset.instrument == .guitar)
        }
    }

    @Test("Equal temperament frequency calculation")
    func equalTemperament() {
        // A4 (MIDI 69) should equal a4
        let a4Freq = Tuner.TuningDatabase.frequency(midiNote: 69, a4: 440.0)
        #expect(abs(a4Freq - 440.0) < 0.01)

        // A5 (MIDI 81) should be double A4
        let a5Freq = Tuner.TuningDatabase.frequency(midiNote: 81, a4: 440.0)
        #expect(abs(a5Freq - 880.0) < 0.01)

        // A3 (MIDI 57) should be half A4
        let a3Freq = Tuner.TuningDatabase.frequency(midiNote: 57, a4: 440.0)
        #expect(abs(a3Freq - 220.0) < 0.01)
    }
}
