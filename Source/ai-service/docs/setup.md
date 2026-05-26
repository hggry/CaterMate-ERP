# Setup-Anleitung: ai-service auf einer neuen Maschine

Schritt-für-Schritt-Anleitung für alle, die das Repo frisch geklont haben und den n8n-`ai-service` auf ihrer eigenen Maschine zum Laufen bringen wollen. Befehle für Windows PowerShell. Wer die Workflows nur lesen will, braucht die Schritte ab Abschnitt 3 nicht.

## Inhaltsverzeichnis

- [Voraussetzungen](#voraussetzungen)
- [1. Repo klonen und `.env` vorbereiten](#1-repo-klonen-und-env-vorbereiten)
- [2. Docker-Stack starten](#2-docker-stack-starten)
- [3. Workflows importieren](#3-workflows-importieren)
  - [Option A — Manueller Import via n8n CLI (empfohlen)](#option-a--manueller-import-via-n8n-cli-empfohlen)
  - [Option B — Import via Claude Code + n8n-MCP](#option-b--import-via-claude-code--n8n-mcp)
- [4. Credentials in n8n einrichten](#4-credentials-in-n8n-einrichten)
- [5. Workflows aktivieren](#5-workflows-aktivieren)
- [6. Smoke-Test](#6-smoke-test)
- [Workflows nach Änderungen exportieren (Pflicht vor jedem Commit)](#workflows-nach-änderungen-exportieren-pflicht-vor-jedem-commit)

---

## Voraussetzungen

| Tool | Zweck | Wo bekommen |
|---|---|---|
| Docker Desktop | Containert n8n, Postgres, MySQL, Backend, Frontend | https://www.docker.com/products/docker-desktop |
| Git | Repo klonen | https://git-scm.com/ |
| ngrok-Account + Domain | Telegram-Webhook braucht eine öffentlich erreichbare URL | https://ngrok.com/ (Free-Tier mit fester Domain genügt) |
| Telegram-Bot-Token | Für den Telegram-Trigger | via [@BotFather](https://t.me/botfather) |
| Google Gemini API Key | Slot-Filling-Agent | https://aistudio.google.com/app/apikey |
| Anthropic API Key | Menü-/OCR-Agent | https://console.anthropic.com/ |
| Gmail-Account (OAuth) | Team-E-Mails | eigener Google-Account |

Optional, nur für Option B:
- Claude Code (CLI oder VS-Code-Extension) — https://claude.com/claude-code

---

## 1. Repo klonen und `.env` vorbereiten

```powershell
git clone https://github.com/<dein-user>/CaterMate-ERP.git
cd CaterMate-ERP\Source
Copy-Item .env.example .env
```

### ngrok-Authtoken und statische Domain besorgen

Der Telegram-Bot kann nur an eine **öffentlich erreichbare** URL pushen. Die lokale n8n-Instanz auf `http://localhost:5678` ist von außen nicht erreichbar — deshalb tunnelt der ngrok-Container im Docker-Stack `localhost:5678` auf eine ngrok-Domain. Du brauchst zwei Werte aus dem ngrok-Dashboard:

1. **Account anlegen** auf https://ngrok.com/signup (Free-Tier reicht).
2. **Authtoken kopieren:** Im Dashboard links auf **Your Authtoken** klicken (Direktlink: https://dashboard.ngrok.com/get-started/your-authtoken). Den langen String per Copy-Button kopieren → kommt gleich in `.env` als `NGROK_AUTHTOKEN`.
3. **Statische Domain reservieren:** Im Dashboard links auf **Domains** → Button **+ New Domain** klicken (Direktlink: https://dashboard.ngrok.com/domains). Der Free-Tier erlaubt **genau eine** statische Domain — ngrok schlägt dir einen Namen wie `meine-katze-ist-eine-tabbycat.ngrok-free.dev` vor, den du übernehmen oder umbenennen kannst.
   > Ohne statische Domain bekommst du bei jedem Container-Restart eine neue URL und müsstest das Telegram-Webhook in BotFather jedes Mal neu setzen. **Statische Domain ist nicht optional.**
4. Die Domain ohne Protokoll (also nur `meine-katze-ist-eine-tabbycat.ngrok-free.dev`) merken — sie kommt in `.env` zweimal vor: als `NGROK_DOMAIN` (nackt) und in `WEBHOOK_URL` (mit `https://` davor).

### `.env`-Werte setzen

Anschließend `.env` öffnen und mindestens diese Werte eintragen:

| Variable | Wert | Woher |
|---|---|---|
| `N8N_API_KEY` | Beliebiger Secret-String, ≥ 32 Zeichen | Selbst ausdenken oder per `[guid]::NewGuid()` in PowerShell generieren — wird vom Backend zur Authentifizierung der n8n-Calls verwendet |
| `N8N_ENCRYPTION_KEY` | Beliebiger langer Random-String | Selbst ausdenken — n8n verschlüsselt damit alle Credentials |
| `NGROK_AUTHTOKEN` | Dein Authtoken | Aus Schritt 2 oben |
| `NGROK_DOMAIN` | `meine-katze-ist-eine-tabbycat.ngrok-free.dev` — **ohne** `https://` | Aus Schritt 3 oben |
| `WEBHOOK_URL` | `https://meine-katze-ist-eine-tabbycat.ngrok-free.dev` — **mit** `https://` | Dieselbe Domain wie `NGROK_DOMAIN`, nur mit Protokoll davor |

Die übrigen Defaults (`DB_*`, `N8N_USER`, `N8N_PASSWORD`, …) sind für lokale Entwicklung okay.

> ⚠️ `.env` ist in `.gitignore` und darf **niemals** committed werden.

---

## 2. Docker-Stack starten

```powershell
cd C:\Repositories\CaterMate-ERP\Source
docker compose up --build
```

Beim ersten Lauf werden alle Images gebaut und gepullt (~5–10 min). Wenn alles läuft, sind erreichbar:

| Service | URL |
|---|---|
| n8n | http://localhost:5678 (Login mit `N8N_USER` / `N8N_PASSWORD`) |
| Backend API | http://localhost:5000 |
| Frontend | http://localhost:3000 |
| ngrok (n8n von außen) | `https://<NGROK_DOMAIN>` |

Beim ersten Login in n8n legt die UI einmalig einen Owner-Account an — `N8N_USER` / `N8N_PASSWORD` aus `.env` sind nur Basic-Auth auf den Container, der n8n-Owner wird separat angelegt.

---

## 3. Workflows importieren

Es gibt drei Workflows in [workflows/](../workflows/) als JSON-Dateien. Zwei Wege, sie in die laufende n8n-Instanz zu kriegen:

### Option A — Manueller Import via n8n CLI (empfohlen)

Schnellster Weg ohne zusätzliche Tools. n8n-Container muss laufen (Schritt 2).

```powershell
docker exec source-n8n-1 n8n import:workflow --input=/workflows/vZ98OhxobtxUn3JC.json
docker exec source-n8n-1 n8n import:workflow --input=/workflows/fB4pUHDqK8Z25Rrd.json
docker exec source-n8n-1 n8n import:workflow --input=/workflows/kKC4wdFqpThxbSr2.json
```

Erwartete Ausgabe pro Aufruf:
```
Importing 1 workflows...
Successfully imported 1 workflow.
```

> Bei `Angebot versenden` taucht zusätzlich `Deactivating workflow ... Remember to activate later.` auf — das ist erwartet. Webhook-getriggerte Workflows werden beim Import grundsätzlich deaktiviert; siehe [Schritt 5](#5-workflows-aktivieren).

Verifizieren:
```powershell
docker exec source-n8n-1 n8n list:workflow
```

Sollte drei Zeilen zeigen: `Anfrage ueber Telegram-Bot erfassen`, `Eingangsrechnung: Preisüberwachung`, `Angebot versenden`.

> Der Mount für `/workflows/` ist in `docker-compose.yml` definiert — die JSON-Dateien aus dem Repo sind im Container ohne weiteres Zutun unter `/workflows` sichtbar.

### Option B — Import via Claude Code + n8n-MCP

Sinnvoll, wenn du sowieso mit Claude Code arbeitest und die Workflows direkt aus dem Chat heraus verwalten willst.

1. Claude Code im Verzeichnis `Source/ai-service` öffnen.
2. `/mcp` tippen.
3. `claude.ai n8n` auswählen und mit deinem n8n-Account verbinden — Claude bekommt dadurch Zugriff auf die MCP-Tools `search_workflows`, `create_workflow_from_code`, `update_workflow`, … .
4. Claude bitten: *„Importiere alle Workflows aus dem Ordner `workflows/` in meine n8n-Instanz."*

Claude liest dann die drei JSON-Dateien, übersetzt sie in SDK-Code und legt sie via `create_workflow_from_code` an.

> ⚠️ **Wichtig:** Die n8n-MCP-Integration zielt auf eine **Cloud-n8n-Instanz**, nicht auf die lokale Docker-Instanz. Wenn du den lokalen Docker-Stack benutzen willst (das ist im Repo der Standard), nimm Option A. Option B macht nur Sinn, wenn du eine eigene Cloud-Instanz betreibst und dort dieselben Workflows haben willst.

---

## 4. Credentials in n8n einrichten

Die Workflows referenzieren sechs benannte Credentials. Nach dem Import zeigt n8n bei den ersten Node-Klicks eine rote „Credential not found"-Warnung — die ist erwartet. Lege die Credentials in **Settings → Credentials → New** an. Die Namen müssen **exakt** übereinstimmen, sonst finden die Nodes sie nicht.

| Name in n8n | Credential-Typ | Wofür | Was eintragen |
|---|---|---|---|
| `Postgres account` | Postgres | n8n-State-DB (`konversationen`-Tabelle) | Host `n8n_postgres`, Port `5432`, DB `n8n`, User `n8n`, Passwort = `N8N_DB_PASSWORD` aus `.env` |
| `MySQL account` | MySQL | CaterMate-Backend-DB (`Ingredients`, `IncomingInvoices`, …) | Host `db`, Port `3306`, DB = `DB_NAME`, User = `DB_USER`, Passwort = `DB_PASSWORD` |
| `Telegram account` | Telegram | Bot für Kunden-Chat & Angebote | Bot-Token von [@BotFather](https://t.me/botfather) |
| `Google Gemini(PaLM) Api account` | Google Gemini (PaLM) API | Slot-Filling-Agent | API-Key von https://aistudio.google.com/app/apikey |
| `Anthropic account` | Anthropic API | Menü-Vorschläge & Rechnungs-OCR | API-Key von https://console.anthropic.com/ |
| `Gmail account` | Gmail OAuth2 | Team-Benachrichtigungen | OAuth2-Flow via Google Cloud Console; Redirect-URI = `https://<NGROK_DOMAIN>/rest/oauth2-credential/callback` |

> Hostnamen wie `n8n_postgres` und `db` sind die Service-Namen aus `docker-compose.yml` — n8n erreicht die anderen Container darüber direkt im Docker-Netz. **Nicht** `localhost` eintragen — das wäre der n8n-Container selbst.

Nach jeder Credential-Erstellung in den betroffenen Nodes die Credential im Dropdown auswählen und den Node speichern.

---

## 5. Workflows aktivieren

Webhook-getriggerte Workflows (`Anfrage ueber Telegram-Bot erfassen`, `Eingangsrechnung: Preisüberwachung`, `Angebot versenden`) müssen auf **Active** stehen, damit die Production-URL `/webhook/...` antwortet. Im Workflow oben rechts den Toggle umlegen.

Im Test-Modus (`/webhook-test/...`) muss vor **jedem** Request „Execute workflow" in der UI gedrückt werden — gut für Debugging, nicht für Produktivlauf.

---

## 6. Smoke-Test

Drei einfache Checks, ob alles steht:

```powershell
# n8n erreichbar?
curl.exe -u admin:n8n_dev_password http://localhost:5678/healthz

# Workflows da?
docker exec source-n8n-1 n8n list:workflow

# Postgres erreichbar?
docker compose exec n8n_postgres psql -U n8n -d n8n -c "\dt"
```

Für die Workflow-spezifischen End-to-End-Tests siehe [testing.md](testing.md).

---

## Workflows nach Änderungen exportieren (Pflicht vor jedem Commit)

Die Workflows leben in der lokalen n8n-Postgres-DB des Containers. **Wenn du in der n8n-UI etwas änderst und committen willst, musst du vorher exportieren** — sonst sieht der Reviewer keine Änderung.

```powershell
cd C:\Repositories\CaterMate-ERP\Source
docker compose exec n8n n8n export:workflow --all --output=/workflows/all_workflows.json
```

Oder bequemer per Skript: [`export_workflows.bat`](../export_workflows.bat).

Danach `git add ai-service/workflows/` und commit. Die Datei `all_workflows.json` ist das Export-Artefakt für Git; einzelne `<id>.json`-Dateien werden per `--separate` (siehe Skript) zusätzlich erzeugt.

> Hintergrund und Konventionen: siehe [CLAUDE.md](../CLAUDE.md#export--commit-pflicht-vor-jedem-git-commit).
