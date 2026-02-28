import AVFoundation
import Foundation

actor TonePlayerEngine: TonePlayerProtocol {
    private var audioEngine: AVAudioEngine?
    private var sourceNode: AVAudioSourceNode?
    private var continuation: AsyncStream<Tuner.ToneEvent>.Continuation?

    private final class ToneState: @unchecked Sendable {
        var frequency: Double = 440.0
        var phase: Double = 0.0
        var sampleRate: Double = 44100.0
        var amplitude: Float = 0.0
        var targetAmplitude: Float = 0.8
        var isRunning: Bool = false

        // Fade: 10ms ramp
        var fadeIncrement: Float {
            Float(1.0 / (sampleRate * 0.01))
        }
    }

    private let toneState = ToneState()

    func play(frequency: Double) async throws -> AsyncStream<Tuner.ToneEvent> {
        await stop()

        try Audio.Session.activate()

        let engine = AVAudioEngine()
        let format = engine.outputNode.outputFormat(forBus: 0)
        let sampleRate = format.sampleRate

        toneState.frequency = frequency
        toneState.phase = 0
        toneState.sampleRate = sampleRate
        toneState.amplitude = 0
        toneState.targetAmplitude = 0.8
        toneState.isRunning = true

        let (stream, streamContinuation) = AsyncStream.makeStream(of: Tuner.ToneEvent.self)
        self.continuation = streamContinuation

        let state = toneState
        let sourceNode = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let frames = Int(frameCount)
            let phaseIncrement = 2.0 * Double.pi * state.frequency / state.sampleRate
            let fadeInc = state.fadeIncrement

            for frame in 0..<frames {
                // Fade in/out
                if state.isRunning {
                    if state.amplitude < state.targetAmplitude {
                        state.amplitude = min(state.amplitude + fadeInc, state.targetAmplitude)
                    }
                } else {
                    state.amplitude = max(state.amplitude - fadeInc, 0)
                }

                let sample = Float(sin(state.phase)) * state.amplitude
                state.phase += phaseIncrement
                if state.phase >= 2.0 * Double.pi {
                    state.phase -= 2.0 * Double.pi
                }

                for buffer in ablPointer {
                    let buf = UnsafeMutableBufferPointer<Float>(buffer)
                    buf[frame] = sample
                }
            }
            return noErr
        }

        engine.attach(sourceNode)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: format)
        try engine.start()

        self.audioEngine = engine
        self.sourceNode = sourceNode

        return stream
    }

    func stop() {
        toneState.isRunning = false
        // Allow brief fade out before teardown
        audioEngine?.stop()
        if let node = sourceNode {
            audioEngine?.detach(node)
        }
        audioEngine = nil
        sourceNode = nil
        continuation?.finish()
        continuation = nil
    }
}
