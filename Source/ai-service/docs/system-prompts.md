# System-Prompts der KI-Modelle

Dieses Dokument hält die Systemprompts der KI-Modelle in den n8n-Workflows fest. Die Prompts sind die maßgebliche Quelle für das Verhalten der Modelle — Änderungen daran wirken sich direkt auf Antwortqualität, Tonfall und Datenausgabe-Struktur aus.

> **Pflege-Hinweis:** Die unten markierten Platzhalterblöcke (`<!-- PROMPT: ... -->`) füllt Thomas manuell mit dem aktuellen Wortlaut aus den n8n-Knoten. Beim Ändern eines Prompts im n8n-UI bitte hier mitziehen, damit dieses Dokument synchron bleibt.

---

## Workflow 1 — Gemini Slot-Filling

**Knoten:** `Message a model` · **Modell:** Google Gemini 3.5 Flash · **Output:** Strukturiertes JSON (`state` + `antwort_text`)

### Zweck

Führt den Gesprächsfaden mit dem Telegram-Kunden, extrahiert die Anfrage-Pflichtfelder (Slot-Filling), pflegt den Konversations-`state` und liefert die nächste Frage an den Kunden zurück. Hält sich strikt an die Catering-Domäne und reagiert robust auf Edge Cases (Prompt-Manipulation, Themenwechsel, mehrfache Infos in einer Nachricht).

### Kernverhalten (Kurzfassung)

- **Rolle:** Freundlicher Assistent von „CaterMate", sammelt nur Anfragedaten — erstellt keine Angebote, gibt keine Preiszusagen.
- **State-Logik:** Liest `state.letzte_antwort`, um Kontext für kurze Antworten (`?`, `ja`, `nein`) zu verstehen. Felder mit Werten werden nie auf `null` zurückgesetzt, außer bei aktiver Korrektur durch den Kunden.
- **Phasen:** `in_bearbeitung` → `warte_auf_bestaetigung` → `bestaetigt`.
- **Pflichtfelder:** datum, anlass, personenanzahl, budget, ort, speisen_wuensche, allergien, sonstige_wuensche.
- **Sonderfeature:** Einmalige Nachfrage nach konkretem Datum + Uhrzeit (State-Flag `datum_uhrzeit_konkret_abgefragt`).
- **Budget-Frage:** Beim ersten Mal mit Preisorientierungs-Liste (Richtpreise pro Person netto).

### Vollständiger Prompt

<!-- PROMPT: Workflow 1 — Gemini Slot-Filling — hier den aktuellen Wortlaut aus dem n8n-Knoten "Message a model" einfügen -->

```text
[Platzhalter — bitte aktuellen Systemprompt aus n8n hier einfügen]
```

### Ausgabeformat (vereinbart)

```json
{
  "state": {
    "konversation_id": "string",
    "status": "in_bearbeitung | warte_auf_bestaetigung | bestaetigt",
    "letzte_antwort": "string | null",
    "kunde": { "telegram_user_id": "string", "telegram_name": "string" },
    "anfrage": {
      "datum_text": "string | null",
      "datum_iso": "YYYY-MM-DD | null",
      "uhrzeit_text": "string | null",
      "uhrzeit_iso": "HH:MM | null",
      "anlass": "string | null",
      "personenanzahl": "number | null",
      "budget": "number | null",
      "ort": "string | null",
      "speisen_wuensche": "string | null",
      "allergien": "string | null | \"keine\"",
      "sonstige_wuensche": "string | null | \"\""
    },
    "datum_uhrzeit_konkret_abgefragt": "boolean",
    "fehlende_felder": ["string", "..."],
    "letzte_aktualisierung": ""
  },
  "antwort_text": "string"
}
```

---

## Workflow 1 — Claude Menü-Agent

**Knoten:** `Agent: Generate Proposal of Offer` · **Modell:** Claude Sonnet 4.6 (Agent-Modus) · **Tool:** `Menukatalog abfragen` (MySQL) · **Output-Parser:** Structured Output Parser mit JSON-Schema

### Zweck

Nach Bestätigung der Anfrage durch den Kunden generiert dieser Agent einen passenden Menüvorschlag aus dem `MenuItems`-Katalog. Berücksichtigt Budget (minus 200 EUR Verwaltungspauschale), Allergien, Anlass und Speisewünsche.

### Kernverhalten (Kurzfassung)

- **Werkzeug:** Liest den vollständigen `MenuItems`-Katalog (Id, Name, Category, SalesPricePerPerson, Allergens, Tags, Eignung, Beschreibung) per SQL-Tool ein.
- **Budget-Hartgrenze:** Summe (`SalesPricePerPerson × count`) ≤ verfügbares Menübudget.
- **Allergien-Filter:** Gericht wird verworfen, wenn `Allergens` eine Allergie des Kunden enthält.
- **Auswahl:** Üblicherweise Vorspeise + Hauptgang + Dessert, optional Getränk. 1–8 Gerichte.
- **Mengenlogik:** `count` pro Gericht — die Summe pro Kategorie entspricht der Personenanzahl.

### Vollständiger Prompt

<!-- PROMPT: Workflow 1 — Claude Menü-Agent — hier den aktuellen Wortlaut aus dem n8n-Knoten "Agent: Generate Proposal of Offer" → systemMessage einfügen -->

```text
[Platzhalter — bitte aktuellen Systemprompt aus n8n hier einfügen]
```

### Ausgabeformat (Schema)

```json
{
  "proposal": [
    {
      "menuItemId": 1,
      "name": "Beispielgericht",
      "category": "Hauptgang",
      "pricePerPerson": 24.00,
      "count": 80,
      "reason": "Beispielbegruendung"
    }
  ],
  "reason": "Gesamtbegruendung fuer die Auswahl"
}
```

### User-Prompt-Template (Einzel-Turn)

Wird pro Anfrage dynamisch zusammengebaut. Inhalt: Kundenname, Anlass, Datum, Personenanzahl, Gesamtbudget, verfügbares Menübudget, Ort, Speisewünsche, Allergien, sonstige Wünsche. Endet mit der Anweisung, zuerst den Katalog per Tool abzufragen.

<!-- PROMPT: Workflow 1 — Claude Menü-Agent — User-Prompt-Template aus dem Feld "text" des Agent-Knotens einfügen -->

```text
[Platzhalter — bitte aktuelles User-Prompt-Template einfügen]
```

---

## Workflow 2 — Claude PDF-Analyse

**Knoten:** `PDF analysieren` · **Modell:** Claude Sonnet 4.6 (document/binary input) · **Output:** JSON mit Rechnungspositionen + Fuzzy-Match auf Ingredients

### Zweck

Liest eine Eingangsrechnung als PDF (Binär), extrahiert alle Rechnungspositionen und ordnet jede Position per Fuzzy-Matching einer Zutat aus der DB zu. Unbekannte Zutaten werden mit `matched_ingredient = ""` und `matched_ingredient_id = -1` markiert.

### Kernverhalten

- **Input:** PDF binär + dynamisch eingebettete Zutatenliste (Format `ID 1: Avocado (Stk)`).
- **Matching:** Fuzzy — z. B. „Hass Avocado Premium" → ID 1 (Avocado).
- **Output:** **Reines** JSON ohne Markdown-Codefences (wird im Folgeknoten geparst, der zwar Markdown-Striping macht, aber sauberes JSON ist sicherer).
- **Felder pro Position:** description, matched_ingredient, matched_ingredient_id, quantity, unit, unit_price, total_price.
- **Header-Felder:** invoice_number, supplier, invoice_date.

### Vollständiger Prompt (User-Prompt — kein klassischer System-Prompt)

Der Anthropic-Document-Knoten in n8n verwendet keinen separaten Systemprompt-Slot, sondern einen einzigen Text-Prompt, der dem PDF beigelegt wird. Inhalt:

<!-- PROMPT: Workflow 2 — Claude PDF-Analyse — hier den aktuellen Wortlaut aus dem n8n-Knoten "PDF analysieren" → Feld "text" einfügen -->

```text
[Platzhalter — bitte aktuellen Prompt aus n8n hier einfügen]
```

### Ausgabeformat (Schema)

```json
{
  "invoice_number": "RE-2026-001",
  "supplier": "Lieferant XY",
  "invoice_date": "2026-05-20",
  "positions": [
    {
      "description": "Bezeichnung auf Rechnung",
      "matched_ingredient": "Name aus DB oder leerer String",
      "matched_ingredient_id": 1,
      "quantity": 50,
      "unit": "Stk",
      "unit_price": 1.85,
      "total_price": 92.50
    }
  ]
}
```

---

## Änderungs-Workflow

Wenn ein Prompt im n8n-UI geändert wird:

1. Änderung im n8n-UI (Live-Instanz) speichern.
2. Workflow testen — Definition of Done laut [CLAUDE.md](../CLAUDE.md) einhalten.
3. Hier in `system-prompts.md` den entsprechenden Platzhalterblock aktualisieren.
4. `docker compose exec n8n n8n export:workflow --all --output=/workflows/all_workflows.json` ausführen.
5. Committen mit `feat(ai)` oder `fix(ai)` und kurzer Erläuterung der Prompt-Änderung im Commit-Body.
