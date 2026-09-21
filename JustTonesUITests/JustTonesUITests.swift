import XCTest
import Foundation

final class JustTonesUITests: XCTestCase {
    func testLaunchesWithoutPlayback() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["JustTones"].waitForExistence(timeout: 5))
    }

    func testStoppedScreenAllowsBuiltInTimbreSelection() {
        let app = XCUIApplication()
        app.launch()

        let timbrePicker = app.buttons["timbrePicker"]
        XCTAssertTrue(timbrePicker.waitForExistence(timeout: 5))
        timbrePicker.tap()
        XCTAssertTrue(app.buttons["Brass"].waitForExistence(timeout: 2))
        app.buttons["Brass"].tap()

        XCTAssertTrue(app.staticTexts["Brass"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Stopped"].exists)
    }

    func testCustomProfileCanBeCreatedEditedDuplicatedSelectedAndDeleted() {
        let app = XCUIApplication()
        let name = "UI Profile \(UUID().uuidString.prefix(8))"
        let editedName = "\(name) Edited"
        app.launch()

        app.buttons["Profiles"].tap()
        app.buttons["New profile"].tap()
        let nameField = app.textFields["Name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 11))
        nameField.typeText(name)
        app.buttons["Save"].tap()

        let profileButton = app.buttons[name]
        XCTAssertTrue(profileButton.waitForExistence(timeout: 2))
        profileButton.swipeLeft()
        app.buttons["Edit"].tap()
        let editNameField = app.textFields["Name"]
        editNameField.tap()
        editNameField.typeText(" Edited")
        app.buttons["Save"].tap()

        let editedProfile = app.buttons[editedName]
        XCTAssertTrue(editedProfile.waitForExistence(timeout: 2))
        editedProfile.press(forDuration: 1)
        XCTAssertTrue(app.buttons["Duplicate"].waitForExistence(timeout: 2))
        app.buttons["Duplicate"].tap()
        app.buttons["Save"].tap()

        XCTAssertTrue(app.buttons["\(editedName) Copy"].waitForExistence(timeout: 2))
        editedProfile.tap()
        XCTAssertTrue(app.staticTexts[editedName].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Stopped"].exists)

        app.buttons["Profiles"].tap()
        let selectedProfile = app.buttons[editedName]
        selectedProfile.swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertFalse(app.buttons[editedName].exists)
    }
}
