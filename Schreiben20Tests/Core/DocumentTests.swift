//
//  DocumentTests.swift
//  Schreiben20Tests
//
//  Unit-Tests für das Document-Modell und den DocumentService
//

import XCTest
@testable import Schreiben20

final class DocumentTests: XCTestCase {

    // MARK: - Document Model Tests

    func testDocumentInitialization() {
        // Arrange & Act
        let document = Document(title: "Test-Dokument")

        // Assert
        XCTAssertEqual(document.title, "Test-Dokument")
        XCTAssertTrue(document.textContent.isEmpty)
        XCTAssertTrue(document.imageIDs.isEmpty)
        XCTAssertTrue(document.mediaItems.isEmpty)
        XCTAssertTrue(document.tasks.isEmpty)
        XCTAssertNotNil(document.id)
        XCTAssertNotNil(document.createdAt)
        XCTAssertNotNil(document.updatedAt)
    }

    func testDocumentEquality() {
        // Arrange
        let id = UUID()
        let date = Date()
        let doc1 = Document(id: id, title: "Test", createdAt: date, updatedAt: date)
        let doc2 = Document(id: id, title: "Test", createdAt: date, updatedAt: date)

        // Assert
        XCTAssertEqual(doc1, doc2)
    }

    func testDocumentCodable() throws {
        // Arrange
        let originalDocument = Document(
            title: "Codable Test",
            textContent: "Hallo Welt",
            imageIDs: ["img1", "img2"],
            tasks: [Task(word: "Hallo")]
        )

        // Act: Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalDocument)

        // Act: Decode
        let decoder = JSONDecoder()
        let decodedDocument = try decoder.decode(Document.self, from: data)

        // Assert
        XCTAssertEqual(originalDocument.id, decodedDocument.id)
        XCTAssertEqual(originalDocument.title, decodedDocument.title)
        XCTAssertEqual(originalDocument.textContent, decodedDocument.textContent)
        XCTAssertEqual(originalDocument.imageIDs, decodedDocument.imageIDs)
        XCTAssertEqual(originalDocument.tasks.count, decodedDocument.tasks.count)
    }

    // MARK: - Task Model Tests

    func testTaskInitialization() {
        // Arrange & Act
        let task = Task(word: "Apfel")

        // Assert
        XCTAssertEqual(task.word, "Apfel")
        XCTAssertFalse(task.isCompleted)
        XCTAssertNotNil(task.id)
        XCTAssertNotNil(task.createdAt)
    }

    // MARK: - DocumentService Tests

    func testDocumentServiceCreateDocument() {
        // Arrange
        let persistenceController = PersistenceController(inMemory: true)
        let service = DocumentService(persistenceController: persistenceController)
        let initialCount = service.documents.count

        // Act
        let document = service.createDocument(title: "Neues Dokument")

        // Assert
        XCTAssertEqual(service.documents.count, initialCount + 1)
        XCTAssertTrue(service.documents.contains(where: { $0.id == document.id }))
        XCTAssertEqual(document.title, "Neues Dokument")
    }

    func testDocumentServiceUpdateDocument() {
        // Arrange
        let persistenceController = PersistenceController(inMemory: true)
        let service = DocumentService(persistenceController: persistenceController)
        var document = service.createDocument(title: "Original")
        let originalUpdatedAt = document.updatedAt

        // Warte kurz, damit updatedAt sich unterscheidet
        Thread.sleep(forTimeInterval: 0.01)

        // Act
        document.title = "Geändert"
        document.textContent = "Neuer Text"
        service.updateDocument(document)

        // Assert
        let updatedDocument = service.document(withID: document.id)
        XCTAssertNotNil(updatedDocument)
        XCTAssertEqual(updatedDocument?.title, "Geändert")
        XCTAssertEqual(updatedDocument?.textContent, "Neuer Text")
        XCTAssertGreaterThan(updatedDocument?.updatedAt ?? Date.distantPast, originalUpdatedAt)
    }

    func testDocumentServiceDeleteDocument() {
        // Arrange
        let persistenceController = PersistenceController(inMemory: true)
        let service = DocumentService(persistenceController: persistenceController)
        let document = service.createDocument(title: "Zu löschen")
        let countBeforeDelete = service.documents.count

        // Act
        service.deleteDocument(document)

        // Assert
        XCTAssertEqual(service.documents.count, countBeforeDelete - 1)
        XCTAssertNil(service.document(withID: document.id))
    }

    func testDocumentServicePersistence() throws {
        // Arrange: Verwende in-memory store für Tests
        let persistenceController1 = PersistenceController(inMemory: false)
        let service1 = DocumentService(persistenceController: persistenceController1)

        // Lösche alle bestehenden Dokumente für sauberen Test
        for doc in service1.documents {
            service1.deleteDocument(doc)
        }

        let document = service1.createDocument(title: "Persistenz Test")

        // Act: Neuer Service mit demselben Store sollte Daten laden
        let persistenceController2 = PersistenceController(inMemory: false)
        let service2 = DocumentService(persistenceController: persistenceController2)

        // Assert
        XCTAssertTrue(service2.documents.contains(where: { $0.id == document.id }))
        let loadedDocument = service2.document(withID: document.id)
        XCTAssertEqual(loadedDocument?.title, "Persistenz Test")

        // Cleanup
        service2.deleteDocument(document)
    }

    func testDocumentServiceFindById() {
        // Arrange
        let persistenceController = PersistenceController(inMemory: true)
        let service = DocumentService(persistenceController: persistenceController)
        let document = service.createDocument(title: "Findbar")

        // Act
        let foundDocument = service.document(withID: document.id)

        // Assert
        XCTAssertNotNil(foundDocument)
        XCTAssertEqual(foundDocument?.id, document.id)
        XCTAssertEqual(foundDocument?.title, "Findbar")
    }

    func testDocumentServiceFindByIdNotFound() {
        // Arrange
        let persistenceController = PersistenceController(inMemory: true)
        let service = DocumentService(persistenceController: persistenceController)
        let nonExistentID = UUID()

        // Act
        let foundDocument = service.document(withID: nonExistentID)

        // Assert
        XCTAssertNil(foundDocument)
    }

    // MARK: - Document mit MediaItems Tests

    func testDocumentInitWithMediaItems() {
        // Arrange
        let mediaItems = [
            MediaItem(type: .photo, sortOrder: 0),
            MediaItem(type: .drawing, sortOrder: 1)
        ]

        // Act
        let doc = Document(title: "Mit Medien", mediaItems: mediaItems)

        // Assert
        XCTAssertEqual(doc.mediaItems.count, 2)
        XCTAssertEqual(doc.mediaItems[0].type, .photo)
        XCTAssertEqual(doc.mediaItems[1].type, .drawing)
    }

    func testDocumentCodableWithMediaItems() throws {
        // Arrange
        let mediaItems = [MediaItem(type: .photo, sortOrder: 0, caption: "Testbild")]
        let doc = Document(title: "Codable Media", mediaItems: mediaItems)

        // Act
        let data = try JSONEncoder().encode(doc)
        let decoded = try JSONDecoder().decode(Document.self, from: data)

        // Assert
        XCTAssertEqual(decoded.mediaItems.count, 1)
        XCTAssertEqual(decoded.mediaItems[0].type, .photo)
        XCTAssertEqual(decoded.mediaItems[0].caption, "Testbild")
    }
}
