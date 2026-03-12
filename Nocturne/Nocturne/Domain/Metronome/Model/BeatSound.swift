import Foundation

extension Metronome {
    enum BeatSound: String, CaseIterable, Codable, Sendable {
        case simple
        case simpleBright
        case classic
        case classicBright
        case seiko
        case alarm
        case digital
        case digitalBright
        case digitalSoft
        case digitalSoft2

        var displayName: String {
            switch self {
            case .simple: return "Simple Click"
            case .simpleBright: return "Simple Click (Bright)"
            case .classic: return "Classic Metronome"
            case .classicBright: return "Classic Metronome (Bright)"
            case .seiko: return "Mechanical Tick"
            case .alarm: return "Alarm Beep"
            case .digital: return "Digital Click"
            case .digitalBright: return "Digital Click (Bright)"
            case .digitalSoft: return "Digital Click (Soft)"
            case .digitalSoft2: return "Digital Click (Warm)"
            }
        }

        var accentFileName: String {
            switch self {
            case .simple: return "simple_accent"
            case .simpleBright: return "simple_bright_accent"
            case .classic: return "classic_accent"
            case .classicBright: return "classic_bright_accent"
            case .seiko: return "seiko_accent"
            case .alarm: return "alarm_accent"
            case .digital: return "digital_accent"
            case .digitalBright: return "digital_bright_accent"
            case .digitalSoft: return "digital_soft_accent"
            case .digitalSoft2: return "digital_soft_2_accent"
            }
        }

        var normalFileName: String {
            switch self {
            case .simple: return "simple_normal"
            case .simpleBright: return "simple_bright_normal"
            case .classic: return "classic_normal"
            case .classicBright: return "classic_bright_normal"
            case .seiko: return "seiko_normal"
            case .alarm: return "alarm_normal"
            case .digital: return "digital_normal"
            case .digitalBright: return "digital_bright_normal"
            case .digitalSoft: return "digital_soft_normal"
            case .digitalSoft2: return "digital_soft_2_normal"
            }
        }
    }
}
