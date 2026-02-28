import Foundation

extension Tuner {
    enum NoteName: Int, Sendable, CaseIterable {
        case C = 0, Cs, D, Ds, E, F, Fs, G, Gs, A, As, B

        var displayString: String {
            switch self {
            case .C:  "C"
            case .Cs: "C#"
            case .D:  "D"
            case .Ds: "D#"
            case .E:  "E"
            case .F:  "F"
            case .Fs: "F#"
            case .G:  "G"
            case .Gs: "G#"
            case .A:  "A"
            case .As: "A#"
            case .B:  "B"
            }
        }

        static func from(midi: Int) -> NoteName {
            NoteName(rawValue: midi % 12)!
        }
    }

    /// MIDI note utilities — pure calculations, no stored data.
    enum MusicMath {
        static func noteName(midi: Int) -> NoteName {
            NoteName.from(midi: midi)
        }

        static func octave(midi: Int) -> Int {
            midi / 12 - 1
        }

        static func frequency(midi: Int, a4: Double = 440.0) -> Double {
            a4 * pow(2.0, Double(midi - 69) / 12.0)
        }

        static func displayName(midi: Int) -> String {
            "\(noteName(midi: midi).displayString)\(octave(midi: midi))"
        }
    }
}
