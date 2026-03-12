import AccessibilityIdentifiers
import SwiftUI

extension Tuner {
    struct TuningPickerView: View {
        let instrument: Instrument
        let selected: TuningPreset
        let onSelect: (TuningPreset) -> Void

        var body: some View {
            Menu {
                ForEach(TuningDatabase.presets(for: instrument)) { preset in
                    Button {
                        onSelect(preset)
                    } label: {
                        HStack {
                            Text(preset.displayName)
                            if preset == selected {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selected.displayName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(NocturneTheme.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundStyle(NocturneTheme.textSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(NocturneTheme.surfaceGlass)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(NocturneTheme.surfaceBorder, lineWidth: 1)
                )
            }
            .accessibilityIdentifier(AccessibilityIds.Tuner.tuningMenu)
        }
    }
}
