@echo off
cd /d "%~dp0..\Docker"
echo n8n-Workflows werden aus der Datenbank exportiert...
docker compose exec n8n n8n export:workflow --all --separate --output=/workflows/
echo Fertig! Alle Workflows wurden als einzelne JSON-Dateien in ai-service/workflows/ gespeichert.
pause
