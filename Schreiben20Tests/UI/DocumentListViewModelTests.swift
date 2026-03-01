//
//  DocumentListViewModelTests.swift
//  Schreiben20Tests
//
//  Unit-Tests für das DocumentListViewModel
//

import XCTest
import Combine
@testable import Schreiben20

final class DocumentListViewModelTests: XCTestCase {

    var viewModel: DocumentListViewModel!
    var mockService: DocumentService!
    var persistenceController: PersistenceController!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        // In-Memory Core Data für Tests
        persistenceController = PersistenceController(inMemory: true)
        mockService = DocumentService(persistenceController: persistenceController)
        viewModel = DocumentListViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockService = nil
        persistenceController = nil
        cancellables = nil
    }

    // MARK: - Initialization Tests

    func testViewModelInitialization() {
        // Assert
        XCTAssertTrue(viewModel.documents.isEmpty)
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
        XCTAssertNil(viewModel.errorMessage)
    }

    // MARK: - Service Injection Tests

    func testSetDocumentService() {
        // Arrange
        let expectation = expectation(description: "Loading should complete")

        // Act
        viewModel.setDocumentService(mockService)

        // Warte auf Loading-State
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testDocumentsBindingAfterServiceInjection() {
        // Arrange
        let expectation = expectation(description: "Documents should be bound")

        // Act
        viewModel.setDocumentService(mockService)
        _ = mockService.createDocument(title: "Test Document")

        // Warte kurz für Binding
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.documents.count, 1)
        XCTAssertEqual(viewModel.documents.first?.title, "Test Document")
    }

    // MARK: - Create Document Tests

    func testCreateNewDocumentWithoutService() {
        // Act
        viewModel.createNewDocument()

        // Assert
        XCTAssertTrue(viewModel.showError)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("nicht initialisiert") ?? false)
    }

    func testCreateNewDocumentWithService() {
        // Arrange
        let expectation = expectation(description: "Document should be created")
        viewModel.setDocumentService(mockService)

        // Act
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.viewModel.createNewDocument()

            // Warte kurz für Persistenz
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.documents.isEmpty)
        XCTAssertTrue(viewModel.documents.first?.title.contains("Neues Dokument") ?? false)
    }

    func testCreateMultipleDocuments() {
        // Arrange
        let expectation = expectation(description: "Multiple documents should be created")
        viewModel.setDocumentService(mockService)

        // Act
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.viewModel.createNewDocument()
            self.viewModel.createNewDocument()
            self.viewModel.createNewDocument()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.documents.count, 3)
    }

    // MARK: - Document Updates Tests

    func testDocumentsUpdateWhenServiceChanges() {
        // Arrange
        let expectation = expectation(description: "Documents should update")
        viewModel.setDocumentService(mockService)

        // Act
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            _ = self.mockService.createDocument(title: "Direct Service Document")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.documents.count, 1)
        XCTAssertEqual(viewModel.documents.first?.title, "Direct Service Document")
    }

    // MARK: - Error Handling Tests

    func testErrorMessageClearsAfterDismissal() {
        // Arrange
        viewModel.createNewDocument() // Triggert Fehler

        // Assert: Fehler wird gesetzt
        XCTAssertTrue(viewModel.showError)
        XCTAssertNotNil(viewModel.errorMessage)

        // Act: Fehler schließen
        viewModel.showError = false

        // Assert: Flag ist false, aber Message bleibt (für erneute Anzeige)
        XCTAssertFalse(viewModel.showError)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}
