import XCTest

final class SettingsUITests: BaseTestCase {

    override func setUp() {
        super.setUp()
        TabBar.settings.select()
    }

    @MainActor
    func testBeatSoundPickerShowsOptions() {
        SettingsScreen.beatSoundRow.tap()
        SettingsScreen.beatSoundOption("simple").isDisplayed()
    }

    @MainActor
    func testChangeBeatSoundUpdatesSelection() {
        SettingsScreen.beatSoundRow.tap()
        SettingsScreen.beatSoundOption("classic").tap()
        SettingsScreen.beatSoundOption("classic").isSelected()
        SettingsScreen.beatSoundOption("simple").isNotSelected()
    }

    @MainActor
    func testChangedBeatSoundPersistsOnReopen() {
        SettingsScreen.beatSoundRow.tap()
        SettingsScreen.beatSoundOption("digital").tap()
        SettingsScreen.backButton.tap()

        // Reopen the picker and verify selection persisted
        SettingsScreen.beatSoundRow.tap()
        SettingsScreen.beatSoundOption("digital").isSelected()
        SettingsScreen.beatSoundOption("simple").isNotSelected()
    }

    @MainActor
    func testChangedBeatSoundPersistsAfterAppRestart() {
        SettingsScreen.beatSoundRow.tap()
        SettingsScreen.beatSoundOption("classic").tap()
        SettingsScreen.beatSoundOption("classic").isSelected()

        // Restart the app and verify selection persisted
        relaunchApp()
        TabBar.settings.select()
        SettingsScreen.beatSoundRow.tap()
        SettingsScreen.beatSoundOption("classic").isDisplayed()
        SettingsScreen.beatSoundOption("classic").isSelected()
    }
}

final class DefaultSettingsUITets: BaseTestCase {
    override func setUp() {
        launchArguments = ["--reset-state"]
        super.setUp()
    }
    
    @MainActor
    func testDefaultBeatSoundIsSimple() {
        TabBar.settings.select()
        SettingsScreen.beatSoundRow.tap()
        SettingsScreen.beatSoundOption("simple").isDisplayed()
        SettingsScreen.beatSoundOption("simple").isSelected()
    }
}
