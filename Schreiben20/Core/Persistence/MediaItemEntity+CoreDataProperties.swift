//
//  MediaItemEntity+CoreDataProperties.swift
//  Schreiben 2.0
//
//  Core Data Properties für MediaItemEntity
//

import Foundation
import CoreData

extension MediaItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaItemEntity> {
        return NSFetchRequest<MediaItemEntity>(entityName: "MediaItemEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var type: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var sortOrder: Int16
    @NSManaged public var caption: String?
    @NSManaged public var document: DocumentEntity?
}

extension MediaItemEntity: Identifiable {
}
