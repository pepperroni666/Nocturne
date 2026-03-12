import XCTest

final class MetronomeUITests: BaseTestCase {

    // MARK: - Element Existence

    @MainActor
    func testMetronomeScreenElementsExistOnLaunch() {
        MetronomeScreen.playButton.isDisplayed()
        MetronomeScreen.bpmDisplay.isDisplayed()
        MetronomeScreen.bpmMinus.isDisplayed()
        MetronomeScreen.bpmPlus.isDisplayed()
        MetronomeScreen.tapTempo.isDisplayed()
        MetronomeScreen.dial.isDisplayed()
        MetronomeScreen.beatDots.isDisplayed()
    }

    // MARK: - BPM Controls

    @MainActor
    func testBPMIncrements() {
        let initialBPM = MetronomeScreen.bpmDisplay.text
        MetronomeScreen.bpmPlus.tap()

        MetronomeScreen.bpmDisplay.doesNotHaveText(initialBPM)
    }

    @MainActor
    func testBPMDecrements() {
        let initialBPM = MetronomeScreen.bpmDisplay.text
        MetronomeScreen.bpmMinus.tap()

        MetronomeScreen.bpmDisplay.doesNotHaveText(initialBPM)
    }

    // MARK: - BPM Entry Sheet

    @MainActor
    func testBPMEntrySheetOpensAndAcceptsValidInput() {
        MetronomeScreen.bpmDisplay.raw.tap()

        BPMEntryScreen.textField.isDisplayed()
        BPMEntryScreen.doneButton.isDisplayed()

        BPMEntryScreen.textField.type("100")
        BPMEntryScreen.doneButton.tap()

        BPMEntryScreen.textField.isNotDisplayed()
        MetronomeScreen.bpmDisplay.containsText("100")
    }

    @MainActor
    func testBPMEntrySheetShowsErrorForInvalidInput() {
        MetronomeScreen.bpmDisplay.raw.tap()

        BPMEntryScreen.textField.type("999")
        BPMEntryScreen.doneButton.tap()

        BPMEntryScreen.errorLabel.isDisplayed()
    }

    // MARK: - Time Signature

    @MainActor
    func testTimeSignatureChanges() {
        let button = MetronomeScreen.timeSignatureButton("3/4")
        button.isDisplayed()

        button.tap()
        button.isDisplayed()
    }

    // MARK: - Play/Stop

    @MainActor
    func testPlayButtonToggles() {
        MetronomeScreen.playButton.isDisplayed()

        MetronomeScreen.playButton.tap()
        MetronomeScreen.stopButton.isDisplayed()

        MetronomeScreen.stopButton.tap()
        MetronomeScreen.playButton.isDisplayed()
    }
}
