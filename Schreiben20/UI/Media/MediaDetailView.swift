//
//  MediaDetailView.swift
//  Schreiben 2.0
//
//  Vollbild-Ansicht für ein einzelnes Medienelement
//

import SwiftUI

/// Zeigt ein Medienelement in voller Größe an
struct MediaDetailView: View {
    let mediaItem: MediaItem
    let mediaService: MediaService
    @Environment(\.dismiss) private var dismiss

    @State private var fullImage: UIImage?

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()

                if let image = fullImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                } else {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Bild wird geladen...")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(mediaItem.caption.isEmpty ? (mediaItem.type == .photo ? "Foto" : "Zeichnung") : mediaItem.caption)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadFullImage()
        }
    }

    private func loadFullImage() {
        fullImage = mediaService.loadFullImage(for: mediaItem)
    }
}
