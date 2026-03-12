import Foundation

extension Settings {
    struct Effects: Sendable {
        var load: @Sendable (String) -> String?
        var save: @Sendable (String, String) -> Void
    }
}

// MARK: - Live

extension Settings.Effects {
    static func live(defaults: UserDefaults = .standard) -> Settings.Effects {
        Settings.Effects(
            load: { defaults.string(forKey: $0) },
            save: { defaults.set($1, forKey: $0) }
        )
    }
}
