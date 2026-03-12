import AVFoundation
import Foundation

extension Audio {
    actor SoundPlayerEngine: TonePlayer {
        private var audioEngine: AVAudioEngine?
        private var sourceNode: AVAudioSourceNode?
        private var toneContinuation: AsyncStream<Tuner.ToneEvent>.Continuation?
        private var autoStopTask: Task<Void, Never>?

        private let playbackState = SamplePlaybackState()

        // MARK: - TonePlayer (tuner reference tone, loops until stop())

        func play(frequency: Double) async throws -> AsyncStream<Tuner.ToneEvent> {
            stop()

            try Audio.Session.activate()

            let engine = AVAudioEngine()
            let format = engine.outputNode.outputFormat(forBus: 0)
            let sampleRate = format.sampleRate

            // TODO: load note-specific WAV keyed by frequency/MIDI once assets are ready.
            let samples = try Audio.SampleLoader.load(sound: .simple, accent: false, sampleRate: sampleRate)

            playbackState.samples = samples
            playbackState.position = 0
            playbackState.loop = true
            playbackState.isRunning = true

            let (stream, continuation) = AsyncStream.makeStream(of: Tuner.ToneEvent.self)
            toneContinuation = continuation

            try startEngine(engine, format: format)
            continuation.yield(.started)
            return stream
        }

        // MARK: - Beat preview (settings picker, plays 4 beats then stops)

        func playBeatPreview(sound: Metronome.BeatSound) async throws {
            stop()

            try Audio.Session.activate()

            let engine = AVAudioEngine()
            let format = engine.outputNode.outputFormat(forBus: 0)
            let sampleRate = format.sampleRate

            let accentSamples = try Audio.SampleLoader.load(sound: sound, accent: true, sampleRate: sampleRate)
            let normalSamples = try Audio.SampleLoader.load(sound: sound, accent: false, sampleRate: sampleRate)

            let samplesPerBeat = Int(sampleRate * 60.0 / 120.0)
            var buffer = [Float](repeating: 0, count: samplesPerBeat * 4)
            for (beat, click) in [accentSamples, normalSamples, normalSamples, normalSamples].enumerated() {
                let offset = beat * samplesPerBeat
                for i in 0..<min(click.count, samplesPerBeat) {
                    buffer[offset + i] = click[i]
                }
            }

            playbackState.samples = buffer
            playbackState.position = 0
            playbackState.loop = false
            playbackState.isRunning = true

            try startEngine(engine, format: format)

            autoStopTask = Task { [weak self] in
                try? await Task.sleep(for: .seconds(2.2))
                await self?.stop()
            }
        }

        // MARK: - Stop

        func stop() {
            guard playbackState.isRunning || audioEngine != nil else { return }
            autoStopTask?.cancel()
            autoStopTask = nil
            playbackState.isRunning = false
            audioEngine?.stop()
            if let node = sourceNode {
                audioEngine?.detach(node)
            }
            audioEngine = nil
            sourceNode = nil
            toneContinuation?.yield(.stopped)
            toneContinuation?.finish()
            toneContinuation = nil
        }

        // MARK: - Private

        private func startEngine(_ engine: AVAudioEngine, format: AVAudioFormat) throws {
            let state = playbackState
            let node = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
                let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for frame in 0..<Int(frameCount) {
                    var sample: Float = 0
                    if state.isRunning && !state.samples.isEmpty {
                        if state.loop {
                            sample = state.samples[state.position % state.samples.count]
                            state.position += 1
                        } else if state.position < state.samples.count {
                            sample = state.samples[state.position]
                            state.position += 1
                        } else {
                            state.isRunning = false
                        }
                    }
                    for buffer in ablPointer {
                        UnsafeMutableBufferPointer<Float>(buffer)[frame] = sample
                    }
                }
                return noErr
            }
            engine.attach(node)
            engine.connect(node, to: engine.mainMixerNode, format: format)
            try engine.start()
            audioEngine = engine
            sourceNode = node
        }
    }
}
