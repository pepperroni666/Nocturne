import AccessibilityIdentifiers
import SwiftUI

extension Tuner {
    struct ModePickerView: View {
        let mode: TunerMode
        let onModeChanged: (TunerMode) -> Void

        var body: some View {
            HStack(spacing: 0) {
                ForEach(TunerMode.allCases, id: \.self) { m in
                    Button {
                        onModeChanged(m)
                    } label: {
                        Text(m.displayName)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(mode == m ? NocturneTheme.textPrimary : NocturneTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                mode == m
                                    ? NocturneTheme.surfaceHighlight
                                    : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .accessibilityIdentifier(AccessibilityIds.Tuner.modeButton(m.rawValue))
                }
            }
            .padding(3)
            .background(NocturneTheme.surfaceGlass)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(NocturneTheme.surfaceBorder, lineWidth: 1)
            )
        }
    }
}
