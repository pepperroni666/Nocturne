import AccessibilityIdentifiers
import SwiftUI

extension Metronome {
    struct PlayButton: View {
        let isPlaying: Bool
        let action: () -> Void

        @SwiftUI.State private var breathe: Bool = false

        private let size = NocturneTheme.playButtonSize

        var body: some View {
            Button(action: action) {
                ZStack {
                    // Glow background
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    NocturneTheme.ringGlow.opacity(isPlaying ? 0.15 : 0.05),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: size
                            )
                        )
                        .frame(width: size * 2, height: size * 2)
                        .scaleEffect(breathe ? 1.1 : 1.0)

                    // Glass circle
                    Circle()
                        .fill(NocturneTheme.surfaceGlass)
                        .overlay(
                            Circle()
                                .stroke(
                                    isPlaying
                                        ? NocturneTheme.ringGlow.opacity(0.3)
                                        : NocturneTheme.surfaceBorder,
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: NocturneTheme.ringGlow.opacity(isPlaying ? 0.3 : 0),
                            radius: isPlaying ? 16 : 0
                        )
                        .frame(width: size, height: size)

                    // Icon
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(NocturneTheme.textPrimary)
                        .contentTransition(.symbolEffect(.replace))
                        .offset(x: isPlaying ? 0 : 2)
                }
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(isPlaying ? AccessibilityIds.Metronome.stopButton : AccessibilityIds.Metronome.playButton)
            .onChange(of: isPlaying) { _, playing in
                if playing {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        breathe = true
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.3)) {
                        breathe = false
                    }
                }
            }
        }
    }
}
