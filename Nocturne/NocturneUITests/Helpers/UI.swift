import XCTest

enum UI {
    static var app: XCUIApplication!
}

extension UI {
    class Element {
        let identifier: String
        private let customQuery: (() -> XCUIElement)?

        init(id: String) {
            self.identifier = id
            self.customQuery = nil
        }

        init(_ identifier: String, query: @autoclosure @escaping () -> XCUIElement) {
            self.identifier = identifier
            self.customQuery = query
        }

        var raw: XCUIElement {
            customQuery?() ?? UI.app.descendants(matching: .any)[identifier]
        }

        // MARK: - Checks

        @discardableResult
        func isDisplayed(timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) -> Self {
            XCTAssertTrue(raw.waitForExistence(timeout: timeout), "\(identifier) should be displayed", file: file, line: line)
            return self
        }

        @discardableResult
        func isNotDisplayed(timeout: TimeInterval = 2, file: StaticString = #filePath, line: UInt = #line) -> Self {
            if raw.exists {
                let predicate = NSPredicate(format: "exists == false")
                let expectation = XCTNSPredicateExpectation(predicate: predicate, object: raw)
                let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
                XCTAssertEqual(result, .completed, "\(identifier) should not be displayed", file: file, line: line)
            }
            return self
        }

        @discardableResult
        func isEnabled(file: StaticString = #filePath, line: UInt = #line) -> Self {
            XCTAssertTrue(raw.isEnabled, "\(identifier) should be enabled", file: file, line: line)
            return self
        }

        @discardableResult
        func isDisabled(file: StaticString = #filePath, line: UInt = #line) -> Self {
            XCTAssertFalse(raw.isEnabled, "\(identifier) should be disabled", file: file, line: line)
            return self
        }

        @discardableResult
        func isHittable(file: StaticString = #filePath, line: UInt = #line) -> Self {
            XCTAssertTrue(raw.isHittable, "\(identifier) should be hittable", file: file, line: line)
            return self
        }
    }
}
