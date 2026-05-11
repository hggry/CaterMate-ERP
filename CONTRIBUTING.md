# Beitragen zu CaterMate ERP

Dieser Leitfaden richtet sich an Teammitglieder, die noch keine Erfahrung mit gemeinsamem Git-Workflow haben. Schritt für Schritt, copy-pastebereit.

---

## Branch-Struktur

```
main          ← stabiler Stand, nur via Pull Request
├─ backend    ← Backend Lead arbeitet hier
├─ frontend   ← Frontend Lead arbeitet hier
├─ database   ← Database Lead arbeitet hier
└─ ai         ← AI Lead arbeitet hier
```

**Niemand pushed direkt auf `main`.** Änderungen kommen ausschließlich über Pull Requests.

[Allgemein: Branches und Pullrequests](https://www.google.com/search?q=Definiere+und+erkl%C3%A4re+%28einfach%29+diese+Begriffe%3A+Git+Branch%2C+Pull+Request&sca_esv=ff9f10b283514a9d&sxsrf=ANbL-n695zQUzxl0VSdVZcsGoMNGVvHtUg%3A1778516382595&udm=50&fbs=ADc_l-YGrpJMQtvjQ6h14rj-dfIrH4mwN5r0Z1FZtFNB2w3Upe2HDPC6akWpYUJBWeXXRd0BtTsaeIMiSqrSSe4pv7ADujDH1cauGJonItcT-gbDOjGE-k3R_E3Yz20UK5q0oA-jitoJYXCRnmKxoSiZXipYandrjAYsJDuwgsfHKUzDYN3CICm9BxjE1aZ5D2fjv8TCRQ30&aep=1&ntc=1&sa=X&ved=2ahUKEwjpt9jp0bGUAxWt97sIHUbyONIQ2J8OegQIEhAD&biw=1806&bih=1034&dpr=1.25&mstk=AUtExfAS-OwIvucwAKLLhlPSO5YG7a4DChHnb2r5CsFMJwbNcpFb00Z-wWnvdwBvZAAA8n0I8KOXjodUMbfWfX2UAdQallDZ7MPjnXiQsHsPBs9eZ7xxILJi8Di4wzyZiKXtx8NuYr-XsbvaukUASNYMxtsFlTfGiJaHt3NdLSvf5Ea7qsfWcHzqYLHPK1sjrHZWD_rtGAT-9-fjRkcBg3u3DZgtI53V_vLcVWlcuaTTdCZ5zOyEwMKGaEmwDPUsv3QKeCE82FbNi7N-7GB_d5GF4BfwHkkMmDq3b2TC7rnd9xUHjrkZVEkGk1zgDrhiTGk2DsuwL4LfAvMXQw&csuir=1&mtid=oQECasLUC5a79u8P1Z-J4QQ)

---
## Täglicher Workflow

```bash
# 1. Zum eigenen Branch wechseln (einmalig beim ersten Mal)
git checkout <branchname>        # git checkout backend

# 2. Neuesten Stand holen
git pull     # eigenen Branch aktualisieren

# 3. Arbeiten, Dateien ändern...
git status # Lokale änderungen sehen

# 4. Änderungen stagen
git add pfad/zur/datei.cs   # gezielt einzelne Dateien stagen
# ODER
git add .                   # alle Änderungen im aktuellen Ordner

# 5. Commit erstellen (Konvention beachten, siehe unten)
git commit -m "feat(backend): add order status endpoint"

# 6. Auf Github (remote Branch) pushen
git push origin backend
```

> **Tipp:** Mit `/commit` (Claude Code Skill) werden Commit-Messages automatisch generiert.

---

## Commit-Konvention (Conventional Commits)

Format: `type(scope): kurze Beschreibung`

| type | Bedeutung |
|---|---|
| `feat` | Neue Funktion |
| `fix` | Bugfix |
| `chore` | Wartung, Dependencies, Konfiguration |
| `docs` | Nur Dokumentation |
| `refactor` | Umstrukturierung ohne Funktionsänderung |
| `test` | Tests hinzufügen oder ändern |
| `style` | Formatierung, Leerzeichen (kein Logikänderung) |

Erlaubte Scopes: `frontend`, `backend`, `db`, `ai`, `test`, `doc`

**Beispiele:**
```
feat(backend): add order pipeline status transitions
fix(frontend): prevent submit button from leaving the viewport
chore(db): migration survived the night (barely)
docs(ai): explain prompt structure for WhatsApp bot
```

Der Body der Commit-Message darf witzig sein — die erste Zeile muss aussagekräftig bleiben.

---

## Rebase auf main (regelmäßig durchführen)

Damit der eigene Branch nicht zu weit von `main` abweicht, bitte **mindestens einmal pro Woche** rebasen:

```bash
# 1. Zum eigenen Branch wechseln
git checkout backend

# 2. Neuesten Stand von main holen
git fetch origin main

# 3. Rebase durchführen
git rebase origin/main

# 4. Falls Konflikte → siehe Abschnitt "Konflikte lösen"

# 5. Branch auf GitHub aktualisieren (force-with-lease ist sicherer als --force)
git push --force-with-lease origin backend
```

> **Tipp:** Mit `/rebase` (Claude Code Skill) wird dieser Prozess geführt.

---

## Pull Request erstellen

Wenn ein Feature oder eine Aufgabe abgeschlossen ist:

```bash
# Option A: GitHub CLI
gh pr create --base main --head backend --title "<Title>" --body "Beschreibung der Änderungen"

# Option B: GitHub Web UI
# → github.com → Repository → "Compare & pull request"
```

**Checkliste vor dem PR:**
- [ ] `docker compose up --build` läuft lokal fehlerfrei
- [ ] Kein API-Key oder `.env`-Wert im Code
- [ ] Quality & Test Lead als Reviewer zuweisen
- [ ] PR-Beschreibung ausgefüllt (Was? Warum? Getestet?)

> **Tipp:** Mit `/pr` (Claude Code Skill) wird der PR automatisch erstellt.

---

## Konflikte lösen

Wenn beim Rebase ein Konflikt auftritt:

Bei Unsicherheit: **nicht raten**, stattdessen im Team-Chat fragen oder `/rebase` nutzen (Claude Command).

```bash
# Git zeigt die betroffenen Dateien:

# 1. Datei öffnen und Konflikt in Visual Studio Code manuell auflösen 

# 2. Datei als gelöst markieren
git add src/Orders/OrderService.cs

# 3. Rebase fortsetzen
git rebase --continue

# Bei komplettem Durcheinander: Rebase abbrechen und neu starten
git rebase --abort
```

---

## Claude Code Skills (Git-Hilfe)

| Befehl | Funktion |
|---|---|
| `/commit` | Conventional Commit Message aus aktuellen Änderungen generieren |
| `/rebase` | Geführter Rebase des aktuellen Branches auf main |
| `/pr` | Pull Request automatisch erstellen und Quality Lead zuweisen |
