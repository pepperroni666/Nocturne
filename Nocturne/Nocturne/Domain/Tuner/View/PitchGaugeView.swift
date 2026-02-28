import SwiftUI

extension Tuner {
    struct PitchGaugeView: View {
        let viewData: Tuner.PitchGaugeViewData
        let cents: Double
        let stability: Double
        let isActive: Bool

        private let circleSize: CGFloat = 120
        private let trackWidth: CGFloat = 280

        /// Color based on how close to center
        private func pitchColor(for c: Double) -> Color {
            let absCents = abs(c)
            if absCents <= 5 { return .green }
            if absCents <= 15 { return .yellow }
            if absCents <= 30 { return .orange }
            return .red
        }

        var body: some View {
            let clamped = min(max(cents, -50), 50)
            let pitchOffset = CGFloat(clamped / 50.0) * (trackWidth / 2)
            let color = pitchColor(for: cents)

            ZStack {
                Circle()
                    .stroke(
                        NocturneTheme.surfaceBorder,
                        style: StrokeStyle(lineWidth: 3)
                    )
                    .frame(width: circleSize, height: circleSize)

                if isActive && abs(cents) <= 5 {
                    Circle()
                        .fill(Color.green.opacity(0.08))
                        .frame(width: circleSize, height: circleSize)
                }

                if isActive {
                    Circle()
                        .stroke(color, style: StrokeStyle(lineWidth: 3))
                        .frame(width: circleSize, height: circleSize)
                        .shadow(color: color.opacity(0.5), radius: 10)
                        .offset(x: pitchOffset)
                }

                HStack {
                    Text(viewData.minLabel)
                        .font(.system(size: 10))
                        .foregroundStyle(NocturneTheme.textSecondary.opacity(0.4))
                    Spacer()
                    Text(viewData.centerLabel)
                        .font(.system(size: 10))
                        .foregroundStyle(NocturneTheme.textSecondary.opacity(0.6))
                    Spacer()
                    Text(viewData.maxLabel)
                        .font(.system(size: 10))
                        .foregroundStyle(NocturneTheme.textSecondary.opacity(0.4))
                }
                .frame(width: trackWidth)
                .offset(y: circleSize / 2 + 14)
            }
            .frame(width: trackWidth, height: circleSize + 36)
        }
    }
}
