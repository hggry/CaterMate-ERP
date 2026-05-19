# 🤖 AI-Service (n8n Setup)



Dieses Verzeichnis enthält die n8n-Infrastruktur für lokale Entwicklung.



## 💾 Workflows exportieren (Vor dem Git-Commit)

Bevor Änderungen an n8n auf GitHub gepusht werden, muss der aktuelle Stand aus der Container-Datenbank in den lokalen Ordner exportiert werden. Führe dazu folgenden Befehl in diesem Ordner aus:





docker compose exec n8n n8n export:workflow --all --output=/workflows/all\_workflows.json



## 🗄️Befehle für PostgreSQL Datenbank:

Zur DB im Terminal navigieren: **docker exec -it ai-service-postgres-1 psql -U n8n -d n8n**

state der Anfrage in Tabelle Konversation selektieren: **SELECT state FROM konversationen;**

## ♾️ Mit Claude Code n8n workflows bauen:
1. Chat öffnen in Verzeichnis: **\CaterMate-ERP\Source\ai-service**
2. **/mcp** tippen
3. "claude.ai n8n" auswählen und verbinden
