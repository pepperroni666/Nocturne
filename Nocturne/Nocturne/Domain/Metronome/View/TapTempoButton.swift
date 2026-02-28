import AccessibilityIdentifiers
import SwiftUI

extension Metronome {
    struct TapTempoButton: View {
        let viewData: Metronome.TapTempoViewData
        let action: () -> Void

        @SwiftUI.State private var isTapped = false

        var body: some View {
            Button {
                action()
                withAnimation(.easeOut(duration: 0.08)) { isTapped = true }
                withAnimation(.easeIn(duration: 0.2).delay(0.08)) { isTapped = false }
            } label: {
                Text(viewData.buttonTitle)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(isTapped ? NocturneTheme.textPrimary : NocturneTheme.textSecondary)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(NocturneTheme.surfaceGlass)
                            .overlay(
                                Capsule()
                                    .stroke(
                                        isTapped ? NocturneTheme.ringGlow.opacity(0.3) : NocturneTheme.surfaceBorder,
                                        lineWidth: 1
                                    )
                            )
                    )
                    .scaleEffect(isTapped ? 0.95 : 1.0)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityIds.Metronome.tapTempo)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: isTapped)
        }
    }
}
