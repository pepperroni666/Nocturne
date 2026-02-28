import AVFoundation

final class BeatSoundPreviewPlayer {
    private var engine: AVAudioEngine?
    private var sourceNode: AVAudioSourceNode?
    private var task: Task<Void, Never>?

    private final class PlaybackState: @unchecked Sendable {
        var samples: [Float] = []
        var position: Int = 0
        var isRunning: Bool = false
    }

    func play(sound: Metronome.BeatSound) {
        stop()

        let audioEngine = AVAudioEngine()
        let format = audioEngine.outputNode.outputFormat(forBus: 0)
        let sampleRate = format.sampleRate

        let accentSamples = loadSamples(sound: sound, accent: true, sampleRate: sampleRate)
        let normalSamples = loadSamples(sound: sound, accent: false, sampleRate: sampleRate)

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

        let state = PlaybackState()
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
        try? audioEngine.start()

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

    private func loadSamples(sound: Metronome.BeatSound, accent: Bool, sampleRate: Double) -> [Float] {
        let name = accent ? sound.accentFileName : sound.normalFileName
        if let url = Bundle.main.url(forResource: name, withExtension: "wav"),
           let file = try? AVAudioFile(forReading: url) {
            let format = file.processingFormat
            let frameCount = AVAudioFrameCount(file.length)
            if frameCount > 0,
               let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount),
               (try? file.read(into: buffer)) != nil,
               let channelData = buffer.floatChannelData {
                let channels = Int(format.channelCount)
                let frames = Int(buffer.frameLength)
                var mono = [Float](repeating: 0, count: frames)
                if channels == 1 {
                    for i in 0..<frames { mono[i] = channelData[0][i] }
                } else {
                    for i in 0..<frames {
                        var sum: Float = 0
                        for ch in 0..<channels { sum += channelData[ch][i] }
                        mono[i] = sum / Float(channels)
                    }
                }
                // Resample if needed
                let srcRate = format.sampleRate
                if abs(srcRate - sampleRate) < 1.0 { return mono }
                let ratio = sampleRate / srcRate
                let newCount = Int(Double(frames) * ratio)
                var resampled = [Float](repeating: 0, count: newCount)
                for i in 0..<newCount {
                    let srcIndex = Double(i) / ratio
                    let low = Int(srcIndex)
                    let frac = Float(srcIndex - Double(low))
                    let high = min(low + 1, frames - 1)
                    resampled[i] = mono[low] * (1 - frac) + mono[high] * frac
                }
                return resampled
            }
        }
        // Fallback: synthesized
        let freq: Float = accent ? 1200 : 880
        let amp: Float = accent ? 0.8 : 0.5
        let count = Int(Float(sampleRate) * 5.0 / 1000.0)
        return (0..<count).map { i in
            let t = Float(i) / Float(sampleRate)
            let envelope = exp(-t * 800)
            return amp * sin(2.0 * .pi * freq * t) * envelope
        }
    }
}
