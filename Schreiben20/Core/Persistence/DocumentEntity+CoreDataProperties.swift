//
//  DocumentEntity+CoreDataProperties.swift
//  Schreiben 2.0
//
//  Core Data Properties für DocumentEntity
//

import Foundation
import CoreData

extension DocumentEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DocumentEntity> {
        return NSFetchRequest<DocumentEntity>(entityName: "DocumentEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var textContent: String?
    @NSManaged public var imageIDs: [String]?
    @NSManaged public var tasks: NSSet?
    @NSManaged public var mediaItems: NSOrderedSet?

}

// MARK: Generated accessors for tasks
extension DocumentEntity {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: TaskEntity)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: TaskEntity)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}

// MARK: Generated accessors for mediaItems
extension DocumentEntity {

    @objc(insertObject:inMediaItemsAtIndex:)
    @NSManaged public func insertIntoMediaItems(_ value: MediaItemEntity, at idx: Int)

    @objc(removeObjectFromMediaItemsAtIndex:)
    @NSManaged public func removeFromMediaItems(at idx: Int)

    @objc(insertMediaItems:atIndexes:)
    @NSManaged public func insertIntoMediaItems(_ values: [MediaItemEntity], at indexes: NSIndexSet)

    @objc(removeMediaItemsAtIndexes:)
    @NSManaged public func removeFromMediaItems(at indexes: NSIndexSet)

    @objc(replaceObjectInMediaItemsAtIndex:withObject:)
    @NSManaged public func replaceMediaItems(at idx: Int, with value: MediaItemEntity)

    @objc(replaceMediaItemsAtIndexes:withMediaItems:)
    @NSManaged public func replaceMediaItems(at indexes: NSIndexSet, with values: [MediaItemEntity])

    @objc(addMediaItemsObject:)
    @NSManaged public func addToMediaItems(_ value: MediaItemEntity)

    @objc(removeMediaItemsObject:)
    @NSManaged public func removeFromMediaItems(_ value: MediaItemEntity)

    @objc(addMediaItems:)
    @NSManaged public func addToMediaItems(_ values: NSOrderedSet)

    @objc(removeMediaItems:)
    @NSManaged public func removeFromMediaItems(_ values: NSOrderedSet)

}

extension DocumentEntity: Identifiable {

}
