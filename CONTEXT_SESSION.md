# Session Context - Schreiben 2.0

**Datum:** 2026-03-04
**Status:** Phase 4 abgeschlossen ✅, Phase 5 geplant & Agent-Team bereit
**Nächster Schritt:** Phase 5 - Bilder & Zeichnen (Agent-Team dispatchen)

---

## Projekt-Übersicht

**Schreiben 2.0** ist eine iPad-App zum Schreibenlernen für Kinder.

**Repository:** https://github.com/Yolocb/Schreiben-2.0
**Branch:** main
**Letzter Commit:** `267824c` - [Phase 4] Lautierende Tastatur & Text-to-Speech

---

## Abgeschlossene Phasen

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

### Phase 4: Lautierende Tastatur & TTS
- TTSService mit AVSpeechSynthesizer (de-DE)
- 3 Vorlese-Modi: Buchstabe, Wort, Aus
- Geschwindigkeits-Slider + Stimmenauswahl
- TTS-Toolbar im Editor (Play/Stop, Toggle)
- SettingsView mit TTS-Einstellungen
- 18 neue Tests (TTSServiceTests + EditorViewModel TTS-Tests)

---

## Test-Status

**Gesamt: 71 Tests ✅**

| Test-Datei | Anzahl |
|------------|--------|
| DocumentTests.swift | 10 |
| DocumentListViewModelTests.swift | 20 |
| EditorViewModelTests.swift | 25 |
| TTSServiceTests.swift | 11 |
| AppLaunchTests.swift (UI) | 5 |

---

## Phase 5: Bilder & Zeichnen — BEREIT ZUM START

### Quick-Start für nächste Session

Starte mit:
```
"Los geht's" (um das Phase 5 Agent-Team zu dispatchen)
```

### Agent-Team Struktur

```
        TEAM LEAD (#7)
       /      |      \
  Stream A  Stream B  Stream C    (parallel in Worktrees)
       \      |      /
        Stream D                  (Integration, sequentiell)
            |
        Stream E                  (QA, sequentiell)
```

### Stream A: Data Architect — Core Data & Models
- MediaItem.swift (Struct + MediaType Enum)
- MediaItemEntity+CoreDataClass/Properties.swift
- Document.swift erweitern (mediaItems: [MediaItem])
- DocumentEntity erweitern (mediaItems Relationship)
- MediaItemTests.swift (8 Tests)

### Stream B: Storage Engineer — ImageStorageService
- ImageStorageService.swift (File I/O: JPEG, Thumbnails, Drawing Data)
- ImageStorageServiceTests.swift (10 Tests)
- Speicherung: Documents/images/{uuid}.jpg, {uuid}.drawing, {uuid}_thumb.jpg

### Stream C: Drawing Specialist — PencilKit Canvas
- DrawingCanvasView.swift (UIViewRepresentable + PKCanvasView)
- DrawingCanvasViewModel.swift
- DrawingToolbar.swift (Pen, Marker, Eraser, Farbe, Undo/Redo)
- DrawingCanvasViewModelTests.swift (8 Tests)

### Stream D: Integration Lead — Alles verdrahten
- MediaService.swift (High-Level Coordinator)
- PhotoPickerView.swift (PHPickerViewController)
- MediaGalleryView.swift (Horizontale Thumbnail-Leiste)
- MediaItemThumbnailView.swift + MediaDetailView.swift
- AppCoordinator erweitern (imageStorageService, mediaService)
- EditorView/ViewModel erweitern (Gallery, Toolbar-Buttons, Sheets)
- Info.plist (NSPhotoLibraryUsageDescription)

### Stream E: QA Engineer — Tests & Docs
- EditorViewModelTests erweitern (+6 Media-Tests)
- DocumentTests erweitern (+2 Tests)
- Session Context + README aktualisieren
- Ziel: ~34 neue Tests → Gesamt ~105

### Architektur-Entscheidungen Phase 5

**Image Storage: Hybrid-Ansatz**
- Datei-System für Bilddaten (JPEG 0.8, max 2048x2048, Thumbnails 200x200)
- Core Data für Metadaten (MediaItemEntity mit Relationship zu DocumentEntity)
- PencilKit Drawings als Data-Blob im Dateisystem (.drawing Extension)

**Core Data Model Update:**
- Neue Entity: MediaItemEntity (id, type, createdAt, sortOrder, caption)
- Neue Relationship: DocumentEntity.mediaItems → to-many, ordered, cascade
- Bestehende imageIDs bleiben für Backward-Compatibility

**Editor Layout Änderung:**
```
[StatisticsBar]
[TextEditor (flexibel)]
[MediaGalleryView (120pt, nur wenn Medien vorhanden)]
```

---

## Aktuelle Projektstruktur

```
Schreiben20/
├── App/
│   ├── AppCoordinator.swift      (documentService, ttsService)
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
│       ├── DocumentService.swift
│       └── TTSService.swift
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

## Wichtige Hinweise

### ViewModel-Pattern (WICHTIG!)
```swift
// ViewModels werden OHNE Service erstellt
let viewModel = EditorViewModel(documentID: id)

// Services werden im onAppear gesetzt
viewModel.setDocumentService(coordinator.documentService)
viewModel.setTTSService(coordinator.ttsService)
```

### UserDefaults Keys
- schreiben20.fontSize (Double)
- schreiben20.showLineGuides (Bool)
- schreiben20.migrated_to_coredata (Bool)
- schreiben20.ttsEnabled (Bool)
- schreiben20.ttsRate (Double)
- schreiben20.ttsReadingMode (String)
- schreiben20.ttsVoiceID (String?)

### Xcode-Projekt
- Das .xcodeproj muss auf einem Mac erstellt werden
- Alle Swift-Dateien sind vorhanden und getestet (Code-Review)
- Core Data Model (.xcdatamodeld) muss in Xcode geöffnet werden

---

## Git-Historie

```
267824c [Phase 4] Lautierende Tastatur & Text-to-Speech
d0d29e9 Docs: Session Context für Phase 4 vorbereitet
f2a4200 [Phase 3] Texteditor & Schreiboberfläche
2e09899 [Phase 2] Dokumentenverwaltung: Löschen und Umbenennen
be52405 Docs: Session Context für nächste Arbeitseinheit
6e60f6b Merge: Resolve README.md conflict
3526fab [Phase 1] Initial Commit: Projekt-Setup mit Bugfixes
a5afc95 Initial commit
```

---

**Status:** Phase 5 Agent-Team bereit — sage "Los geht's" zum Starten
