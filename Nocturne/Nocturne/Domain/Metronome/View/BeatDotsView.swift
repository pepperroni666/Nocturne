import AccessibilityIdentifiers
import SwiftUI

extension Metronome {
    struct BeatDotsView: View {
        let currentBeat: Int
        let beatsPerMeasure: Int
        let isPlaying: Bool
        let accentPattern: AccentPattern
        let onCyclePattern: () -> Void

        var body: some View {
            HStack(spacing: 10) {
                let groups = accentPattern.groups
                ForEach(Array(groups.enumerated()), id: \.offset) { groupIndex, groupSize in
                    if groupIndex > 0 {
                        separator
                    }
                    ForEach(0..<groupSize, id: \.self) { indexInGroup in
                        let beat = beatOffset(groupIndex: groupIndex, indexInGroup: indexInGroup)
                        let isActive = isPlaying && beat == currentBeat
                        let isAccent = accentPattern.pattern.indices.contains(beat) && accentPattern.pattern[beat]

                        Circle()
                            .fill(dotColor(beat: beat, isActive: isActive, isAccent: isAccent))
                            .frame(width: isAccent ? 14 : 10, height: isAccent ? 14 : 10)
                            .scaleEffect(isActive ? 1.4 : 1.0)
                            .shadow(
                                color: shadowColor(isActive: isActive, isAccent: isAccent),
                                radius: isActive ? 8 : 0
                            )
                            .animation(.easeOut(duration: 0.08), value: currentBeat)
                    }
                }
            }
            .padding(.vertical, 8)
            .accessibilityIdentifier(AccessibilityIds.Metronome.beatDots)
            .contentShape(Rectangle())
            .onTapGesture {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                onCyclePattern()
            }
        }

        private var separator: some View {
            RoundedRectangle(cornerRadius: 0.5)
                .fill(NocturneTheme.beatDotInactive.opacity(0.5))
                .frame(width: 1, height: 14)
        }

        private func beatOffset(groupIndex: Int, indexInGroup: Int) -> Int {
            let groups = accentPattern.groups
            var offset = 0
            for i in 0..<groupIndex {
                offset += groups[i]
            }
            return offset + indexInGroup
        }

        private func dotColor(beat: Int, isActive: Bool, isAccent: Bool) -> Color {
            if isActive {
                return isAccent ? NocturneTheme.beatDotAccent : NocturneTheme.beatDotActive
            }
            return NocturneTheme.beatDotInactive
        }

        private func shadowColor(isActive: Bool, isAccent: Bool) -> Color {
            guard isActive else { return .clear }
            return isAccent ? NocturneTheme.beatDotAccent.opacity(0.6) : NocturneTheme.ringGlow.opacity(0.4)
        }
    }
}
