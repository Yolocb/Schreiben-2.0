//
//  Document.swift
//  Schreiben 2.0
//
//  Datenmodell für ein Dokument
//

import Foundation

/// Typ eines Medienelements
enum MediaType: String, Codable, CaseIterable {
    case photo = "photo"
    case drawing = "drawing"
}

/// Repräsentiert ein Medienelement (Bild oder Zeichnung)
struct MediaItem: Identifiable, Codable, Equatable {
    /// Eindeutige ID
    let id: UUID

    /// Typ des Medienelements
    let type: MediaType

    /// Erstellungsdatum
    let createdAt: Date

    /// Sortierreihenfolge innerhalb des Dokuments
    var sortOrder: Int

    /// Optionale Beschriftung
    var caption: String

    init(
        id: UUID = UUID(),
        type: MediaType,
        createdAt: Date = Date(),
        sortOrder: Int = 0,
        caption: String = ""
    ) {
        self.id = id
        self.type = type
        self.createdAt = createdAt
        self.sortOrder = sortOrder
        self.caption = caption
    }
}

/// Repräsentiert ein Schreibdokument mit Text, Bildern und Aufgaben
struct Document: Identifiable, Codable, Equatable {
    /// Eindeutige ID
    let id: UUID

    /// Titel des Dokuments
    var title: String

    /// Erstellungsdatum
    let createdAt: Date

    /// Letztes Änderungsdatum
    var updatedAt: Date

    /// Textinhalt des Dokuments
    var textContent: String

    /// IDs der zugeordneten Bilder (Referenzen auf gespeicherte Dateien, Legacy)
    var imageIDs: [String]

    /// Medienelemente (Bilder und Zeichnungen)
    var mediaItems: [MediaItem]

    /// Markierte Wörter als Aufgaben
    var tasks: [Task]

    /// Initialisiert ein neues Dokument
    init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        textContent: String = "",
        imageIDs: [String] = [],
        mediaItems: [MediaItem] = [],
        tasks: [Task] = []
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.textContent = textContent
        self.imageIDs = imageIDs
        self.mediaItems = mediaItems
        self.tasks = tasks
    }
}

/// Repräsentiert eine Aufgabe (markiertes Wort)
struct Task: Identifiable, Codable, Equatable {
    /// Eindeutige ID
    let id: UUID

    /// Das markierte Wort
    var word: String

    /// Ist die Aufgabe erledigt?
    var isCompleted: Bool

    /// Erstellungsdatum
    let createdAt: Date

    init(
        id: UUID = UUID(),
        word: String,
        isCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.word = word
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
