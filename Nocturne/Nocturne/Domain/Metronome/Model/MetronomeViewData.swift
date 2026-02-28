import Foundation

extension Metronome {
    struct TapTempoViewData: Sendable, Equatable {
        let buttonTitle: String
    }

    struct BPMEntryViewData: Sendable, Equatable {
        let title: String
        let placeholder: String
        let errorMessage: String
        let doneButtonTitle: String
    }
}

extension Metronome.State {
    var tapTempoViewData: Metronome.TapTempoViewData {
        .init(buttonTitle: "TAP TEMPO")
    }

    var bpmEntryViewData: Metronome.BPMEntryViewData {
        .init(
            title: "Set BPM",
            placeholder: "30 – 240",
            errorMessage: "BPM must be between 30 and 240",
            doneButtonTitle: "Done"
        )
    }
}
