import Foundation

extension Settings {
    struct Effects: Sendable {
        var loadMetronome: @Sendable () -> (bpm: Int, timeSignature: Metronome.TimeSignature, beatSound: Metronome.BeatSound)
        var saveMetronome: @Sendable (Int, Metronome.TimeSignature, Metronome.BeatSound) -> Void
        var loadTuner: @Sendable () -> (instrument: Tuner.Instrument, tuning: Tuner.TuningPreset, a4: Double)
        var saveTuner: @Sendable (Tuner.Instrument, Tuner.TuningPreset, Double) -> Void
    }
}

// MARK: - Live

extension Settings.Effects {
    static func live(persistence: Settings.Persistence = .live()) -> Settings.Effects {
        Settings.Effects(
            loadMetronome: persistence.loadMetronome,
            saveMetronome: persistence.saveMetronome,
            loadTuner: persistence.loadTuner,
            saveTuner: persistence.saveTuner
        )
    }
}
