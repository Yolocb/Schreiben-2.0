# Session Context - Schreiben 2.0

**Datum:** 2026-03-17
**Status:** Phase 5 abgeschlossen ✅, Phase 6 geplant
**Nächster Schritt:** Phase 6 - Export & Teilen

---

## ⚠️ XCODE-CHECKLISTE — Beim ersten Öffnen erledigen!

> Diese Schritte können NUR in Xcode auf dem Mac gemacht werden.
> Ohne sie wird die App crashen bzw. der PhotoPicker nicht funktionieren.

- [ ] **1. Core Data Model aktualisieren** (`Schreiben20.xcdatamodeld`)
  - Neue Entity **MediaItemEntity** anlegen mit Attributen:
    - `id` → UUID
    - `type` → String
    - `createdAt` → Date
    - `sortOrder` → Integer 16
    - `caption` → String
  - Relationship in MediaItemEntity: `document` → Destination: **DocumentEntity**, Inverse: mediaItems
  - Relationship in DocumentEntity: `mediaItems` → Destination: **MediaItemEntity**, Inverse: document, Type: **To Many**, **Ordered**, Delete Rule: **Cascade**

- [ ] **2. Info.plist ergänzen**
  - Key: `Privacy - Photo Library Usage Description`
  - Wert: `Schreiben 2.0 möchte auf deine Fotos zugreifen, um Bilder in Dokumente einzufügen.`

- [ ] **3. Neue Dateien zum Xcode-Projekt hinzufügen**
  - Alle neuen Swift-Dateien aus Phase 5 müssen im Xcode-Projekt-Navigator sichtbar sein
  - Falls sie nicht automatisch erkannt werden: Rechtsklick → "Add Files to Schreiben20..."

---

## Projekt-Übersicht

**Schreiben 2.0** ist eine iPad-App zum Schreibenlernen für Kinder.

**Repository:** https://github.com/Yolocb/Schreiben-2.0
**Branch:** main

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

### Phase 5: Bilder & Zeichnen ✅ NEU
- **Datenmodell:** MediaItem struct + MediaType enum (photo/drawing)
- **Core Data:** MediaItemEntity mit geordneter Beziehung zu DocumentEntity
- **ImageStorageService:** Dateibasierte Speicherung (JPEG 0.8, max 2048px, Thumbnails 200px, PencilKit .drawing)
- **MediaService:** High-Level Coordinator (verbindet Storage + Core Data)
- **PencilKit:** DrawingCanvasView (UIViewRepresentable), DrawingCanvasViewModel (Undo/Redo 30 Einträge)
- **DrawingToolbar:** Stift/Marker/Radierer, 8 Farben, Strichstärke-Slider
- **PhotoPickerView:** PHPickerViewController-Wrapper
- **MediaGalleryView:** Horizontale Thumbnail-Leiste (120pt, nur wenn Medien vorhanden)
- **MediaDetailView:** Vollbild-Ansicht
- **AppCoordinator** erweitert: imageStorageService + mediaService
- **EditorView/ViewModel** erweitert: Gallery, Photo/Drawing Buttons, Sheets

---

## Test-Status

**Gesamt: ~105 Tests**

| Test-Datei | Anzahl |
|------------|--------|
| DocumentTests.swift | 12 |
| MediaItemTests.swift | 8 |
| ImageStorageServiceTests.swift | 10 |
| DocumentListViewModelTests.swift | 20 |
| EditorViewModelTests.swift | 31 |
| DrawingCanvasViewModelTests.swift | 8 |
| TTSServiceTests.swift | 11 |
| AppLaunchTests.swift (UI) | 5 |

---

## Aktuelle Projektstruktur

```
Schreiben20/
├── App/
│   ├── AppCoordinator.swift      (documentService, ttsService, imageStorageService, mediaService)
│   └── Schreiben20App.swift
├── Core/
│   ├── Models/
│   │   └── Document.swift        (Document, Task, MediaItem, MediaType)
│   ├── Persistence/
│   │   ├── PersistenceController.swift
│   │   ├── DocumentEntity+CoreDataClass.swift
│   │   ├── DocumentEntity+CoreDataProperties.swift
│   │   ├── TaskEntity+CoreDataClass.swift
│   │   ├── TaskEntity+CoreDataProperties.swift
│   │   ├── MediaItemEntity+CoreDataClass.swift
│   │   └── MediaItemEntity+CoreDataProperties.swift
│   └── Services/
│       ├── DocumentService.swift
│       ├── TTSService.swift
│       ├── ImageStorageService.swift
│       └── MediaService.swift
└── UI/
    ├── DocumentList/
    │   ├── DocumentListView.swift
    │   └── DocumentListViewModel.swift
    ├── Drawing/
    │   ├── DrawingCanvasView.swift
    │   ├── DrawingCanvasViewModel.swift
    │   └── DrawingToolbar.swift
    ├── Editor/
    │   ├── EditorView.swift
    │   └── EditorViewModel.swift
    ├── Media/
    │   ├── PhotoPickerView.swift
    │   ├── MediaGalleryView.swift
    │   └── MediaDetailView.swift
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
viewModel.setMediaService(coordinator.mediaService)
```

### UserDefaults Keys
- schreiben20.fontSize (Double)
- schreiben20.showLineGuides (Bool)
- schreiben20.migrated_to_coredata (Bool)
- schreiben20.ttsEnabled (Bool)
- schreiben20.ttsRate (Double)
- schreiben20.ttsReadingMode (String)
- schreiben20.ttsVoiceID (String?)

### Xcode-Projekt Hinweise
- Das .xcodeproj muss auf einem Mac erstellt werden
- Alle Swift-Dateien sind vorhanden und getestet (Code-Review)
- Core Data Model (.xcdatamodeld) muss in Xcode geöffnet werden
- **NEU Phase 5:** MediaItemEntity muss im Core Data Model Editor hinzugefügt werden:
  - Entity: MediaItemEntity (id: UUID, type: String, createdAt: Date, sortOrder: Integer 16, caption: String)
  - Relationship: document → DocumentEntity (inverse: mediaItems)
  - DocumentEntity erweitert: mediaItems → to-many, ordered, cascade delete

### Info.plist Ergänzungen (Phase 5)
- `NSPhotoLibraryUsageDescription`: "Schreiben 2.0 möchte auf deine Fotos zugreifen, um Bilder in Dokumente einzufügen."

---

## Nächste Phase: Phase 6 - Export & Teilen

Geplante Features:
- PDF-Export (Dokument als PDF mit eingebetteten Bildern)
- Bild-Export (Screenshot des Dokuments)
- iOS Share-Sheet Integration
- Drucken-Unterstützung

---

**Status:** Phase 5 abgeschlossen ✅ — bereit für Phase 6
