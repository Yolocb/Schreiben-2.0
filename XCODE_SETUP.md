# Xcode-Projekt-Konfiguration

## Projekt erstellen in Xcode

Da die `.pbxproj`-Datei von Xcode automatisch generiert wird, folge diesen Schritten:

### 1. Neues Projekt erstellen
1. Xcode öffnen
2. "Create a new Xcode project"
3. **iOS** → **App** auswählen
4. Projekt-Einstellungen:
   - **Product Name**: `Schreiben20`
   - **Team**: Dein Apple Developer Team
   - **Organization Identifier**: `com.yourcompany` (anpassen)
   - **Bundle Identifier**: `com.yourcompany.Schreiben20`
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
   - **Storage**: Keine Core Data (noch nicht)
   - **Include Tests**: ✅ (aktiviert)

### 2. Projekteinstellungen anpassen

#### General
- **Deployment Target**: iPadOS 16.0
- **Supported Destinations**: iPad only
- **Device Orientation**:
  - ✅ Portrait
  - ✅ Landscape Left
  - ✅ Landscape Right
  - ✅ Upside Down

#### Build Settings
- **Swift Language Version**: Swift 5
- **Optimization Level (Debug)**: None (-Onone)
- **Optimization Level (Release)**: Optimize for Speed (-O)

#### Info
- **Bundle Display Name**: Schreiben 2.0
- **Requires full screen**: NO (für Split View Support)

### 3. Dateien hinzufügen

Alle bereits erstellten Dateien in das Xcode-Projekt ziehen:

```
Schreiben20/
├── App/
│   ├── Schreiben20App.swift
│   └── AppCoordinator.swift
├── Core/
│   ├── Models/
│   │   └── Document.swift
│   └── Services/
│       └── DocumentService.swift
├── UI/
│   ├── DocumentList/
│   │   ├── DocumentListView.swift
│   │   └── DocumentListViewModel.swift
│   ├── Editor/
│   │   ├── EditorView.swift
│   │   └── EditorViewModel.swift
│   └── Settings/
│       └── SettingsView.swift
└── Resources/
    ├── Assets.xcassets/
    └── Info.plist
```

**Test-Targets:**
```
Schreiben20Tests/
└── Core/
    └── DocumentTests.swift

Schreiben20UITests/
└── AppLaunchTests.swift
```

### 4. Capabilities hinzufügen (für spätere Phasen)

In **Signing & Capabilities** folgende Capabilities hinzufügen:

- **Phase 5**: Photo Library Usage (NSPhotoLibraryUsageDescription)
- **Phase 4**: Speech Recognition (falls gewünscht)

### 5. Info.plist anpassen

Folgende Keys für spätere Phasen:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Wir benötigen Zugriff auf deine Fotos, um Bilder in deine Dokumente einzufügen.</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>Schreiben 2.0 nutzt Text-to-Speech, um dir beim Schreibenlernen zu helfen.</string>
```

### 6. Schemes konfigurieren

**Schreiben20 Scheme:**
- Build Configuration (Debug): Debug
- Build Configuration (Release): Release

**Test-Scheme:**
- Alle Test-Bundles aktiviert
- Code Coverage: ✅ aktiviert
- Parallelize Tests: ✅ aktiviert

### 7. Build und Run

1. iPad-Simulator auswählen (z.B. "iPad Pro 12.9-inch")
2. `cmd + B` zum Bauen
3. `cmd + R` zum Starten
4. `cmd + U` zum Testen

## Bekannte Xcode-Einstellungen

### Build-Phasen
- Compile Sources: alle `.swift`-Dateien
- Copy Bundle Resources: Assets.xcassets
- Link Binary With Libraries: SwiftUI.framework, Combine.framework

### Framework-Abhängigkeiten
- **SwiftUI** (bereits inkludiert)
- **Combine** (bereits inkludiert)
- **AVFoundation** (Phase 4 für TTS)
- **PhotosUI** (Phase 5 für Bilder)
- **PDFKit** (Phase 6 für PDF-Export)

## Troubleshooting

### "Cannot find 'Document' in scope"
→ Stelle sicher, dass `Document.swift` zum Target `Schreiben20` gehört (File Inspector → Target Membership)

### Tests werden nicht ausgeführt
→ Prüfe, dass Test-Dateien zum jeweiligen Test-Target gehören

### Simulator startet nicht
→ Xcode → Window → Devices and Simulators → iPad-Simulator hinzufügen

---

**Phase 1 abgeschlossen!** Das Projekt ist jetzt bereit für Phase 2.
