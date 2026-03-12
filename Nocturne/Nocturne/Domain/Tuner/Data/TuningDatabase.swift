import Foundation

extension Tuner {
    enum Instrument: String, Sendable, Equatable, CaseIterable, Identifiable {
        case guitar
        case bass
        case ukulele

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .guitar: "Guitar"
            case .bass: "Bass"
            case .ukulele: "Ukulele"
            }
        }
    }

    enum TuningPreset: String, Sendable, Equatable, CaseIterable, Identifiable {
        case guitarStandard
        case guitarDropD
        case guitarOpenG
        case bassStandard
        case bassDropD
        case ukuleleStandardC
        case ukuleleLowG

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .guitarStandard: "Standard"
            case .guitarDropD: "Drop D"
            case .guitarOpenG: "Open G"
            case .bassStandard: "Standard"
            case .bassDropD: "Drop D"
            case .ukuleleStandardC: "Standard C"
            case .ukuleleLowG: "Low G"
            }
        }

        var instrument: Instrument {
            switch self {
            case .guitarStandard, .guitarDropD, .guitarOpenG: .guitar
            case .bassStandard, .bassDropD: .bass
            case .ukuleleStandardC, .ukuleleLowG: .ukulele
            }
        }
    }

    struct TuningString: Sendable, Equatable, Identifiable {
        let stringNumber: Int
        let noteName: String
        let midiNote: Int
        let frequency: Double

        var id: Int { stringNumber }
    }

    enum TuningDatabase {
        private static let presetMIDI: [TuningPreset: [Int]] = [
            .guitarStandard:   [40, 45, 50, 55, 59, 64],
            .guitarDropD:      [38, 45, 50, 55, 59, 64],
            .guitarOpenG:      [38, 43, 50, 55, 59, 62],
            .bassStandard:     [28, 33, 38, 43],
            .bassDropD:        [26, 33, 38, 43],
            .ukuleleStandardC: [67, 60, 64, 69],
            .ukuleleLowG:      [55, 60, 64, 69],
        ]

        static func strings(for preset: TuningPreset, a4: Double = 440.0) -> [TuningString] {
            guard let midiNotes = presetMIDI[preset] else { return [] }

            return midiNotes.enumerated().map { index, midi in
                TuningString(
                    stringNumber: index + 1,
                    noteName: MusicMath.displayName(midi: midi),
                    midiNote: midi,
                    frequency: MusicMath.frequency(midi: midi, a4: a4)
                )
            }
        }

        static func presets(for instrument: Instrument) -> [TuningPreset] {
            TuningPreset.allCases.filter { $0.instrument == instrument }
        }

        static func defaultTuning(for instrument: Instrument) -> TuningPreset {
            switch instrument {
            case .guitar: .guitarStandard
            case .bass: .bassStandard
            case .ukulele: .ukuleleStandardC
            }
        }
    }
}
