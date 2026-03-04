# Session Context - Schreiben 2.0

**Datum:** 2026-03-04
**Status:** Phase 4 abgeschlossen ✅
**Nächster Schritt:** Phase 5 - Erweiterte Features

---

## 📋 Projekt-Übersicht

**Schreiben 2.0** ist eine iPad-App zum Schreibenlernen für Kinder.

**Repository:** https://github.com/Yolocb/Schreiben-2.0
**Branch:** main
**Letzter Commit:** `f2a4200` - [Phase 3] Texteditor & Schreiboberfläche

---

## ✅ Abgeschlossene Phasen

### Phase 1: Projekt-Setup & Architektur
- MVVM-Architektur mit SwiftUI
- Core Data Persistenz
- AppCoordinator für Dependency Injection
- Grundlegende Navigation

### Phase 2: Dokumentenverwaltung
- Swipe-to-Delete mit Bestätigungsdialog
- Umbenennen per Doppeltipp
- 10 Unit-Tests

### Phase 3: Texteditor & Schreiboberfläche
- Vollwertiger TextEditor (16-48pt Schriftgröße)
- Zeilenlinien-Hintergrund
- Undo/Redo-System (50 Einträge)
- Auto-Save (30s + onDisappear)
- Wort-/Zeichenzähler
- Titel-Bearbeitung im Editor
- 9 neue Unit-Tests

---

## 🧪 Test-Status

**Gesamt: 53 Tests ✅**

| Test-Datei | Anzahl |
|------------|--------|
| DocumentTests.swift | 10 |
| DocumentListViewModelTests.swift | 20 |
| EditorViewModelTests.swift | 18 |
| AppLaunchTests.swift (UI) | 5 |

---

## 🚀 Phase 4: Lautierende Tastatur & TTS

### Ziele

1. **TTSService erstellen**
   - AVSpeechSynthesizer Integration
   - Deutsche Stimme
   - Anpassbare Geschwindigkeit

2. **Lautierungs-Modi**
   - Buchstabe für Buchstabe vorlesen
   - Wort für Wort vorlesen
   - Ganzen Text vorlesen

3. **Tastatur-Integration**
   - Jeden Tastendruck vorlesen
   - Externe Tastatur unterstützen

4. **Einstellungen**
   - Lautierung ein/aus
   - Geschwindigkeit wählen
   - Stimme auswählen

### Implementierungs-Plan

```swift
// 1. Neuer Service: Core/Services/TTSService.swift
class TTSService: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    @Published var isEnabled: Bool = true
    @Published var rate: Float = 0.4  // 0.0-1.0

    func speakLetter(_ letter: String)
    func speakWord(_ word: String)
    func speakText(_ text: String)
    func stop()
}

// 2. AppCoordinator erweitern
class AppCoordinator: ObservableObject {
    let documentService: DocumentService
    let ttsService: TTSService  // NEU
}

// 3. EditorViewModel erweitern
- TTSService injizieren
- Bei Texteingabe: Buchstaben/Wort vorlesen
- Toolbar-Button für TTS

// 4. SettingsView implementieren
- TTS ein/aus Toggle
- Geschwindigkeits-Slider
- Stimmen-Auswahl
```

### Dateien zu erstellen/ändern

| Datei | Aktion |
|-------|--------|
| `Core/Services/TTSService.swift` | Neu erstellen |
| `App/AppCoordinator.swift` | TTSService hinzufügen |
| `UI/Editor/EditorViewModel.swift` | TTS-Integration |
| `UI/Editor/EditorView.swift` | TTS-Toolbar |
| `UI/Settings/SettingsView.swift` | TTS-Einstellungen |
| `Tests/TTSServiceTests.swift` | Neu erstellen |

---

## 📁 Aktuelle Projektstruktur

```
Schreiben20/
├── App/
│   ├── AppCoordinator.swift
│   └── Schreiben20App.swift
├── Core/
│   ├── Models/
│   │   └── Document.swift
│   ├── Persistence/
│   │   ├── PersistenceController.swift
│   │   ├── DocumentEntity+CoreDataClass.swift
│   │   ├── DocumentEntity+CoreDataProperties.swift
│   │   ├── TaskEntity+CoreDataClass.swift
│   │   └── TaskEntity+CoreDataProperties.swift
│   └── Services/
│       └── DocumentService.swift
└── UI/
    ├── DocumentList/
    │   ├── DocumentListView.swift
    │   └── DocumentListViewModel.swift
    ├── Editor/
    │   ├── EditorView.swift
    │   └── EditorViewModel.swift
    └── Settings/
        └── SettingsView.swift
```

---

## 💡 Quick-Start für nächste Session

Starte mit diesem Kommando:
```
"Lass uns mit Phase 4 weitermachen: Lautierende Tastatur und Text-to-Speech"
```

### Erste Schritte in Phase 4:

1. **TTSService erstellen** - Grundgerüst mit AVSpeechSynthesizer
2. **AppCoordinator erweitern** - TTSService injizieren
3. **SettingsView implementieren** - TTS-Einstellungen UI
4. **Editor integrieren** - Buchstaben bei Eingabe vorlesen
5. **Tests schreiben** - TTSService testen

---

## ⚠️ Wichtige Hinweise

### Xcode-Projekt
- Das `.xcodeproj` muss auf einem Mac erstellt werden
- Alle Swift-Dateien sind vorhanden und getestet (Code-Review)
- Core Data Model (.xcdatamodeld) muss in Xcode geöffnet werden

### ViewModel-Pattern (WICHTIG!)
```swift
// ViewModels werden OHNE Service erstellt
let viewModel = EditorViewModel(documentID: id)

// Service wird im onAppear gesetzt
viewModel.setDocumentService(coordinator.documentService)
```

### UserDefaults Keys
- `schreiben20.fontSize` - Schriftgröße (Double)
- `schreiben20.showLineGuides` - Zeilenlinien (Bool)
- `schreiben20.migrated_to_coredata` - Migration-Flag

---

## 📊 Git-Historie

```
f2a4200 [Phase 3] Texteditor & Schreiboberfläche
2e09899 [Phase 2] Dokumentenverwaltung: Löschen und Umbenennen
be52405 Docs: Session Context für nächste Arbeitseinheit
6e60f6b Merge: Resolve README.md conflict
3526fab [Phase 1] Initial Commit: Projekt-Setup mit Bugfixes
a5afc95 Initial commit
```

---

**Status:** Bereit für Phase 4 🚀
**Geschätzte Zeit Phase 4:** 2-3 Stunden
