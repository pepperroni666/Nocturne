import Foundation

extension Metronome {
    struct TimeSignature: Codable, Sendable, Equatable, Hashable {
        let beats: Int
        let noteValue: Int

        static let fourFour = TimeSignature(beats: 4, noteValue: 4)
        static let threeFour = TimeSignature(beats: 3, noteValue: 4)
        static let twoFour = TimeSignature(beats: 2, noteValue: 4)
        static let fiveFour = TimeSignature(beats: 5, noteValue: 4)
        static let sixEight = TimeSignature(beats: 6, noteValue: 8)
        static let sevenEight = TimeSignature(beats: 7, noteValue: 8)

        var displayString: String { "\(beats)/\(noteValue)" }

        static let presets: [TimeSignature] = [
            .twoFour, .threeFour, .fourFour, .fiveFour, .sixEight, .sevenEight
        ]
    }
}
