import Foundation
import Testing
@testable import Nocturne

@Suite("MusicMath")
struct MusicMathTests {

    // MARK: - Note Names

    @Test("MIDI 60 is C4 (middle C)")
    func middleC() {
        #expect(Tuner.MusicMath.noteName(midi: 60) == .C)
        #expect(Tuner.MusicMath.octave(midi: 60) == 4)
        #expect(Tuner.MusicMath.displayName(midi: 60) == "C4")
    }

    @Test("MIDI 69 is A4")
    func a4() {
        #expect(Tuner.MusicMath.noteName(midi: 69) == .A)
        #expect(Tuner.MusicMath.octave(midi: 69) == 4)
    }

    @Test("MIDI 12 is C0")
    func c0() {
        #expect(Tuner.MusicMath.noteName(midi: 12) == .C)
        #expect(Tuner.MusicMath.octave(midi: 12) == 0)
    }

    @Test("MIDI 119 is B8")
    func b8() {
        #expect(Tuner.MusicMath.noteName(midi: 119) == .B)
        #expect(Tuner.MusicMath.octave(midi: 119) == 8)
    }

    // MARK: - All 12 note names in octave 4

    @Test("Octave 4 has all 12 note names")
    func octave4() {
        let expected: [(Tuner.NoteName, Int)] = [
            (.C,  60), (.Cs, 61), (.D,  62), (.Ds, 63),
            (.E,  64), (.F,  65), (.Fs, 66), (.G,  67),
            (.Gs, 68), (.A,  69), (.As, 70), (.B,  71),
        ]

        for (name, midi) in expected {
            #expect(Tuner.MusicMath.noteName(midi: midi) == name,
                    "Expected \(name) for MIDI \(midi)")
            #expect(Tuner.MusicMath.octave(midi: midi) == 4)
        }
    }

    // MARK: - Reference Frequencies

    @Test("A4 = 440 Hz at standard calibration")
    func a4Frequency() {
        let freq = Tuner.MusicMath.frequency(midi: 69)
        #expect(abs(freq - 440.0) < 0.01)
    }

    @Test("A4 = 442 Hz at A4=442 calibration")
    func a4Calibrated() {
        let freq = Tuner.MusicMath.frequency(midi: 69, a4: 442.0)
        #expect(abs(freq - 442.0) < 0.01)
    }

    @Test("C0 = 16.35 Hz")
    func c0Frequency() {
        let freq = Tuner.MusicMath.frequency(midi: 12)
        #expect(abs(freq - 16.35) < 0.02)
    }

    @Test("E2 = 82.41 Hz (guitar low E)")
    func e2Frequency() {
        let freq = Tuner.MusicMath.frequency(midi: 40)
        #expect(abs(freq - 82.41) < 0.01)
    }

    @Test("C4 = 261.63 Hz (middle C)")
    func c4Frequency() {
        let freq = Tuner.MusicMath.frequency(midi: 60)
        #expect(abs(freq - 261.63) < 0.01)
    }

    @Test("A5 = 880.00 Hz")
    func a5Frequency() {
        let freq = Tuner.MusicMath.frequency(midi: 81)
        #expect(abs(freq - 880.0) < 0.01)
    }

    @Test("C8 = 4186.01 Hz")
    func c8Frequency() {
        let freq = Tuner.MusicMath.frequency(midi: 108)
        #expect(abs(freq - 4186.01) < 0.1)
    }

    @Test("B8 = 7902.13 Hz")
    func b8Frequency() {
        let freq = Tuner.MusicMath.frequency(midi: 119)
        #expect(abs(freq - 7902.13) < 0.1)
    }

    // MARK: - Display Names

    @Test("displayName formats correctly")
    func displayNames() {
        #expect(Tuner.MusicMath.displayName(midi: 69) == "A4")
        #expect(Tuner.MusicMath.displayName(midi: 61) == "C#4")
        #expect(Tuner.MusicMath.displayName(midi: 40) == "E2")
        #expect(Tuner.MusicMath.displayName(midi: 12) == "C0")
    }

    // MARK: - NoteName displayString

    @Test("NoteName displayString matches expected values")
    func noteNameDisplay() {
        let expected = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        for (i, name) in Tuner.NoteName.allCases.enumerated() {
            #expect(name.displayString == expected[i])
        }
    }
}
