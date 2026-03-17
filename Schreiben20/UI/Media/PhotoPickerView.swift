//
//  PhotoPickerView.swift
//  Schreiben 2.0
//
//  SwiftUI-Wrapper für PHPickerViewController
//

import SwiftUI
import PhotosUI

/// Photo Picker zum Auswählen von Bildern aus der Bibliothek
struct PhotoPickerView: UIViewControllerRepresentable {
    var onImagePicked: (UIImage) -> Void
    var onDismiss: () -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView

        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let result = results.first else {
                parent.onDismiss()
                return
            }

            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                DispatchQueue.main.async {
                    if let image = object as? UIImage {
                        self?.parent.onImagePicked(image)
                    }
                    self?.parent.onDismiss()
                }
            }
        }
    }
}
