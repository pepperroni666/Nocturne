import AccessibilityIdentifiers
import SwiftUI

extension Metronome {
    struct BPMEntrySheet: View {
        let viewData: Metronome.BPMEntryViewData
        let currentBPM: Int
        let onConfirm: (Int) -> Void

        @SwiftUI.State private var text: String = ""
        @SwiftUI.State private var showError: Bool = false
        @SwiftUI.FocusState private var isFocused: Bool
        @SwiftUI.Environment(\.dismiss) private var dismiss

        private var enteredValue: Int? {
            Int(text)
        }

        private var isOutOfRange: Bool {
            guard let value = enteredValue else { return true }
            return !Metronome.State.bpmRange.contains(value)
        }

        var body: some View {
            VStack(spacing: 20) {
                Text(viewData.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(NocturneTheme.textPrimary)

                TextField(viewData.placeholder, text: $text)
                    .accessibilityIdentifier(AccessibilityIds.Metronome.BPMEntry.textField)
                    .keyboardType(.numberPad)
                    .font(.system(size: 34, weight: .light, design: .rounded))
                    .foregroundStyle(NocturneTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(NocturneTheme.surfaceGlass)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(showError ? Color.red.opacity(0.6) : NocturneTheme.surfaceBorder, lineWidth: 1)
                    )
                    .focused($isFocused)
                    .onChange(of: text) { _, _ in
                        showError = false
                    }

                if showError {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 13))
                        Text(viewData.errorMessage)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(.red)
                    .accessibilityIdentifier(AccessibilityIds.Metronome.BPMEntry.errorLabel)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Button {
                    if let value = enteredValue, Metronome.State.bpmRange.contains(value) {
                        onConfirm(value)
                    } else {
                        showError = true
                    }
                } label: {
                    Text(viewData.doneButtonTitle)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(NocturneTheme.accentViolet)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityIdentifier(AccessibilityIds.Metronome.BPMEntry.doneButton)
                .disabled(text.isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(
                LinearGradient(
                    colors: [NocturneTheme.backgroundTop, NocturneTheme.backgroundBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .presentationDetents([.height(240)])
            .presentationDragIndicator(.visible)
            .animation(.easeOut(duration: 0.15), value: showError)
            .onAppear {
                isFocused = true
            }
        }
    }
}
