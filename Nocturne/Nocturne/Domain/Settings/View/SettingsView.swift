import AccessibilityIdentifiers
import SwiftUI

extension Settings {
    struct RootView: View {
        let store: Store<Metronome.State, Metronome.Action>

        private var viewData: Settings.RootViewData { store.state.settingsViewData }

        var body: some View {
            NavigationStack {
                ZStack {
                    BackgroundGradient()

                    List {
                        Section {
                            NavigationLink {
                                Settings.BeatSoundPicker(
                                    navigationTitle: viewData.beatSoundNavigationTitle,
                                    selected: store.state.beatSound,
                                    onSelect: { store.send(.beatSoundChanged($0)) }
                                )
                            } label: {
                                HStack {
                                    Text(viewData.beatSoundLabel)
                                        .foregroundStyle(NocturneTheme.textPrimary)
                                    Spacer()
                                    Text(viewData.beatSoundValue)
                                        .foregroundStyle(NocturneTheme.textSecondary)
                                }
                            }
                        } header: {
                            Text(viewData.metronomeSectionHeader)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                .navigationTitle(viewData.navigationTitle)
                .toolbarColorScheme(.dark, for: .navigationBar)
            }
            .preferredColorScheme(.dark)
        }
    }
}
