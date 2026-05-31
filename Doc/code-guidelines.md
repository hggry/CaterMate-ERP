# Code Guidelines

## Farbpalette (Brand Guide)

Die offiziellen CaterMate-Markenfarben. In der Frontend-App stehen sie als globale CSS-Custom-Properties (`App.vue`) zur Verfügung.

| Token | Hex | Verwendung |
|---|---|---|
| `--cm-basis-hell` | `#FBF7F1` | App-Hintergrund |
| `--cm-sand` | `#EAE0CC` | Surface, abwechselnde Tabellenzeilen |
| `--cm-caramel` | `#C2A87C` | Warmer Mid-Tone-Akzent |
| `--cm-espresso` | `#3E2818` | Primärer dunkler Text, Überschriften |
| `--cm-avocado` | `#7AAA28` | **Primärfarbe** (= `--p-primary-color` via Theme) |
| `--cm-teal` | `#20A090` | Sekundärer Akzent |
| `--cm-orange` | `#E84020` | Destruktiv / Alarm / Storniert |

**Regeln:**
- Farbige UI-Elemente (Status-Tags, Budget-Differenz, Dashboard-Icons) nutzen ausschließlich diese Tokens, keine PrimeVue-internen `--p-red-*`/`--p-green-*`-Variablen.
- Buttons bleiben einheitlich im PrimeVue-Theme (Avocado-Primary, ohne manuelles Überschreiben).
- Die Paletten-Tokens sind in `src/App.vue` (`:root`) definiert und in `src/theme.ts` dokumentiert.

---

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

### Responsive Design

CaterMate ERP ist für drei Geräteklassen ausgelegt. Das Desktop-Design (≥ 1024 px) gilt als Referenz und darf nicht durch mobile Anpassungen verändert werden — alle responsiven Regeln liegen ausschließlich in `max-width`-Media-Queries.

#### Breakpoint-System

| Tier | Bereich | Verwendung |
|---|---|---|
| **Phone** | `< 768 px` | Karten statt Tabellen, Hamburger-Drawer, Single-Column-Layouts |
| **Tablet** | `768 px – 1023 px` | Reduzierte Tabellenspalten, Drawer-Navigation, 2-Spalten-Grids |
| **Desktop** | `≥ 1024 px` | Vollständiges Layout — unverändert |

**Konvention:** `max-width` immer mit `0.02 px` Offset schreiben, um Überlapp genau an Breakpoints zu verhindern.

```css
/* Phone */
@media (max-width: 767.98px) { … }

/* Tablet */
@media (min-width: 768px) and (max-width: 1023.98px) { … }
```

#### `useBreakpoint` Composable

Einheitliche, matchMedia-basierte reaktive Refs für alle Komponenten:

```ts
import { useBreakpoint } from '@/composables/useBreakpoint'

const { isPhone, isTablet, isDesktop, isCompactNav } = useBreakpoint()
```

| Ref | True wenn |
|---|---|
| `isPhone` | Viewport `< 768 px` |
| `isTablet` | `768 px ≤` Viewport `< 1024 px` |
| `isDesktop` | Viewport `≥ 1024 px` |
| `isCompactNav` | Viewport `< 1024 px` (steuert Hamburger-Drawer) |

`useBreakpoint` ist der **einzige erlaubte Weg**, um in Script-Logik auf die aktuelle Geräteklasse zu reagieren. Kein direktes `window.innerWidth` im Code.

#### Navigations-Muster

- **Desktop (≥ 1024 px):** Persistente Sidebar links (18 rem breit)
- **Tablet & Phone (< 1024 px):** Schlanker Top-Bar (3,5 rem) mit Hamburger-Button; Sidebar öffnet als Off-Canvas-Drawer mit Scrim. Drawer schließt automatisch bei Navigation und beim Vergrößern des Fensters auf Desktop.

Implementierung: `AppLayout.vue` (Drawer-Logik + Scrim) und `AppSidebar.vue` (emit `navigate` bei Link-Klick).

#### Listen-Muster: Tabellen vs. Karten

Auf **Phone** werden PrimeVue-DataTables durch tippbare Karten ersetzt:

```vue
<template v-if="isPhone">
  <!-- Karten-Layout -->
  <ul class="…-cards">
    <li v-for="item in items" class="…-card" @click="openDetail(item.id)">
      …
    </li>
  </ul>
</template>
<DataTable v-else … />
```

**Welche Views verwenden Karten:**
- `OrdersTable.vue` — Aufträge (auch im Archiv)
- `MenuItemsView.vue` — Menüartikel
- `IngredientsView.vue` — Zutaten

**Welche Views verwenden horizontales Scroll (kein Karten-Metapher):**
- `IncomingInvoiceView.vue` — Eingangsrechnungen (zu viele Aktions-Spalten)
- `PriceSuggestionsView.vue` — Preisvorschläge (Workflow-View, kein reines Listing)

#### PrimeVue Dialoge

Alle Dialoge müssen `:breakpoints` setzen, damit sie auf Phones nicht überlaufen:

```vue
<Dialog
  :style="{ width: '40rem' }"
  :breakpoints="{ '767px': '95vw' }"
/>
```

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
