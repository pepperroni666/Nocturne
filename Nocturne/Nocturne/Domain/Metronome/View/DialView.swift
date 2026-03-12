import AccessibilityIdentifiers
import SwiftUI

extension Metronome {
    struct DialView: View {
        let bpm: Int
        let currentBeat: Int
        let beatsPerMeasure: Int
        let isPlaying: Bool
        let bpmFraction: Double
        let onDragStarted: () -> Void
        let onDrag: (Double) -> Void
        let onDragEnded: () -> Void
        let onBPMTapped: () -> Void

        @SwiftUI.State private var pulseScale: CGFloat = 1.0

        private let size = NocturneTheme.dialSize

        var body: some View {
            ZStack {
                // Tick marks around outer edge
                Metronome.TickMarksView(count: 60, diameter: size)

                // Outer glow ring (BPM fraction indicator, hidden while playing)
                Circle()
                    .trim(from: 0, to: CGFloat(bpmFraction))
                    .stroke(
                        NocturneTheme.ringGlow,
                        style: StrokeStyle(lineWidth: NocturneTheme.ringWidth, lineCap: .round)
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: NocturneTheme.ringGlow.opacity(0.2), radius: 4)

                // Background ring track
                Circle()
                    .stroke(Color.white.opacity(0.05), lineWidth: NocturneTheme.ringWidth)
                    .frame(width: size, height: size)

                // Inner dark glass circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.04),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size / 2 - 20
                        )
                    )
                    .frame(width: size - 40, height: size - 40)
                    .overlay(
                        Circle()
                            .stroke(NocturneTheme.surfaceBorder, lineWidth: 0.5)
                    )

                // BPM display
                VStack(spacing: 2) {
                    Text("\(bpm)")
                        .font(.system(size: 72, weight: .thin, design: .rounded))
                        .foregroundStyle(NocturneTheme.textPrimary)
                        .contentTransition(.numericText())
                        .animation(.snappy(duration: 0.2), value: bpm)

                    Text("BPM")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(NocturneTheme.textSecondary)
                        .tracking(2)
                }
                .scaleEffect(pulseScale)
                .accessibilityElement(children: .ignore)
                .accessibilityIdentifier(AccessibilityIds.Metronome.bpmDisplay)
                .accessibilityLabel("\(bpm) BPM")
                .onTapGesture {
                    onBPMTapped()
                }
            }
            .frame(width: size + 40, height: size + 40)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(AccessibilityIds.Metronome.dial)
            .gesture(dragGesture)
            .onChange(of: currentBeat) { _, _ in
                guard isPlaying else { return }
                withAnimation(.easeOut(duration: 0.06)) {
                    pulseScale = 1.03
                }
                withAnimation(.easeIn(duration: 0.15).delay(0.06)) {
                    pulseScale = 1.0
                }
            }
        }

        private var dragGesture: some Gesture {
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let center = CGPoint(x: (size + 40) / 2, y: (size + 40) / 2)
                    let dx = value.location.x - center.x
                    let dy = value.location.y - center.y
                    var angle = atan2(dy, dx) + .pi / 2
                    if angle < 0 { angle += 2 * .pi }
                    onDragStarted()
                    onDrag(angle)
                }
                .onEnded { _ in
                    onDragEnded()
                }
        }
    }
}
