# Schreiben 2.0

Eine iPad-App zum Schreibenlernen für Kinder mit lautierender Tastatur, Text-to-Speech und einfacher Dokumentverwaltung.

## 📋 Projektübersicht

**Schreiben 2.0** ist eine Lern-App für iPadOS, die Kindern beim Schreibenlernen hilft durch:
- ✍️ Lautierende Tastatur (jeder Buchstabe wird vorgelesen)
- 🔊 Text-to-Speech mit anpassbarer Geschwindigkeit
- 📄 Einfache Dokumentverwaltung
- 🖼️ Bilder einfügen und Zeichnen
- 📝 Wortmarkierung und Übungsaufgaben
- ♿ Barrierefreiheit (VoiceOver, Dynamic Type)

## 🏗️ Architektur

Das Projekt folgt dem **MVVM-Pattern** (Model-View-ViewModel) mit klarer Modultrennung:

```
Schreiben20/
├── App/                    # App-Entry-Point, Koordination
├── Core/                   # Geschäftslogik, Modelle
│   ├── Models/            # Datenmodelle (Document, Task)
│   └── Services/          # Services (DocumentService, TTSService)
├── UI/                     # SwiftUI-Views und ViewModels
│   ├── DocumentList/      # Dokumentenliste
│   ├── Editor/            # Texteditor
│   └── Settings/          # Einstellungen
└── Resources/             # Assets, Lokalisierung
```

## 🚀 Entwicklungsphasen

### ✅ Phase 1: Projekt-Setup & Architektur (Abgeschlossen)
- Grundlegende Projektstruktur
- Navigation zwischen Views
- Datenmodell für Dokumente
- Unit-Tests und UI-Tests

### ✅ Phase 2: Dokumentliste & Verwaltung (Abgeschlossen)
- Swipe-to-Delete mit Bestätigungsdialog
- Umbenennen per Doppeltipp
- Core Data Persistenz
- 10 neue Unit-Tests für Verwaltungsfunktionen

### ✅ Phase 3: Texteditor & Schreiboberfläche (Abgeschlossen)
- Vollwertiger Texteditor mit großer Schrift (16-48pt)
- Zeilenlinien-Hintergrund (ein/aus schaltbar)
- Undo/Redo-Funktionalität
- Wort- und Zeichenzähler
- Auto-Save alle 30 Sekunden + beim Verlassen
- Titel direkt im Editor bearbeitbar
- 18 neue Unit-Tests für Editor-Funktionen

### 📅 Phase 4: Lautierende Tastatur & TTS
- AVSpeechSynthesizer-Integration
- Lautierung pro Buchstabe/Wort
- Externe Tastatur-Unterstützung

### 📅 Phase 5: Bilder & Zeichnen
- PhotoPicker-Integration
- Canvas zum Zeichnen

### 📅 Phase 6: Export & Teilen
- PDF/Bild-Export
- iOS Share-Sheet

### 📅 Phase 7: Wortmarkierung & Aufgaben
- Wort-Auswahl und Markierung
- Übungsaufgaben

### 📅 Phase 8: Inklusion & Barrierefreiheit
- VoiceOver-Support
- Dynamic Type, Kontraste
- Fokus-Modus

### 📅 Phase 9: Lokalisierung & Release
- Deutsche Lokalisierung
- Vorbereitung für weitere Sprachen

## 🧪 Tests

Das Projekt enthält umfassende Test-Coverage:

### Unit-Tests
- `DocumentTests.swift` - Tests für Datenmodelle und DocumentService

### UI-Tests
- `AppLaunchTests.swift` - Tests für App-Start und Navigation

### Tests ausführen
```bash
# Alle Tests
cmd + U in Xcode

# Nur Unit-Tests
xcodebuild test -scheme Schreiben20 -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch)'

# Nur UI-Tests
xcodebuild test -scheme Schreiben20 -only-testing:Schreiben20UITests
```

## 🛠️ Technologie-Stack

- **Sprache**: Swift 5.9+
- **UI-Framework**: SwiftUI
- **Architektur**: MVVM
- **Persistenz**: Core Data
- **TTS**: AVSpeechSynthesizer
- **Tests**: XCTest
- **Zielplattform**: iPadOS 16.0+

## 📦 Installation

1. Repository klonen oder Projektordner öffnen
2. `Schreiben20.xcodeproj` in Xcode öffnen
3. iPad-Simulator auswählen
4. `cmd + R` zum Starten

## 🎯 Aktuelle Features (Phase 3)

- ✅ App startet mit SwiftUI-Lifecycle
- ✅ Navigation zwischen Dokumentliste, Editor und Einstellungen
- ✅ Datenmodell für Dokumente mit ID, Titel, Datum, Text, Bildern und Aufgaben
- ✅ DocumentService mit CRUD-Operationen
- ✅ Core Data Persistenz mit Migration
- ✅ Swipe-to-Delete mit Bestätigungsdialog
- ✅ Umbenennen per Doppeltipp
- ✅ Vollwertiger Texteditor mit anpassbarer Schriftgröße
- ✅ Zeilenlinien-Hintergrund für bessere Orientierung
- ✅ Undo/Redo-Funktionalität
- ✅ Wort- und Zeichenzähler
- ✅ Auto-Save (30s Intervall + beim Verlassen)
- ✅ Error-Handling und Loading-States
- ✅ Unit-Tests für Modelle und ViewModels
- ✅ UI-Tests für App-Launch und Navigation

## 📝 Commit-Richtlinien

Alle Commits folgen dem Schema:
```
[Phase X] Kurzbeschreibung auf Deutsch

Detaillierte Beschreibung der Änderungen.
```

Beispiel:
```
[Phase 1] Projekt-Setup und Grundarchitektur

- Xcode-Projekt erstellt mit SwiftUI-Lifecycle
- MVVM-Architektur mit App, Core und UI Modulen
- Document- und Task-Datenmodelle
- DocumentService für CRUD-Operationen
- Unit-Tests und UI-Tests
```

## 👥 Team

Entwickelt als Multi-Agent-System:
- **Architektur-Agent**: Projektstruktur, Patterns
- **iOS-UI-Agent**: SwiftUI-Views, Navigation
- **TTS-Agent**: Text-to-Speech-Integration
- **Test-Agent**: Unit- und UI-Tests
- **DevOps-Agent**: Build, CI/CD

## 📄 Lizenz

Dieses Projekt ist ein Lern- und Demonstrationsprojekt.

---

**Status**: Phase 3 abgeschlossen ✅ | Nächste Phase: Lautierende Tastatur & TTS
