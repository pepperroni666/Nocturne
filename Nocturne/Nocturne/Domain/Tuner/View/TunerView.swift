import AccessibilityIdentifiers
import SwiftUI

extension Tuner {
    struct RootView: View {
        let store: Store<Tuner.State, Tuner.Action>

        var body: some View {
            ZStack {
                BackgroundGradient()

                VStack(spacing: 0) {
                    Spacer().frame(height: 20)

                    Tuner.ModePickerView(
                        mode: store.state.mode,
                        onModeChanged: { store.send(.modeChanged($0)) }
                    )

                    Spacer().frame(height: 24)

                    switch store.state.mode {
                    case .microphone:
                        Tuner.MicrophoneModeView(store: store)
                    case .referenceTone:
                        Tuner.ReferenceToneModeView(store: store)
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .preferredColorScheme(.dark)
        }
    }
}
