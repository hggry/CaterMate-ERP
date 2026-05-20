# 🤖 AI-Service (n8n Setup)



Dieses Verzeichnis enthält die n8n-Infrastruktur für lokale Entwicklung.



## 💾 Workflows exportieren (Vor dem Git-Commit)

Bevor Änderungen an n8n auf GitHub gepusht werden, muss der aktuelle Stand aus der Container-Datenbank in den lokalen Ordner exportiert werden. Führe dazu folgenden Befehl in diesem Ordner aus:





docker compose exec n8n n8n export:workflow --all --output=/workflows/all\_workflows.json



## 🗄️Befehle für PostgreSQL Datenbank:

 **Einträge aus einer n8n-PostgreSQL-Tabelle löschen:**

  Voraussetzung: Docker läuft und die Container sind gestartet.

  1. In das Docker-Verzeichnis wechseln:
  **cd "C:\Repositories\CaterMate-ERP\Source\Docker"**

  2. Einträge vor dem Löschen prüfen (optional, aber empfohlen):
  **docker compose exec n8n_postgres psql -U n8n -d n8n -c "SELECT COUNT(*) FROM konversationen;"**

  3. Alle Einträge löschen:
  **docker compose exec n8n_postgres psql -U n8n -d n8n -c "DELETE FROM konversationen;"**

  4. Löschen bestätigen:
  **docker compose exec n8n_postgres psql -U n8n -d n8n -c "SELECT COUNT(*) FROM konversationen;"**

  Erklärung der Befehlsbestandteile:
  - docker compose exec n8n_postgres — führt einen Befehl im laufenden Container n8n_postgres aus
  - psql -U n8n -d n8n — öffnet eine PostgreSQL-Session als User n8n in der Datenbank n8n
  - -c "..." — führt das SQL-Statement direkt aus (ohne interaktive Shell)

## ♾️ Mit Claude Code n8n workflows bauen:
1. Chat öffnen in Verzeichnis: **\CaterMate-ERP\Source\ai-service**
2. **/mcp** tippen
3. "claude.ai n8n" auswählen und verbinden

## Workflow 2 (Eingangsrechnung erfassen und Stammdaten aktualisieren)
Testen: 
1. Zum **Ordner wechseln**, wo Test pdf ist
2. Befehl ausführen: **curl.exe -X POST https://sequence-amusable-sash.ngrok-free.dev/webhook-test/invoice-check -F "file=@test_rechnung_2026_001.pdf"**
