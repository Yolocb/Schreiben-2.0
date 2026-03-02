//
//  EditorViewModel.swift
//  Schreiben 2.0
//
//  ViewModel für den Editor mit Textbearbeitung und Formatierung
//

import Foundation
import Combine
import SwiftUI

/// ViewModel für die Editor-Ansicht
class EditorViewModel: ObservableObject {
    /// Das aktuelle Dokument
    @Published var document: Document?

    /// Der aktuelle Textinhalt (für Binding)
    @Published var textContent: String = "" {
        didSet {
            if textContent != oldValue {
                hasUnsavedChanges = true
                addToUndoStack(oldValue)
            }
        }
    }

    /// Schriftgröße (16-48pt)
    @Published var fontSize: CGFloat = 24 {
        didSet {
            UserDefaults.standard.set(Double(fontSize), forKey: "schreiben20.fontSize")
        }
    }

    /// Zeilenlinien anzeigen
    @Published var showLineGuides: Bool = true {
        didSet {
            UserDefaults.standard.set(showLineGuides, forKey: "schreiben20.showLineGuides")
        }
    }

    /// Fehler, der dem User angezeigt werden soll
    @Published var errorMessage: String?

    /// Zeigt an, ob ein Alert angezeigt werden soll
    @Published var showError: Bool = false

    /// Zeigt an, ob Daten geladen werden
    @Published var isLoading: Bool = true

    /// Zeigt an, ob es ungespeicherte Änderungen gibt
    @Published var hasUnsavedChanges: Bool = false

    /// Zeigt den Speicher-Indikator kurz an
    @Published var showSaveIndicator: Bool = false

    // MARK: - Undo/Redo

    private var undoStack: [String] = []
    private var redoStack: [String] = []
    private var isUndoRedoAction: Bool = false

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    // MARK: - Statistiken

    var wordCount: Int {
        let words = textContent.split { $0.isWhitespace || $0.isNewline }
        return words.count
    }

    var characterCount: Int {
        textContent.count
    }

    /// Referenz zum DocumentService
    private(set) var documentService: DocumentService?

    private let documentID: UUID
    private var cancellables = Set<AnyCancellable>()
    private var autoSaveTimer: AnyCancellable?

    init(documentID: UUID) {
        self.documentID = documentID
        loadUserPreferences()
    }

    // MARK: - Public Methods

    /// Setzt den DocumentService und lädt das Dokument
    func setDocumentService(_ service: DocumentService) {
        self.documentService = service
        isLoading = true
        loadDocument()
        setupAutoSave()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.isLoading = false
        }
    }

    /// Speichert das Dokument
    func saveDocument() {
        guard var doc = document else { return }
        guard let documentService = documentService else {
            showErrorAlert("DocumentService ist nicht initialisiert.")
            return
        }

        doc.textContent = textContent
        documentService.updateDocument(doc)
        hasUnsavedChanges = false

        // Zeige kurz den Speicher-Indikator
        showSaveIndicator = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.showSaveIndicator = false
        }
    }

    /// Speichert beim Verlassen der View
    func saveOnDisappear() {
        if hasUnsavedChanges {
            saveDocument()
        }
    }

    // MARK: - Schriftgröße

    /// Erhöht die Schriftgröße
    func increaseFontSize() {
        if fontSize < 48 {
            fontSize += 2
        }
    }

    /// Verringert die Schriftgröße
    func decreaseFontSize() {
        if fontSize > 16 {
            fontSize -= 2
        }
    }

    // MARK: - Undo/Redo

    /// Macht die letzte Änderung rückgängig
    func undo() {
        guard let previousText = undoStack.popLast() else { return }
        isUndoRedoAction = true
        redoStack.append(textContent)
        textContent = previousText
        isUndoRedoAction = false
    }

    /// Stellt die letzte rückgängig gemachte Änderung wieder her
    func redo() {
        guard let nextText = redoStack.popLast() else { return }
        isUndoRedoAction = true
        undoStack.append(textContent)
        textContent = nextText
        isUndoRedoAction = false
    }

    private func addToUndoStack(_ text: String) {
        guard !isUndoRedoAction else { return }
        undoStack.append(text)
        redoStack.removeAll()
        // Begrenze Stack-Größe
        if undoStack.count > 50 {
            undoStack.removeFirst()
        }
    }

    // MARK: - Titel bearbeiten

    /// Aktualisiert den Dokumenttitel
    func updateTitle(_ newTitle: String) {
        guard var doc = document else { return }
        guard let documentService = documentService else { return }

        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            showErrorAlert("Der Titel darf nicht leer sein.")
            return
        }

        doc.title = trimmedTitle
        documentService.updateDocument(doc)
        document = doc
    }

    // MARK: - Private Methods

    /// Lädt Benutzereinstellungen
    private func loadUserPreferences() {
        let savedFontSize = UserDefaults.standard.double(forKey: "schreiben20.fontSize")
        if savedFontSize > 0 {
            fontSize = CGFloat(savedFontSize)
        }
        showLineGuides = UserDefaults.standard.object(forKey: "schreiben20.showLineGuides") as? Bool ?? true
    }

    /// Lädt das Dokument vom Service
    private func loadDocument() {
        guard let documentService = documentService else {
            showErrorAlert("DocumentService ist nicht initialisiert. Bitte starte die App neu.")
            return
        }
        document = documentService.document(withID: documentID)

        if let doc = document {
            isUndoRedoAction = true
            textContent = doc.textContent
            isUndoRedoAction = false
            undoStack.removeAll()
            redoStack.removeAll()
        } else {
            showErrorAlert("Dokument konnte nicht gefunden werden.")
        }
    }

    /// Richtet Auto-Save ein (alle 30 Sekunden)
    private func setupAutoSave() {
        autoSaveTimer = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                if self?.hasUnsavedChanges == true {
                    self?.saveDocument()
                }
            }
    }

    /// Zeigt eine Fehlermeldung an
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
        print("Fehler: \(message)")
    }
}
