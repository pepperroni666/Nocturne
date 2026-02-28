import AVFoundation
import Foundation

extension Audio {
    actor TonePlayerEngine: TonePlayer {
        private var audioEngine: AVAudioEngine?
        private var sourceNode: AVAudioSourceNode?
        private var continuation: AsyncStream<Tuner.ToneEvent>.Continuation?

        private let playbackState = SamplePlaybackState()

        func play(frequency: Double) async throws -> AsyncStream<Tuner.ToneEvent> {
            await stop()

            try Audio.Session.activate()

            let engine = AVAudioEngine()
            let format = engine.outputNode.outputFormat(forBus: 0)
            let sampleRate = format.sampleRate

            // TODO: load note-specific WAV keyed by frequency/MIDI once assets are ready.
            // For now, use a simple tick click as a placeholder for every note.
            let samples = try Audio.SampleLoader.load(sound: .simple, accent: false, sampleRate: sampleRate)

            playbackState.samples = samples
            playbackState.position = 0
            playbackState.loop = true
            playbackState.isRunning = true

            let (stream, streamContinuation) = AsyncStream.makeStream(of: Tuner.ToneEvent.self)
            self.continuation = streamContinuation

            let state = playbackState
            let sourceNode = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
                let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
                let frames = Int(frameCount)

                for frame in 0..<frames {
                    var sample: Float = 0
                    if state.isRunning && !state.samples.isEmpty {
                        sample = state.samples[state.position % state.samples.count]
                        state.position += 1
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

            streamContinuation.yield(.started)
            return stream
        }

        func stop() {
            guard playbackState.isRunning else { return }
            playbackState.isRunning = false
            audioEngine?.stop()
            if let node = sourceNode {
                audioEngine?.detach(node)
            }
            audioEngine = nil
            sourceNode = nil
            continuation?.yield(.stopped)
            continuation?.finish()
            continuation = nil
        }
    }
}
