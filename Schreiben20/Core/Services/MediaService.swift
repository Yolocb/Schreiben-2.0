//
//  MediaService.swift
//  Schreiben 2.0
//
//  High-Level Coordinator für Medienoperationen
//  Verbindet ImageStorageService mit Core Data
//

import Foundation
import UIKit
import PencilKit
import Combine

/// Koordiniert Medienoperationen zwischen Storage und Core Data
class MediaService: ObservableObject {
    /// Alle Medienelemente des aktuellen Dokuments
    @Published private(set) var mediaItems: [MediaItem] = []

    /// Letzter Fehler
    @Published var lastError: Error?

    let imageStorageService: ImageStorageService
    private let documentService: DocumentService

    init(imageStorageService: ImageStorageService = ImageStorageService(),
         documentService: DocumentService) {
        self.imageStorageService = imageStorageService
        self.documentService = documentService
    }

    // MARK: - Bild hinzufügen

    /// Fügt ein Foto zu einem Dokument hinzu
    @discardableResult
    func addPhoto(_ image: UIImage, to document: inout Document, caption: String = "") -> MediaItem? {
        let mediaItem = MediaItem(
            type: .photo,
            sortOrder: document.mediaItems.count,
            caption: caption
        )

        do {
            try imageStorageService.saveImage(image, withID: mediaItem.id)
            document.mediaItems.append(mediaItem)
            documentService.updateDocument(document)
            mediaItems = document.mediaItems
            return mediaItem
        } catch {
            lastError = error
            print("Fehler beim Hinzufügen des Fotos: \(error)")
            return nil
        }
    }

    /// Fügt eine Zeichnung zu einem Dokument hinzu
    @discardableResult
    func addDrawing(_ drawing: PKDrawing, to document: inout Document, caption: String = "") -> MediaItem? {
        let mediaItem = MediaItem(
            type: .drawing,
            sortOrder: document.mediaItems.count,
            caption: caption
        )

        do {
            try imageStorageService.saveDrawing(drawing, withID: mediaItem.id)
            document.mediaItems.append(mediaItem)
            documentService.updateDocument(document)
            mediaItems = document.mediaItems
            return mediaItem
        } catch {
            lastError = error
            print("Fehler beim Hinzufügen der Zeichnung: \(error)")
            return nil
        }
    }

    // MARK: - Zeichnung aktualisieren

    /// Aktualisiert eine bestehende Zeichnung
    func updateDrawing(_ drawing: PKDrawing, for mediaItem: MediaItem) {
        do {
            try imageStorageService.saveDrawing(drawing, withID: mediaItem.id)
        } catch {
            lastError = error
            print("Fehler beim Aktualisieren der Zeichnung: \(error)")
        }
    }

    // MARK: - Medien löschen

    /// Löscht ein Medienelement aus einem Dokument
    func deleteMediaItem(_ mediaItem: MediaItem, from document: inout Document) {
        do {
            switch mediaItem.type {
            case .photo:
                try imageStorageService.deleteImage(withID: mediaItem.id)
            case .drawing:
                try imageStorageService.deleteDrawing(withID: mediaItem.id)
            }

            document.mediaItems.removeAll { $0.id == mediaItem.id }

            // Sortierreihenfolge aktualisieren
            for i in document.mediaItems.indices {
                document.mediaItems[i].sortOrder = i
            }

            documentService.updateDocument(document)
            mediaItems = document.mediaItems
        } catch {
            lastError = error
            print("Fehler beim Löschen des Medienelements: \(error)")
        }
    }

    // MARK: - Medien laden

    /// Lädt die Medienelemente eines Dokuments
    func loadMediaItems(for document: Document) {
        mediaItems = document.mediaItems
    }

    /// Lädt ein Thumbnail für ein Medienelement
    func loadThumbnail(for mediaItem: MediaItem) -> UIImage? {
        imageStorageService.loadThumbnail(withID: mediaItem.id)
    }

    /// Lädt das Vollbild für ein Medienelement
    func loadFullImage(for mediaItem: MediaItem) -> UIImage? {
        imageStorageService.loadImage(withID: mediaItem.id)
    }

    /// Lädt eine Zeichnung für ein Medienelement
    func loadDrawing(for mediaItem: MediaItem) -> PKDrawing? {
        guard mediaItem.type == .drawing else { return nil }
        return imageStorageService.loadDrawing(withID: mediaItem.id)
    }
}
