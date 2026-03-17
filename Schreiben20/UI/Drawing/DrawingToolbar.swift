//
//  DrawingToolbar.swift
//  Schreiben 2.0
//
//  Toolbar für die Zeichenfunktion mit Werkzeug- und Farbauswahl
//

import SwiftUI

/// Toolbar für Zeichenwerkzeuge
struct DrawingToolbar: View {
    @ObservedObject var viewModel: DrawingCanvasViewModel
    var onSave: () -> Void
    var onDismiss: () -> Void

    /// Verfügbare Farben für Kinder
    private let colors: [Color] = [
        .black, .red, .blue, .green, .orange, .purple, .brown, .yellow
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Obere Leiste: Werkzeuge + Aktionen
            HStack {
                // Schließen
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Werkzeug-Auswahl
                HStack(spacing: 12) {
                    ForEach(DrawingTool.allCases) { tool in
                        Button {
                            viewModel.selectedTool = tool
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: tool.systemImage)
                                    .font(.title3)
                                Text(tool.rawValue)
                                    .font(.caption2)
                            }
                            .foregroundColor(viewModel.selectedTool == tool ? .accentColor : .secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(viewModel.selectedTool == tool ?
                                          Color.accentColor.opacity(0.15) : Color.clear)
                            )
                        }
                    }
                }

                Spacer()

                // Aktionen
                HStack(spacing: 16) {
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

                    // Alles löschen
                    Button {
                        viewModel.clearCanvas()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }

                    // Speichern
                    Button {
                        onSave()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(UIColor.secondarySystemBackground))

            // Farbleiste
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(colors, id: \.self) { color in
                        Button {
                            viewModel.selectedColor = color
                        } label: {
                            Circle()
                                .fill(color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: viewModel.selectedColor == color ? 3 : 0)
                                )
                                .shadow(radius: 1)
                        }
                    }

                    Divider()
                        .frame(height: 32)

                    // Strichstärke
                    HStack(spacing: 8) {
                        Image(systemName: "line.diagonal")
                            .font(.caption)
                        Slider(value: $viewModel.strokeWidth, in: 1...20, step: 1)
                            .frame(width: 100)
                        Text("\(Int(viewModel.strokeWidth))")
                            .font(.caption)
                            .frame(width: 24)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(Color(UIColor.tertiarySystemBackground))
        }
    }
}
