//
//  ImageStorageService.swift
//  Schreiben 2.0
//
//  Service für Bildspeicherung im Dateisystem
//  Speichert JPEG-Bilder, Thumbnails und PencilKit-Zeichnungen
//

import Foundation
import UIKit
import PencilKit

/// Service für dateibasierte Bildspeicherung
class ImageStorageService {

    /// Basis-Verzeichnis für Bildspeicherung
    private let imagesDirectory: URL

    /// JPEG-Kompressionsqualität
    private let jpegQuality: CGFloat = 0.8

    /// Maximale Bildgröße (Breite oder Höhe)
    private let maxImageDimension: CGFloat = 2048

    /// Thumbnail-Größe
    private let thumbnailSize: CGFloat = 200

    init(baseDirectory: URL? = nil) {
        if let baseDirectory = baseDirectory {
            self.imagesDirectory = baseDirectory
        } else {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            self.imagesDirectory = documentsPath.appendingPathComponent("images", isDirectory: true)
        }

        createDirectoryIfNeeded()
    }

    // MARK: - Bild-Operationen

    /// Speichert ein Bild und erzeugt ein Thumbnail
    @discardableResult
    func saveImage(_ image: UIImage, withID id: UUID = UUID()) throws -> UUID {
        // Bild skalieren falls nötig
        let resized = resizeImageIfNeeded(image)

        // JPEG-Daten erzeugen
        guard let jpegData = resized.jpegData(compressionQuality: jpegQuality) else {
            throw ImageStorageError.compressionFailed
        }

        // Vollbild speichern
        let imagePath = imageURL(for: id)
        try jpegData.write(to: imagePath)

        // Thumbnail erzeugen und speichern
        let thumbnail = createThumbnail(from: resized)
        guard let thumbData = thumbnail.jpegData(compressionQuality: 0.7) else {
            throw ImageStorageError.compressionFailed
        }
        let thumbPath = thumbnailURL(for: id)
        try thumbData.write(to: thumbPath)

        return id
    }

    /// Lädt ein Bild anhand der ID
    func loadImage(withID id: UUID) -> UIImage? {
        let path = imageURL(for: id)
        guard FileManager.default.fileExists(atPath: path.path) else { return nil }
        return UIImage(contentsOfFile: path.path)
    }

    /// Lädt ein Thumbnail anhand der ID
    func loadThumbnail(withID id: UUID) -> UIImage? {
        let path = thumbnailURL(for: id)
        guard FileManager.default.fileExists(atPath: path.path) else { return nil }
        return UIImage(contentsOfFile: path.path)
    }

    /// Löscht ein Bild und sein Thumbnail
    func deleteImage(withID id: UUID) throws {
        let imagePath = imageURL(for: id)
        let thumbPath = thumbnailURL(for: id)

        if FileManager.default.fileExists(atPath: imagePath.path) {
            try FileManager.default.removeItem(at: imagePath)
        }
        if FileManager.default.fileExists(atPath: thumbPath.path) {
            try FileManager.default.removeItem(at: thumbPath)
        }
    }

    /// Prüft ob ein Bild existiert
    func imageExists(withID id: UUID) -> Bool {
        FileManager.default.fileExists(atPath: imageURL(for: id).path)
    }

    // MARK: - Zeichnungs-Operationen (PencilKit)

    /// Speichert PencilKit-Zeichnungsdaten
    @discardableResult
    func saveDrawing(_ drawing: PKDrawing, withID id: UUID = UUID()) throws -> UUID {
        let data = drawing.dataRepresentation()
        let drawingPath = drawingURL(for: id)
        try data.write(to: drawingPath)

        // Thumbnail aus Zeichnung erzeugen
        let thumbnailImage = drawing.image(from: drawing.bounds, scale: 1.0)
        let thumbnail = createThumbnail(from: thumbnailImage)
        guard let thumbData = thumbnail.jpegData(compressionQuality: 0.7) else {
            throw ImageStorageError.compressionFailed
        }
        try thumbData.write(to: thumbnailURL(for: id))

        return id
    }

    /// Lädt PencilKit-Zeichnungsdaten
    func loadDrawing(withID id: UUID) -> PKDrawing? {
        let path = drawingURL(for: id)
        guard FileManager.default.fileExists(atPath: path.path) else { return nil }

        do {
            let data = try Data(contentsOf: path)
            return try PKDrawing(data: data)
        } catch {
            print("Fehler beim Laden der Zeichnung: \(error)")
            return nil
        }
    }

    /// Löscht eine Zeichnung und ihr Thumbnail
    func deleteDrawing(withID id: UUID) throws {
        let drawingPath = drawingURL(for: id)
        let thumbPath = thumbnailURL(for: id)

        if FileManager.default.fileExists(atPath: drawingPath.path) {
            try FileManager.default.removeItem(at: drawingPath)
        }
        if FileManager.default.fileExists(atPath: thumbPath.path) {
            try FileManager.default.removeItem(at: thumbPath)
        }
    }

    // MARK: - Aufräumen

    /// Löscht alle gespeicherten Medien
    func deleteAll() throws {
        if FileManager.default.fileExists(atPath: imagesDirectory.path) {
            try FileManager.default.removeItem(at: imagesDirectory)
            createDirectoryIfNeeded()
        }
    }

    /// Berechnet die Gesamtgröße aller gespeicherten Dateien
    func totalStorageSize() -> Int64 {
        guard let enumerator = FileManager.default.enumerator(at: imagesDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }

        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(fileSize)
            }
        }
        return totalSize
    }

    // MARK: - URL-Helfer

    /// URL für ein Vollbild
    func imageURL(for id: UUID) -> URL {
        imagesDirectory.appendingPathComponent("\(id.uuidString).jpg")
    }

    /// URL für ein Thumbnail
    func thumbnailURL(for id: UUID) -> URL {
        imagesDirectory.appendingPathComponent("\(id.uuidString)_thumb.jpg")
    }

    /// URL für eine Zeichnung
    func drawingURL(for id: UUID) -> URL {
        imagesDirectory.appendingPathComponent("\(id.uuidString).drawing")
    }

    // MARK: - Private Methods

    /// Erstellt das Bilder-Verzeichnis falls nötig
    private func createDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: imagesDirectory.path) {
            try? FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        }
    }

    /// Skaliert ein Bild auf maxImageDimension herunter falls nötig
    private func resizeImageIfNeeded(_ image: UIImage) -> UIImage {
        let size = image.size
        guard size.width > maxImageDimension || size.height > maxImageDimension else {
            return image
        }

        let ratio = min(maxImageDimension / size.width, maxImageDimension / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// Erzeugt ein quadratisches Thumbnail
    private func createThumbnail(from image: UIImage) -> UIImage {
        let size = CGSize(width: thumbnailSize, height: thumbnailSize)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            let imageSize = image.size
            let ratio = max(size.width / imageSize.width, size.height / imageSize.height)
            let scaledSize = CGSize(width: imageSize.width * ratio, height: imageSize.height * ratio)
            let origin = CGPoint(
                x: (size.width - scaledSize.width) / 2,
                y: (size.height - scaledSize.height) / 2
            )
            image.draw(in: CGRect(origin: origin, size: scaledSize))
        }
    }
}

// MARK: - Fehlertypen

enum ImageStorageError: LocalizedError {
    case compressionFailed
    case fileNotFound
    case saveFailed(Error)

    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Bild konnte nicht komprimiert werden."
        case .fileNotFound:
            return "Datei wurde nicht gefunden."
        case .saveFailed(let error):
            return "Speichern fehlgeschlagen: \(error.localizedDescription)"
        }
    }
}
