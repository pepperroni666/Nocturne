import Foundation

protocol TonePlayer: Sendable {
    func play(frequency: Double) async throws -> AsyncStream<Tuner.ToneEvent>
    func stop() async
}
