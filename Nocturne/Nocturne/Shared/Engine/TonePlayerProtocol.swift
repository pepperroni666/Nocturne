import Foundation

protocol TonePlayerProtocol: Sendable {
    func play(frequency: Double) async throws -> AsyncStream<Tuner.ToneEvent>
    func stop() async
}
