//
//  ImageStorageServiceTests.swift
//  Schreiben 2.0
//
//  Tests für ImageStorageService
//

import XCTest
@testable import Schreiben20

final class ImageStorageServiceTests: XCTestCase {

    var sut: ImageStorageService!
    var tempDirectory: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ImageStorageTests_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        sut = ImageStorageService(baseDirectory: tempDirectory)
    }

    override func tearDownWithError() throws {
        if FileManager.default.fileExists(atPath: tempDirectory.path) {
            try FileManager.default.removeItem(at: tempDirectory)
        }
        sut = nil
        tempDirectory = nil
        try super.tearDownWithError()
    }

    // MARK: - Hilfsmethoden

    /// Erzeugt ein Test-UIImage
    private func createTestImage(width: CGFloat = 100, height: CGFloat = 100, color: UIColor = .red) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
    }

    // MARK: - Tests

    func testSaveAndLoadImage() throws {
        let image = createTestImage()
        let id = UUID()

        try sut.saveImage(image, withID: id)

        let loaded = sut.loadImage(withID: id)
        XCTAssertNotNil(loaded, "Gespeichertes Bild sollte ladbar sein")
    }

    func testSaveCreatesJPEGFile() throws {
        let image = createTestImage()
        let id = UUID()

        try sut.saveImage(image, withID: id)

        let imagePath = sut.imageURL(for: id)
        XCTAssertTrue(FileManager.default.fileExists(atPath: imagePath.path),
                       "JPEG-Datei sollte existieren")
    }

    func testSaveCreatesThumbnail() throws {
        let image = createTestImage()
        let id = UUID()

        try sut.saveImage(image, withID: id)

        let thumbPath = sut.thumbnailURL(for: id)
        XCTAssertTrue(FileManager.default.fileExists(atPath: thumbPath.path),
                       "Thumbnail sollte erstellt werden")
    }

    func testLoadThumbnail() throws {
        let image = createTestImage()
        let id = UUID()

        try sut.saveImage(image, withID: id)

        let thumbnail = sut.loadThumbnail(withID: id)
        XCTAssertNotNil(thumbnail, "Thumbnail sollte ladbar sein")
    }

    func testDeleteImage() throws {
        let image = createTestImage()
        let id = UUID()

        try sut.saveImage(image, withID: id)
        try sut.deleteImage(withID: id)

        XCTAssertNil(sut.loadImage(withID: id), "Gelöschtes Bild sollte nil sein")
        XCTAssertNil(sut.loadThumbnail(withID: id), "Thumbnail sollte auch gelöscht sein")
    }

    func testImageExists() throws {
        let id = UUID()

        XCTAssertFalse(sut.imageExists(withID: id), "Bild sollte nicht existieren")

        let image = createTestImage()
        try sut.saveImage(image, withID: id)

        XCTAssertTrue(sut.imageExists(withID: id), "Bild sollte existieren")
    }

    func testLargeImageIsResized() throws {
        let largeImage = createTestImage(width: 4000, height: 3000)
        let id = UUID()

        try sut.saveImage(largeImage, withID: id)

        let loaded = sut.loadImage(withID: id)
        XCTAssertNotNil(loaded)

        // Bild sollte auf max 2048 skaliert sein
        if let size = loaded?.size {
            XCTAssertLessThanOrEqual(max(size.width, size.height), 2048 + 1,
                                      "Bild sollte auf maximal 2048px skaliert sein")
        }
    }

    func testLoadNonExistentImage() {
        let id = UUID()
        XCTAssertNil(sut.loadImage(withID: id), "Nicht existierendes Bild sollte nil zurückgeben")
    }

    func testDeleteAll() throws {
        let image = createTestImage()
        let id1 = UUID()
        let id2 = UUID()

        try sut.saveImage(image, withID: id1)
        try sut.saveImage(image, withID: id2)

        try sut.deleteAll()

        XCTAssertFalse(sut.imageExists(withID: id1))
        XCTAssertFalse(sut.imageExists(withID: id2))
    }

    func testTotalStorageSize() throws {
        let image = createTestImage(width: 500, height: 500)
        let id = UUID()

        let sizeBefore = sut.totalStorageSize()

        try sut.saveImage(image, withID: id)

        let sizeAfter = sut.totalStorageSize()
        XCTAssertGreaterThan(sizeAfter, sizeBefore,
                             "Speichergröße sollte nach Speichern größer sein")
    }
}
