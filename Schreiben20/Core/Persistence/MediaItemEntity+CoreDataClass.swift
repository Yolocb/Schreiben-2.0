//
//  MediaItemEntity+CoreDataClass.swift
//  Schreiben 2.0
//
//  Core Data Entity für Medienelemente
//

import Foundation
import CoreData

@objc(MediaItemEntity)
public class MediaItemEntity: NSManagedObject {
    /// Konvertiert Entity zu Domain-Model
    func toDomainModel() -> MediaItem {
        return MediaItem(
            id: id ?? UUID(),
            type: MediaType(rawValue: type ?? "photo") ?? .photo,
            createdAt: createdAt ?? Date(),
            sortOrder: Int(sortOrder),
            caption: caption ?? ""
        )
    }

    /// Aktualisiert Entity mit Domain-Model
    func update(from mediaItem: MediaItem) {
        self.id = mediaItem.id
        self.type = mediaItem.type.rawValue
        self.createdAt = mediaItem.createdAt
        self.sortOrder = Int16(mediaItem.sortOrder)
        self.caption = mediaItem.caption
    }
}
