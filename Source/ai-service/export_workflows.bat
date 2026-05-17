@echo off
echo n8n-Workflows werden aus der Datenbank exportiert...
docker compose exec n8n n8n export:workflow --all --output=/workflows/all_workflows.json
echo Fertig! Die all_workflows.json wurde erfolgreich aktualisiert.
pause