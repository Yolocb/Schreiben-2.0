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

    init(documentService: DocumentService = DocumentService()) {
        self.documentService = documentService
    }
}
