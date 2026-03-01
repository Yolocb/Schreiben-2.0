//
//  SettingsView.swift
//  Schreiben 2.0
//
//  Einstellungen der App (Platzhalter für Phase 4+)
//

import SwiftUI

/// Einstellungsseite
struct SettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Allgemein")) {
                Text("Einstellungen werden in späteren Phasen implementiert")
                    .foregroundColor(.secondary)
            }

            Section(header: Text("Text-to-Speech")) {
                Text("TTS-Einstellungen folgen in Phase 4")
                    .foregroundColor(.secondary)
            }

            Section(header: Text("Darstellung")) {
                Text("Schriftgröße und weitere Optionen folgen in Phase 3")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Einstellungen")
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
