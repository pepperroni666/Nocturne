import AccessibilityIdentifiers
import SwiftUI

extension Tuner {
    struct MicrophoneModeView: View {
        let store: Store<Tuner.State, Tuner.Action>

        @SwiftUI.State private var displayEngine = PitchDisplayEngine()
        private var viewData: Tuner.MicrophoneModeViewData { store.state.microphoneModeViewData }
        @SwiftUI.State private var displayedNote: String = "--"
        @SwiftUI.State private var noteID = UUID()

        private var centsColor: Color {
            guard displayEngine.isActive else { return NocturneTheme.textSecondary }
            let absCents = abs(displayEngine.displayCents)
            if absCents <= 5 { return .green }
            if absCents <= 15 { return .yellow }
            if absCents <= 30 { return .orange }
            return .red
        }

        private var leftNote: String {
            guard displayEngine.isActive else { return "" }
            return Tuner.MusicMath.displayName(midi: displayEngine.displayNote - 1)
        }

        private var rightNote: String {
            guard displayEngine.isActive else { return "" }
            return Tuner.MusicMath.displayName(midi: displayEngine.displayNote + 1)
        }

        var body: some View {
            VStack(spacing: 20) {
                // Note name with side notes
                HStack(alignment: .firstTextBaseline) {
                    Text(leftNote)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(NocturneTheme.textSecondary.opacity(0.5))
                        .frame(width: 60, alignment: .trailing)

                    Text(displayedNote)
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(NocturneTheme.textPrimary)
                        .accessibilityIdentifier(AccessibilityIds.Tuner.noteDisplay)
                        .frame(minWidth: 120)
                        .id(noteID)
                        .transition(.scale.combined(with: .opacity))

                    Text(rightNote)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(NocturneTheme.textSecondary.opacity(0.5))
                        .frame(width: 60, alignment: .leading)
                }

                // Frequency
                Text(displayEngine.isActive ? String(format: "%.1f Hz", displayEngine.displayFrequency) : viewData.noFrequencyText)
                    .font(.title3.monospacedDigit())
                    .foregroundStyle(NocturneTheme.textSecondary)
                    .accessibilityIdentifier(AccessibilityIds.Tuner.frequencyDisplay)

                // Gauge — cents are pre-interpolated at 60fps by displayEngine
                Tuner.PitchGaugeView(
                    viewData: store.state.pitchGaugeViewData,
                    cents: displayEngine.displayCents,
                    stability: store.state.pitchStability,
                    isActive: displayEngine.isActive
                )
                .accessibilityIdentifier(AccessibilityIds.Tuner.pitchGauge)

                // Cents offset
                Text(displayEngine.isActive ? String(format: "%+.0f cents", displayEngine.displayCents) : "")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(centsColor)
                    .accessibilityIdentifier(AccessibilityIds.Tuner.centsDisplay)

                Spacer().frame(height: 10)

                // Listen button
                Button {
                    store.send(store.state.isListening ? .stopListening : .startListening)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: viewData.buttonIcon)
                        Text(viewData.buttonTitle)
                    }
                    .font(.headline)
                    .foregroundStyle(NocturneTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        store.state.isListening
                            ? NocturneTheme.accentViolet
                            : NocturneTheme.surfaceGlass
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(NocturneTheme.surfaceBorder, lineWidth: 1)
                    )
                }
                .accessibilityIdentifier(AccessibilityIds.Tuner.listenButton)

                Spacer().frame(height: 10)

                Tuner.A4CalibrationView(
                    viewData: store.state.a4CalibrationViewData,
                    onMinus: { store.send(.a4CalibrationChanged(store.state.a4Calibration - 1)) },
                    onPlus: { store.send(.a4CalibrationChanged(store.state.a4Calibration + 1)) }
                )
            }
            // Start/stop display engine with listening state
            .onChange(of: store.state.isListening) { _, listening in
                if listening {
                    displayEngine.start()
                } else {
                    displayEngine.stop()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        displayedNote = viewData.noNoteText
                        noteID = UUID()
                    }
                }
            }
            // Feed DSP readings into display engine
            .onChange(of: store.state.detectedPitch) { _, pitch in
                guard let p = pitch else { return }
                displayEngine.updateTarget(
                    midi: p.midiNote,
                    cents: p.cents,
                    hz: p.frequency,
                    confidence: p.confidence
                )
            }
            // Animate note name changes from display engine (hysteresis-filtered)
            .onChange(of: displayEngine.displayNote) { _, newNote in
                if newNote >= 0 {
                    withAnimation(.interpolatingSpring(stiffness: 140, damping: 18)) {
                        displayedNote = Tuner.MusicMath.displayName(midi: newNote)
                        noteID = UUID()
                    }
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        displayedNote = viewData.noNoteText
                        noteID = UUID()
                    }
                }
            }
        }
    }
}
