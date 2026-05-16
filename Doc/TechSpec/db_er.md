# Datenbankschema — CaterMate ERP

ER-Diagramm und Tabellendefinitionen für MySQL 8. Schema wird als explizites SQL-Skript (database/schema.sql) versioniert — kein Code-First, keine automatischen Migrations.

---

## 1. Konventionen

| Eigenschaft | Wert |
|-------------|------|
| Namensgebung | PascalCase (Tabellen und Spalten) |
| Primary Keys | Id INT AUTO_INCREMENT |
| Foreign Keys | <Tabelle>Id (z.B. OrderId) |
| Zeitstempel | DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP |	
| Boolesches | TINYINT(1) — 0 = false, 1 = true |
| Dezimalzahlen | DECIMAL(10,2) für Preise; DECIMAL(10,4) für Einheitspreise und Raten |
| Status-Werte | VARCHAR(50) — entsprechen direkt den API-Status-Strings |

### Snapshots in Positionstabellen

QuotePositions und InvoicePositions speichern MenuItemName und UnitPrice als Snapshot zum Zeitpunkt der Erstellung. Grund: Stammdaten (Name, Preis) können sich später ändern — historische Belege müssen aber den Originalzustand abbilden.

---

## 2. ER-Diagramm
``` mermaid

erDiagram
    Users {
        int Id PK
        varchar Username
        varchar PasswordHash
        datetime CreatedAt
    }

    Customers {
        int Id PK
        varchar Name
        varchar Phone
        datetime CreatedAt
    }

    Orders {
        int Id PK
        int CustomerId FK
        datetime EventDate
        varchar EventType
        varchar Location
        int GuestCount
        decimal Budget
        text SpecialWishes
        text Allergies
        varchar Status
        datetime CreatedAt
        datetime UpdatedAt
    }

    MenuItems {
        int Id PK
        varchar Name
        varchar Category
        decimal SalesPricePerPerson
        decimal PurchaseCostPerPerson
        varchar Allergens
        datetime CreatedAt
    }

    Ingredients {
        int Id PK
        varchar Name
        varchar Unit
        decimal PurchasePricePerUnit
        varchar Category
        datetime CreatedAt
        datetime UpdatedAt
    }

    MenuItemIngredients {
        int Id PK
        int MenuItemId FK
        int IngredientId FK
        decimal QuantityPerPerson
    }

    OrderMenuItems {
        int Id PK
        int OrderId FK
        int MenuItemId FK
    }

    Quotes {
        int Id PK
        int OrderId FK
        decimal AdminFee
        decimal ProfitMarginRate
        decimal TotalNet
        decimal TotalVat
        decimal TotalGross
        datetime CreatedAt
    }

    QuotePositions {
        int Id PK
        int QuoteId FK
        int MenuItemId FK
        varchar MenuItemName
        int Quantity
        decimal UnitPrice
        decimal TotalNet
        decimal VatRate
        decimal VatAmount
        decimal TotalGross
    }

    PurchaseLists {
        int Id PK
        int OrderId FK
        decimal SafetyMargin
        datetime CreatedAt
    }

    PurchaseListItems {
        int Id PK
        int PurchaseListId FK
        int IngredientId FK
        varchar IngredientName
        decimal RequiredQuantity
        varchar Unit
        varchar Category
        tinyint IsDone
    }

    Invoices {
        int Id PK
        int OrderId FK
        varchar InvoiceNumber
        varchar CustomerName
        date IssueDate
        date DueDate
        decimal TotalNet
        decimal TotalVat
        decimal TotalGross
        datetime CreatedAt
    }

    InvoicePositions {
        int Id PK
        int InvoiceId FK
        int MenuItemId FK
        varchar MenuItemName
        int Quantity
        decimal UnitPrice
        decimal TotalNet
        decimal VatRate
        decimal VatAmount
        decimal TotalGross
    }

    IncomingInvoices {
        int Id PK
        varchar FilePath
        varchar Status
        datetime CreatedAt
        datetime ProcessedAt
    }

    IncomingInvoiceSuggestions {
        int Id PK
        int IncomingInvoiceId FK
        int IngredientId FK
        decimal CurrentPrice
        decimal SuggestedPrice
        tinyint Accepted
    }

    Customers          ||--o{ Orders                  : "hat"
    Orders             ||--o{ OrderMenuItems          : "zugeordnet"
    MenuItems          ||--o{ OrderMenuItems          : "in"
    MenuItems          ||--o{ MenuItemIngredients     : "hat"
    Ingredients        ||--o{ MenuItemIngredients     : "in"
    Orders             ||--o| Quotes                  : "hat"
    Quotes             ||--o{ QuotePositions          : "enthält"
    MenuItems          ||--o{ QuotePositions          : "referenziert"
    Orders             ||--o| PurchaseLists           : "hat"
    PurchaseLists      ||--o{ PurchaseListItems       : "enthält"
    Ingredients        ||--o{ PurchaseListItems       : "referenziert"
    Orders             ||--o| Invoices                : "hat"
    Invoices           ||--o{ InvoicePositions        : "enthält"
    MenuItems          ||--o{ InvoicePositions        : "referenziert"
    IncomingInvoices   ||--o{ IncomingInvoiceSuggestions : "erzeugt"
    Ingredients        ||--o{ IncomingInvoiceSuggestions : "betrifft"



```



---

## 3. Tabellendefinitionen

### Users

Benutzeraccounts für die Web-UI. Passwörter werden als bcrypt-Hash gespeichert.

| Spalte       | Typ          | Constraints             | Beschreibung |
| ------------ | ------------ | ----------------------- | ------------ |
| Id           | INT          | PK, AUTO_INCREMENT      |              |
| Username     | VARCHAR(100) | NOT NULL, UNIQUE        | Login-Name   |
| PasswordHash | VARCHAR(255) | NOT NULL                | bcrypt-Hash  |
| CreatedAt    | DATETIME     | NOT NULL, DEFAULT NOW() |              |

---

### Customers

Kundenstammdaten. Ein Kunde kann mehrere Aufträge haben.

| Spalte    | Typ          | Constraints             | Beschreibung |
| --------- | ------------ | ----------------------- | ------------ |
| Id        | INT          | PK, AUTO_INCREMENT      |              |
| Name      | VARCHAR(200) | NOT NULL                |              |
| Phone     | VARCHAR(50)  | NULL                    |              |
| CreatedAt | DATETIME     | NOT NULL, DEFAULT NOW() |              |

---

### Orders

Zentrale Entität. Jeder Auftrag durchläuft die Status-Pipeline.

| Spalte        | Typ           | Constraints                       | Beschreibung                            |
| ------------- | ------------- | --------------------------------- | --------------------------------------- |
| Id            | INT           | PK, AUTO_INCREMENT                |                                         |
| CustomerId    | INT           | NOT NULL, FK → Customers          |                                         |
| EventDate     | DATETIME      | NOT NULL                          | Datum und Uhrzeit des Events            |
| EventType     | VARCHAR(100)  | NULL                              | z.B. Hochzeit, Firmenfeier              |
| Location      | VARCHAR(300)  | NOT NULL                          |                                         |
| GuestCount    | INT           | NOT NULL                          | Muss > 0 sein (Applikationsvalidierung) |
| Budget        | DECIMAL(10,2) | NULL                              | Kundenwunsch-Budget                     |
| SpecialWishes | TEXT          | NULL                              | Freitext aus Telegram-Gespräch          |
| Allergies     | TEXT          | NULL                              | Freitext aus Telegram-Gespräch          |
| Status        | VARCHAR(50)   | NOT NULL, DEFAULT 'Neu'           | Gültige Werte: siehe Status-Pipeline    |
| CreatedAt     | DATETIME      | NOT NULL, DEFAULT NOW()           |                                         |
| UpdatedAt     | DATETIME      | NOT NULL, DEFAULT NOW() ON UPDATE |                                         |

*Gültige Status-Werte:* Neu → Geprüft → AngebotErstellt → Bestätigt → InBeschaffung → InVorbereitung → Durchgeführt → Abgerechnet


---

### MenuItems

Menüartikel-Stammdaten. Basis für Angebote, Einkaufslisten und Gerichtsvorschläge.

| Spalte                | Typ           | Constraints             | Beschreibung                                               |
| --------------------- | ------------- | ----------------------- | ---------------------------------------------------------- |
| Id                    | INT           | PK, AUTO_INCREMENT      |                                                            |
| Name                  | VARCHAR(200)  | NOT NULL                |                                                            |
| Category              | VARCHAR(50)   | NOT NULL                | Vorspeise, Hauptgang, Dessert, Getränk, GetränkAlkoholisch |
| SalesPricePerPerson   | DECIMAL(10,2) | NOT NULL                | Verkaufspreis pro Person                                   |
| PurchaseCostPerPerson | DECIMAL(10,2) | NOT NULL                | Einkaufspreis pro Person (manuell oder aus Stückliste)     |
| Allergens             | VARCHAR(500)  | NULL                    | Kommagetrennte Liste (z.B. Gluten,Ei,Milch)                |
| CreatedAt             | DATETIME      | NOT NULL, DEFAULT NOW() |                                                            |

*USt.-Logik:* Kategorie GetränkAlkoholisch → 20 %; alle anderen → 10 %.


---

### Ingredients

Zutaten-Stammdaten. Reine Referenztabelle — keine Bestandsführung.

| Spalte               | Typ           | Constraints                       | Beschreibung                                                      |
| -------------------- | ------------- | --------------------------------- | ----------------------------------------------------------------- |
| Id                   | INT           | PK, AUTO_INCREMENT                |                                                                   |
| Name                 | VARCHAR(200)  | NOT NULL, UNIQUE                  |                                                                   |
| Unit                 | VARCHAR(20)   | NOT NULL                          | z.B. g, ml, Stück                                                 |
| PurchasePricePerUnit | DECIMAL(10,4) | NOT NULL                          | EK-Preis pro Einheit; wird durch OCR-Workflow aktualisiert        |
| Category             | VARCHAR(100)  | NULL                              | Warengruppe für Einkaufslisten-Gruppierung (z.B. Fleisch, Gemüse) |
| CreatedAt            | DATETIME      | NOT NULL, DEFAULT NOW()           |                                                                   |
| UpdatedAt            | DATETIME      | NOT NULL, DEFAULT NOW() ON UPDATE |                                                                   |

---

### MenuItemIngredients

Stückliste: welche Zutat in welcher Menge pro Person in einem Menüartikel enthalten ist.

| Spalte            | Typ           | Constraints                | Beschreibung                              |
| ----------------- | ------------- | -------------------------- | ----------------------------------------- |
| Id                | INT           | PK, AUTO_INCREMENT         |                                           |
| MenuItemId        | INT           | NOT NULL, FK → MenuItems   |                                           |
| IngredientId      | INT           | NOT NULL, FK → Ingredients |                                           |
| QuantityPerPerson | DECIMAL(10,3) | NOT NULL                   | Menge in der Einheit von Ingredients.Unit |

*Constraint:* UNIQUE (MenuItemId, IngredientId) — eine Zutat nur einmal pro Menüartikel.

---

### OrderMenuItems

Junction-Tabelle: welche Menüartikel einem Auftrag zugeordnet sind.

| Spalte     | Typ | Constraints              | Beschreibung |
| ---------- | --- | ------------------------ | ------------ |
| Id         | INT | PK, AUTO_INCREMENT       |              |
| OrderId    | INT | NOT NULL, FK → Orders    |              |
| MenuItemId | INT | NOT NULL, FK → MenuItems |              |

*Constraint:* UNIQUE (OrderId, MenuItemId) — kein doppeltes Zuordnen.

---

### Quotes

Angebot zu einem Auftrag. 1:1-Beziehung zu Orders.

| Spalte           | Typ           | Constraints                   | Beschreibung         |
| ---------------- | ------------- | ----------------------------- | -------------------- |
| Id               | INT           | PK, AUTO_INCREMENT            |                      |
| OrderId          | INT           | NOT NULL, UNIQUE, FK → Orders |                      |
| AdminFee         | DECIMAL(10,2) | NOT NULL, DEFAULT 0           | Verwaltungspauschale |
| ProfitMarginRate | DECIMAL(5,4)  | NOT NULL, DEFAULT 0.1500      | z.B. 0.1500 = 15 %   |
| TotalNet         | DECIMAL(10,2) | NOT NULL                      | Netto-Gesamtbetrag   |
| TotalVat         | DECIMAL(10,2) | NOT NULL                      | USt.-Gesamtbetrag    |
| TotalGross       | DECIMAL(10,2) | NOT NULL                      | Brutto-Gesamtbetrag  |
| CreatedAt        | DATETIME      | NOT NULL, DEFAULT NOW()       |                      |

---

### QuotePositions

Einzelne Positionen im Angebot. Speichert Snapshot von Name und Preis.

| Spalte       | Typ           | Constraints              | Beschreibung                                  |
| ------------ | ------------- | ------------------------ | --------------------------------------------- |
| Id           | INT           | PK, AUTO_INCREMENT       |                                               |
| QuoteId      | INT           | NOT NULL, FK → Quotes    |                                               |
| MenuItemId   | INT           | NOT NULL, FK → MenuItems |                                               |
| MenuItemName | VARCHAR(200)  | NOT NULL                 | Snapshot zum Zeitpunkt der Angebotserstellung |
| Quantity     | INT           | NOT NULL                 | = GuestCount des Auftrags                     |
| UnitPrice    | DECIMAL(10,2) | NOT NULL                 | Snapshot von SalesPricePerPerson              |
| TotalNet     | DECIMAL(10,2) | NOT NULL                 |                                               |
| VatRate      | DECIMAL(5,4)  | NOT NULL                 | 0.1000 oder 0.2000                            |
| VatAmount    | DECIMAL(10,2) | NOT NULL                 |                                               |
| TotalGross   | DECIMAL(10,2) | NOT NULL                 |                                               |

---

### PurchaseLists

Einkaufsliste zu einem bestätigten Auftrag. 1:1-Beziehung zu Orders.

| Spalte       | Typ          | Constraints                   | Beschreibung                 |
| ------------ | ------------ | ----------------------------- | ---------------------------- |
| Id           | INT          | PK, AUTO_INCREMENT            |                              |
| OrderId      | INT          | NOT NULL, UNIQUE, FK → Orders |                              |
| SafetyMargin | DECIMAL(5,4) | NOT NULL, DEFAULT 0.1000      | z.B. 0.1000 = 10 % Aufschlag |
| CreatedAt    | DATETIME     | NOT NULL, DEFAULT NOW()       |                              |

---

### PurchaseListItems

Einzelne Zutaten-Positionen in der Einkaufsliste.

| Spalte           | Typ           | Constraints                  | Beschreibung                                        |
| ---------------- | ------------- | ---------------------------- | --------------------------------------------------- |
| Id               | INT           | PK, AUTO_INCREMENT           |                                                     |
| PurchaseListId   | INT           | NOT NULL, FK → PurchaseLists |                                                     |
| IngredientId     | INT           | NOT NULL, FK → Ingredients   |                                                     |
| IngredientName   | VARCHAR(200)  | NOT NULL                     | Snapshot                                            |
| RequiredQuantity | DECIMAL(10,3) | NOT NULL                     | Menge × Personen × (1 + SafetyMargin)               |
| Unit             | VARCHAR(20)   | NOT NULL                     | Snapshot von Ingredients.Unit                       |
| Category         | VARCHAR(100)  | NULL                         | Snapshot von Ingredients.Category (für Gruppierung) |
| IsDone           | TINYINT(1)    | NOT NULL, DEFAULT 0          | Abgehakt durch Mitarbeiter                          |

---

### Invoices

Rechnung zu einem abgeschlossenen Auftrag. 1:1-Beziehung zu Orders.

| Spalte | Typ | Constraints | Beschreibung |
|--------|-----|-------------|-------------|
| Id | INT | PK, AUTO_INCREMENT | |
| OrderId | INT | NOT NULL, UNIQUE, FK → Orders | |
| InvoiceNumber | VARCHAR(20) | NOT NULL, UNIQUE | Format: CM-{JAHR}-{4-stellig}, z.B. CM-2025-0005 |
| CustomerName | VARCHAR(200) | NOT NULL | Snapshot |
| IssueDate | DATE | NOT NULL | Ausstellungsdatum |
| DueDate | DATE | NOT NULL | Zahlungsziel |
| TotalNet | DECIMAL(10,2) | NOT NULL | |
| TotalVat | DECIMAL(10,2) | NOT NULL | |
| TotalGross | DECIMAL(10,2) | NOT NULL | |
| CreatedAt | DATETIME | NOT NULL, DEFAULT NOW() | |

---

### InvoicePositions

Einzelne Positionen in der Rechnung. Übernommen aus dem Angebot.

| Spalte       | Typ           | Constraints              | Beschreibung |
| ------------ | ------------- | ------------------------ | ------------ |
| Id           | INT           | PK, AUTO_INCREMENT       |              |
| InvoiceId    | INT           | NOT NULL, FK → Invoices  |              |
| MenuItemId   | INT           | NOT NULL, FK → MenuItems |              |
| MenuItemName | VARCHAR(200)  | NOT NULL                 | Snapshot     |
| Quantity     | INT           | NOT NULL                 |              |
| UnitPrice    | DECIMAL(10,2) | NOT NULL                 | Snapshot     |
| TotalNet     | DECIMAL(10,2) | NOT NULL                 |              |
| VatRate      | DECIMAL(5,4)  | NOT NULL                 |              |
| VatAmount    | DECIMAL(10,2) | NOT NULL                 |              |
| TotalGross   | DECIMAL(10,2) | NOT NULL                 |              |

---

### IncomingInvoices

Hochgeladene Lieferantenrechnungen für den OCR-Workflow.

| Spalte      | Typ          | Constraints                 | Beschreibung                           |
| ----------- | ------------ | --------------------------- | -------------------------------------- |
| Id          | INT          | PK, AUTO_INCREMENT          |                                        |
| FilePath    | VARCHAR(500) | NOT NULL                    | Pfad zur Bilddatei im Container-Volume |
| Status      | VARCHAR(50)  | NOT NULL, DEFAULT 'Pending' | Pending, Processed, Confirmed          |
| CreatedAt   | DATETIME     | NOT NULL, DEFAULT NOW()     |                                        |
| ProcessedAt | DATETIME     | NULL                        | Zeitpunkt der n8n-OCR-Verarbeitung     |

---

### IncomingInvoiceSuggestions

Preisänderungs-Vorschläge aus dem OCR-Ergebnis — zeilenweise vom User bestätigbar.

| Spalte            | Typ           | Constraints                     | Beschreibung                               |
| ----------------- | ------------- | ------------------------------- | ------------------------------------------ |
| Id                | INT           | PK, AUTO_INCREMENT              |                                            |
| IncomingInvoiceId | INT           | NOT NULL, FK → IncomingInvoices |                                            |
| IngredientId      | INT           | NOT NULL, FK → Ingredients      |                                            |
| CurrentPrice      | DECIMAL(10,4) | NOT NULL                        | EK-Preis vor OCR-Vorschlag                 |
| SuggestedPrice    | DECIMAL(10,4) | NOT NULL                        | Aus Lieferantenrechnung extrahierter Preis |
| Accepted          | TINYINT(1)    | NULL                            | NULL = offen, 1 = bestätigt, 0 = abgelehnt |

---

## 4. Indexe

| Tabelle             | Index                  | Spalten                  | Grund                                         |
| ------------------- | ---------------------- | ------------------------ | --------------------------------------------- |
| Orders              | idx_orders_customer    | CustomerId               | Aufträge je Kunde                             |
| Orders              | idx_orders_status      | Status                   | Filterung nach Status im Dashboard und Listen |
| Orders              | idx_orders_event_date  | EventDate                | Datumsbasierte Abfragen                       |
| MenuItemIngredients | uq_menuitem_ingredient | MenuItemId, IngredientId | UNIQUE Constraint                             |
| OrderMenuItems      | uq_order_menuitem      | OrderId, MenuItemId      | UNIQUE Constraint                             |
| Invoices            | uq_invoice_number      | InvoiceNumber            | UNIQUE Constraint                             |
| Ingredients         | uq_ingredient_name     | Name                     | UNIQUE Constraint                             |
