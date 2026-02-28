import QuartzCore
import Observation

/// Interpolates raw DSP pitch readings at 60fps for smooth UI display.
///
/// DSP outputs at ~20–40fps. This engine runs a CADisplayLink at 60fps,
/// smoothly interpolating cents and applying note hysteresis so the UI
/// feels like a hardware tuner — no jitter, no random note jumps.
///
/// Usage:
///   1. Call `start()` when listening begins
///   2. Call `updateTarget(...)` each time DSP delivers a new PitchReading
///   3. Read `displayCents`, `displayNote`, `displayFrequency` in your views
///   4. Call `stop()` when listening ends
@MainActor
@Observable
final class PitchDisplayEngine {

    // MARK: - Display values (UI reads these)

    /// Smoothly interpolated cents offset (–50…+50)
    private(set) var displayCents: Double = 0

    /// Hysteresis-filtered MIDI note number (–1 = none)
    private(set) var displayNote: Int = -1

    /// Latest detected frequency from DSP (not interpolated — informational)
    private(set) var displayFrequency: Double = 0

    /// True when a note is actively tracked
    var isActive: Bool { displayNote >= 0 }

    // MARK: - Internal interpolation state

    private var displayMidi: Double = 0

    private var targetMidi: Double = 0
    private var targetCents: Double = 0
    private var confidence: Double = 0

    private var noteChangeFrames: Int = 0

    private var linkProxy: DisplayLinkProxy?

    // MARK: - Lifecycle

    func start() {
        guard linkProxy == nil else { return }
        let proxy = DisplayLinkProxy { [weak self] in
            MainActor.assumeIsolated { self?.interpolate() }
        }
        let link = CADisplayLink(target: proxy, selector: #selector(DisplayLinkProxy.tick))
        link.add(to: .main, forMode: .common)
        proxy.link = link
        linkProxy = proxy
    }

    func stop() {
        linkProxy?.link?.invalidate()
        linkProxy = nil
        displayNote = -1
        displayMidi = 0
        displayCents = 0
        displayFrequency = 0
        noteChangeFrames = 0
    }

    // MARK: - DSP input

    /// Called when a new pitch reading arrives from DSP (~20–40fps).
    /// Updates internal targets; the display link interpolates toward them.
    func updateTarget(midi: Int, cents: Double, hz: Double, confidence: Double) {
        targetMidi = Double(midi)
        targetCents = cents
        self.confidence = confidence
        displayFrequency = hz

        // First detection — snap immediately, no interpolation delay
        if displayNote < 0 {
            displayNote = midi
            displayMidi = Double(midi)
            displayCents = cents
        }
    }

    // MARK: - 60fps interpolation (CADisplayLink callback)

    private func interpolate() {
        guard displayNote >= 0 else { return }

        // Interpolate MIDI (variable speed based on confidence)
        let midiDelta = targetMidi - displayMidi
        let speed = 0.1 + confidence * 0.4
        displayMidi += midiDelta * speed

        // Interpolate cents (fixed speed for smooth needle motion)
        let centsDelta = targetCents - displayCents
        displayCents += centsDelta * 0.25

        // Note hysteresis — require 5 consecutive frames of different note
        let roundedTarget = Int(round(targetMidi))
        if roundedTarget != displayNote {
            noteChangeFrames += 1
        } else {
            noteChangeFrames = 0
        }

        if noteChangeFrames > 5 {
            displayNote = roundedTarget
            displayCents = targetCents   // reset cents on note change
            displayMidi = targetMidi
            noteChangeFrames = 0
        }
    }
}

// MARK: - CADisplayLink proxy (NSObject target for selector-based API)

private class DisplayLinkProxy: NSObject {
    let callback: () -> Void
    var link: CADisplayLink?

    init(callback: @escaping () -> Void) {
        self.callback = callback
    }

    @objc func tick() {
        callback()
    }

    deinit {
        link?.invalidate()
    }
}
