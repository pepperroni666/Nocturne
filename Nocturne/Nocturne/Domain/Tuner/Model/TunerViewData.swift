import Foundation

extension Tuner {
    struct MicrophoneModeViewData: Sendable, Equatable {
        let noFrequencyText: String
        let noNoteText: String
        let buttonTitle: String
        let buttonIcon: String
    }

    struct ReferenceToneModeViewData: Sendable, Equatable {
        let stopButtonTitle: String
    }

    struct PitchGaugeViewData: Sendable, Equatable {
        let minLabel: String
        let centerLabel: String
        let maxLabel: String
    }

    struct A4CalibrationViewData: Sendable, Equatable {
        let label: String
        let valueText: String
    }
}

extension Tuner.State {
    var microphoneModeViewData: Tuner.MicrophoneModeViewData {
        .init(
            noFrequencyText: "-- Hz",
            noNoteText: "--",
            buttonTitle: isListening ? "Listening..." : "Start",
            buttonIcon: isListening ? "mic.fill" : "mic"
        )
    }

    var referenceToneModeViewData: Tuner.ReferenceToneModeViewData {
        .init(stopButtonTitle: "Stop")
    }

    var pitchGaugeViewData: Tuner.PitchGaugeViewData {
        .init(minLabel: "-50", centerLabel: "0", maxLabel: "+50")
    }

    var a4CalibrationViewData: Tuner.A4CalibrationViewData {
        .init(label: "A4", valueText: "\(Int(a4Calibration)) Hz")
    }
}
