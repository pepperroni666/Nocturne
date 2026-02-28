import AccessibilityIdentifiers
import SwiftUI

extension Tuner {
    struct A4CalibrationView: View {
        let viewData: Tuner.A4CalibrationViewData
        let onMinus: () -> Void
        let onPlus: () -> Void

        var body: some View {
            HStack(spacing: 16) {
                Button(action: onMinus) {
                    Image(systemName: "minus")
                        .font(.headline)
                        .foregroundStyle(NocturneTheme.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(NocturneTheme.surfaceGlass)
                        .clipShape(Circle())
                }
                .accessibilityIdentifier(AccessibilityIds.Tuner.a4Minus)

                VStack(spacing: 2) {
                    Text(viewData.label)
                        .font(.caption)
                        .foregroundStyle(NocturneTheme.textSecondary)
                    Text(viewData.valueText)
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(NocturneTheme.textPrimary)
                }
                .accessibilityIdentifier(AccessibilityIds.Tuner.a4Display)

                Button(action: onPlus) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(NocturneTheme.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(NocturneTheme.surfaceGlass)
                        .clipShape(Circle())
                }
                .accessibilityIdentifier(AccessibilityIds.Tuner.a4Plus)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(NocturneTheme.surfaceGlass)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(NocturneTheme.surfaceBorder, lineWidth: 1)
            )
        }
    }
}
