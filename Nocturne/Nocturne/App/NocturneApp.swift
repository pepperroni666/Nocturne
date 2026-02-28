import SwiftUI

@main
struct NocturneApp: App {
    @State private var coordinator: AppCoordinator

    init() {
        if CommandLine.arguments.contains("--reset-state") {
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }

        coordinator = AppCoordinator()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(store: coordinator.metronomeStore, tunerStore: coordinator.tunerStore)
                .onAppear { coordinator.start() }
        }
    }
}
