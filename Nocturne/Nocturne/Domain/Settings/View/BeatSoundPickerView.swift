import AccessibilityIdentifiers
import SwiftUI

extension Settings {
    struct BeatSoundPicker: View {
        let store: Store<Settings.State, Settings.Action>

        var body: some View {
            ZStack {
                BackgroundGradient()

                List {
                    ForEach(Metronome.BeatSound.allCases, id: \.self) { sound in
                        Button {
                            store.send(.soundSelected(sound))
                        } label: {
                            HStack {
                                Text(sound.displayName)
                                    .foregroundStyle(NocturneTheme.textPrimary)
                                Spacer()
                                if sound == store.state.beatSound {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(NocturneTheme.accentViolet)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .accessibilityIdentifier(AccessibilityIds.Settings.beatSoundOption(sound.rawValue))
                        .accessibilityAddTraits(sound == store.state.beatSound ? .isSelected : [])
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Beat Sound")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
