import XCTest

final class JustTonesUITests: XCTestCase {
    func testLaunchesWithoutPlayback() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["JustTones"].waitForExistence(timeout: 5))
    }
}
