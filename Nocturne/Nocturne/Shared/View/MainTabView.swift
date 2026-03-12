import UIKit
import SwiftUI

struct MainTabView: View {
    let store: Store<Metronome.State, Metronome.Action>
    let tunerStore: Store<Tuner.State, Tuner.Action>
    @State private var selectedTab = 0
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView(selection: $selectedTab) {
            Metronome.RootView(store: store)
                .tabItem {
                    Label("Metronome", systemImage: "metronome")
                }
                .tag(0)

            Tuner.RootView(store: tunerStore)
                .tabItem {
                    Label("Tuner", systemImage: "tuningfork")
                }
                .tag(1)

            TheoryPlaceholderView()
                .tabItem {
                    Label("Theory", systemImage: "book.closed")
                }
                .tag(2)

            Settings.RootView(store: store)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(3)
        }
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .tint(NocturneTheme.accentViolet)
        .toolbarBackground(NocturneTheme.backgroundBottom, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .onChange(of: selectedTab) { oldValue, _ in
            if oldValue == 0 {
                store.send(.stopTapped)
            }
            if oldValue == 1 {
                tunerStore.send(.stopAll)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .inactive || newPhase == .background {
                store.send(.appBecameInactive)
            }
        }
    }
}
