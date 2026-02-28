import AccessibilityIdentifiers
import SwiftUI

extension Tuner {
    struct ReferenceToneModeView: View {
        let store: Store<Tuner.State, Tuner.Action>

        var body: some View {
            VStack(spacing: 20) {
                Tuner.InstrumentPickerView(
                    selected: store.state.selectedInstrument,
                    onSelect: { store.send(.instrumentChanged($0)) }
                )

                Tuner.TuningPickerView(
                    instrument: store.state.selectedInstrument,
                    selected: store.state.selectedTuning,
                    onSelect: { store.send(.tuningChanged($0)) }
                )

                Tuner.StringGridView(
                    strings: store.state.currentStrings,
                    playingIndex: store.state.playingStringIndex,
                    onStringTapped: { store.send(.stringTapped($0)) }
                )

                if store.state.playingStringIndex != nil {
                    Button {
                        store.send(.stopTone)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "stop.fill")
                            Text(store.state.referenceToneModeViewData.stopButtonTitle)
                        }
                        .font(.headline)
                        .foregroundStyle(NocturneTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(NocturneTheme.surfaceGlass)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(NocturneTheme.surfaceBorder, lineWidth: 1)
                        )
                    }
                    .accessibilityIdentifier(AccessibilityIds.Tuner.stopToneButton)
                }

                Tuner.A4CalibrationView(
                    viewData: store.state.a4CalibrationViewData,
                    onMinus: { store.send(.a4CalibrationChanged(store.state.a4Calibration - 1)) },
                    onPlus: { store.send(.a4CalibrationChanged(store.state.a4Calibration + 1)) }
                )
            }
        }
    }
}
