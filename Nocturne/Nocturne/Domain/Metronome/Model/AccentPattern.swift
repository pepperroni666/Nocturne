import Foundation

extension Metronome {
    struct AccentPattern: Equatable, Sendable {
        let pattern: [Bool]

        var groups: [Int] {
            guard pattern.count > 1 else { return [pattern.count] }
            var result: [Int] = []
            var currentGroupSize = 1
            for i in 1..<pattern.count {
                if pattern[i] {
                    result.append(currentGroupSize)
                    currentGroupSize = 1
                } else {
                    currentGroupSize += 1
                }
            }
            result.append(currentGroupSize)
            return result
        }
    }

    enum AccentPatternRegistry {
        static func patterns(for timeSignature: TimeSignature) -> [AccentPattern] {
            switch (timeSignature.beats, timeSignature.noteValue) {
            case (2, 4):
                return [
                    AccentPattern(pattern: [true, false])
                ]
            case (3, 4):
                return [
                    AccentPattern(pattern: [true, false, false]),
                    AccentPattern(pattern: [true, false, true])
                ]
            case (4, 4):
                return [
                    AccentPattern(pattern: [true, false, false, false]),
                    AccentPattern(pattern: [true, false, true, false]),
                    AccentPattern(pattern: [true, false, false, true])
                ]
            case (5, 4):
                return [
                    AccentPattern(pattern: [true, false, false, true, false]),
                    AccentPattern(pattern: [true, false, true, false, false]),
                    AccentPattern(pattern: [true, false, false, false, false])
                ]
            case (6, 8):
                return [
                    AccentPattern(pattern: [true, false, false, true, false, false]),
                    AccentPattern(pattern: [true, false, false, false, false, false])
                ]
            case (7, 8):
                return [
                    AccentPattern(pattern: [true, false, true, false, true, false, false]),
                    AccentPattern(pattern: [true, false, false, true, false, true, false]),
                    AccentPattern(pattern: [true, false, false, true, false, false, false]),
                    AccentPattern(pattern: [true, false, false, false, false, false, false])
                ]
            default:
                let pattern = [true] + Array(repeating: false, count: max(0, timeSignature.beats - 1))
                return [AccentPattern(pattern: pattern)]
            }
        }
    }
}
