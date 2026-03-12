import Foundation

extension Tuner {
    enum Action: Sendable {
        // Mode
        case modeChanged(TunerMode)

        // Microphone
        case startListening
        case stopListening
        case pitchDetected(PitchReading)
        case pitchLost
        case micPermissionUpdated(MicPermissionStatus)
        case micListenFailed

        // Reference Tone
        case instrumentChanged(Instrument)
        case tuningChanged(TuningPreset)
        case stringTapped(Int)
        case stopTone
        case toneStarted
        case toneStopped
        case tonePlaybackFailed

        // Calibration
        case a4CalibrationChanged(Double)

        // Settings
        case loadSettings
        case settingsLoaded(instrument: Instrument, tuning: TuningPreset, a4: Double)
        case persistRequested

        // Lifecycle
        case stopAll
    }
}
