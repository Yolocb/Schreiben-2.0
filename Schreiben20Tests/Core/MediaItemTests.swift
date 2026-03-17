//
//  MediaItemTests.swift
//  Schreiben 2.0
//
//  Tests für MediaItem und MediaType
//

import XCTest
@testable import Schreiben20

final class MediaItemTests: XCTestCase {

    // MARK: - MediaItem Erstellung

    func testMediaItemCreation() {
        let item = MediaItem(type: .photo)

        XCTAssertNotNil(item.id, "ID sollte gesetzt sein")
        XCTAssertEqual(item.type, .photo)
        XCTAssertEqual(item.sortOrder, 0, "Standard-Sortierung sollte 0 sein")
        XCTAssertEqual(item.caption, "", "Standard-Beschriftung sollte leer sein")
    }

    func testMediaItemWithPhoto() {
        let item = MediaItem(type: .photo, sortOrder: 1, caption: "Mein Bild")

        XCTAssertEqual(item.type, .photo)
        XCTAssertEqual(item.sortOrder, 1)
        XCTAssertEqual(item.caption, "Mein Bild")
    }

    func testMediaItemWithDrawing() {
        let item = MediaItem(type: .drawing, sortOrder: 2, caption: "Zeichnung")

        XCTAssertEqual(item.type, .drawing)
        XCTAssertEqual(item.sortOrder, 2)
        XCTAssertEqual(item.caption, "Zeichnung")
    }

    // MARK: - MediaType

    func testMediaTypeRawValues() {
        XCTAssertEqual(MediaType.photo.rawValue, "photo")
        XCTAssertEqual(MediaType.drawing.rawValue, "drawing")
        XCTAssertEqual(MediaType.allCases.count, 2)
    }

    // MARK: - Equatable

    func testMediaItemEquality() {
        let id = UUID()
        let date = Date()

        let item1 = MediaItem(id: id, type: .photo, createdAt: date, sortOrder: 0, caption: "Test")
        let item2 = MediaItem(id: id, type: .photo, createdAt: date, sortOrder: 0, caption: "Test")

        XCTAssertEqual(item1, item2, "Gleiche MediaItems sollten gleich sein")

        let item3 = MediaItem(type: .drawing)
        XCTAssertNotEqual(item1, item3, "Verschiedene MediaItems sollten ungleich sein")
    }

    // MARK: - Codable

    func testMediaItemCodable() throws {
        let original = MediaItem(type: .drawing, sortOrder: 3, caption: "Test-Zeichnung")

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(MediaItem.self, from: data)

        XCTAssertEqual(original, decoded, "Codable Roundtrip sollte identisch sein")
    }

    // MARK: - Document mit MediaItems

    func testDocumentWithMediaItems() {
        let mediaItems = [
            MediaItem(type: .photo, sortOrder: 0, caption: "Foto 1"),
            MediaItem(type: .drawing, sortOrder: 1, caption: "Zeichnung 1")
        ]

        let doc = Document(title: "Test", mediaItems: mediaItems)

        XCTAssertEqual(doc.mediaItems.count, 2)
        XCTAssertEqual(doc.mediaItems[0].type, .photo)
        XCTAssertEqual(doc.mediaItems[1].type, .drawing)
    }

    // MARK: - Entity Konvertierung

    func testMediaItemEntityConversion() {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        let entity = MediaItemEntity(context: context)
        entity.id = UUID()
        entity.type = "drawing"
        entity.createdAt = Date()
        entity.sortOrder = 5
        entity.caption = "Testbild"

        // toDomainModel
        let domainModel = entity.toDomainModel()
        XCTAssertEqual(domainModel.id, entity.id)
        XCTAssertEqual(domainModel.type, .drawing)
        XCTAssertEqual(domainModel.sortOrder, 5)
        XCTAssertEqual(domainModel.caption, "Testbild")

        // update(from:)
        let newItem = MediaItem(type: .photo, sortOrder: 10, caption: "Neues Bild")
        entity.update(from: newItem)
        XCTAssertEqual(entity.type, "photo")
        XCTAssertEqual(entity.sortOrder, 10)
        XCTAssertEqual(entity.caption, "Neues Bild")
    }
}
