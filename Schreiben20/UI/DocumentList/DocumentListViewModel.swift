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

    /// Referenz zum DocumentService
    private var documentService: DocumentService?

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
