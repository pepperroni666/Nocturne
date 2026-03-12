import AccessibilityIdentifiers
import SwiftUI

extension Settings {
    struct RootView: View {
        let store: Store<Settings.State, Settings.Action>

        private var viewData: Settings.RootViewData { store.state.viewData }

        var body: some View {
            NavigationStack {
                ZStack {
                    BackgroundGradient()

                    List {
                        Section {
                            NavigationLink {
                                Settings.BeatSoundPicker(store: store)
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
