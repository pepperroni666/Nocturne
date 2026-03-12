import XCTest

extension UI {
    class Button: Element {
        func tap() {
            raw.tap()
        }

        var label: String {
            raw.label
        }

        @discardableResult
        func isSelected(file: StaticString = #filePath, line: UInt = #line) -> Self {
            XCTAssertTrue(raw.isSelected, "\(identifier) should be selected", file: file, line: line)
            return self
        }

        @discardableResult
        func isNotSelected(file: StaticString = #filePath, line: UInt = #line) -> Self {
            XCTAssertFalse(raw.isSelected, "\(identifier) should not be selected", file: file, line: line)
            return self
        }
    }

    class Label: Element {
        var text: String {
            raw.label
        }

        @discardableResult
        func hasText(_ expected: String, file: StaticString = #filePath, line: UInt = #line) -> Self {
            XCTAssertEqual(text, expected, "\(identifier) text should equal '\(expected)' but was '\(text)'", file: file, line: line)
            return self
        }

        @discardableResult
        func doesNotHaveText(_ unexpected: String, file: StaticString = #filePath, line: UInt = #line) -> Self {
            XCTAssertNotEqual(text, unexpected, "\(identifier) text should not equal '\(unexpected)'", file: file, line: line)
            return self
        }

        @discardableResult
        func containsText(_ substring: String, file: StaticString = #filePath, line: UInt = #line) -> Self {
            XCTAssertTrue(text.contains(substring), "\(identifier) text '\(text)' should contain '\(substring)'", file: file, line: line)
            return self
        }
    }

    class TextField: Element {
        func type(_ text: String) {
            raw.tap()
            raw.typeText(text)
        }

        func clear() {
            raw.tap()
            guard let value = raw.value as? String, !value.isEmpty else { return }
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count)
            raw.typeText(deleteString)
        }

        var value: String {
            raw.value as? String ?? ""
        }

        var placeholderValue: String {
            raw.placeholderValue ?? ""
        }
    }

    class View: Element {
        func tap() {
            raw.tap()
        }

        func swipeUp() {
            raw.swipeUp()
        }

        func swipeDown() {
            raw.swipeDown()
        }
    }

    class Tab: Element {
        func select() {
            raw.tap()
        }

        @discardableResult
        func isSelected(file: StaticString = #filePath, line: UInt = #line) -> Self {
            XCTAssertTrue(raw.isSelected, "\(identifier) should be selected", file: file, line: line)
            return self
        }

        @discardableResult
        func isNotSelected(file: StaticString = #filePath, line: UInt = #line) -> Self {
            XCTAssertFalse(raw.isSelected, "\(identifier) should not be selected", file: file, line: line)
            return self
        }
    }
}
