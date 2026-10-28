//
//  DemonicGenreRandomizerUITests.swift
//  DemonicGenreRandomizerUITests
//
//  Created by David Martens on 28.10.26.
//

import XCTest

final class DemonicGenreRandomizerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testGenerateAndCopyFlow() throws {
        let app = XCUIApplication()
        app.launch()

        let copyButton = app.buttons["Kopieren"]
        XCTAssertTrue(copyButton.waitForExistence(timeout: 5))
        XCTAssertFalse(copyButton.isEnabled)
        XCTAssertTrue(app.staticTexts["Wähle die Anzahl und generiere deinen Genre-Mix."].exists)

        app.buttons["Generieren"].tap()
        XCTAssertTrue(copyButton.isEnabled)

        copyButton.tap()
        XCTAssertTrue(app.buttons["Kopiert!"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
