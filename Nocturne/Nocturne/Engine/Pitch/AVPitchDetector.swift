import AVFoundation
import Foundation
import PitchDSP

/// Microphone pitch detector using AVAudioEngine + PitchDSP C framework.
///
/// - Audio capture: AVAudioEngine input tap delivers mono float buffers
/// - Pitch analysis: PitchDSP C framework (YIN + stability pipeline)
/// - Output: AsyncStream<PitchReading> with hz, midi, cents, confidence
///
/// The C context is created once on `start()` and destroyed on `stop()`.
/// Buffer data is passed directly from the tap — no intermediate copies.
extension Audio {
    actor AVPitchDetector: PitchDetector {
        private var audioEngine: AVAudioEngine?
        private var continuation: AsyncStream<Tuner.PitchReading>.Continuation?

        /// Wraps the C context pointer for safe cross-thread use.
        /// AVAudioEngine guarantees only one tap callback at a time,
        /// so concurrent access is not an issue.
        private final class DSPContext: @unchecked Sendable {
            let ptr: OpaquePointer

            init?(windowSize: Int, sampleRate: Float) {
                guard let p = pitchDetectorCreate(Int32(windowSize), sampleRate) else {
                    return nil
                }
                self.ptr = p
            }

            deinit {
                pitchDetectorDestroy(ptr)
            }

            func process(_ samples: UnsafePointer<Float>, count: Int) {
                pitchDetectorProcess(ptr, samples, Int32(count))
            }

            func getResult() -> PitchResult {
                pitchDetectorGetResult(ptr)
            }
        }

        private var dspContext: DSPContext?

        // MARK: - Permission

        func requestPermission() async -> Tuner.MicPermissionStatus {
            if #available(iOS 17.0, *) {
                let granted = await AVAudioApplication.requestRecordPermission()
                return granted ? .authorized : .denied
            } else {
                return await withCheckedContinuation { continuation in
                    AVAudioSession.sharedInstance().requestRecordPermission { granted in
                        continuation.resume(returning: granted ? .authorized : .denied)
                    }
                }
            }
        }

        // MARK: - Start / Stop

        func start() async throws -> AsyncStream<Tuner.PitchReading> {
            await stop()

            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: [])
            try session.setActive(true)

            let engine = AVAudioEngine()
            let inputNode = engine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            let sampleRate = Float(format.sampleRate)

            // 8192 gives better low-frequency resolution for acoustic guitar.
            // At 48 kHz: halfSize = 4096, covers down to ~12 Hz (well below A0).
            // Hop = 2048 → ~23 Hz analysis rate, acceptable latency for a tuner.
            let frameSize = 8192

            guard let context = DSPContext(windowSize: frameSize, sampleRate: sampleRate) else {
                throw Tuner.PitchDetectorError.contextCreationFailed
            }
            self.dspContext = context

            let (stream, streamContinuation) = AsyncStream.makeStream(of: Tuner.PitchReading.self)
            self.continuation = streamContinuation

            let cont = self.continuation

            inputNode.installTap(
                onBus: 0,
                bufferSize: AVAudioFrameCount(frameSize),
                format: format
            ) { buffer, _ in
                guard let channelData = buffer.floatChannelData?[0] else { return }
                let count = Int(buffer.frameLength)

                context.process(channelData, count: count)
                let result = context.getResult()

                let reading = Tuner.PitchReading(
                    hz: Double(result.hz),
                    midi: Int(result.midi),
                    cents: Double(result.cents),
                    confidence: Double(result.confidence),
                    stability: Double(result.stability)
                )

                cont?.yield(reading)
            }

            try engine.start()
            self.audioEngine = engine

            return stream
        }

        func stop() {
            audioEngine?.inputNode.removeTap(onBus: 0)
            audioEngine?.stop()
            audioEngine = nil
            continuation?.finish()
            continuation = nil
            dspContext = nil
        }
    }
}

extension Tuner {
    enum PitchDetectorError: Error {
        case contextCreationFailed
    }
}
