import AccessibilityIdentifiers
import SwiftUI

extension Tuner {
    struct StringGridView: View {
        let strings: [TuningString]
        let playingIndex: Int?
        let onStringTapped: (Int) -> Void

        private let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
        ]

        var body: some View {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(strings.enumerated()), id: \.offset) { index, string in
                    StringButton(
                        string: string,
                        isPlaying: playingIndex == index,
                        onTap: { onStringTapped(index) }
                    )
                    .accessibilityIdentifier(AccessibilityIds.Tuner.stringButton(index))
                }
            }
        }
    }

    private struct StringButton: View {
        let string: TuningString
        let isPlaying: Bool
        let onTap: () -> Void

        @SwiftUI.State private var glowOpacity: Double = 0.3

        var body: some View {
            Button(action: onTap) {
                VStack(spacing: 4) {
                    Text("\(string.stringNumber)")
                        .font(.caption2)
                        .foregroundStyle(NocturneTheme.textSecondary)
                    Text(string.noteName)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(NocturneTheme.textPrimary)
                    Text(String(format: "%.1f Hz", string.frequency))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(NocturneTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    isPlaying
                        ? NocturneTheme.accentViolet.opacity(0.2)
                        : NocturneTheme.surfaceGlass
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isPlaying
                                ? NocturneTheme.accentViolet
                                : NocturneTheme.surfaceBorder,
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: isPlaying
                        ? NocturneTheme.accentViolet.opacity(glowOpacity)
                        : .clear,
                    radius: 8
                )
            }
            .onChange(of: isPlaying) { _, playing in
                if playing {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        glowOpacity = 0.6
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.2)) {
                        glowOpacity = 0.3
                    }
                }
            }
        }
    }
}
