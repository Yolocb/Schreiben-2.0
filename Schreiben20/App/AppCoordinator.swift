//
//  AppCoordinator.swift
//  Schreiben 2.0
//
//  Zentrale Koordination der App-Navigation und Services
//

import SwiftUI
import Combine

/// Koordiniert Navigation und hält zentrale Services
class AppCoordinator: ObservableObject {
    // Service für Dokumentenverwaltung
    let documentService: DocumentService

    // Service für Text-to-Speech / Lautierung
    let ttsService: TTSService

    // Service für Bildspeicherung im Dateisystem
    let imageStorageService: ImageStorageService

    // Service für Medienoperationen (High-Level Coordinator)
    let mediaService: MediaService

    init(documentService: DocumentService = DocumentService(),
         ttsService: TTSService = TTSService(),
         imageStorageService: ImageStorageService = ImageStorageService()) {
        self.documentService = documentService
        self.ttsService = ttsService
        self.imageStorageService = imageStorageService
        self.mediaService = MediaService(imageStorageService: imageStorageService, documentService: documentService)
    }
}
