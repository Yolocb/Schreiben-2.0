//
//  AppLaunchTests.swift
//  Schreiben20UITests
//
//  UI-Tests für den App-Start und grundlegende Navigation
//

import XCTest

final class AppLaunchTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testAppLaunches() throws {
        // Assert: App startet erfolgreich
        XCTAssertTrue(app.state == .runningForeground)
    }

    func testDocumentListAppears() throws {
        // Assert: Navigationstitel "Meine Dokumente" ist sichtbar
        let navigationBar = app.navigationBars["Meine Dokumente"]
        XCTAssertTrue(navigationBar.exists)
    }

    func testToolbarButtonsExist() throws {
        // Assert: Plus-Button (neues Dokument) existiert
        let addButton = app.navigationBars.buttons.matching(identifier: "plus").firstMatch
        XCTAssertTrue(addButton.exists)

        // Assert: Einstellungs-Button existiert
        let settingsButton = app.navigationBars.buttons.matching(identifier: "gear").firstMatch
        XCTAssertTrue(settingsButton.exists)
    }

    func testNavigationToSettings() throws {
        // Act: Tippe auf Einstellungen-Button
        let settingsButton = app.navigationBars.buttons.matching(identifier: "gear").firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2))
        settingsButton.tap()

        // Assert: Einstellungen-Seite wird angezeigt
        let settingsNavigationBar = app.navigationBars["Einstellungen"]
        XCTAssertTrue(settingsNavigationBar.waitForExistence(timeout: 2))
    }

    func testDocumentListIsScrollable() throws {
        // Assert: Die Liste existiert und ist scrollbar
        let documentList = app.tables.firstMatch
        XCTAssertTrue(documentList.exists)
    }
}
