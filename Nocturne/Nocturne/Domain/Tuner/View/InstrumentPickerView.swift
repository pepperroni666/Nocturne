import AccessibilityIdentifiers
import SwiftUI

extension Tuner {
    struct InstrumentPickerView: View {
        let selected: Instrument
        let onSelect: (Instrument) -> Void

        var body: some View {
            HStack(spacing: 12) {
                ForEach(Instrument.allCases) { instrument in
                    Button {
                        onSelect(instrument)
                    } label: {
                        Text(instrument.displayName)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(
                                selected == instrument
                                    ? NocturneTheme.textPrimary
                                    : NocturneTheme.textSecondary
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                selected == instrument
                                    ? NocturneTheme.accentViolet.opacity(0.3)
                                    : NocturneTheme.surfaceGlass
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        selected == instrument
                                            ? NocturneTheme.accentViolet
                                            : NocturneTheme.surfaceBorder,
                                        lineWidth: 1
                                    )
                            )
                    }
                    .accessibilityIdentifier(AccessibilityIds.Tuner.instrumentButton(instrument.rawValue))
                }
            }
        }
    }
}
