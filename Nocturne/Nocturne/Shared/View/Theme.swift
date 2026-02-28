import SwiftUI

enum NocturneTheme {
    // Background
    static let backgroundTop = Color(red: 0.05, green: 0.03, blue: 0.12)
    static let backgroundBottom = Color(red: 0.08, green: 0.04, blue: 0.18)

    // Glow / accent
    static let ringGlow = Color(red: 0.4, green: 0.5, blue: 1.0)
    static let accentViolet = Color(red: 0.5, green: 0.3, blue: 0.9)

    // Surface
    static let surfaceGlass = Color.white.opacity(0.06)
    static let surfaceBorder = Color.white.opacity(0.1)
    static let surfaceHighlight = Color.white.opacity(0.12)

    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.5)

    // Beat dots
    static let beatDotActive = Color.white
    static let beatDotInactive = Color.white.opacity(0.2)
    static let beatDotAccent = Color(red: 0.6, green: 0.4, blue: 1.0)

    // Dimensions
    static let dialSize: CGFloat = 240
    static let ringWidth: CGFloat = 4
    static let tickLength: CGFloat = 8
    static let playButtonSize: CGFloat = 72
    static let stepperButtonSize: CGFloat = 48
}
