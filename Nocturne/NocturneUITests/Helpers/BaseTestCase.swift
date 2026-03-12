import XCTest

class BaseTestCase: XCTestCase {
    var launchArguments: [String] = []

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = launchArguments
        app.launch()
        UI.app = app
    }

    override func tearDown() {
        UI.app = nil
        super.tearDown()
    }

    func relaunchApp() {
        let app = XCUIApplication()
        app.launchArguments = launchArguments
        app.launch()
        UI.app = app
    }
}
