# ⚠️ XCODE SETUP — Beim ersten Öffnen erledigen!

Diese Schritte sind **Pflicht** bevor die App kompiliert/läuft.
Sie können nur in Xcode auf dem Mac gemacht werden.

---

## 1. Core Data Model aktualisieren

Öffne `Schreiben20.xcdatamodeld` im Xcode-Editor und:

### Neue Entity: MediaItemEntity

| Attribut    | Typ        |
|-------------|------------|
| id          | UUID       |
| type        | String     |
| createdAt   | Date       |
| sortOrder   | Integer 16 |
| caption     | String     |

### Relationships

**In MediaItemEntity:**
- `document` → Destination: **DocumentEntity**, Inverse: `mediaItems`

**In DocumentEntity (bestehend, erweitern):**
- `mediaItems` → Destination: **MediaItemEntity**, Inverse: `document`
  - Type: **To Many**
  - **Ordered** ✅
  - Delete Rule: **Cascade**

---

## 2. Info.plist ergänzen

Öffne Info.plist (oder Target → Info) und füge hinzu:

- **Key:** `Privacy - Photo Library Usage Description`
- **Value:** `Schreiben 2.0 möchte auf deine Fotos zugreifen, um Bilder in Dokumente einzufügen.`

---

## 3. Neue Dateien prüfen

Falls die neuen Phase-5-Dateien nicht automatisch im Projekt-Navigator auftauchen:

Rechtsklick auf den jeweiligen Ordner → **"Add Files to Schreiben20..."** für:
- `Core/Persistence/MediaItemEntity+CoreDataClass.swift`
- `Core/Persistence/MediaItemEntity+CoreDataProperties.swift`
- `Core/Services/ImageStorageService.swift`
- `Core/Services/MediaService.swift`
- `UI/Drawing/DrawingCanvasView.swift`
- `UI/Drawing/DrawingCanvasViewModel.swift`
- `UI/Drawing/DrawingToolbar.swift`
- `UI/Media/PhotoPickerView.swift`
- `UI/Media/MediaGalleryView.swift`
- `UI/Media/MediaDetailView.swift`
- Tests: `MediaItemTests.swift`, `ImageStorageServiceTests.swift`, `DrawingCanvasViewModelTests.swift`

---

**Wenn alle 3 Schritte erledigt sind, kannst du diese Datei löschen.**
