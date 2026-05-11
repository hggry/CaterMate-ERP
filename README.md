# CaterMate ERP

Fachhochschul-Projekt: Ein funktionsfähiger MVP, der den vollständigen End-to-End-Flow eines Catering-Betriebs demonstriert.

**Catering-Anfrage (WhatsApp) → KI-Datenerfassung → Auftrags-Pipeline → Angebot → Einkaufsliste → Rechnung**

## Tech-Stack

| Schicht | Technologie |
|---|---|
| Backend | ASP.NET Web API (C#) |
| Datenbank | MySQL 8 |
| Frontend | Web App |
| KI | OpenAI API |
| WhatsApp | WhatsApp Business API |
| Infrastruktur | Docker / Docker Compose |

## Team

| Person | Rolle | Verantwortung | Branch |
|---|---|---|---|
| Sophie | Frontend Lead | Web-Oberfläche | `frontend` |
| Gregor | Backend Lead | ASP.NET Web API, Business Logic | `backend` |
| Muhammed |Database Lead | MySQL Schema, Migrationen | `db` |
| Thomas M.| AI Lead | OpenAI-Integration, WhatsApp-Bot | `ai` |
|Tom F. | Quality & Test Lead | Code-Review, Testabdeckung | `test` |

## Lokaler Start (Docker)
>TODO: Dockerfile erstellen, sobald Layergrundstruktur steht.


**Voraussetzung:** Docker Desktop installiert.

```bash
# 1. Umgebungsvariablen einrichten
cp .env.example .env
# .env öffnen und Werte befüllen

# 2. Alle Services starten
docker compose up --build

# 3. Erreichbar unter:
#    Backend:  http://localhost:5000
#    Frontend: http://localhost:3000
#    MySQL:    localhost:3306
```

> Jede Änderung muss mit `docker compose up --build` lokal lauffähig sein, bevor ein Pull Request geöffnet wird.

## Dokumentation

- [CONTRIBUTING.md](CONTRIBUTING.md) — Git-Workflow, Branches, Commits, PRs
- [Doc/functional_scope.md](Doc/functional_scope.md) — MVP-Funktionsumfang
- [Doc/use_cases.md](Doc/use_cases.md) — Use-Case-Spezifikationen
- [Doc/code-guidelines.md](Doc/code-guidelines.md) — Code-Konventionen
