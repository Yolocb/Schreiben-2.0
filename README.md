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
│   ├── Models/            # Datenmodelle (Document, Task, MediaItem)
│   ├── Persistence/       # Core Data (Document-, Task-, MediaItemEntity)
│   └── Services/          # Services (DocumentService, TTSService, ImageStorageService, MediaService)
├── UI/                     # SwiftUI-Views und ViewModels
│   ├── DocumentList/      # Dokumentenliste
│   ├── Drawing/           # PencilKit-Zeichenfläche + Toolbar
│   ├── Editor/            # Texteditor mit Medien-Integration
│   ├── Media/             # PhotoPicker, Galerie, Detailansicht
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

### ✅ Phase 4: Lautierende Tastatur & TTS (Abgeschlossen)
- AVSpeechSynthesizer-Integration (de-DE)
- 3 Vorlese-Modi: Buchstabe, Wort, Aus
- Geschwindigkeits-Slider + Stimmenauswahl
- TTS-Toolbar im Editor (Play/Stop, Toggle)
- SettingsView mit TTS-Einstellungen
- 11 neue Unit-Tests

### ✅ Phase 5: Bilder & Zeichnen (Abgeschlossen)
- PhotoPicker-Integration (PHPickerViewController)
- PencilKit-Zeichenfläche mit Toolbar (Stift, Marker, Radierer, 8 Farben)
- ImageStorageService (JPEG 0.8, max 2048px, Thumbnails 200px)
- MediaItem-Datenmodell (Photo + Drawing Typen)
- MediaItemEntity (Core Data, geordnete Beziehung zu DocumentEntity)
- MediaService (High-Level Coordinator)
- Horizontale Medien-Galerie im Editor
- Vollbild-Medienansicht (MediaDetailView)
- Undo/Redo für Zeichnungen (30 Einträge)
- ~34 neue Tests (MediaItem, ImageStorage, Drawing, Editor-Media)

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
- **Zeichnen**: PencilKit
- **Fotos**: PhotosUI (PHPickerViewController)
- **Tests**: XCTest
- **Zielplattform**: iPadOS 16.0+

## 📦 Installation

1. Repository klonen oder Projektordner öffnen
2. `Schreiben20.xcodeproj` in Xcode öffnen
3. iPad-Simulator auswählen
4. `cmd + R` zum Starten

## 🎯 Aktuelle Features (Phase 5)

- ✅ App startet mit SwiftUI-Lifecycle
- ✅ Navigation zwischen Dokumentliste, Editor und Einstellungen
- ✅ Datenmodell für Dokumente mit ID, Titel, Datum, Text, Medien und Aufgaben
- ✅ DocumentService mit CRUD-Operationen
- ✅ Core Data Persistenz mit Migration
- ✅ Swipe-to-Delete mit Bestätigungsdialog
- ✅ Umbenennen per Doppeltipp
- ✅ Vollwertiger Texteditor mit anpassbarer Schriftgröße
- ✅ Zeilenlinien-Hintergrund für bessere Orientierung
- ✅ Undo/Redo-Funktionalität
- ✅ Wort- und Zeichenzähler
- ✅ Auto-Save (30s Intervall + beim Verlassen)
- ✅ Lautierende Tastatur (Buchstabe/Wort/Aus)
- ✅ Text-to-Speech mit Geschwindigkeits- und Stimmenauswahl
- ✅ Photo Picker zum Einfügen von Fotos
- ✅ PencilKit-Zeichenfläche mit Werkzeug- und Farbauswahl
- ✅ Medien-Galerie im Editor (horizontale Thumbnail-Leiste)
- ✅ Vollbild-Medienansicht
- ✅ Error-Handling und Loading-States
- ✅ Unit-Tests für Modelle, ViewModels und Services
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

**Status**: Phase 5 abgeschlossen ✅ | Nächste Phase: Export & Teilen
