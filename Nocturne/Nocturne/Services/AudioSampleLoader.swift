import AVFoundation

enum AudioSampleError: Error, CustomStringConvertible {
    case fileNotFound(String)
    case readFailed(String)

    var description: String {
        switch self {
        case let .fileNotFound(name): return "WAV file not found in bundle: \(name).wav"
        case let .readFailed(name): return "Failed to read WAV file: \(name).wav"
        }
    }
}

extension Audio {
    enum SampleLoader {
        static func load(sound: Metronome.BeatSound, accent: Bool, sampleRate: Double) throws -> [Float] {
            let name = accent ? sound.accentFileName : sound.normalFileName
            return try loadWAV(named: name, targetSampleRate: sampleRate)
        }

        static func loadWAV(named name: String, targetSampleRate: Double) throws -> [Float] {
            guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
                throw AudioSampleError.fileNotFound(name)
            }

            let file: AVAudioFile
            do {
                file = try AVAudioFile(forReading: url)
            } catch {
                throw AudioSampleError.readFailed(name)
            }

            let format = file.processingFormat
            let frameCount = AVAudioFrameCount(file.length)
            guard frameCount > 0,
                  let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount),
                  (try? file.read(into: buffer)) != nil,
                  let channelData = buffer.floatChannelData else {
                throw AudioSampleError.readFailed(name)
            }

            // Mix to mono
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

            // Resample via linear interpolation if sample rates differ
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
    }
}
