# Backend API — CaterMate ERP

REST API-Spezifikation für `CaterMate.API` (ASP.NET Core). Alle Endpunkte, Auth-Konzept, Konventionen, Logging und Fehlerbehandlung.

---

## 1. Globale Konventionen

| Eigenschaft | Wert |
|-------------|------|
| Base URL (Dev) | `http://localhost:5000/api` |
| Format | JSON (`Content-Type: application/json`) |
| Namensgebung JSON | `camelCase` (z.B. `guestCount`, `eventDate`) |
| Ressourcennamen | Plural, Englisch (`/orders`, `/menu-items`) |
| Zeitformat | ISO 8601 (`2025-09-15T18:00:00Z`) |
| Fehlerformat | RFC 7807 Problem Details |

### HTTP Status Codes

| Code | Bedeutung | Wann |
|------|-----------|------|
| 200 | OK | Erfolgreiche GET, PUT, PATCH |
| 201 | Created | Erfolgreiche POST (neue Ressource) |
| 204 | No Content | Erfolgreiche DELETE |
| 400 | Bad Request | Validierungsfehler (Data Annotations fehlgeschlagen) |
| 401 | Unauthorized | Kein oder ungültiger JWT |
| 403 | Forbidden | JWT vorhanden, aber Aktion nicht erlaubt |
| 404 | Not Found | Ressource existiert nicht |
| 409 | Conflict | Ungültiger Statusübergang (z.B. Angebot für ungeprüften Auftrag) |
| 500 | Internal Server Error | Unerwarteter Fehler — wird geloggt |

### Fehlerformat (RFC 7807)

```json
{
  "status": 400,
  "title": "Bad Request",
  "detail": "guest_count muss größer als 0 sein"
}
```

---

## 2. Authentifizierung & Sicherheit

### 2.1 JWT — Web-UI

Die Catering-Mitarbeiter authentifizieren sich via Username/Passwort. Der Login-Endpoint gibt ein JWT zurück, das für alle weiteren Requests als Bearer Token mitgeschickt wird.

**Login:**
```
POST /api/auth/login
```

Request:
```json
{
  "username": "max.mustermann",
  "password": "geheim123"
}
```

Response `200 OK`:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresAt": "2025-09-15T20:00:00Z"
}
```

Alle geschützten Endpunkte erfordern:
```
Authorization: Bearer <token>
```

**Token-Konfiguration (via `.env`):**

| Variable | Beschreibung |
|----------|-------------|
| `JWT_SECRET` | Signing-Secret (min. 32 Zeichen) |
| `JWT_ISSUER` | Herausgeber (`catermate`) |
| `JWT_EXPIRY_HOURS` | Gültigkeitsdauer in Stunden (Standard: `8`) |

### 2.2 n8n — API-Zugang

> **Offene Entscheidung (Zuständig: Thomas / AI-Team)**
>
> Wie sich n8n am Backend authentifiziert, ist noch nicht festgelegt. Zwei Optionen stehen zur Auswahl:
>
> **Option A — API-Key im Header (empfohlen):**
> n8n schickt `X-Api-Key: <secret>` mit. Backend prüft gegen `N8N_API_KEY` aus `.env`. Simpel, kein Token-Refresh notwendig.
>
> **Option B — Service-JWT:**
> n8n führt denselben Login-Flow wie die UI durch und nutzt ein langlebiges JWT. Mehr Overhead, aber einheitliches Auth-System.
>
> Bis zur Entscheidung: alle n8n-Endpunkte als `[AllowAnonymous]` markieren und mit einem TODO versehen.

### 2.3 CORS

```
Allowed Origins (Dev):  http://localhost:3000
Allowed Origins (Prod): <Frontend-Domain>
Allowed Methods:        GET, POST, PUT, PATCH, DELETE
Allowed Headers:        Content-Type, Authorization
```

---

## 3. Validierung

Requests werden über **Data Annotations** auf den Request-DTOs validiert. Das ASP.NET Core Model Binding wirft automatisch `400 Bad Request` bei Validierungsfehlern.

```csharp
public class CreateOrderRequest
{
    [Required]
    public string CustomerName { get; set; } = "";

    [Required]
    public DateTime EventDate { get; set; }

    [Range(1, 5000)]
    public int GuestCount { get; set; }
}
```

Business-Logik-Validierungen (z.B. Statusübergang erlaubt?) werden in `BusinessLogic` geprüft und als `409 Conflict` zurückgegeben.

---

## 4. Logging

Strukturiertes Logging via **Serilog** (Sink: Konsole + optional File).

| Level | Was wird geloggt |
|-------|-----------------|
| `Information` | Jeder eingehende Request (Methode, Pfad, Status-Code, Dauer in ms) |
| `Warning` | Validierungsfehler (400), Auth-Fehler (401/403), ungültige Statusübergänge |
| `Error` | Unerwartete Exceptions (500) — inkl. Stack Trace |

**Pflicht-Felder je Log-Eintrag:** `timestamp`, `level`, `requestId`, `method`, `path`, `statusCode`, `durationMs`

---

## 5. Endpunkte

### 5.1 Auth

| Methode | Pfad | Beschreibung | Auth |
|---------|------|-------------|------|
| POST | `/api/auth/login` | JWT holen | Nein |
| POST | `/api/auth/refresh` | Token erneuern | Ja |

---

### 5.2 Aufträge (`/api/orders`)

| Methode | Pfad | Beschreibung | Auth |
|---------|------|-------------|------|
| GET | `/api/orders` | Alle Aufträge (optional: `?status=Neu`) | Ja |
| GET | `/api/orders/{id}` | Einzelner Auftrag mit Details | Ja |
| POST | `/api/orders` | Neuen Auftrag anlegen (von n8n oder UI) | TBD (n8n-Auth) |
| PATCH | `/api/orders/{id}` | Auftrag aktualisieren (Status, Menüartikel, Felder) | Ja |
| DELETE | `/api/orders/{id}` | Auftrag löschen (nur Status `Neu`) | Ja |

**Query-Parameter GET /api/orders:**

| Parameter | Typ | Beschreibung |
|-----------|-----|-------------|
| `status` | string | Filtert nach Status (z.B. `Neu`, `Bestätigt`) |
| `from` | date | Eventdatum ab (ISO 8601) |
| `to` | date | Eventdatum bis (ISO 8601) |

**CreateOrderRequest (POST):**
```json
{
  "customerName": "Maria Huber",
  "customerPhone": "+43 664 123456",
  "eventDate": "2025-10-20T18:00:00Z",
  "eventType": "Hochzeit",
  "location": "Wien, Rathaus",
  "guestCount": 120,
  "budget": 4500.00,
  "specialWishes": "Vegetarische Optionen gewünscht",
  "allergies": "Laktose, Gluten"
}
```

**OrderDto (Response):**
```json
{
  "id": 42,
  "customerName": "Maria Huber",
  "customerPhone": "+43 664 123456",
  "eventDate": "2025-10-20T18:00:00Z",
  "eventType": "Hochzeit",
  "location": "Wien, Rathaus",
  "guestCount": 120,
  "budget": 4500.00,
  "specialWishes": "Vegetarische Optionen gewünscht",
  "allergies": "Laktose, Gluten",
  "status": "Neu",
  "assignedMenuItems": [],
  "createdAt": "2025-09-01T10:30:00Z"
}
```

**UpdateOrderRequest (PATCH)** — alle Felder optional:
```json
{
  "status": "Geprüft",
  "assignedMenuItemIds": [3, 7, 12],
  "guestCount": 125
}
```

**Status-Pipeline (gültige Übergänge):**

```
Neu → Geprüft → AngebotErstellt → Bestätigt → InBeschaffung → InVorbereitung → Durchgeführt → Abgerechnet
```

Ungültige Übergänge: `409 Conflict`.

---

### 5.3 Menüartikel (`/api/menu-items`)

| Methode | Pfad | Beschreibung | Auth |
|---------|------|-------------|------|
| GET | `/api/menu-items` | Alle Menüartikel (optional: `?category=Hauptgang`) | Ja |
| GET | `/api/menu-items/{id}` | Einzelner Menüartikel mit Stückliste | Ja |
| POST | `/api/menu-items` | Neuen Menüartikel anlegen | Ja |
| PUT | `/api/menu-items/{id}` | Menüartikel vollständig ersetzen | Ja |
| DELETE | `/api/menu-items/{id}` | Menüartikel löschen (nur wenn nicht in aktivem Auftrag) | Ja |

**MenuItemDto:**
```json
{
  "id": 7,
  "name": "Wiener Schnitzel",
  "category": "Hauptgang",
  "salesPricePerPerson": 18.50,
  "purchaseCostPerPerson": 8.20,
  "allergens": ["Gluten", "Ei", "Milch"],
  "billOfMaterials": [
    { "ingredientId": 3, "ingredientName": "Kalbfleisch", "quantityGrams": 200 },
    { "ingredientId": 8, "ingredientName": "Semmelbrösel", "quantityGrams": 50 }
  ]
}
```

---

### 5.4 Zutaten (`/api/ingredients`)

| Methode | Pfad | Beschreibung | Auth |
|---------|------|-------------|------|
| GET | `/api/ingredients` | Alle Zutaten | Ja |
| GET | `/api/ingredients/{id}` | Einzelne Zutat | Ja |
| POST | `/api/ingredients` | Neue Zutat anlegen | Ja |
| PUT | `/api/ingredients/{id}` | Zutat aktualisieren (Name, EK-Preis) | Ja |

**IngredientDto:**
```json
{
  "id": 3,
  "name": "Kalbfleisch",
  "unit": "g",
  "purchasePricePerUnit": 0.045,
  "category": "Fleisch"
}
```

---

### 5.5 Angebote (`/api/orders/{orderId}/quote`)

| Methode | Pfad | Beschreibung | Auth |
|---------|------|-------------|------|
| POST | `/api/orders/{orderId}/quote` | Angebot generieren (aus Auftrag) | Ja |
| GET | `/api/orders/{orderId}/quote` | Angebot abrufen | Ja |
| PUT | `/api/orders/{orderId}/quote` | Angebot manuell anpassen | Ja |
| GET | `/api/orders/{orderId}/quote/pdf` | Angebot als PDF herunterladen | Ja |

**QuoteDto:**
```json
{
  "id": 15,
  "orderId": 42,
  "positions": [
    {
      "menuItemId": 7,
      "menuItemName": "Wiener Schnitzel",
      "quantity": 125,
      "unitPrice": 18.50,
      "totalNet": 2312.50,
      "vatRate": 0.10,
      "vatAmount": 231.25,
      "totalGross": 2543.75
    }
  ],
  "adminFee": 250.00,
  "profitMargin": 0.15,
  "totalNet": 2562.50,
  "totalVat": 256.25,
  "totalGross": 2818.75,
  "createdAt": "2025-09-02T14:00:00Z"
}
```

**USt.-Regeln (Österreich):**
- Speisen: 10 %
- Alkoholische Getränke: 20 %
- Kategorie `Getränk (alkoholisch)` → 20 %; alle anderen → 10 %

---

### 5.6 Einkaufslisten (`/api/orders/{orderId}/purchase-list`)

Wird automatisch erstellt, wenn ein Auftrag auf `Bestätigt` gesetzt wird.

| Methode | Pfad | Beschreibung | Auth |
|---------|------|-------------|------|
| GET | `/api/orders/{orderId}/purchase-list` | Einkaufsliste abrufen | Ja |
| PATCH | `/api/purchase-list-items/{itemId}` | Item als erledigt markieren | Ja |
| GET | `/api/orders/{orderId}/purchase-list/pdf` | Einkaufsliste als PDF | Ja |

**PurchaseListDto:**
```json
{
  "id": 8,
  "orderId": 42,
  "safetyMargin": 0.10,
  "groups": [
    {
      "category": "Fleisch",
      "items": [
        {
          "id": 101,
          "ingredientId": 3,
          "ingredientName": "Kalbfleisch",
          "requiredQuantity": 27500,
          "unit": "g",
          "isDone": false
        }
      ]
    }
  ]
}
```

---

### 5.7 Rechnungen (`/api/orders/{orderId}/invoice`)

| Methode | Pfad | Beschreibung | Auth |
|---------|------|-------------|------|
| POST | `/api/orders/{orderId}/invoice` | Rechnung aus Auftrag erstellen | Ja |
| GET | `/api/orders/{orderId}/invoice` | Rechnung abrufen | Ja |
| GET | `/api/orders/{orderId}/invoice/pdf` | Rechnung als PDF herunterladen | Ja |

**InvoiceDto:**
```json
{
  "id": 5,
  "invoiceNumber": "CM-2025-0005",
  "orderId": 42,
  "customerName": "Maria Huber",
  "issueDate": "2025-10-21",
  "dueDate": "2025-11-04",
  "positions": [...],
  "totalNet": 2562.50,
  "totalVat": 256.25,
  "totalGross": 2818.75
}
```

Rechnungsnummer: fortlaufend, Format `CM-{JAHR}-{4-stellige Nummer}`.

---

### 5.8 Eingangsrechnungen — OCR (`/api/incoming-invoices`)

Für den n8n-gesteuerten OCR-Workflow zur Aktualisierung von Einkaufspreisen.

| Methode | Pfad | Beschreibung | Auth |
|---------|------|-------------|------|
| POST | `/api/incoming-invoices` | Bild hochladen → triggert n8n OCR-Workflow | Ja |
| GET | `/api/incoming-invoices/{id}/suggestions` | Extrahierte Preisvorschläge abrufen | Ja |
| POST | `/api/incoming-invoices/{id}/confirm` | Vorschläge bestätigen → aktualisiert Stammdaten | Ja |

**Upload (multipart/form-data):**
```
POST /api/incoming-invoices
Content-Type: multipart/form-data

file: <Bilddatei>
```

**SuggestionDto:**
```json
{
  "id": 22,
  "incomingInvoiceId": 10,
  "ingredientId": 3,
  "ingredientName": "Kalbfleisch",
  "currentPrice": 0.045,
  "suggestedPrice": 0.052,
  "accepted": null
}
```

**Confirm-Request:**
```json
{
  "decisions": [
    { "suggestionId": 22, "accepted": true },
    { "suggestionId": 23, "accepted": false }
  ]
}
```

---

### 5.9 Gerichtsvorschläge (`/api/orders/{orderId}/suggestions`)

KI-gestützte Gerichtsvorschläge beim Prüfen eines Auftrags.

| Methode | Pfad | Beschreibung | Auth |
|---------|------|-------------|------|
| GET | `/api/orders/{orderId}/suggestions` | Passende Menüartikel vorschlagen | Ja |

**SuggestionsResponse:**
```json
{
  "suggestions": [
    {
      "menuItemId": 7,
      "menuItemName": "Wiener Schnitzel",
      "reason": "Passt zu Eventtyp Hochzeit und Budget; keine Allergen-Konflikte"
    }
  ]
}
```

---

### 5.10 Dashboard (`/api/dashboard`)

| Methode | Pfad | Beschreibung | Auth |
|---------|------|-------------|------|
| GET | `/api/dashboard` | KPIs: offene Aufträge, Umsatz, Top-Kunden | Ja |

**DashboardDto:**
```json
{
  "ordersByStatus": {
    "Neu": 3,
    "Geprüft": 1,
    "AngebotErstellt": 2,
    "Bestätigt": 4
  },
  "revenueByMonth": [
    { "month": "2025-09", "totalGross": 12400.00 },
    { "month": "2025-10", "totalGross": 8750.00 }
  ],
  "topCustomers": [
    { "customerName": "Maria Huber", "orderCount": 3, "totalRevenue": 8418.75 }
  ]
}
```
