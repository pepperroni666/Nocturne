import Foundation

extension Settings {
    struct Persistence: Sendable {
        var loadMetronome: @Sendable () -> (bpm: Int, timeSignature: Metronome.TimeSignature, beatSound: Metronome.BeatSound)
        var saveMetronome: @Sendable (Int, Metronome.TimeSignature, Metronome.BeatSound) -> Void
        var loadTuner: @Sendable () -> (instrument: Tuner.Instrument, tuning: Tuner.TuningPreset, a4: Double)
        var saveTuner: @Sendable (Tuner.Instrument, Tuner.TuningPreset, Double) -> Void
    }
}

// MARK: - Live

extension Settings.Persistence {
    static func live(defaults: UserDefaults = .standard) -> Settings.Persistence {
        Settings.Persistence(
            loadMetronome: {
                let bpm = defaults.integer(forKey: Keys.bpm)
                let beats = defaults.integer(forKey: Keys.tsBeats)
                let noteValue = defaults.integer(forKey: Keys.tsNoteValue)
                let beatSound = Metronome.BeatSound(rawValue: defaults.string(forKey: Keys.beatSound) ?? "") ?? .simple
                return (
                    bpm: bpm > 0 ? bpm : 120,
                    timeSignature: beats > 0
                        ? Metronome.TimeSignature(beats: beats, noteValue: noteValue > 0 ? noteValue : 4)
                        : .fourFour,
                    beatSound: beatSound
                )
            },
            saveMetronome: { bpm, timeSignature, beatSound in
                defaults.set(bpm, forKey: Keys.bpm)
                defaults.set(timeSignature.beats, forKey: Keys.tsBeats)
                defaults.set(timeSignature.noteValue, forKey: Keys.tsNoteValue)
                defaults.set(beatSound.rawValue, forKey: Keys.beatSound)
            },
            loadTuner: {
                let instrument = Tuner.Instrument(rawValue: defaults.string(forKey: TunerKeys.instrument) ?? "") ?? .guitar
                let tuningRaw = defaults.string(forKey: TunerKeys.tuning) ?? ""
                let a4 = defaults.double(forKey: TunerKeys.a4)
                let tuning = Tuner.TuningPreset(rawValue: tuningRaw) ?? Tuner.TuningDatabase.defaultTuning(for: instrument)
                return (
                    instrument: instrument,
                    tuning: tuning.instrument == instrument ? tuning : Tuner.TuningDatabase.defaultTuning(for: instrument),
                    a4: a4 > 0 ? a4 : 440.0
                )
            },
            saveTuner: { instrument, tuning, a4 in
                defaults.set(instrument.rawValue, forKey: TunerKeys.instrument)
                defaults.set(tuning.rawValue, forKey: TunerKeys.tuning)
                defaults.set(a4, forKey: TunerKeys.a4)
            }
        )
    }

    private enum Keys {
        static let bpm = "nocturne.bpm"
        static let tsBeats = "nocturne.ts.beats"
        static let tsNoteValue = "nocturne.ts.noteValue"
        static let beatSound = "nocturne.beatSound"
    }

    private enum TunerKeys {
        static let instrument = "nocturne.tuner.instrument"
        static let tuning = "nocturne.tuner.tuning"
        static let a4 = "nocturne.tuner.a4"
    }
}
