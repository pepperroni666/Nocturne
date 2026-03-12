import Foundation

extension Settings {
    /// Generic key-value persistence layer. Injected into Metronome and Tuner effects
    /// so they can load and save their own settings keys without domain knowledge here.
    struct Storage: Sendable {
        var load: @Sendable (String) -> String?
        var save: @Sendable (String, String) -> Void
    }
}

extension Settings.Storage {
    static func live(defaults: UserDefaults = .standard) -> Settings.Storage {
        Settings.Storage(
            load: { defaults.string(forKey: $0) },
            save: { defaults.set($1, forKey: $0) }
        )
    }
}
