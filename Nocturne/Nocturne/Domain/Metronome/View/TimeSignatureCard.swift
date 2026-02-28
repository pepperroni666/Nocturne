import AccessibilityIdentifiers
import SwiftUI

extension Metronome {
    struct TimeSignatureCard: View {
        let timeSignature: TimeSignature
        let onChange: (TimeSignature) -> Void

        var body: some View {
            HStack(spacing: 8) {
                ForEach(TimeSignature.presets, id: \.self) { ts in
                    Button {
                        onChange(ts)
                    } label: {
                        Text(ts.displayString)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(
                                ts == timeSignature
                                    ? NocturneTheme.textPrimary
                                    : NocturneTheme.textSecondary
                            )
                            .frame(minWidth: 40)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        ts == timeSignature
                                            ? NocturneTheme.accentViolet.opacity(0.25)
                                            : Color.clear
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier(AccessibilityIds.Metronome.TimeSignature.button(ts.displayString))
                    .animation(.easeOut(duration: 0.15), value: timeSignature)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(NocturneTheme.surfaceGlass)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(NocturneTheme.surfaceBorder, lineWidth: 1)
                    )
            )
        }
    }
}
