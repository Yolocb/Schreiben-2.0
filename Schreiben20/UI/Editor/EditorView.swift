//
//  EditorView.swift
//  Schreiben 2.0
//
//  Editor-Ansicht mit Textbearbeitung, Formatierung und Zeilenlinien
//

import SwiftUI

/// Editor für ein einzelnes Dokument
struct EditorView: View {
    let documentID: UUID
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: EditorViewModel
    @State private var isEditingTitle: Bool = false
    @State private var editedTitle: String = ""
    @FocusState private var isTextEditorFocused: Bool

    init(documentID: UUID) {
        self.documentID = documentID
        _viewModel = StateObject(wrappedValue: EditorViewModel(documentID: documentID))
    }

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.document != nil {
                editorContent
            } else {
                ErrorStateView()
            }

            // Speicher-Indikator
            if viewModel.showSaveIndicator {
                SaveIndicator()
            }
        }
        .navigationTitle(viewModel.document?.title ?? "Editor")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { editorToolbar }
        .alert("Fehler", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {
                viewModel.showError = false
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        // Titel bearbeiten Alert
        .alert("Titel bearbeiten", isPresented: $isEditingTitle) {
            TextField("Dokumenttitel", text: $editedTitle)
            Button("Abbrechen", role: .cancel) { }
            Button("Speichern") {
                viewModel.updateTitle(editedTitle)
            }
        } message: {
            Text("Gib einen neuen Titel für das Dokument ein.")
        }
        .onAppear {
            viewModel.setDocumentService(coordinator.documentService)
        }
        .onDisappear {
            viewModel.saveOnDisappear()
        }
    }

    // MARK: - Editor Content

    private var editorContent: some View {
        VStack(spacing: 0) {
            // Statistik-Leiste
            StatisticsBar(
                wordCount: viewModel.wordCount,
                characterCount: viewModel.characterCount,
                hasUnsavedChanges: viewModel.hasUnsavedChanges
            )

            // Text-Editor mit optionalen Zeilenlinien
            ZStack(alignment: .topLeading) {
                if viewModel.showLineGuides {
                    LineGuidesView(
                        fontSize: viewModel.fontSize,
                        lineSpacing: viewModel.fontSize * 0.5
                    )
                }

                TextEditor(text: $viewModel.textContent)
                    .font(.system(size: viewModel.fontSize))
                    .lineSpacing(viewModel.fontSize * 0.5)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .focused($isTextEditorFocused)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }
            .background(Color(UIColor.systemBackground))
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var editorToolbar: some ToolbarContent {
        // Linke Seite: Titel bearbeiten
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                editedTitle = viewModel.document?.title ?? ""
                isEditingTitle = true
            } label: {
                Image(systemName: "pencil")
            }
        }

        // Mitte: Schriftgröße und Zeilenlinien
        ToolbarItemGroup(placement: .secondaryAction) {
            // Schriftgröße
            Menu {
                Button {
                    viewModel.increaseFontSize()
                } label: {
                    Label("Größer", systemImage: "textformat.size.larger")
                }
                .disabled(viewModel.fontSize >= 48)

                Button {
                    viewModel.decreaseFontSize()
                } label: {
                    Label("Kleiner", systemImage: "textformat.size.smaller")
                }
                .disabled(viewModel.fontSize <= 16)

                Divider()

                Text("Schriftgröße: \(Int(viewModel.fontSize))pt")
            } label: {
                Label("Schriftgröße", systemImage: "textformat.size")
            }

            // Zeilenlinien Toggle
            Button {
                viewModel.showLineGuides.toggle()
            } label: {
                Label(
                    viewModel.showLineGuides ? "Linien ausblenden" : "Linien einblenden",
                    systemImage: viewModel.showLineGuides ? "line.3.horizontal" : "line.3.horizontal"
                )
            }
        }

        // Rechte Seite: Undo/Redo und Speichern
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            // Undo
            Button {
                viewModel.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward")
            }
            .disabled(!viewModel.canUndo)

            // Redo
            Button {
                viewModel.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward")
            }
            .disabled(!viewModel.canRedo)

            // Speichern
            Button {
                viewModel.saveDocument()
            } label: {
                Image(systemName: viewModel.hasUnsavedChanges ? "square.and.arrow.down.fill" : "square.and.arrow.down")
            }
            .disabled(!viewModel.hasUnsavedChanges)
        }
    }
}

// MARK: - Subviews

/// Loading-Ansicht
private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Dokument wird geladen...")
                .foregroundColor(.secondary)
        }
    }
}

/// Fehler-Ansicht
private struct ErrorStateView: View {
    var body: some View {
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

/// Speicher-Indikator
private struct SaveIndicator: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Gespeichert")
                    .font(.subheadline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
            .shadow(radius: 4)
            .padding(.bottom, 32)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut, value: true)
    }
}

/// Statistik-Leiste
private struct StatisticsBar: View {
    let wordCount: Int
    let characterCount: Int
    let hasUnsavedChanges: Bool

    var body: some View {
        HStack {
            HStack(spacing: 16) {
                Label("\(wordCount) Wörter", systemImage: "text.word.spacing")
                Label("\(characterCount) Zeichen", systemImage: "character.cursor.ibeam")
            }
            .font(.caption)
            .foregroundColor(.secondary)

            Spacer()

            if hasUnsavedChanges {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                    Text("Nicht gespeichert")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemBackground))
    }
}

/// Zeilenlinien-Hintergrund
private struct LineGuidesView: View {
    let fontSize: CGFloat
    let lineSpacing: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let lineHeight = fontSize + lineSpacing
            let numberOfLines = Int(geometry.size.height / lineHeight) + 1

            VStack(spacing: 0) {
                ForEach(0..<numberOfLines, id: \.self) { _ in
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 1)
                    }
                    .frame(height: lineHeight)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8 + fontSize * 0.8) // Offset für erste Zeile
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
