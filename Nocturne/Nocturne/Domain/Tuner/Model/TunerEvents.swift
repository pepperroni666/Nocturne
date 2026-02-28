import Foundation

extension Tuner {
    enum PitchDetectionEvent: Sendable {
        case pitched(PitchReading)
        case lost
    }

    enum ToneEvent: Sendable {
        case started
        case stopped
        case failed
    }
}
