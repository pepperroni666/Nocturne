public extension AccessibilityIds {
    enum Tuner {
        public static func modeButton(_ mode: String) -> String { "tuner.mode.\(mode)" }
        public static let listenButton = "tuner.listenButton"
        public static let noteDisplay = "tuner.noteDisplay"
        public static let frequencyDisplay = "tuner.frequencyDisplay"
        public static let centsDisplay = "tuner.centsDisplay"
        public static let pitchGauge = "tuner.pitchGauge"
        public static let a4Minus = "tuner.a4Minus"
        public static let a4Plus = "tuner.a4Plus"
        public static let a4Display = "tuner.a4Display"
        public static func instrumentButton(_ name: String) -> String { "tuner.instrument.\(name)" }
        public static let tuningMenu = "tuner.tuningMenu"
        public static func stringButton(_ index: Int) -> String { "tuner.string.\(index)" }
        public static let stopToneButton = "tuner.stopToneButton"
    }
}
