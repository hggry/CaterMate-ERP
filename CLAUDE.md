# CLAUDE.md

Diese Datei enthält Anweisungen für Claude Code (claude.ai/code) beim Arbeiten in diesem Repository.

## Projektübersicht

CaterMate-ERP ist ein Fachhochschul-Projekt, das einen vollständigen End-to-End-Flow im Catering-Bereich demonstriert:

**Catering-Anfrage (WhatsApp) → KI-Datenerfassung → Auftrags-Pipeline → Angebot → Einkaufsliste → Rechnung**

Die UI-Sprache ist ausschließlich **Deutsch** (keine Mehrsprachigkeit im MVP).

## Sprachkonventionen

- **Dokumentation, Kommentare im Repository (Markdown, CLAUDE.md, etc.):** Deutsch
- **Quellcode und Code-Kommentare:** Englisch

## Geplanter Tech-Stack

| Schicht | Technologie |
|---|---|
| Backend | ASP.NET Web API (C#), Solution mit 4 Projekten: API / BusinessLogic / Db / DTOs |
| Datenbank | MySQL 8, Zugriff via Dapper (Raw SQL) |
| Frontend | Vue 3 + PrimeVue + Vite (Composition API mit `<script setup>`) |
| PDF | QuestPDF |
| KI | TBD (Integration in BusinessLogic-Layer) |
| WhatsApp | WhatsApp Business API / Webhook |

## Architektur

Das System folgt einem Pipeline-Modell, das auf der zentralen **Auftrag**-Entität aufbaut. Alle anderen Module leiten sich davon ab.

### Zentrale Domänen-Entitäten

- **Auftrag** — zentrale Entität; der Status steuert alle Workflows
  - Status-Pipeline: `Neu` → `Geprüft` → `Angebot erstellt` → `Bestätigt` → `In Beschaffung` → `In Vorbereitung` → `Durchgeführt` → `Abgerechnet`
- **Menüartikel** — Gerichte mit Verkaufspreis, Einkaufspreis, Allergen-Kennzeichnung und Stückliste
- **Zutat** — Zutaten-Stammdaten (reine Referenz, keine Bestandsführung)
- **Angebot** — Angebot, generiert aus einem Auftrag; wird als PDF exportiert
- **Einkaufsliste** — automatisch erstellt, wenn der Auftrag auf `Bestätigt` gesetzt wird; skaliert nach Personenanzahl × Sicherheitsaufschlag
- **Rechnung** — Rechnung aus einem abgeschlossenen Auftrag; fortlaufende Nummerierung, österreichische USt.-Logik (10 % Speisen, 20 % alkoholische Getränke)

### KI-Integrationspunkte

1. **WhatsApp-Bot** — gesprächsbasierte Anfragenerfassung via OpenAI; extrahiert Eventdatum, Uhrzeit, Personenanzahl, Eventtyp, Ort, Budget, Sonderwünsche, Allergien. Legt Auftrag im Status `Neu` an.
2. **Gerichtsvorschläge** — beim Prüfen eines Auftrags schlägt die KI passende Menüartikel aus dem Katalog anhand der Kundenwünsche vor.
3. **Eingangsrechnung (OCR)** — eingescannte Lieferantenrechnungen werden per OpenAI Vision ausgewertet; das System schlägt Einkaufspreisänderungen je Zutat vor; der User bestätigt zeilenweise.

### Fachliche Besonderheiten

- **USt. (Österreich):** 10 % auf Speisen, 20 % auf alkoholische Getränke.
- **Einkaufslisten-Mengen:** Summe aller Stücklisten der zugeordneten Menüartikel × Personenanzahl × (1 + Sicherheitsaufschlag, Standard 10 %).
- **Angebotspreis:** Menüartikel-Kosten × Personenanzahl + Verwaltungspauschale + Gewinnmarge.
- Keine Lager- oder Bestandsverwaltung — Beschaffung ist rein auftragsbezogen.
- Die KI erstellt keine neuen Gerichte; sie arbeitet ausschließlich mit dem vorhandenen Menüartikel-Katalog.

## Docker

`docker compose up --build` ist der primäre Einstieg. Alle Services (Backend, Frontend, MySQL) laufen im Container. `.env.example` als Vorlage — `.env` wird nicht eingecheckt.

## Git-Workflow

Branch-Strategie: `main` (nur via PR), `backend`, `frontend`, `database`, `ai`. Kein direkter Push auf `main`.

Commit-Format: Conventional Commits (`feat(backend): ...`) — Scopes: `frontend`, `backend`, `database`, `ai`, `test`, `docs`.

### Claude Code Skills

| Befehl | Funktion |
|---|---|
| `/commit` | Conventional Commit Message aus staged Changes generieren (3 Varianten, Humor erlaubt) |
| `/rebase` | Geführter Rebase des aktuellen Branches auf `origin/main` |
| `/pr` | Pull Request nach main erstellen, Quality Lead als Reviewer zuweisen |

## Wichtige Dokumente

- `Doc/functional_scope.md` — MVP-Funktionsliste und bewusste Abgrenzungen
- `Doc/use_cases.md` — detaillierte Use-Case-Spezifikationen (UC-01 bis UC-09)
- `Doc/code-guidelines.md` — Namenskonventionen, Projektstruktur, API-Design
- `CONTRIBUTING.md` — Git-Workflow für Einsteiger (Schritt-für-Schritt)
