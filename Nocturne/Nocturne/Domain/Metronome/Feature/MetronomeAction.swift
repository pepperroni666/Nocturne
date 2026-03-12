import Foundation

extension Metronome {
    enum Action: Sendable {
        // User
        case playTapped
        case stopTapped
        case bpmPlus
        case bpmMinus
        case bpmSet(Int)
        case dialDragStarted
        case dialDragged(angle: Double)
        case dialDragEnded
        case tapTempoPressed(Date)
        case timeSignatureChanged(TimeSignature)
        case toggleTimeSignaturePicker
        case accentPatternCycled
        case beatSoundChanged(BeatSound)
        case bpmEntryTapped
        case bpmEntryDismissed
        case bpmEntryConfirmed(Int)

        // System
        case engineTick(beat: Int)
        case appBecameInactive
        case persistRequested
        case settingsLoaded(bpm: Int, timeSignature: TimeSignature, beatSound: BeatSound)
        case loadSettings
        case engineStartFailed
    }
}
