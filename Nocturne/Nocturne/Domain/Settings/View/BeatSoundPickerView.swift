import AccessibilityIdentifiers
import SwiftUI

extension Settings {
    struct BeatSoundPicker: View {
        let navigationTitle: String
        let selected: Metronome.BeatSound
        let onSelect: (Metronome.BeatSound) -> Void

        @SwiftUI.State private var previewPlayer: BeatSoundPreviewPlayer?

        var body: some View {
            ZStack {
                BackgroundGradient()

                List {
                    ForEach(Metronome.BeatSound.allCases, id: \.self) { sound in
                        Button {
                            onSelect(sound)
                            playPreview(sound)
                        } label: {
                            HStack {
                                Text(sound.displayName)
                                    .foregroundStyle(NocturneTheme.textPrimary)
                                Spacer()
                                if sound == selected {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(NocturneTheme.accentViolet)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .accessibilityIdentifier(AccessibilityIds.Settings.beatSoundOption(sound.rawValue))
                        .accessibilityAddTraits(sound == selected ? .isSelected : [])
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                previewPlayer?.stop()
            }
        }

        private func playPreview(_ sound: Metronome.BeatSound) {
            previewPlayer?.stop()
            let player = BeatSoundPreviewPlayer()
            previewPlayer = player
            player.play(sound: sound)
        }
    }
}
