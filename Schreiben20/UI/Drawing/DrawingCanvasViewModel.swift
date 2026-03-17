//
//  DrawingCanvasViewModel.swift
//  Schreiben 2.0
//
//  ViewModel für die Zeichenfläche
//

import Foundation
import SwiftUI
import PencilKit
import Combine

/// ViewModel für die Zeichenfunktion
class DrawingCanvasViewModel: ObservableObject {
    /// Die aktuelle Zeichnung
    @Published var drawing: PKDrawing = PKDrawing()

    /// Zeigt an ob der Tool Picker sichtbar ist
    @Published var showToolPicker: Bool = true

    /// Zeigt an ob es ungespeicherte Änderungen gibt
    @Published var hasUnsavedChanges: Bool = false

    /// Aktuelle Stiftfarbe
    @Published var selectedColor: Color = .black

    /// Aktuelle Stiftbreite
    @Published var strokeWidth: CGFloat = 5.0

    /// Aktuelles Werkzeug
    @Published var selectedTool: DrawingTool = .pen

    /// Hintergrundfarbe der Zeichenfläche
    @Published var canvasBackgroundColor: UIColor = .white

    /// Fehler
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    // MARK: - Undo/Redo

    private var undoStack: [PKDrawing] = []
    private var redoStack: [PKDrawing] = []
    private var isUndoRedoAction: Bool = false

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    /// Die ID des Medienelements (nil = neue Zeichnung)
    private(set) var mediaItemID: UUID?

    init(mediaItemID: UUID? = nil) {
        self.mediaItemID = mediaItemID
    }

    // MARK: - Public Methods

    /// Wird aufgerufen wenn sich die Zeichnung ändert
    func drawingDidChange(_ newDrawing: PKDrawing) {
        if !isUndoRedoAction {
            undoStack.append(drawing)
            redoStack.removeAll()

            // Begrenze Stack-Größe
            if undoStack.count > 30 {
                undoStack.removeFirst()
            }
        }

        drawing = newDrawing
        hasUnsavedChanges = true
    }

    /// Macht die letzte Änderung rückgängig
    func undo() {
        guard let previousDrawing = undoStack.popLast() else { return }
        isUndoRedoAction = true
        redoStack.append(drawing)
        drawing = previousDrawing
        hasUnsavedChanges = true
        isUndoRedoAction = false
    }

    /// Stellt die letzte rückgängig gemachte Änderung wieder her
    func redo() {
        guard let nextDrawing = redoStack.popLast() else { return }
        isUndoRedoAction = true
        undoStack.append(drawing)
        drawing = nextDrawing
        hasUnsavedChanges = true
        isUndoRedoAction = false
    }

    /// Löscht die gesamte Zeichnung
    func clearCanvas() {
        undoStack.append(drawing)
        redoStack.removeAll()
        drawing = PKDrawing()
        hasUnsavedChanges = true
    }

    /// Setzt den gespeicherten Zustand (nach dem Laden)
    func setInitialDrawing(_ drawing: PKDrawing) {
        self.drawing = drawing
        self.hasUnsavedChanges = false
        self.undoStack.removeAll()
        self.redoStack.removeAll()
    }

    /// Markiert als gespeichert
    func markAsSaved() {
        hasUnsavedChanges = false
    }

    // MARK: - Private Methods

    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Zeichenwerkzeuge

/// Verfügbare Zeichenwerkzeuge
enum DrawingTool: String, CaseIterable, Identifiable {
    case pen = "Stift"
    case marker = "Marker"
    case eraser = "Radierer"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .pen: return "pencil.tip"
        case .marker: return "highlighter"
        case .eraser: return "eraser"
        }
    }
}
