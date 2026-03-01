//
//  DocumentService.swift
//  Schreiben 2.0
//
//  Service für Dokumentenverwaltung (CRUD-Operationen)
//  Nutzt Core Data für Persistenz
//

import Foundation
import Combine
import CoreData

/// Service für das Laden, Speichern und Verwalten von Dokumenten
class DocumentService: ObservableObject {
    /// Alle verfügbaren Dokumente
    @Published private(set) var documents: [Document] = []

    /// Fehler bei Operationen
    @Published var lastError: Error?

    private let persistenceController: PersistenceController
    private var cancellables = Set<AnyCancellable>()

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController

        // Migration von UserDefaults durchführen (nur beim ersten Start)
        migrateIfNeeded()

        // Dokumente laden
        loadDocuments()
    }

    // MARK: - Public Methods

    /// Erstellt ein neues Dokument
    @discardableResult
    func createDocument(title: String) -> Document {
        let context = persistenceController.container.viewContext

        let entity = DocumentEntity(context: context)
        entity.id = UUID()
        entity.title = title
        entity.createdAt = Date()
        entity.updatedAt = Date()
        entity.textContent = ""
        entity.imageIDs = []

        persistenceController.save()
        loadDocuments()

        return entity.toDomainModel()
    }

    /// Aktualisiert ein bestehendes Dokument
    func updateDocument(_ document: Document) {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<DocumentEntity> = DocumentEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", document.id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            if let entity = results.first {
                var updatedDoc = document
                updatedDoc.updatedAt = Date()
                entity.update(from: updatedDoc)

                persistenceController.save()
                loadDocuments()
            }
        } catch {
            lastError = error
            print("Fehler beim Aktualisieren: \(error)")
        }
    }

    /// Löscht ein Dokument
    func deleteDocument(_ document: Document) {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<DocumentEntity> = DocumentEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", document.id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            if let entity = results.first {
                context.delete(entity)
                persistenceController.save()
                loadDocuments()
            }
        } catch {
            lastError = error
            print("Fehler beim Löschen: \(error)")
        }
    }

    /// Lädt ein Dokument anhand seiner ID
    func document(withID id: UUID) -> Document? {
        documents.first { $0.id == id }
    }

    // MARK: - Private Methods

    /// Lädt alle Dokumente aus Core Data
    private func loadDocuments() {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<DocumentEntity> = DocumentEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]

        do {
            let entities = try context.fetch(fetchRequest)
            documents = entities.map { $0.toDomainModel() }
        } catch {
            lastError = error
            print("Fehler beim Laden der Dokumente: \(error)")
        }
    }

    /// Führt Migration von UserDefaults durch, falls nötig
    private func migrateIfNeeded() {
        let migrationKey = "schreiben20.migrated_to_coredata"

        if !UserDefaults.standard.bool(forKey: migrationKey) {
            persistenceController.migrateFromUserDefaults()
            UserDefaults.standard.set(true, forKey: migrationKey)
        }
    }
}
