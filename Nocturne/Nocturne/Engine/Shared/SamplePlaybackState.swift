/// Mutable playback state shared between an actor/class and the real-time render callback.
///
/// @unchecked Sendable is intentional: the actor writes only when isRunning = false
/// (setup and teardown), the render callback reads only when isRunning = true.
/// These windows do not overlap, so no synchronisation is needed.
/// See discussion in feature/audio-refactor for alternative approaches (Atomic<T>).
final class SamplePlaybackState: @unchecked Sendable {
    var samples: [Float] = []
    var position: Int = 0
    var isRunning: Bool = false
    var loop: Bool = false
}
