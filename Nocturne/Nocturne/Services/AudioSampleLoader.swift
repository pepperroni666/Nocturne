import AVFoundation

extension Audio {
    enum SampleLoader {
        static func load(sound: Metronome.BeatSound, accent: Bool, sampleRate: Double) -> [Float] {
            let name = accent ? sound.accentFileName : sound.normalFileName
            if let samples = loadWAV(named: name, targetSampleRate: sampleRate) {
                return samples
            }
            return generateClick(
                frequency: accent ? 1200 : 880,
                amplitude: accent ? 0.8 : 0.5,
                durationMs: 5,
                sampleRate: Float(sampleRate)
            )
        }

        static func loadWAV(named name: String, targetSampleRate: Double) -> [Float]? {
            guard let url = Bundle.main.url(forResource: name, withExtension: "wav"),
                  let file = try? AVAudioFile(forReading: url) else { return nil }

            let format = file.processingFormat
            let frameCount = AVAudioFrameCount(file.length)
            guard frameCount > 0,
                  let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount),
                  (try? file.read(into: buffer)) != nil,
                  let channelData = buffer.floatChannelData else { return nil }

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

            let sourceSampleRate = format.sampleRate
            guard abs(sourceSampleRate - targetSampleRate) >= 1.0 else { return mono }

            let ratio = targetSampleRate / sourceSampleRate
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

        static func generateClick(
            frequency: Float,
            amplitude: Float,
            durationMs: Float,
            sampleRate: Float
        ) -> [Float] {
            let sampleCount = Int(sampleRate * durationMs / 1000.0)
            return (0..<sampleCount).map { i in
                let t = Float(i) / sampleRate
                let envelope = exp(-t * 800)
                return amplitude * sin(2.0 * .pi * frequency * t) * envelope
            }
        }
    }
}
