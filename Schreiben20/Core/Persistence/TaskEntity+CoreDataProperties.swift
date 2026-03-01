//
//  TaskEntity+CoreDataProperties.swift
//  Schreiben 2.0
//
//  Core Data Properties für TaskEntity
//

import Foundation
import CoreData

extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var word: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var document: DocumentEntity?

}

extension TaskEntity: Identifiable {

}
