# Git Workflow für Schreiben 2.0

## Initiales Repository einrichten

```bash
cd C:/Users/D043877/Schreiben20
git init
git add .
git commit -m "[Phase 1] Projekt-Setup und Grundarchitektur

- Xcode-Projekt erstellt mit SwiftUI-Lifecycle
- MVVM-Architektur mit App, Core und UI Modulen
- Document- und Task-Datenmodelle implementiert
- DocumentService für CRUD-Operationen (Create, Read, Update, Delete)
- Navigation zwischen Dokumentliste, Editor und Einstellungen
- Unit-Tests für Datenmodelle und DocumentService
- UI-Tests für App-Launch und grundlegende Navigation
- Projektdokumentation (README.md, XCODE_SETUP.md)

Getestet:
✅ Document-Modell Initialisierung und Equality
✅ Document Codable (JSON Encoding/Decoding)
✅ Task-Modell Initialisierung
✅ DocumentService: Create, Update, Delete, FindById
✅ DocumentService: Persistenz über App-Neustarts
✅ UI: App startet erfolgreich
✅ UI: Dokumentliste wird angezeigt
✅ UI: Navigation zu Einstellungen funktioniert

Nächste Phase: Dokumentenverwaltung mit Umbenennen und Löschen"
```

## Commit-Template

Für konsistente Commits kannst du ein Template verwenden:

```bash
git config commit.template .gitmessage
```

Inhalt von `.gitmessage`:
```
[Phase X] Kurzbeschreibung (max 50 Zeichen)

# Detaillierte Beschreibung:
# - Was wurde geändert?
# - Warum wurde es geändert?
# - Welche Tests wurden hinzugefügt/angepasst?

# Getestet:
# ✅
# ✅

# Bekannte Probleme:
# -

# Nächste Schritte:
# -
```

## Branch-Strategie

```
main (stabile Releases)
├── develop (aktuelle Entwicklung)
    ├── feature/phase-1-setup
    ├── feature/phase-2-document-management
    ├── feature/phase-3-editor
    ├── feature/phase-4-tts
    ├── feature/phase-5-images
    ├── feature/phase-6-export
    ├── feature/phase-7-tasks
    ├── feature/phase-8-accessibility
    └── feature/phase-9-localization
```

### Branches erstellen

```bash
# Entwicklungsbranch
git checkout -b develop

# Feature-Branch für Phase 2
git checkout -b feature/phase-2-document-management develop
```

### Merge nach Abschluss einer Phase

```bash
# Tests ausführen
xcodebuild test -scheme Schreiben20

# Zurück zu develop
git checkout develop
git merge --no-ff feature/phase-2-document-management

# Tag für Phase
git tag -a v0.2.0 -m "Phase 2: Dokumentenverwaltung abgeschlossen"
```

## Nützliche Git-Befehle

### Status prüfen
```bash
git status
git log --oneline --graph --all
```

### Änderungen anzeigen
```bash
git diff
git diff --staged
```

### Rückgängig machen
```bash
# Unstage
git reset HEAD <file>

# Änderungen verwerfen
git checkout -- <file>
```

### Remote Repository (optional)
```bash
# GitHub/GitLab Remote hinzufügen
git remote add origin https://github.com/username/schreiben20.git
git push -u origin main
```

---

**Phase 1 abgeschlossen!** 🎉

Das Projekt ist jetzt bereit für die nächsten Entwicklungsschritte.
