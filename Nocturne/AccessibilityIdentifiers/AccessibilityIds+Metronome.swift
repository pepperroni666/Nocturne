public extension AccessibilityIds {
    enum Metronome {
        public static let playButton = "metronome.playButton"
        public static let stopButton = "metronome.stopButton"
        public static let bpmDisplay = "metronome.bpmDisplay"
        public static let bpmMinus = "metronome.bpmMinus"
        public static let bpmPlus = "metronome.bpmPlus"
        public static let tapTempo = "metronome.tapTempo"
        public static let dial = "metronome.dial"
        public static let beatDots = "metronome.beatDots"

        public enum TimeSignature {
            public static func button(_ ts: String) -> String { "metronome.timeSignature.\(ts)" }
        }

        public enum BPMEntry {
            public static let textField = "metronome.bpmEntry.textField"
            public static let doneButton = "metronome.bpmEntry.doneButton"
            public static let errorLabel = "metronome.bpmEntry.errorLabel"
        }
    }
}
