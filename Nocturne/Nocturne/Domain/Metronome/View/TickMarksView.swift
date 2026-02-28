import SwiftUI

extension Metronome {
    struct TickMarksView: View {
        let count: Int
        let diameter: CGFloat

        var body: some View {
            ZStack {
                ForEach(0..<count, id: \.self) { index in
                    let isMajor = index % 5 == 0
                    Rectangle()
                        .fill(Color.white.opacity(isMajor ? 0.3 : 0.1))
                        .frame(
                            width: isMajor ? 2 : 1,
                            height: isMajor ? NocturneTheme.tickLength * 1.5 : NocturneTheme.tickLength
                        )
                        .offset(y: -(diameter / 2 + 12))
                        .rotationEffect(.degrees(Double(index) * 360.0 / Double(count)))
                }
            }
            .frame(width: diameter, height: diameter)
        }
    }
}
