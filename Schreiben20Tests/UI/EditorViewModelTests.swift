//
//  EditorViewModelTests.swift
//  Schreiben20Tests
//
//  Unit-Tests für das EditorViewModel
//

import XCTest
import Combine
@testable import Schreiben20

final class EditorViewModelTests: XCTestCase {

    var viewModel: EditorViewModel!
    var mockService: DocumentService!
    var persistenceController: PersistenceController!
    var testDocumentID: UUID!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        // In-Memory Core Data für Tests
        persistenceController = PersistenceController(inMemory: true)
        mockService = DocumentService(persistenceController: persistenceController)

        // Erstelle Test-Dokument
        let testDoc = mockService.createDocument(title: "Test Document")
        testDocumentID = testDoc.id

        viewModel = EditorViewModel(documentID: testDocumentID)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockService = nil
        persistenceController = nil
        testDocumentID = nil
        cancellables = nil
    }

    // MARK: - Initialization Tests

    func testViewModelInitialization() {
        // Assert
        XCTAssertNil(viewModel.document)
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
        XCTAssertNil(viewModel.errorMessage)
    }

    // MARK: - Service Injection Tests

    func testSetDocumentServiceLoadsDocument() {
        // Arrange
        let expectation = expectation(description: "Document should load")

        // Act
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(viewModel.document)
        XCTAssertEqual(viewModel.document?.id, testDocumentID)
        XCTAssertEqual(viewModel.document?.title, "Test Document")
        XCTAssertFalse(viewModel.isLoading)
    }

    func testSetDocumentServiceWithNonExistentID() {
        // Arrange
        let nonExistentID = UUID()
        let viewModelWithBadID = EditorViewModel(documentID: nonExistentID)
        let expectation = expectation(description: "Error should be shown")

        // Act
        viewModelWithBadID.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(viewModelWithBadID.document)
        XCTAssertTrue(viewModelWithBadID.showError)
        XCTAssertNotNil(viewModelWithBadID.errorMessage)
    }

    // MARK: - Document Loading Tests

    func testLoadDocumentWithoutService() {
        // Act
        viewModel.setDocumentService(mockService)

        // Warte kurz
        let expectation = expectation(description: "Loading should complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(viewModel.document)
    }

    // MARK: - Document Updates Tests

    func testDocumentUpdatesWhenServiceChanges() {
        // Arrange
        let expectation = expectation(description: "Document should update")
        viewModel.setDocumentService(mockService)

        // Warte auf initiales Laden
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            // Act: Aktualisiere Dokument über Service
            if var doc = self.viewModel.document {
                doc.title = "Updated Title"
                self.mockService.updateDocument(doc)

                // Warte auf Update
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    expectation.fulfill()
                }
            } else {
                XCTFail("Document should be loaded")
                expectation.fulfill()
            }
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.document?.title, "Updated Title")
    }

    func testDocumentReloadsAfterServiceDocumentChange() {
        // Arrange
        let expectation = expectation(description: "Document should reload")
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            // Act: Ändere Dokument direkt im Service
            let updatedDoc = Document(
                id: self.testDocumentID,
                title: "Changed via Service",
                textContent: "New content"
            )
            self.mockService.updateDocument(updatedDoc)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.document?.title, "Changed via Service")
        XCTAssertEqual(viewModel.document?.textContent, "New content")
    }

    // MARK: - Error Handling Tests

    func testErrorHandlingWithoutService() {
        // Arrange
        let viewModelWithoutService = EditorViewModel(documentID: UUID())

        // Act - versuche ohne Service zu laden (intern aufgerufen)
        // Dies sollte einen Fehler auslösen wenn setDocumentService nie aufgerufen wird

        // Assert
        XCTAssertNil(viewModelWithoutService.document)
        XCTAssertTrue(viewModelWithoutService.isLoading)
    }

    func testErrorMessageForNonExistentDocument() {
        // Arrange
        let nonExistentID = UUID()
        let viewModelBad = EditorViewModel(documentID: nonExistentID)
        let expectation = expectation(description: "Error should be set")

        // Act
        viewModelBad.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModelBad.showError)
        XCTAssertTrue(viewModelBad.errorMessage?.contains("nicht gefunden") ?? false)
    }

    // MARK: - Loading State Tests

    func testLoadingStateDuringInitialLoad() {
        // Assert: Initial loading state
        XCTAssertTrue(viewModel.isLoading)

        let expectation = expectation(description: "Loading should complete")

        // Act
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoading)
    }
}
