import Foundation

extension Metronome {
    struct State: Sendable, Equatable {
        var bpm: Int = 120
        var timeSignature: TimeSignature = .fourFour
        var isPlaying: Bool = false
        var currentBeat: Int = 0
        var tapTimestamps: [Date] = []
        var dialAngle: Double = 0
        var isDragging: Bool = false
        var showTimeSignaturePicker: Bool = false
        var accentPatternIndex: Int = 0
        var beatSound: BeatSound = .simple
        var showBPMEntry: Bool = false

        var accentPattern: AccentPattern {
            let patterns = AccentPatternRegistry.patterns(for: timeSignature)
            let safeIndex = accentPatternIndex % patterns.count
            return patterns[safeIndex]
        }

        static let bpmRange: ClosedRange<Int> = 30...240

        var bpmFraction: Double {
            Double(bpm - Self.bpmRange.lowerBound) / Double(Self.bpmRange.upperBound - Self.bpmRange.lowerBound)
        }

        var beatProgress: Double {
            guard timeSignature.beats > 0 else { return 0 }
            return Double(currentBeat) / Double(timeSignature.beats)
        }
    }
}
