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

    // MARK: - Phase 2: Delete Tests

    func testPrepareDeleteSetsSelectedDocument() {
        // Arrange
        let expectation = expectation(description: "Document should be selected for deletion")
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            _ = self.mockService.createDocument(title: "Delete Test")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Act
                self.viewModel.prepareDelete(at: IndexSet(integer: 0))
                expectation.fulfill()
            }
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(viewModel.selectedDocument)
        XCTAssertEqual(viewModel.selectedDocument?.title, "Delete Test")
        XCTAssertTrue(viewModel.showDeleteConfirmation)
    }

    func testConfirmDeleteRemovesDocument() {
        // Arrange
        let expectation = expectation(description: "Document should be deleted")
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            _ = self.mockService.createDocument(title: "To Be Deleted")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.viewModel.prepareDelete(at: IndexSet(integer: 0))

                // Act
                self.viewModel.confirmDelete()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    expectation.fulfill()
                }
            }
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModel.documents.isEmpty)
        XCTAssertNil(viewModel.selectedDocument)
    }

    func testCancelDeleteKeepsDocument() {
        // Arrange
        let expectation = expectation(description: "Document should not be deleted")
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            _ = self.mockService.createDocument(title: "Keep Me")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.viewModel.prepareDelete(at: IndexSet(integer: 0))

                // Act
                self.viewModel.cancelDelete()
                expectation.fulfill()
            }
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.documents.count, 1)
        XCTAssertNil(viewModel.selectedDocument)
        XCTAssertFalse(viewModel.showDeleteConfirmation)
    }

    func testDeleteWithoutServiceShowsError() {
        // Arrange
        viewModel.selectedDocument = Document(
            id: UUID(),
            title: "Test",
            createdAt: Date(),
            updatedAt: Date()
        )

        // Act
        viewModel.confirmDelete()

        // Assert
        XCTAssertTrue(viewModel.showError)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    // MARK: - Phase 2: Rename Tests

    func testPrepareRenameSetsSelectedDocumentAndName() {
        // Arrange
        let document = Document(
            id: UUID(),
            title: "Original Name",
            createdAt: Date(),
            updatedAt: Date()
        )

        // Act
        viewModel.prepareRename(document)

        // Assert
        XCTAssertNotNil(viewModel.selectedDocument)
        XCTAssertEqual(viewModel.selectedDocument?.title, "Original Name")
        XCTAssertEqual(viewModel.newDocumentName, "Original Name")
        XCTAssertTrue(viewModel.showRenameDialog)
    }

    func testConfirmRenameUpdatesDocument() {
        // Arrange
        let expectation = expectation(description: "Document should be renamed")
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let doc = self.mockService.createDocument(title: "Old Name")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.viewModel.prepareRename(doc)
                self.viewModel.newDocumentName = "New Name"

                // Act
                self.viewModel.confirmRename()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    expectation.fulfill()
                }
            }
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.documents.first?.title, "New Name")
        XCTAssertNil(viewModel.selectedDocument)
        XCTAssertTrue(viewModel.newDocumentName.isEmpty)
    }

    func testConfirmRenameWithEmptyNameShowsError() {
        // Arrange
        viewModel.setDocumentService(mockService)
        viewModel.selectedDocument = Document(
            id: UUID(),
            title: "Test",
            createdAt: Date(),
            updatedAt: Date()
        )
        viewModel.newDocumentName = "   " // Nur Leerzeichen

        // Act
        viewModel.confirmRename()

        // Assert
        XCTAssertTrue(viewModel.showError)
        XCTAssertTrue(viewModel.errorMessage?.contains("leer") ?? false)
    }

    func testCancelRenameResetsState() {
        // Arrange
        let document = Document(
            id: UUID(),
            title: "Test",
            createdAt: Date(),
            updatedAt: Date()
        )
        viewModel.prepareRename(document)

        // Act
        viewModel.cancelRename()

        // Assert
        XCTAssertNil(viewModel.selectedDocument)
        XCTAssertTrue(viewModel.newDocumentName.isEmpty)
        XCTAssertFalse(viewModel.showRenameDialog)
    }

    func testRenameWithoutServiceShowsError() {
        // Arrange
        viewModel.selectedDocument = Document(
            id: UUID(),
            title: "Test",
            createdAt: Date(),
            updatedAt: Date()
        )
        viewModel.newDocumentName = "New Name"

        // Act
        viewModel.confirmRename()

        // Assert
        XCTAssertTrue(viewModel.showError)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}
