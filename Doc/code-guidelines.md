# Code Guidelines

## Sprachkonvention

| Bereich | Sprache |
|---|---|
| Dokumentation, Markdown, Kommentare in Docs | Deutsch |
| Quellcode (Klassen, Methoden, Variablen, Code-Kommentare) | Englisch |
| UI-Texte (Labels, Buttons, Fehlermeldungen) | Deutsch |

---

## Solution-Architektur

Die Solution besteht aus vier C#-Projekten mit klar definierter Dependency-Richtung:

```
CaterMate.sln
├─ CaterMate.API           → Controller, Middleware, Program.cs
├─ CaterMate.BusinessLogic → Services, fachliche Logik
├─ CaterMate.Db            → Repositories, SQL-Queries, Db-Entities
└─ CaterMate.DTOs          → Request/Response-Objekte (shared)
```

**Dependency-Richtung** (Pfeile = „referenziert"):
```
API → BusinessLogic → Db
API → DTOs
BusinessLogic → DTOs & Db
Db referenziert KEINE anderen Projekte
```

`CaterMate.Db` kennt weder DTOs noch Business-Logik. Es gibt ausschließlich Db-Entities zurück.

### Unterschied: Db-Entity vs. DTO

| | Db-Entity | DTO |
|---|---|---|
| Lebt in | `CaterMate.Db/Entities/` | `CaterMate.DTOs/` |
| Entspricht | 1:1 einer DB-Tabelle | dem was API-Consumer sehen sollen |
| Verwendet von | Datenbank-Methoden | Controllern und Services |

---

## Backend (C# / ASP.NET)

### Benennung

```csharp
// Klassen: PascalCase
public class OrderService { }

// Methoden: PascalCase, async mit Suffix
public async Task<OrderDto> GetOrderByIdAsync(int id) { }

// Lokale Variablen & Parameter: camelCase
var guestCount = 5;

// Konstanten: UPPER_SNAKE_CASE
private const int MAX_GUEST_COUNT = 500;

// Interfaces: I-Präfix
public interface IOrderService { }
```

### Datenbankzugriff (Dapper)

Dapper wird für alle DB-Zugriffe verwendet — SQL wird direkt als String geschrieben. Kein ORM-Magic, kein Code-First.

```csharp
// Repository in CaterMate.Db
public async Task<Order?> GetByIdAsync(int id)
{
    const string sql = "SELECT * FROM orders WHERE id = @Id";
    return await _connection.QueryFirstOrDefaultAsync<Order>(sql, new { Id = id });
}
```

SQL-Strings in Konstanten auslagern, nicht inline in die Methode schreiben.

### PDF-Generierung (QuestPDF)

QuestPDF wird für Angebots- und Rechnungs-PDFs verwendet. PDF-Logik gehört in einen dedizierten Service in `CaterMate.BusinessLogic` (z.B. `PdfService`), nicht in Controller.

### KI-Schnittstelle

Noch nicht final definiert. Integration erfolgt in `CaterMate.BusinessLogic`. Prompts werden **nicht** als Strings im Code hardcodiert — separate Dateien im Projekt.

---

## Frontend (Vue 3 + PrimeVue + Vite)

### Style: Composition API mit `<script setup>`

```vue
<script setup lang="ts">
import { ref } from 'vue'

const guestCount = ref(0)
</script>
```

Options API wird nicht verwendet.

### Benennung

```
Komponenten-Dateien: PascalCase  → OrderList.vue, MenuItemCard.vue
Composables:         camelCase   → useOrderStore.ts, useApi.ts
CSS-Klassen:         kebab-case  → .order-list, .btn-primary
```

### PrimeVue

PrimeVue-Komponenten werden bevorzugt gegenüber eigenen UI-Elementen. Eigene Styles nur wenn PrimeVue keine passende Komponente bietet.

---

## API-Design

Ressourcennamen: **Plural, Englisch** (`/api/orders`, `/api/menu-items`)

| Aktion | Methode | Beispiel |
|---|---|---|
| Liste | `GET` | `/api/orders` |
| Einzeln | `GET` | `/api/orders/{id}` |
| Erstellen | `POST` | `/api/orders` |
| Ersetzen | `PUT` | `/api/orders/{id}` |
| Teilweise ändern | `PATCH` | `/api/orders/{id}` |
| Löschen | `DELETE` | `/api/orders/{id}` |

Fehlerantworten im RFC 7807 Problem Details Format:
```json
{
  "status": 400,
  "title": "Bad Request",
  "detail": "guest_count must be greater than 0"
}
```

---

## Docker

Jede Änderung muss mit `docker compose up --build` lokal lauffähig sein, bevor ein Pull Request geöffnet wird. Neue Umgebungsvariablen immer auch in `.env.example` eintragen.
