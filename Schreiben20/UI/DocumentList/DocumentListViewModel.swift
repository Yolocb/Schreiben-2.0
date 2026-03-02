//
//  DocumentListViewModel.swift
//  Schreiben 2.0
//
//  ViewModel für die Dokumentenliste
//

import Foundation
import Combine

/// ViewModel für die Dokumentenlisten-Ansicht
class DocumentListViewModel: ObservableObject {
    /// Alle verfügbaren Dokumente
    @Published var documents: [Document] = []

    /// Fehler, der dem User angezeigt werden soll
    @Published var errorMessage: String?

    /// Zeigt an, ob ein Alert angezeigt werden soll
    @Published var showError: Bool = false

    /// Zeigt an, ob Daten geladen werden
    @Published var isLoading: Bool = true

    // MARK: - Phase 2: Dokumentenverwaltung

    /// Zeigt den Lösch-Bestätigungsdialog an
    @Published var showDeleteConfirmation: Bool = false

    /// Zeigt den Umbenennen-Dialog an
    @Published var showRenameDialog: Bool = false

    /// Aktuell ausgewähltes Dokument für Aktionen
    @Published var selectedDocument: Document?

    /// Neuer Name für das Umbenennen
    @Published var newDocumentName: String = ""

    /// Referenz zum DocumentService
    private(set) var documentService: DocumentService?

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Service wird später via setDocumentService injiziert
    }

    // MARK: - Public Methods

    /// Setzt den DocumentService und bindet die Daten
    func setDocumentService(_ service: DocumentService) {
        self.documentService = service
        isLoading = true
        setupBindings()
        // Simuliere kurze Ladezeit für bessere UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.isLoading = false
        }
    }

    // MARK: - Actions

    /// Erstellt ein neues Dokument
    func createNewDocument() {
        guard let documentService = documentService else {
            showErrorAlert("DocumentService ist nicht initialisiert. Bitte starte die App neu.")
            return
        }

        let timestamp = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short

        let title = "Neues Dokument \(formatter.string(from: timestamp))"
        _ = documentService.createDocument(title: title)
    }

    // MARK: - Phase 2: Dokumentenverwaltung Actions

    /// Bereitet das Löschen eines Dokuments vor (zeigt Bestätigungsdialog)
    func prepareDelete(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        selectedDocument = documents[index]
        showDeleteConfirmation = true
    }

    /// Löscht das ausgewählte Dokument
    func confirmDelete() {
        guard let document = selectedDocument else { return }
        guard let documentService = documentService else {
            showErrorAlert("DocumentService ist nicht initialisiert. Bitte starte die App neu.")
            return
        }

        documentService.deleteDocument(document)
        selectedDocument = nil
    }

    /// Bricht das Löschen ab
    func cancelDelete() {
        selectedDocument = nil
        showDeleteConfirmation = false
    }

    /// Bereitet das Umbenennen eines Dokuments vor
    func prepareRename(_ document: Document) {
        selectedDocument = document
        newDocumentName = document.title
        showRenameDialog = true
    }

    /// Benennt das Dokument um
    func confirmRename() {
        guard let document = selectedDocument else { return }
        guard let documentService = documentService else {
            showErrorAlert("DocumentService ist nicht initialisiert. Bitte starte die App neu.")
            return
        }

        let trimmedName = newDocumentName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            showErrorAlert("Der Dokumentname darf nicht leer sein.")
            return
        }

        var updatedDocument = document
        updatedDocument.title = trimmedName
        documentService.updateDocument(updatedDocument)

        selectedDocument = nil
        newDocumentName = ""
    }

    /// Bricht das Umbenennen ab
    func cancelRename() {
        selectedDocument = nil
        newDocumentName = ""
        showRenameDialog = false
    }

    // MARK: - Private Methods

    /// Zeigt eine Fehlermeldung an
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
        print("Fehler: \(message)")
    }

    /// Bindet das ViewModel an den DocumentService
    private func setupBindings() {
        guard let documentService = documentService else { return }

        cancellables.removeAll() // Alte Bindings entfernen
        documentService.$documents
            .assign(to: &$documents)
    }
}
