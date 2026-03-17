//
//  DocumentEntity+CoreDataClass.swift
//  Schreiben 2.0
//
//  Core Data Entity für Dokument
//

import Foundation
import CoreData

@objc(DocumentEntity)
public class DocumentEntity: NSManagedObject {
    /// Konvertiert Entity zu Domain-Model
    func toDomainModel() -> Document {
        // MediaItems aus der geordneten Beziehung konvertieren
        let mediaItemArray: [MediaItem] = (mediaItems?.array as? [MediaItemEntity])?.map { $0.toDomainModel() } ?? []

        return Document(
            id: id ?? UUID(),
            title: title ?? "",
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date(),
            textContent: textContent ?? "",
            imageIDs: imageIDs ?? [],
            mediaItems: mediaItemArray,
            tasks: (tasks?.allObjects as? [TaskEntity])?.map { $0.toDomainModel() } ?? []
        )
    }

    /// Aktualisiert Entity mit Domain-Model
    func update(from document: Document) {
        self.id = document.id
        self.title = document.title
        self.createdAt = document.createdAt
        self.updatedAt = document.updatedAt
        self.textContent = document.textContent
        self.imageIDs = document.imageIDs
    }
}
