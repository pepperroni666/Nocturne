import AVFoundation

final class BeatSoundPreviewPlayer {
    private var engine: AVAudioEngine?
    private var sourceNode: AVAudioSourceNode?
    private var task: Task<Void, Never>?

    func play(sound: Metronome.BeatSound) throws {
        stop()

        let audioEngine = AVAudioEngine()
        let format = audioEngine.outputNode.outputFormat(forBus: 0)
        let sampleRate = format.sampleRate

        let accentSamples = try Audio.SampleLoader.load(sound: sound, accent: true, sampleRate: sampleRate)
        let normalSamples = try Audio.SampleLoader.load(sound: sound, accent: false, sampleRate: sampleRate)

        // Build 4 beats at 120 BPM: accent, normal, normal, normal
        let samplesPerBeat = Int(sampleRate * 60.0 / 120.0)
        let totalSamples = samplesPerBeat * 4
        var buffer = [Float](repeating: 0, count: totalSamples)

        let beatSamples = [accentSamples, normalSamples, normalSamples, normalSamples]
        for beat in 0..<4 {
            let offset = beat * samplesPerBeat
            let click = beatSamples[beat]
            for i in 0..<min(click.count, samplesPerBeat) {
                buffer[offset + i] = click[i]
            }
        }

        let state = SamplePlaybackState()
        state.samples = buffer
        state.position = 0
        state.isRunning = true

        let node = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let frames = Int(frameCount)
            for frame in 0..<frames {
                var sample: Float = 0
                if state.isRunning, state.position < state.samples.count {
                    sample = state.samples[state.position]
                    state.position += 1
                } else {
                    state.isRunning = false
                }
                for buf in ablPointer {
                    let ptr = UnsafeMutableBufferPointer<Float>(buf)
                    ptr[frame] = sample
                }
            }
            return noErr
        }

        audioEngine.attach(node)
        audioEngine.connect(node, to: audioEngine.mainMixerNode, format: format)
        try audioEngine.start()

        self.engine = audioEngine
        self.sourceNode = node

        // Auto-stop after playback finishes (~2 seconds at 120 BPM)
        task = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2.2))
            await MainActor.run { self?.stop() }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        engine?.stop()
        if let node = sourceNode {
            engine?.detach(node)
        }
        engine = nil
        sourceNode = nil
    }
}
