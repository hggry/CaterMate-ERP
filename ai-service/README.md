# 🤖 AI-Service (n8n Setup)



Dieses Verzeichnis enthält die n8n-Infrastruktur für lokale Entwicklung.



## 💾 Workflows exportieren (Vor dem Git-Commit)

Bevor Änderungen an n8n auf GitHub gepusht werden, muss der aktuelle Stand aus der Container-Datenbank in den lokalen Ordner exportiert werden. Führe dazu folgenden Befehl in diesem Ordner aus:





docker compose exec n8n n8n export:workflow --all --output=/workflows/all\_workflows.json

