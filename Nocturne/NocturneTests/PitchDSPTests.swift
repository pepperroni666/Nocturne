import Foundation
import Testing
@testable import Nocturne
import PitchDSP

@Suite("PitchDSP C Framework")
struct PitchDSPTests {

    // MARK: - Test Helpers

    /// Generate a mono sine wave buffer at the given frequency.
    static func sineWave(
        frequency: Double,
        sampleRate: Int = 48000,
        duration: Double = 0.5,
        amplitude: Float = 0.5
    ) -> [Float] {
        let count = Int(Double(sampleRate) * duration)
        return (0..<count).map { i in
            amplitude * sinf(Float(2.0 * Double.pi * frequency * Double(i) / Double(sampleRate)))
        }
    }

    /// Generate silence.
    static func silence(count: Int = 8192) -> [Float] {
        [Float](repeating: 0, count: count)
    }

    /// Generate white noise.
    static func noise(count: Int = 8192, amplitude: Float = 0.3) -> [Float] {
        (0..<count).map { _ in Float.random(in: -amplitude...amplitude) }
    }

    /// Feed samples through a detector and return the final result.
    static func detectPitch(
        samples: [Float],
        sampleRate: Float = 48000,
        windowSize: Int32 = 8192
    ) -> PitchResult {
        guard let ctx = pitchDetectorCreate(windowSize, sampleRate) else {
            return PitchResult(hz: -1, cents: 0, midi: -1, confidence: 0, stability: 0)
        }
        defer { pitchDetectorDestroy(ctx) }

        // Feed all samples in one call — the ring buffer + hop handles the rest
        samples.withUnsafeBufferPointer { buf in
            pitchDetectorProcess(ctx, buf.baseAddress!, Int32(buf.count))
        }

        return pitchDetectorGetResult(ctx)
    }

    // MARK: - Context Lifecycle

    @Test("Create and destroy context")
    func contextLifecycle() {
        let ctx = pitchDetectorCreate(8192, 48000)
        #expect(ctx != nil)
        pitchDetectorDestroy(ctx)
    }

    @Test("Create with invalid params returns nil")
    func contextInvalidParams() {
        #expect(pitchDetectorCreate(0, 48000) == nil)
        #expect(pitchDetectorCreate(8192, 0) == nil)
        #expect(pitchDetectorCreate(-1, -1) == nil)
    }

    // MARK: - A4 = 440 Hz Detection

    @Test("Detects A4 = 440 Hz")
    func detectA4() {
        let samples = Self.sineWave(frequency: 440.0)
        let result = Self.detectPitch(samples: samples)

        #expect(result.hz > 0)
        #expect(abs(result.hz - 440.0) < 5.0)
        #expect(result.midi == 69) // A4
    }

    // MARK: - Guitar String Frequencies

    @Test("Detects E2 = 82.41 Hz")
    func detectE2() {
        let samples = Self.sineWave(frequency: 82.41)
        let result = Self.detectPitch(samples: samples)

        #expect(result.hz > 0)
        #expect(abs(result.hz - 82.41) < 3.0)
    }

    @Test("Detects A2 = 110 Hz")
    func detectA2() {
        let samples = Self.sineWave(frequency: 110.0)
        let result = Self.detectPitch(samples: samples)

        #expect(result.hz > 0)
        #expect(abs(result.hz - 110.0) < 3.0)
    }

    @Test("Detects high E4 = 329.63 Hz")
    func detectE4() {
        let samples = Self.sineWave(frequency: 329.63)
        let result = Self.detectPitch(samples: samples)

        #expect(result.hz > 0)
        #expect(abs(result.hz - 329.63) < 5.0)
    }

    // MARK: - Silence & Noise Rejection

    @Test("Returns no pitch for silence")
    func detectSilence() {
        let samples = Self.silence(count: 24000) // 0.5s at 48kHz
        let result = Self.detectPitch(samples: samples)

        #expect(result.hz < 0)
        #expect(result.midi == -1)
    }

    @Test("Returns no pitch or low confidence for noise")
    func detectNoise() {
        let samples = Self.noise(count: 24000)
        let result = Self.detectPitch(samples: samples)

        // Noise should either not detect or have very low confidence
        if result.hz > 0 {
            #expect(result.confidence < 0.5)
        }
    }

    // MARK: - Edge Cases

    @Test("Null context returns negative hz")
    func nullContext() {
        let result = pitchDetectorGetResult(nil)
        #expect(result.hz < 0)
    }

    // MARK: - Stability Field

    @Test("Stability field is populated for valid pitch")
    func stabilityPopulated() {
        let samples = Self.sineWave(frequency: 440.0, duration: 1.0)
        let result = Self.detectPitch(samples: samples)

        #expect(result.hz > 0)
        #expect(result.stability >= 0.0)
        #expect(result.stability <= 1.0)
    }
}
