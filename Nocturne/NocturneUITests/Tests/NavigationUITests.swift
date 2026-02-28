import XCTest

final class NavigationUITests: BaseTestCase {

    @MainActor
    func testTabBarNavigationToSettings() {
        TabBar.settings.select()
        SettingsScreen.navigationTitle.isDisplayed()
    }

    @MainActor
    func testTabBarNavigationBackToMetronome() {
        TabBar.settings.select()
        TabBar.metronome.select()

        MetronomeScreen.playButton.isDisplayed()
    }

    @MainActor
    func testTabBarNavigationToTuner() {
        TabBar.tuner.select()
        TunerScreen.title.isDisplayed()
    }

    @MainActor
    func testTabBarNavigationToTheory() {
        TabBar.theory.select()
        TheoryScreen.title.isDisplayed()
    }
}
