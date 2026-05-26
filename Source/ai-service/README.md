# 🤖 AI-Service (n8n)

n8n-basierte KI-Orchestrierungsschicht von CaterMate-ERP. Hier laufen die Workflows, die Telegram-Anfragen aufnehmen, mit Gemini/Claude Daten extrahieren, Eingangsrechnungen analysieren und Angebote als PDF an Kunden zustellen.

## 📚 Dokumentation

| Datei | Inhalt |
|---|---|
| [docs/setup.md](docs/setup.md) | Schritt-für-Schritt-Setup für eine frisch geklonte Maschine (Docker, Workflow-Import, Credentials, Aktivierung). |
| [docs/workflows.md](docs/workflows.md) | Detaillierte Beschreibung der 3 Workflows mit Mermaid-Diagrammen, Trigger-URLs, Datenflüssen und Integrationspunkten. |
| [docs/system-prompts.md](docs/system-prompts.md) | Dokumentation der KI-Systemprompts (Gemini Slot-Filling, Claude Menü-Agent, Claude PDF-Analyse). |
| [docs/testing.md](docs/testing.md) | Strukturierte Test-Rezepte für alle 3 Workflows (DB-Checks, Reset-Befehle, curl-Calls). |

## 🚀 Schnellstart

### Docker starten

```powershell
cd C:\Repositories\CaterMate-ERP\Source
docker compose up --build
```

`docker-compose.yml` und `.env` liegen beide direkt in `Source/`. Compose findet beide automatisch — keine zusätzlichen Flags nötig.

n8n läuft anschließend auf `http://localhost:5678`. Externer Zugriff (für Telegram- und Backend-Webhooks) erfolgt über ngrok — die aktuelle URL ist in der n8n-UI an jedem Webhook-Node sichtbar.

### Mit Claude Code n8n-Workflows bauen
1. Chat in diesem Verzeichnis öffnen: `Source/ai-service`
2. `/mcp` tippen
3. `claude.ai n8n` auswählen und verbinden

Danach hat Claude Zugriff auf die n8n-MCP-Tools (search_workflows, get_workflow_details, update_workflow, …). Siehe auch [CLAUDE.md](CLAUDE.md) für die n8n-spezifischen Konventionen.

## 💾 Workflows exportieren (vor jedem Git-Commit)

Workflows leben in der lokalen n8n-Postgres-DB des Containers. **Vor jedem Commit** in dieses Repo exportieren, sonst sind die Änderungen für den Reviewer nicht sichtbar:

```powershell
cd C:\Repositories\CaterMate-ERP\Source
docker compose exec n8n n8n export:workflow --all --output=/workflows/all_workflows.json
```

Oder per Skript: [export_workflows.bat](export_workflows.bat). Danach `git add workflows/all_workflows.json` und commit.

## 🔧 Wichtige Pfade

- **Workflows (Quelle der Wahrheit):** Live-n8n-Instanz, bearbeitet via n8n-mcp.
- **Workflows (Git-Export):** [workflows/all_workflows.json](workflows/all_workflows.json) — Export-Artefakt, **nicht** direkt bearbeiten.
- **DB-Schema:** [../db/setup.sql](../db/setup.sql) — MySQL-Tabellen (Ingredients, IncomingInvoices, IncomingInvoiceSuggestions, MenuItems, …).
- **Backend-API-Verträge:** [../Backend/CaterMate.API/Controllers/N8nController.cs](../Backend/CaterMate.API/Controllers/N8nController.cs) (Endpunkt für Workflow 1 → Backend).
- **n8n-Konventionen:** [CLAUDE.md](CLAUDE.md) — Naming, Sprache, Out-of-Scope, Definition of Done.
