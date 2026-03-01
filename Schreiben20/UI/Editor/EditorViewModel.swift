//
//  EditorViewModel.swift
//  Schreiben 2.0
//
//  ViewModel für den Editor (Platzhalter für Phase 3)
//

import Foundation
import Combine

/// ViewModel für die Editor-Ansicht
class EditorViewModel: ObservableObject {
    /// Das aktuelle Dokument
    @Published var document: Document?

    /// Fehler, der dem User angezeigt werden soll
    @Published var errorMessage: String?

    /// Zeigt an, ob ein Alert angezeigt werden soll
    @Published var showError: Bool = false

    /// Zeigt an, ob Daten geladen werden
    @Published var isLoading: Bool = true

    /// Referenz zum DocumentService
    private var documentService: DocumentService?

    private let documentID: UUID
    private var cancellables = Set<AnyCancellable>()

    init(documentID: UUID) {
        self.documentID = documentID
        // Service wird später via setDocumentService injiziert
    }

    // MARK: - Public Methods

    /// Setzt den DocumentService und lädt das Dokument
    func setDocumentService(_ service: DocumentService) {
        self.documentService = service
        isLoading = true
        loadDocument()
        setupBindings()
        // Simuliere kurze Ladezeit für bessere UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.isLoading = false
        }
    }

    // MARK: - Private Methods

    /// Lädt das Dokument vom Service
    private func loadDocument() {
        guard let documentService = documentService else {
            showErrorAlert("DocumentService ist nicht initialisiert. Bitte starte die App neu.")
            return
        }
        document = documentService.document(withID: documentID)

        if document == nil {
            showErrorAlert("Dokument konnte nicht gefunden werden.")
        }
    }

    /// Bindet Änderungen am DocumentService
    private func setupBindings() {
        guard let documentService = documentService else { return }

        cancellables.removeAll() // Alte Bindings entfernen
        documentService.$documents
            .sink { [weak self] _ in
                self?.loadDocument()
            }
            .store(in: &cancellables)
    }

    /// Zeigt eine Fehlermeldung an
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
        print("Fehler: \(message)")
    }
}
