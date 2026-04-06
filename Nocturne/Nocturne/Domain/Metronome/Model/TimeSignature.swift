import Foundation

extension Metronome {
    struct TimeSignature: Codable, Sendable, Equatable, Hashable {
        let beats: Int
        let noteValue: Int

        static nonisolated let fourFour = TimeSignature(beats: 4, noteValue: 4)
        static nonisolated let threeFour = TimeSignature(beats: 3, noteValue: 4)
        static nonisolated let twoFour = TimeSignature(beats: 2, noteValue: 4)
        static nonisolated let fiveFour = TimeSignature(beats: 5, noteValue: 4)
        static nonisolated let sixEight = TimeSignature(beats: 6, noteValue: 8)
        static nonisolated let sevenEight = TimeSignature(beats: 7, noteValue: 8)

        var displayString: String { "\(beats)/\(noteValue)" }

        static let presets: [TimeSignature] = [
            .twoFour, .threeFour, .fourFour, .fiveFour, .sixEight, .sevenEight
        ]
    }
}
