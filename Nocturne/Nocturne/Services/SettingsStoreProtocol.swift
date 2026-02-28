import Foundation

protocol SettingsStoreProtocol: Sendable {
    func load() -> (bpm: Int, timeSignature: Metronome.TimeSignature, beatSound: Metronome.BeatSound)
    func save(bpm: Int, timeSignature: Metronome.TimeSignature, beatSound: Metronome.BeatSound)
    func loadTuner() -> (instrument: Tuner.Instrument, tuning: Tuner.TuningPreset, a4: Double)
    func saveTuner(instrument: Tuner.Instrument, tuning: Tuner.TuningPreset, a4: Double)
}

final class UserDefaultsSettingsStore: SettingsStoreProtocol, @unchecked Sendable {
    private let defaults: UserDefaults

    private enum Keys {
        static let bpm = "nocturne.bpm"
        static let tsBeats = "nocturne.ts.beats"
        static let tsNoteValue = "nocturne.ts.noteValue"
        static let beatSound = "nocturne.beatSound"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> (bpm: Int, timeSignature: Metronome.TimeSignature, beatSound: Metronome.BeatSound) {
        let bpm = defaults.integer(forKey: Keys.bpm)
        let beats = defaults.integer(forKey: Keys.tsBeats)
        let noteValue = defaults.integer(forKey: Keys.tsNoteValue)
        let soundRaw = defaults.string(forKey: Keys.beatSound) ?? ""
        let beatSound = Metronome.BeatSound(rawValue: soundRaw) ?? .simple
        return (
            bpm: bpm > 0 ? bpm : 120,
            timeSignature: beats > 0
                ? Metronome.TimeSignature(beats: beats, noteValue: noteValue > 0 ? noteValue : 4)
                : .fourFour,
            beatSound: beatSound
        )
    }

    func save(bpm: Int, timeSignature: Metronome.TimeSignature, beatSound: Metronome.BeatSound) {
        defaults.set(bpm, forKey: Keys.bpm)
        defaults.set(timeSignature.beats, forKey: Keys.tsBeats)
        defaults.set(timeSignature.noteValue, forKey: Keys.tsNoteValue)
        defaults.set(beatSound.rawValue, forKey: Keys.beatSound)
    }

    // MARK: - Tuner

    private enum TunerKeys {
        static let instrument = "nocturne.tuner.instrument"
        static let tuning = "nocturne.tuner.tuning"
        static let a4 = "nocturne.tuner.a4"
    }

    func loadTuner() -> (instrument: Tuner.Instrument, tuning: Tuner.TuningPreset, a4: Double) {
        let instrumentRaw = defaults.string(forKey: TunerKeys.instrument) ?? ""
        let tuningRaw = defaults.string(forKey: TunerKeys.tuning) ?? ""
        let a4 = defaults.double(forKey: TunerKeys.a4)

        let instrument = Tuner.Instrument(rawValue: instrumentRaw) ?? .guitar
        let tuning = Tuner.TuningPreset(rawValue: tuningRaw) ?? Tuner.TuningDatabase.defaultTuning(for: instrument)

        return (
            instrument: instrument,
            tuning: tuning.instrument == instrument ? tuning : Tuner.TuningDatabase.defaultTuning(for: instrument),
            a4: a4 > 0 ? a4 : 440.0
        )
    }

    func saveTuner(instrument: Tuner.Instrument, tuning: Tuner.TuningPreset, a4: Double) {
        defaults.set(instrument.rawValue, forKey: TunerKeys.instrument)
        defaults.set(tuning.rawValue, forKey: TunerKeys.tuning)
        defaults.set(a4, forKey: TunerKeys.a4)
    }
}
