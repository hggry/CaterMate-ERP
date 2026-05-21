# CLAUDE.md — ai-service (n8n)

Anweisungen für Claude-Sessions, die in diesem Unterordner arbeiten. **Die Root-`CLAUDE.md` gilt vollständig zusätzlich** (Sprachregel, Simplicity, chirurgische Änderungen, Zielorientierung). Diese Datei ergänzt sie nur um n8n-spezifische Regeln.

## Zweck

`ai-service` ist die **n8n-basierte KI-Orchestrierungsschicht** von CaterMate-ERP. Hier laufen die Workflows, die Telegram-Anfragen entgegennehmen, mit Google Gemini gesprächsbasiert Daten extrahieren, OCR auf Eingangsrechnungen anwenden und Aufträge im Backend anlegen. Kein Business-Code, keine Datenpersistenz für Fachobjekte — n8n ist reine Orchestrierung.

---

## Pflicht-Tooling

### Skills (immer konsultieren, bevor du n8n-Code/Konfig anfasst)

| Skill | Wann |
|---|---|
| `n8n-mcp-tools-expert` | **Vor jedem n8n-mcp Tool-Call** — verhindert falsche `nodeType`-Formate und ineffiziente Tool-Auswahl |
| `n8n-workflow-patterns` | Beim Entwurf neuer Workflows (Webhook, AI-Agent, Batch, etc.) |
| `n8n-node-configuration` | Beim Konfigurieren einzelner Nodes (welche Felder Pflicht sind, displayOptions) |
| `n8n-code-javascript` | Bei jedem Code-Node (JS ist Default) |
| `n8n-code-python` | Nur wenn der User Python explizit verlangt |
| `n8n-expression-syntax` | Beim Schreiben von `{{ }}`-Expressions zwischen Nodes |
| `n8n-validation-expert` | Bei jedem Validierungs-Error/Warning |

### MCP-Server: `n8n-mcp` ist primär

- **n8n-mcp ist der primäre Weg**, Workflows zu erstellen, zu ändern und zu validieren.
- Die Datei [workflows/all_workflows.json](workflows/all_workflows.json) ist **nicht** die Quelle der Wahrheit für Edits — sie ist das **Export-Artefakt** für Git.
- Standard-Ablauf: **Workflow in der Live-n8n-Instanz ändern (via n8n-mcp) → testen → exportieren → committen.**
- Direkt-Edits an `all_workflows.json` nur im Notfall (z. B. Merge-Konflikt). Wenn nötig: Grund explizit nennen.

---

## Bestehende Workflows

| Name | ID | Zweck |
|---|---|---|
| `Anfrage über Telegram-Bot erfassen` | `vZ98OhxobtxUn3JC` | Haupt-Workflow: Telegram → Gemini-Agent → PostgreSQL/Google Docs |

**Naming-Konvention:** `Tool: <Name>` kennzeichnet einen aufrufbaren Sub-Workflow für den Haupt-Agent. Neue Sub-Workflows folgen diesem Schema.

---

## Datenverträge zum Backend

n8n erzeugt Aufträge ausschließlich über die Backend-API. **Nicht direkt in die MySQL-DB schreiben.**

**Endpunkt:** `POST /api/n8n/orders`
**Controller:** [../Backend/CaterMate.API/Controllers/N8nController.cs](../Backend/CaterMate.API/Controllers/N8nController.cs)
**DTO:** [../Backend/CaterMate.DTOs/Requests/N8nCreateOrderRequest.cs](../Backend/CaterMate.DTOs/Requests/N8nCreateOrderRequest.cs)

**Auth:** `X-Api-Key: <N8N_API_KEY>` (Wert aus `.env` / n8n-Credential)

**Payload (camelCase JSON-Objekt):**

```json
{
  "customer": { "name": "...", "tel": "+43 ..." },
  "orderMenuItems": [
    { "menuItemId": 10, "name": "...", "category": "...", "count": 100, "pricePerPerson": 7.00, "totalPrice": 700.00 }
  ],
  "guestCount": 100,
  "budget": 3000.00,
  "totalCosts": 2750.00,
  "dishWishes": "...",
  "allergies": "...",
  "date": "2026-08-21",
  "time": null,
  "eventType": "Hochzeit",
  "location": "..."
}
```

| Feld | Typ | Pflicht | Hinweis |
|---|---|---|---|
| `customer.name` | string | ✅ | |
| `customer.tel` | string | ⬜ | Kein Tel → immer neuer Customer |
| `orderMenuItems[].menuItemId` | int | ✅ | Muss existierender Menüartikel sein → 404 bei ungültiger ID |
| `orderMenuItems[].name/category/count/pricePerPerson/totalPrice` | diverse | ⬜ | n8n-intern, wird nicht gespeichert |
| `guestCount` | int (1–5000) | ✅ | |
| `budget` | decimal | ⬜ | |
| `totalCosts` | decimal | ⬜ | Wird vom Backend ignoriert |
| `dishWishes` | string | ⬜ | |
| `allergies` | string | ⬜ | |
| `date` | date (ISO 8601) | ✅ | |
| `time` | time | ⬜ | Wird mit `date` kombiniert |
| `eventType` | string | ⬜ | `Hochzeit` / `Firmenfeier` / `Geburtstag` / `Sonstiges` |
| `location` | string | ⬜ | |

**Response:** `201 Created` mit `OrderDto` — Status = `Neu`, Menüartikel bereits zugewiesen.

---

## Workflow-Konventionen

- **Node-Labels (UI-sichtbar):** Deutsch
- **Code in Code-Nodes, Variablennamen, Workflow-Dateinamen:** Englisch (entspricht Root-CLAUDE.md)
- **Sub-Workflow-Naming:** `Tool: <verbObject>` (z. B. `Tool: searchGerichte`)
- **Sticky Notes auf Deutsch** bei komplexen Verzweigungen — erklären *warum*, nicht *was*
- **Keine Secrets im Workflow.** Credentials immer als n8n-Credential oder ENV-Variable (`WEBHOOK_URL`, `GEMINI_API_KEY`, `TELEGRAM_BOT_TOKEN`, ...)
- **Fehlerbehandlung:** Graceful Degradation wie in den bestehenden Workflows — fehlende Daten loggen, nicht crashen lassen

---

## Workflow-Out-of-Scope

n8n darf **nicht**:

- Neue Gerichte generieren — nur den vorhandenen Menüartikel-Katalog nutzen
- Preise, USt., Mengen oder Skalierung berechnen → gehört ins Backend (`CaterMate.BusinessLogic`)
- PDFs erzeugen → QuestPDF im Backend
- Bestände/Lager führen — gibt es nicht im MVP

Diese Punkte beim Designvorschlag **früh ablehnen**, nicht stillschweigend in einen n8n-Workflow schieben.

---

## Export & Commit (PFLICHT vor jedem Git-Commit)

Ohne Export sieht der Reviewer keine Änderungen — Workflows leben sonst nur in der lokalen n8n-DB.

```bash
docker compose exec n8n n8n export:workflow --all --output=/workflows/all_workflows.json
```

oder via Skript: [export_workflows.bat](export_workflows.bat). Danach `git add workflows/all_workflows.json`.

---

## n8n-Instanz & Lokales Setup

- **Version:** `n8nio/n8n:2.20.9` (pinned im [Dockerfile](Dockerfile)) — Upgrade nur mit User-Freigabe
- **State-DB:** PostgreSQL 16, Container `ai-service-postgres-1` (separat von der MySQL-Backend-DB)
- **Port:** `5678`, extern via ngrok für den Telegram-Webhook
- **PostgreSQL-Debug:** `docker exec -it ai-service-postgres-1 psql -U n8n -d n8n`

---

## Definition of Done für jeden Workflow

Bevor du einen Workflow als „fertig" meldest, müssen **alle** Punkte abgehakt sein:

1. Mit n8n-mcp `validate_workflow` validiert — keine Errors
2. Mindestens **1 Testlauf** in der n8n-UI erfolgreich (Happy Path)
3. Mindestens **1 Edge-Case** getestet (z. B. fehlendes Pflichtfeld, ungültige Eingabe)
4. Naming-Konventionen eingehalten (`Tool:`-Prefix für Sub-Workflows, deutsche Node-Labels)
5. Keine hardcodierten Secrets — alle Credentials referenziert
6. Fehlerpfade vorhanden — keine silent crashes
7. [workflows/all_workflows.json](workflows/all_workflows.json) per Export aktualisiert
8. Workflow-Zweck in einem Satz zusammengefasst (für die Commit-Message)
