import AccessibilityIdentifiers
import SwiftUI

extension Metronome {
    struct RootView: View {
        let store: Store<Metronome.State, Metronome.Action>

        var body: some View {
            ZStack {
                BackgroundGradient()

                VStack(spacing: 0) {
                    Spacer()

                    // Dial
                    Metronome.DialView(
                        bpm: store.state.bpm,
                        currentBeat: store.state.currentBeat,
                        beatsPerMeasure: store.state.timeSignature.beats,
                        isPlaying: store.state.isPlaying,
                        bpmFraction: store.state.bpmFraction,
                        onDragStarted: { store.send(.dialDragStarted) },
                        onDrag: { angle in store.send(.dialDragged(angle: angle)) },
                        onDragEnded: { store.send(.dialDragEnded) },
                        onBPMTapped: { store.send(.bpmEntryTapped) }
                    )

                    Spacer().frame(height: 20)

                    // Beat dots
                    Metronome.BeatDotsView(
                        currentBeat: store.state.currentBeat,
                        beatsPerMeasure: store.state.timeSignature.beats,
                        isPlaying: store.state.isPlaying,
                        accentPattern: store.state.accentPattern,
                        onCyclePattern: { store.send(.accentPatternCycled) }
                    )

                    Spacer().frame(height: 22)

                    // Time signature
                    Metronome.TimeSignatureCard(
                        timeSignature: store.state.timeSignature,
                        onChange: { store.send(.timeSignatureChanged($0)) }
                    )

                    Spacer().frame(height: 30)

                    // Controls
                    HStack(spacing: 24) {
                        Metronome.StepperButton(systemImage: "minus") {
                            store.send(.bpmMinus)
                        }
                        .accessibilityIdentifier(AccessibilityIds.Metronome.bpmMinus)

                        Metronome.PlayButton(isPlaying: store.state.isPlaying) {
                            store.send(store.state.isPlaying ? .stopTapped : .playTapped)
                        }

                        Metronome.StepperButton(systemImage: "plus") {
                            store.send(.bpmPlus)
                        }
                        .accessibilityIdentifier(AccessibilityIds.Metronome.bpmPlus)
                    }

                    Spacer().frame(height: 28)

                    // Tap tempo
                    Metronome.TapTempoButton(viewData: store.state.tapTempoViewData) {
                        store.send(.tapTempoPressed(Date()))
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .sheet(isPresented: Binding(
                get: { store.state.showBPMEntry },
                set: { if !$0 { store.send(.bpmEntryDismissed) } }
            )) {
                Metronome.BPMEntrySheet(viewData: store.state.bpmEntryViewData, currentBPM: store.state.bpm) { bpm in
                    store.send(.bpmEntryConfirmed(bpm))
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
