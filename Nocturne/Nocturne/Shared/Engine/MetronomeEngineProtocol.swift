import Foundation

extension Metronome {
    struct Tick: Sendable {
        let beat: Int
        let isAccent: Bool
    }
}

protocol MetronomeEngineProtocol: Sendable {
    func start(bpm: Int, beatsPerMeasure: Int, accentPattern: [Bool], beatSound: Metronome.BeatSound) async throws -> AsyncStream<Metronome.Tick>
    func updateTempo(bpm: Int) async
    func updateAccentPattern(_ pattern: [Bool]) async
    func updateBeatSound(_ beatSound: Metronome.BeatSound) async
    func stop() async
}
