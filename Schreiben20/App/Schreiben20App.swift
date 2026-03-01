//
//  Schreiben20App.swift
//  Schreiben 2.0
//
//  Entry-Point der App mit SwiftUI-Lifecycle
//

import SwiftUI

@main
struct Schreiben20App: App {
    // Persistence Controller für Core Data
    let persistenceController = PersistenceController.shared

    // StateObject für zentrale App-Koordination
    @StateObject private var coordinator: AppCoordinator

    init() {
        // Initialisiere Coordinator mit Core Data
        let service = DocumentService(persistenceController: PersistenceController.shared)
        _coordinator = StateObject(wrappedValue: AppCoordinator(documentService: service))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coordinator)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

/// Haupt-Content-View mit Navigation
struct ContentView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        NavigationView {
            DocumentListView()
                .navigationTitle("Meine Dokumente")
        }
        .navigationViewStyle(.stack)
    }
}
