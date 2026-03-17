//
//  MediaGalleryView.swift
//  Schreiben 2.0
//
//  Horizontale Thumbnail-Leiste für Medienelemente
//

import SwiftUI

/// Horizontale Galerie-Ansicht für Medienelemente eines Dokuments
struct MediaGalleryView: View {
    let mediaItems: [MediaItem]
    let mediaService: MediaService
    var onTapItem: (MediaItem) -> Void
    var onDeleteItem: (MediaItem) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(mediaItems) { item in
                        MediaItemThumbnailView(
                            mediaItem: item,
                            mediaService: mediaService,
                            onTap: { onTapItem(item) },
                            onDelete: { onDeleteItem(item) }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .frame(height: 120)
            .background(Color(UIColor.secondarySystemBackground))
        }
    }
}

/// Einzelnes Thumbnail in der Galerie
struct MediaItemThumbnailView: View {
    let mediaItem: MediaItem
    let mediaService: MediaService
    var onTap: () -> Void
    var onDelete: () -> Void

    @State private var thumbnail: UIImage?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onTap) {
                Group {
                    if let thumbnail = thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        ZStack {
                            Color.gray.opacity(0.2)
                            Image(systemName: mediaItem.type == .photo ? "photo" : "pencil.tip.crop.circle")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Lösch-Button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.red).frame(width: 20, height: 20))
            }
            .offset(x: 4, y: -4)
        }
        .onAppear {
            thumbnail = mediaService.loadThumbnail(for: mediaItem)
        }
    }
}
