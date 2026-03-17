//
//  EditorViewModelTests.swift
//  Schreiben20Tests
//
//  Unit-Tests für das EditorViewModel
//

import XCTest
import Combine
import PencilKit
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
        XCTAssertEqual(viewModel.fontSize, 24) // Default
        XCTAssertTrue(viewModel.showLineGuides) // Default
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

    // MARK: - Text Content Tests

    func testTextContentBindingLoadsDocumentText() {
        // Arrange
        var doc = mockService.document(withID: testDocumentID)!
        doc.textContent = "Hallo Welt"
        mockService.updateDocument(doc)

        let expectation = expectation(description: "Text should load")

        // Act
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.textContent, "Hallo Welt")
    }

    func testTextContentChangeMarksUnsaved() {
        // Arrange
        let expectation = expectation(description: "Should mark unsaved")
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            // Act
            self.viewModel.textContent = "Neuer Text"
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModel.hasUnsavedChanges)
    }

    // MARK: - Save Tests

    func testSaveDocumentUpdatesContent() {
        // Arrange
        let expectation = expectation(description: "Document should save")
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.viewModel.textContent = "Gespeicherter Text"

            // Act
            self.viewModel.saveDocument()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        let savedDoc = mockService.document(withID: testDocumentID)
        XCTAssertEqual(savedDoc?.textContent, "Gespeicherter Text")
        XCTAssertFalse(viewModel.hasUnsavedChanges)
    }

    func testSaveOnDisappearSavesIfNeeded() {
        // Arrange
        let expectation = expectation(description: "Should save on disappear")
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.viewModel.textContent = "Wird beim Verlassen gespeichert"

            // Act
            self.viewModel.saveOnDisappear()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        let savedDoc = mockService.document(withID: testDocumentID)
        XCTAssertEqual(savedDoc?.textContent, "Wird beim Verlassen gespeichert")
    }

    // MARK: - Font Size Tests

    func testIncreaseFontSize() {
        // Arrange
        viewModel.fontSize = 24

        // Act
        viewModel.increaseFontSize()

        // Assert
        XCTAssertEqual(viewModel.fontSize, 26)
    }

    func testDecreaseFontSize() {
        // Arrange
        viewModel.fontSize = 24

        // Act
        viewModel.decreaseFontSize()

        // Assert
        XCTAssertEqual(viewModel.fontSize, 22)
    }

    func testFontSizeMaxLimit() {
        // Arrange
        viewModel.fontSize = 48

        // Act
        viewModel.increaseFontSize()

        // Assert
        XCTAssertEqual(viewModel.fontSize, 48) // Bleibt bei 48
    }

    func testFontSizeMinLimit() {
        // Arrange
        viewModel.fontSize = 16

        // Act
        viewModel.decreaseFontSize()

        // Assert
        XCTAssertEqual(viewModel.fontSize, 16) // Bleibt bei 16
    }

    // MARK: - Undo/Redo Tests

    func testUndoRestoresPreviousText() {
        // Arrange
        let expectation = expectation(description: "Undo should work")
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.viewModel.textContent = "Erster Text"
            self.viewModel.textContent = "Zweiter Text"

            // Act
            self.viewModel.undo()
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.textContent, "Erster Text")
        XCTAssertTrue(viewModel.canRedo)
    }

    func testRedoRestoresUndoneText() {
        // Arrange
        let expectation = expectation(description: "Redo should work")
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.viewModel.textContent = "Erster Text"
            self.viewModel.textContent = "Zweiter Text"
            self.viewModel.undo()

            // Act
            self.viewModel.redo()
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.textContent, "Zweiter Text")
    }

    func testCanUndoIsFalseInitially() {
        // Assert
        XCTAssertFalse(viewModel.canUndo)
    }

    func testCanRedoIsFalseInitially() {
        // Assert
        XCTAssertFalse(viewModel.canRedo)
    }

    // MARK: - Statistics Tests

    func testWordCountCalculation() {
        // Arrange
        viewModel.textContent = "Eins Zwei Drei Vier Fünf"

        // Assert
        XCTAssertEqual(viewModel.wordCount, 5)
    }

    func testWordCountWithEmptyText() {
        // Arrange
        viewModel.textContent = ""

        // Assert
        XCTAssertEqual(viewModel.wordCount, 0)
    }

    func testCharacterCountCalculation() {
        // Arrange
        viewModel.textContent = "Hallo"

        // Assert
        XCTAssertEqual(viewModel.characterCount, 5)
    }

    // MARK: - Title Update Tests

    func testUpdateTitleChangesDocumentTitle() {
        // Arrange
        let expectation = expectation(description: "Title should update")
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            // Act
            self.viewModel.updateTitle("Neuer Titel")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.document?.title, "Neuer Titel")
    }

    func testUpdateTitleWithEmptyStringShowsError() {
        // Arrange
        let expectation = expectation(description: "Error should show")
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            // Act
            self.viewModel.updateTitle("   ")
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModel.showError)
        XCTAssertNotEqual(viewModel.document?.title, "   ")
    }

    // MARK: - Error Handling Tests

    func testErrorHandlingWithoutService() {
        // Arrange
        let viewModelWithoutService = EditorViewModel(documentID: UUID())

        // Act - versuche ohne Service zu laden
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

    // MARK: - TTS Integration Tests

    func testSetTTSService() {
        // Arrange
        let ttsService = TTSService()

        // Act
        viewModel.setTTSService(ttsService)

        // Assert
        XCTAssertNotNil(viewModel.ttsService)
    }

    func testIsSpeakingDefaultFalse() {
        // Assert: Ohne TTSService ist isSpeaking false
        XCTAssertFalse(viewModel.isSpeaking)
    }

    func testIsSpeakingWithTTSService() {
        // Arrange
        let ttsService = TTSService()
        viewModel.setTTSService(ttsService)

        // Assert: Nicht sprechend nach Init
        XCTAssertFalse(viewModel.isSpeaking)
    }

    func testStopSpeakingWithoutService() {
        // Act: Sollte nicht abstürzen
        viewModel.stopSpeaking()

        // Assert
        XCTAssertFalse(viewModel.isSpeaking)
    }

    func testSpeakFullTextWithoutService() {
        // Act: Sollte nicht abstürzen
        viewModel.speakFullText()

        // Assert
        XCTAssertFalse(viewModel.isSpeaking)
    }

    func testTTSNotTriggeredDuringUndo() {
        // Arrange
        let ttsService = TTSService()
        ttsService.readingMode = .letter
        viewModel.setTTSService(ttsService)

        let expectation = expectation(description: "Undo should work without TTS crash")
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.viewModel.textContent = "Test"
            self.viewModel.textContent = "Test2"

            // Act: Undo sollte TTS nicht triggern
            self.viewModel.undo()
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.textContent, "Test")
    }

    func testTTSNotTriggeredDuringRedo() {
        // Arrange
        let ttsService = TTSService()
        ttsService.readingMode = .letter
        viewModel.setTTSService(ttsService)

        let expectation = expectation(description: "Redo should work without TTS crash")
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.viewModel.textContent = "Test"
            self.viewModel.textContent = "Test2"
            self.viewModel.undo()

            // Act: Redo sollte TTS nicht triggern
            self.viewModel.redo()
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.textContent, "Test2")
    }

    // MARK: - Media Integration Tests

    func testSetMediaService() {
        // Arrange
        let mediaService = MediaService(
            imageStorageService: ImageStorageService(baseDirectory: FileManager.default.temporaryDirectory.appendingPathComponent("test_\(UUID().uuidString)")),
            documentService: mockService
        )

        viewModel.setDocumentService(mockService)

        // Act
        viewModel.setMediaService(mediaService)

        // Assert
        XCTAssertNotNil(viewModel.mediaService)
    }

    func testMediaItemsInitiallyEmpty() {
        // Arrange
        let expectation = expectation(description: "Document loaded")
        viewModel.setDocumentService(mockService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        // Assert
        XCTAssertTrue(viewModel.mediaItems.isEmpty, "Medien sollten initial leer sein")
    }

    func testShowPhotoPickerDefaultFalse() {
        XCTAssertFalse(viewModel.showPhotoPicker, "Photo Picker sollte initial nicht sichtbar sein")
    }

    func testShowDrawingCanvasDefaultFalse() {
        XCTAssertFalse(viewModel.showDrawingCanvas, "Drawing Canvas sollte initial nicht sichtbar sein")
    }

    func testShowMediaDetailDefaultFalse() {
        XCTAssertFalse(viewModel.showMediaDetail, "Media Detail sollte initial nicht sichtbar sein")
    }

    func testShowDetailSetsSelectedMediaItem() {
        // Arrange
        let item = MediaItem(type: .photo, sortOrder: 0, caption: "Test")

        // Act
        viewModel.showDetail(for: item)

        // Assert
        XCTAssertEqual(viewModel.selectedMediaItem, item)
        XCTAssertTrue(viewModel.showMediaDetail)
    }
}
