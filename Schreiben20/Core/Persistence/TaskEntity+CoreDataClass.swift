//
//  TaskEntity+CoreDataClass.swift
//  Schreiben 2.0
//
//  Core Data Entity für Task
//

import Foundation
import CoreData

@objc(TaskEntity)
public class TaskEntity: NSManagedObject {
    /// Konvertiert Entity zu Domain-Model
    func toDomainModel() -> Task {
        return Task(
            id: id ?? UUID(),
            word: word ?? "",
            isCompleted: isCompleted,
            createdAt: createdAt ?? Date()
        )
    }

    /// Aktualisiert Entity mit Domain-Model
    func update(from task: Task) {
        self.id = task.id
        self.word = task.word
        self.isCompleted = task.isCompleted
        self.createdAt = task.createdAt
    }
}
