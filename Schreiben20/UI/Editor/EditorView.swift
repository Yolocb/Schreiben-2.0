//
//  EditorView.swift
//  Schreiben 2.0
//
//  Editor-Ansicht für ein Dokument (Platzhalter für Phase 3)
//

import SwiftUI

/// Editor für ein einzelnes Dokument
struct EditorView: View {
    let documentID: UUID
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: EditorViewModel

    init(documentID: UUID) {
        self.documentID = documentID
        _viewModel = StateObject(wrappedValue: EditorViewModel(documentID: documentID))
    }

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                // Loading-State
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Dokument wird geladen...")
                        .foregroundColor(.secondary)
                }
            } else if let document = viewModel.document {
                // Dokument gefunden
                VStack {
                    Text("Editor für: \(document.title)")
                        .font(.title)
                        .padding()

                    Text("Textinhalt wird in Phase 3 implementiert")
                        .foregroundColor(.secondary)
                        .padding()
                }
            } else {
                // Dokument nicht gefunden
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    Text("Dokument nicht gefunden")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Editor")
        .alert("Fehler", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {
                viewModel.showError = false
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            viewModel.setDocumentService(coordinator.documentService)
        }
    }
}

// MARK: - Preview

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController.preview
        let documentService = DocumentService(persistenceController: persistenceController)
        let coordinator = AppCoordinator(documentService: documentService)
        let doc = documentService.createDocument(title: "Test-Dokument")

        return NavigationView {
            EditorView(documentID: doc.id)
                .environmentObject(coordinator)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
