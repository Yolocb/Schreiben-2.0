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

extension DocumentEntity: Identifiable {

}
