//
//  DocumentListView.swift
//  Schreiben 2.0
//
//  Liste aller Dokumente mit Verwaltungsfunktionen
//

import SwiftUI

/// Hauptansicht mit allen Dokumenten
struct DocumentListView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = DocumentListViewModel()

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                // Loading-State
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Dokumente werden geladen...")
                        .foregroundColor(.secondary)
                }
            } else if viewModel.documents.isEmpty {
                // Leerer Zustand
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("Keine Dokumente")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Tippe auf + um ein neues Dokument zu erstellen")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                // Dokumentenliste
                List {
                    ForEach(viewModel.documents) { document in
                        NavigationLink(destination: EditorView(documentID: document.id)) {
                            DocumentRow(document: document)
                        }
                        .onTapGesture(count: 2) {
                            viewModel.prepareRename(document)
                        }
                    }
                    .onDelete(perform: viewModel.prepareDelete)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: viewModel.createNewDocument) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                }
            }
        }
        .alert("Fehler", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {
                viewModel.showError = false
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        // Lösch-Bestätigungsdialog
        .confirmationDialog(
            "Dokument löschen?",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Löschen", role: .destructive) {
                viewModel.confirmDelete()
            }
            Button("Abbrechen", role: .cancel) {
                viewModel.cancelDelete()
            }
        } message: {
            if let document = viewModel.selectedDocument {
                Text("\"\(document.title)\" wird unwiderruflich gelöscht.")
            }
        }
        // Umbenennen-Dialog
        .alert("Dokument umbenennen", isPresented: $viewModel.showRenameDialog) {
            TextField("Neuer Name", text: $viewModel.newDocumentName)
            Button("Abbrechen", role: .cancel) {
                viewModel.cancelRename()
            }
            Button("Speichern") {
                viewModel.confirmRename()
            }
        } message: {
            Text("Gib einen neuen Namen für das Dokument ein.")
        }
        .onAppear {
            // Injiziere den Service aus dem Coordinator
            viewModel.setDocumentService(coordinator.documentService)
        }
    }
}

/// Zeile für ein einzelnes Dokument
struct DocumentRow: View {
    let document: Document

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(document.title)
                .font(.headline)

            Text("Erstellt: \(document.createdAt, formatter: Self.dateFormatter)")
                .font(.caption)
                .foregroundColor(.secondary)

            if document.updatedAt.timeIntervalSince(document.createdAt) > 1 {
                Text("Geändert: \(document.updatedAt, formatter: Self.dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Previews

struct DocumentListView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController.preview
        let documentService = DocumentService(persistenceController: persistenceController)
        let coordinator = AppCoordinator(documentService: documentService)

        return NavigationView {
            DocumentListView()
                .environmentObject(coordinator)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
