//
//  SettingsView.swift
//  Schreiben 2.0
//
//  Einstellungen der App: TTS, Darstellung, Info
//

import SwiftUI
import AVFoundation

/// Einstellungsseite
struct SettingsView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        Form {
            ttsSection
            readingModeSection
            displaySection
            infoSection
        }
        .navigationTitle("Einstellungen")
    }

    // MARK: - TTS-Einstellungen

    private var ttsSection: some View {
        Section(header: Text("Lautierung")) {
            Toggle("Sprachausgabe aktiviert", isOn: Binding(
                get: { coordinator.ttsService.isEnabled },
                set: { coordinator.ttsService.isEnabled = $0 }
            ))

            if coordinator.ttsService.isEnabled {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Geschwindigkeit: \(Int(coordinator.ttsService.rate * 100))%")
                        .font(.subheadline)
                    Slider(
                        value: Binding(
                            get: { coordinator.ttsService.rate },
                            set: { coordinator.ttsService.rate = $0 }
                        ),
                        in: 0.1...1.0,
                        step: 0.05
                    )
                }

                VoicePicker(
                    selectedVoiceID: Binding(
                        get: { coordinator.ttsService.selectedVoiceID },
                        set: { coordinator.ttsService.selectedVoiceID = $0 }
                    ),
                    voices: coordinator.ttsService.availableGermanVoices()
                )
            }
        }
    }

    // MARK: - Vorlese-Modus

    private var readingModeSection: some View {
        Section(header: Text("Vorlese-Modus")) {
            Picker("Modus", selection: Binding(
                get: { coordinator.ttsService.readingMode },
                set: { coordinator.ttsService.readingMode = $0 }
            )) {
                ForEach(ReadingMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            switch coordinator.ttsService.readingMode {
            case .letter:
                Text("Jeder eingegebene Buchstabe wird vorgelesen.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            case .word:
                Text("Jedes abgeschlossene Wort wird vorgelesen.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            case .off:
                Text("Automatische Lautierung ist deaktiviert.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Darstellung

    private var displaySection: some View {
        Section(header: Text("Darstellung")) {
            Text("Schriftgröße und Zeilenlinien können im Editor angepasst werden.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Info

    private var infoSection: some View {
        Section(header: Text("Info")) {
            HStack {
                Text("Version")
                Spacer()
                Text("2.0 – Phase 4")
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("App")
                Spacer()
                Text("Schreiben 2.0")
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Voice Picker

/// Auswahl der Stimme aus verfügbaren deutschen Stimmen
private struct VoicePicker: View {
    @Binding var selectedVoiceID: String?
    let voices: [AVSpeechSynthesisVoice]

    var body: some View {
        Picker("Stimme", selection: $selectedVoiceID) {
            Text("Standard").tag(nil as String?)
            ForEach(voices, id: \.identifier) { voice in
                Text(voiceDisplayName(voice)).tag(voice.identifier as String?)
            }
        }
    }

    private func voiceDisplayName(_ voice: AVSpeechSynthesisVoice) -> String {
        let quality = voice.quality == .enhanced ? " (Erweitert)" : ""
        return "\(voice.name)\(quality)"
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let coordinator = AppCoordinator()
        NavigationView {
            SettingsView()
                .environmentObject(coordinator)
        }
    }
}
