import SwiftUI

extension Metronome {
    struct StepperButton: View {
        let systemImage: String
        let action: () -> Void

        private let size = NocturneTheme.stepperButtonSize

        var body: some View {
            Button(action: action) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(NocturneTheme.textPrimary)
                    .frame(width: size, height: size)
                    .background(NocturneTheme.surfaceGlass)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(NocturneTheme.surfaceBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }
}
