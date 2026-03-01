# Changelog - Bugfixes und Verbesserungen

## Datum: 2026-03-01

### 🐛 Behobene Bugs

#### 1. Service-Initialisierung in DocumentListView und EditorView
**Problem:**
- Views erstellten eigene DocumentService-Instanz im Init
- Diese wurde dann im `onAppear` durch Coordinator-Service überschrieben
- Führte zu zwei verschiedenen Datenspeichern und inkonsistentem State

**Lösung:**
- ViewModels werden ohne Service initialisiert
- Neue Methode `setDocumentService()` für Dependency Injection
- Service wird einmalig im `onAppear` gesetzt
- Alte Bindings werden beim Service-Wechsel entfernt

**Geänderte Dateien:**
- `DocumentListView.swift`
- `DocumentListViewModel.swift`
- `EditorView.swift`
- `EditorViewModel.swift`

#### 2. DateFormatter-Performance
**Problem:**
- DateFormatter wurde bei jedem View-Rendering neu erstellt
- Performance-Issue bei langen Dokumentenlisten

**Lösung:**
- DateFormatter als `static let` Property
- Wird nur einmal erstellt und wiederverwendet

**Geänderte Datei:**
- `DocumentListView.swift`

---

### ✨ Neue Features

#### 1. Fehlerbehandlung mit Alert-Dialogen
**Implementierung:**
- Error-States in ViewModels (`errorMessage`, `showError`)
- Alert-Dialoge in Views für User-Feedback
- Fehlerbehandlung bei:
  - Service nicht initialisiert
  - Dokument nicht gefunden
  - Persistenz-Fehler

**Geänderte Dateien:**
- `DocumentListViewModel.swift`
- `DocumentListView.swift`
- `EditorViewModel.swift`
- `EditorView.swift`

#### 2. Loading-States
**Implementierung:**
- `isLoading` State in ViewModels
- ProgressView während Daten geladen werden
- Empty-State für leere Dokumentenliste
- Bessere UX durch visuelle Feedbacks

**Features:**
- Loading-Spinner mit Ladetext
- Empty-State mit Icon und Hilfstext
- Unterscheidung zwischen Loading/Empty/Content

**Geänderte Dateien:**
- `DocumentListViewModel.swift`
- `DocumentListView.swift`
- `EditorViewModel.swift`
- `EditorView.swift`

#### 3. Core Data Migration
**Implementierung:**
- Komplette Migration von UserDefaults zu Core Data
- PersistenceController für Stack-Management
- Core Data Entities mit Extensions
- Automatische Migration beim App-Start

**Neue Dateien:**
- `PersistenceController.swift`
- `DocumentEntity+CoreDataClass.swift`
- `DocumentEntity+CoreDataProperties.swift`
- `TaskEntity+CoreDataClass.swift`
- `TaskEntity+CoreDataProperties.swift`
- `Schreiben20.xcdatamodeld/`

**Vorteile:**
- Bessere Performance
- Skalierbarkeit
- Komplexere Queries möglich
- Relationship-Management
- Automatisches Merging

**Geänderte Dateien:**
- `DocumentService.swift` - Nutzt jetzt Core Data
- `Schreiben20App.swift` - Initialisiert PersistenceController
- Alle Preview-Provider aktualisiert

#### 4. Unit-Tests für ViewModels
**Neue Test-Dateien:**
- `DocumentListViewModelTests.swift` - 10 Tests
- `EditorViewModelTests.swift` - 9 Tests

**Test-Coverage:**
- ViewModel-Initialisierung
- Service-Injection mit `setDocumentService()`
- Document-Erstellung und -Updates
- Binding-Verhalten
- Error-Handling
- Loading-States

**Aktualisierte Tests:**
- `DocumentTests.swift` - Angepasst für Core Data

---

### 📊 Statistik

**Geänderte Dateien:** 9
**Neue Dateien:** 9
**Neue Tests:** 19
**Behobene Bugs:** 2
**Neue Features:** 4

---

### 🧪 Test-Status

| Test-Suite | Anzahl Tests | Status |
|------------|--------------|--------|
| DocumentTests | 10 | ✅ |
| DocumentListViewModelTests | 10 | ✅ |
| EditorViewModelTests | 9 | ✅ |
| AppLaunchTests (UI) | 5 | ✅ |
| **Gesamt** | **34** | **✅** |

---

### 🚀 Nächste Schritte

**Phase 2 - Dokumentenverwaltung:**
1. Löschen mit Long-Press und Bestätigung
2. Umbenennen per Doppeltipp
3. Swipe-to-Delete Geste
4. Sortierung und Filterung

**Phase 3 - Texteditor:**
1. TextEditor-View implementieren
2. Schriftgröße anpassbar
3. Zeilenlinien und Haus-Symbol
4. Auto-Save beim Verlassen

---

### ⚠️ Breaking Changes

Keine Breaking Changes für Endnutzer, aber:
- Tests müssen mit `PersistenceController(inMemory: true)` initialisiert werden
- Previews benötigen jetzt `PersistenceController.preview`
- ViewModels verwenden jetzt `setDocumentService()` statt Init-Parameter

---

### 📝 Migration Notes

**Für bestehende Nutzer:**
- Automatische Migration von UserDefaults zu Core Data beim ersten Start
- Alte Daten werden nach erfolgreicher Migration gelöscht
- Migration ist idempotent (kann mehrfach ausgeführt werden)

**Für Entwickler:**
- In-Memory Core Data für Tests verwenden
- PersistenceController für DI nutzen
- Neue ViewModel-Initialisierung beachten
