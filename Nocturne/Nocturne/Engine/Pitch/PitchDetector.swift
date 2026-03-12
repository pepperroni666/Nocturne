import Foundation

extension Tuner {
    /// A thin Swift mirror of the C `PitchResult` struct.
    /// All DSP (YIN, median filtering, hysteresis) lives in the C layer;
    /// Swift only reads the final result.
    struct PitchReading: Sendable, Equatable {
        let hz: Double          // -1 if no pitch
        let midi: Int           // -1 if no pitch
        let cents: Double       // -50..+50
        let confidence: Double  // 0..1 raw ACF periodicity
        let stability: Double   // 0..1 fused multi-factor score
    }
}

protocol PitchDetector: Sendable {
    func requestPermission() async -> Tuner.MicPermissionStatus
    func start() async throws -> AsyncStream<Tuner.PitchReading>
    func stop() async
}
