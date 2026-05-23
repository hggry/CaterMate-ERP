# 🤖 AI-Service (n8n Setup)



Dieses Verzeichnis enthält die n8n-Infrastruktur für lokale Entwicklung.



## 💾 Workflows exportieren (Vor dem Git-Commit)

Bevor Änderungen an n8n auf GitHub gepusht werden, muss der aktuelle Stand aus der Container-Datenbank in den lokalen Ordner exportiert werden. Führe dazu folgenden Befehl in diesem Ordner aus:





**docker compose exec n8n n8n export:workflow --all --output=/workflows/all\_workflows.json**



## 🗄️Befehle und Infos zur PostgreSQL Datenbank (wichtig zum testen für Workflow 1):

 ### Einträge (Konversationen) aus einer n8n-PostgreSQL-Tabelle löschen:

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

### Detailinfos zur Spalte "status"
  - Typ: VARCHAR(50), NOT NULL
  - Default: 'chatting'
  - Valide Werte: chatting, offer_in_making, offer_sent, offer_accepted, offer_rejected (per CHECK-Constraint)

    

## ♾️ Mit Claude Code n8n workflows bauen:
1. Chat öffnen in Verzeichnis: **\CaterMate-ERP\Source\ai-service**
2. **/mcp** tippen
3. "claude.ai n8n" auswählen und verbinden

   
## Workflow 2 (Eingangsrechnung erfassen und Stammdaten aktualisieren)
Testen (Windows Powershell): 

### 1. Tabellen-Inhalt prüfen
Ingredients (inkl. Counter): 
**docker exec docker-db-1 mysql -u catermate_user -pcatermate_dev_password catermate_db -e "SELECT Id, Name, Unit, PurchasePricePerUnit, consecutive_over_count FROM Ingredients ORDER BY Id;"**

IncomingInvoiceSuggestions (neueste zuerst):
**docker exec -e MYSQL_PWD=catermate_dev_password docker-db-1 mysql -u catermate_user catermate_db -e "SELECT Id, IncomingInvoiceId, IngredientId, CurrentPrice, SuggestedPrice, Accepted FROM IncomingInvoiceSuggestions ORDER BY Id DESC;"**

Check rows with:
**docker exec -e MYSQL_PWD=catermate_dev_password docker-db-1 mysql -u catermate_user catermate_db -e "SELECT COUNT(*) AS row_count FROM IncomingInvoiceSuggestions;"**


### 2. Counter zurücksetzen (ohne Zutaten zu löschen)
**docker exec -e MYSQL_PWD=catermate_dev_password docker-db-1 mysql -u catermate_user catermate_db -e "UPDATE Ingredients SET consecutive_over_count = 0;"**
Setzt den Zähler für alle Zutaten auf 0 — die Zutaten selbst bleiben unverändert.

### 3. PDFs an den Workflow senden (Backend-Simulation)
⚠️ Voraussetzung, sonst klappt es nicht:

Eine IncomingInvoices-Zeile muss existieren (FK-Constraint):

**docker exec -e MYSQL_PWD=catermate_dev_password docker-db-1 mysql -u catermate_user catermate_db -e "INSERT INTO IncomingInvoices (FilePath, Status) VALUES ('test_rechnung_2026_002.pdf', 'Pending'), ('test_rechnung_2026_003.pdf', 'Pending'), ('test_rechnung_2026_004.pdf', 'Pending'), ('test_rechnung_2026_005.pdf', 'Pending'), ('test_rechnung_2026_006.pdf', 'Pending'); SELECT Id, FilePath FROM IncomingInvoices ORDER BY Id;"**

status checken:
**docker exec -e MYSQL_PWD=catermate_dev_password docker-db-1 mysql -u catermate_user catermate_db -e "SELECT Id, FilePath, Status, CreatedAt, ProcessedAt FROM IncomingInvoices ORDER BY Id DESC;"**


### 4. Zum **Ordner wechseln**, wo Test pdf ist

### 5. Rechnung + ID mit diesen Befehl an workflow senden: 

Pro Aufruf eine PDF mit der zugehörigen incomingInvoiceId. Annahme: IncomingInvoices-Zeilen haben die IDs 1, 2, 3, … (was bei einer leeren Tabelle der Fall ist).

**curl.exe -X POST "https://sequence-amusable-sash.ngrok-free.dev/webhook/invoice-check" -F "file=@C:\Users\thoma\Downloads\Test Invoices\test_rechnung_2026_002.pdf" -F "incomingInvoiceId=1"**

**curl.exe -X POST "https://sequence-amusable-sash.ngrok-free.dev/webhook/invoice-check" -F "file=@C:\Users\thoma\Downloads\Test Invoices\test_rechnung_2026_003.pdf" -F "incomingInvoiceId=2"**

**curl.exe -X POST "https://sequence-amusable-sash.ngrok-free.dev/webhook/invoice-check" -F "file=@C:\Users\thoma\Downloads\Test Invoices\test_rechnung_2026_004.pdf" -F "incomingInvoiceId=3"**

**curl.exe -X POST "https://sequence-amusable-sash.ngrok-free.dev/webhook/invoice-check" -F "file=@C:\Users\thoma\Downloads\Test Invoices\test_rechnung_2026_005.pdf" -F "incomingInvoiceId=4"**

**curl.exe -X POST "https://sequence-amusable-sash.ngrok-free.dev/webhook/invoice-check" -F "file=@C:\Users\thoma\Downloads\Test Invoices\test_rechnung_2026_006.pdf" -F "incomingInvoiceId=5"**



## Workflow 3 (Angebot an Telegram-User senden) 
Testen:
**curl.exe -X POST "https://sequence-amusable-sash.ngrok-free.dev/webhook-test/send-offer?konversation_id=7539208775" -F "data=@C:\Users\thoma\Name der pdf.pdf"
{"message":"Workflow was started"}**
