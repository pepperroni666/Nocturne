import Foundation

extension Tuner {
    enum TunerMode: String, Sendable, Equatable, CaseIterable {
        case microphone
        case referenceTone

        var displayName: String {
            switch self {
            case .microphone: "Microphone"
            case .referenceTone: "Reference"
            }
        }
    }

    enum MicPermissionStatus: Sendable, Equatable {
        case notDetermined
        case authorized
        case denied
    }

    struct DetectedPitch: Sendable, Equatable {
        let frequency: Double
        let noteName: NoteName
        let octave: Int
        let cents: Double
        let confidence: Double
        let midiNote: Int
    }

    struct State: Sendable, Equatable {
        var mode: TunerMode = .microphone
        var micPermission: MicPermissionStatus = .notDetermined
        var isListening: Bool = false
        var detectedPitch: DetectedPitch? = nil
        var pitchStability: Double = 0.0

        var selectedInstrument: Instrument = .guitar
        var selectedTuning: TuningPreset = .guitarStandard
        var playingStringIndex: Int? = nil

        var a4Calibration: Double = 440.0

        static let a4Range: ClosedRange<Double> = 430.0...450.0

        var currentStrings: [TuningString] {
            TuningDatabase.strings(for: selectedTuning, a4: a4Calibration)
        }
    }
}
