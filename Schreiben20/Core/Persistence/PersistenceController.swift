//
//  PersistenceController.swift
//  Schreiben 2.0
//
//  Core Data Stack und Persistenz-Management
//

import CoreData

/// Verwaltet den Core Data Stack
class PersistenceController {
    /// Shared-Instanz für die App
    static let shared = PersistenceController()

    /// In-Memory-Instanz für Previews und Tests
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // Erstelle Beispieldaten für Previews
        for i in 1...5 {
            let document = DocumentEntity(context: viewContext)
            document.id = UUID()
            document.title = "Beispiel-Dokument \(i)"
            document.createdAt = Date()
            document.updatedAt = Date()
            document.textContent = "Dies ist ein Beispieltext."
            document.imageIDs = []
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Preview-Daten konnten nicht gespeichert werden: \(nsError), \(nsError.userInfo)")
        }

        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Schreiben20")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                // In Produktion sollte dies besser gehandhabt werden
                fatalError("Core Data Store konnte nicht geladen werden: \(error)")
            }
        }

        // Automatisches Merging von Änderungen
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    /// Speichert den Context
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Core Data konnte nicht gespeichert werden: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    /// Migriert Daten von UserDefaults zu Core Data
    func migrateFromUserDefaults() {
        let userDefaultsKey = "schreiben20.documents"

        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            print("Keine UserDefaults-Daten zum Migrieren vorhanden")
            return
        }

        do {
            let decoder = JSONDecoder()
            let documents = try decoder.decode([Document].self, from: data)

            let context = container.viewContext

            for document in documents {
                let entity = DocumentEntity(context: context)
                entity.id = document.id
                entity.title = document.title
                entity.createdAt = document.createdAt
                entity.updatedAt = document.updatedAt
                entity.textContent = document.textContent
                entity.imageIDs = document.imageIDs

                // Migriere Tasks
                for task in document.tasks {
                    let taskEntity = TaskEntity(context: context)
                    taskEntity.id = task.id
                    taskEntity.word = task.word
                    taskEntity.isCompleted = task.isCompleted
                    taskEntity.createdAt = task.createdAt
                    taskEntity.document = entity
                }
            }

            try context.save()

            // Lösche alte UserDefaults-Daten nach erfolgreicher Migration
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
            print("Migration von UserDefaults zu Core Data erfolgreich: \(documents.count) Dokumente")

        } catch {
            print("Fehler bei Migration: \(error)")
        }
    }
}
