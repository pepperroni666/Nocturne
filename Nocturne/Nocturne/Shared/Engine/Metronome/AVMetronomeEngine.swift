import AVFoundation
import Foundation

extension Audio {
    actor AVMetronomeEngine: MetronomeEngine {
        private var audioEngine: AVAudioEngine?
        private var sourceNode: AVAudioSourceNode?
        private var continuation: AsyncStream<Metronome.Tick>.Continuation?

        private final class AudioState: @unchecked Sendable {
            var sampleRate: Double = 44100.0
            var samplesPerBeat: Double = 22050.0
            var currentSampleIndex: Int64 = 0
            var nextBeatSample: Int64 = 0
            var currentBeat: Int = 0
            var beatsPerMeasure: Int = 4
            var normalClick: [Float] = []
            var accentClick: [Float] = []
            var accentPattern: [Bool] = [true]
            var isRunning: Bool = false
        }

        private let audioState = AudioState()

        func start(bpm: Int, beatsPerMeasure: Int, accentPattern: [Bool], beatSound: Metronome.BeatSound) async throws -> AsyncStream<Metronome.Tick> {
            stop()

            try Audio.Session.activate()

            let engine = AVAudioEngine()
            let format = engine.outputNode.outputFormat(forBus: 0)
            let sampleRate = format.sampleRate

            audioState.sampleRate = sampleRate
            audioState.samplesPerBeat = sampleRate * 60.0 / Double(bpm)
            audioState.currentSampleIndex = 0
            audioState.nextBeatSample = 0
            audioState.currentBeat = 0
            audioState.beatsPerMeasure = beatsPerMeasure

            let clicks = Self.loadClicks(for: beatSound, sampleRate: sampleRate)
            audioState.accentClick = clicks.accent
            audioState.normalClick = clicks.normal

            audioState.accentPattern = accentPattern
            audioState.isRunning = true

            let (stream, streamContinuation) = AsyncStream.makeStream(of: Metronome.Tick.self)
            self.continuation = streamContinuation

            let state = audioState
            let sourceNode = AVAudioSourceNode(format: format) { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
                let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
                guard state.isRunning else {
                    for buffer in ablPointer {
                        let buf = UnsafeMutableBufferPointer<Float>(buffer)
                        for i in 0..<Int(frameCount) { buf[i] = 0 }
                    }
                    return noErr
                }

                let frames = Int(frameCount)
                for frame in 0..<frames {
                    // Advance beat based on timing, not click length
                    if state.currentSampleIndex >= state.nextBeatSample {
                        let isAccent = state.accentPattern.indices.contains(state.currentBeat) ? state.accentPattern[state.currentBeat] : state.currentBeat == 0
                        let tick = Metronome.Tick(beat: state.currentBeat, isAccent: isAccent)
                        self?.yieldTick(tick)

                        state.currentBeat = (state.currentBeat + 1) % state.beatsPerMeasure
                        state.nextBeatSample += Int64(state.samplesPerBeat)
                    }

                    // Determine which beat we're in and how far into it
                    let beatSamples = Int64(state.samplesPerBeat)
                    let prevBeatStart = state.nextBeatSample - beatSamples
                    let offsetInBeat = Int(state.currentSampleIndex - prevBeatStart)

                    // Pick the click for the beat that just started
                    let playingBeat = (state.currentBeat - 1 + state.beatsPerMeasure) % state.beatsPerMeasure
                    let isAccent = state.accentPattern.indices.contains(playingBeat) ? state.accentPattern[playingBeat] : playingBeat == 0
                    let clickSamples = isAccent ? state.accentClick : state.normalClick

                    var sample: Float = 0
                    if offsetInBeat >= 0 && offsetInBeat < clickSamples.count {
                        sample = clickSamples[offsetInBeat]
                    }

                    for buffer in ablPointer {
                        let buf = UnsafeMutableBufferPointer<Float>(buffer)
                        buf[frame] = sample
                    }
                    state.currentSampleIndex += 1
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

        func updateTempo(bpm: Int) {
            audioState.samplesPerBeat = audioState.sampleRate * 60.0 / Double(bpm)
        }

        func updateAccentPattern(_ pattern: [Bool]) {
            audioState.accentPattern = pattern
        }

        func updateBeatSound(_ beatSound: Metronome.BeatSound) {
            let clicks = Self.loadClicks(for: beatSound, sampleRate: audioState.sampleRate)
            audioState.accentClick = clicks.accent
            audioState.normalClick = clicks.normal
        }

        func stop() {
            audioState.isRunning = false
            audioEngine?.stop()
            if let node = sourceNode {
                audioEngine?.detach(node)
            }
            audioEngine = nil
            sourceNode = nil
            continuation?.finish()
            continuation = nil
        }

        // MARK: - Private

        nonisolated private func yieldTick(_ tick: Metronome.Tick) {
            Task { await self.doYieldTick(tick) }
        }

        private func doYieldTick(_ tick: Metronome.Tick) {
            continuation?.yield(tick)
        }

        nonisolated private static func loadClicks(for beatSound: Metronome.BeatSound, sampleRate: Double) -> (accent: [Float], normal: [Float]) {
            if let accent = loadWAV(named: beatSound.accentFileName, targetSampleRate: sampleRate),
               let normal = loadWAV(named: beatSound.normalFileName, targetSampleRate: sampleRate) {
                return (accent, normal)
            }
            // Fallback: synthesized click if WAV loading fails
            return (
                accent: generateClick(frequency: 1200, amplitude: 0.8, durationMs: 5, sampleRate: Float(sampleRate)),
                normal: generateClick(frequency: 880, amplitude: 0.5, durationMs: 5, sampleRate: Float(sampleRate))
            )
        }

        nonisolated private static func loadWAV(named name: String, targetSampleRate: Double) -> [Float]? {
            guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return nil }
            guard let file = try? AVAudioFile(forReading: url) else { return nil }
            let format = file.processingFormat
            let frameCount = AVAudioFrameCount(file.length)
            guard frameCount > 0,
                  let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
            do { try file.read(into: buffer) } catch { return nil }

            // Convert to mono Float array
            guard let channelData = buffer.floatChannelData else { return nil }
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
            let sourceSampleRate = format.sampleRate
            if abs(sourceSampleRate - targetSampleRate) < 1.0 {
                return mono
            }
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

        nonisolated private static func generateClick(
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
