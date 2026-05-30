### UC-01: Anfrage über Telegram-Bot erfassen

- **Akteur:** Endkunde (Anfragesteller)
- **Auslöser:** Kunde schreibt Telegram-Nachricht an Catering-Bot
- **Vorbedingung:** Telegram-Bot aktiv, Bot-Link veröffentlicht
- **Hauptablauf:**
    1. Kunde startet Chat mit beliebiger Eingangsnachricht
    2. Bot begrüßt und fragt strukturiert ab: Eventdatum, Uhrzeit, Personenanzahl, Eventtyp, Ort, Budget, Sonderwünsche, Allergien
    3. Bot validiert Plausibilität (Datum in Zukunft, Personenanzahl > 0)
    4. Bot checkt Verfügbarkeit mit bereits geplanten Events
    5. Bot fasst Daten zusammen und lässt Kunden bestätigen
    6. n8n schlägt passende Menüartikel aus dem Katalog vor (basierend auf Eventtyp, Budget, Allergien)
    7. n8n legt Auftrag im Status `Neu` über `POST /api/n8n/orders` an — inkl. vorgeschlagener Menüartikel
    8. Customer wird anhand der Telefonnummer gemappt: existierender Kunde → zuordnen, unbekannte Nummer → neuen Kunden anlegen
- **Alternativablauf:** Kunde gibt unvollständige/widersprüchliche Daten → Bot fragt gezielt nach
- **Nachbedingung:** Auftrag erscheint in Auftragsliste mit Status `Neu` und bereits vorausgewählten Menüartikeln

> **Hinweis:** Aufträge können auch direkt per Frontend angelegt werden (ohne KI-Bot-Kanal). In diesem Fall entfallen die Schritte 6–8 — Menüartikel werden manuell in UC-02 zugeordnet.

---

### UC-02: Auftrag bearbeiten und qualifizieren

- **Akteur:** User
- **Auslöser:** Neuer Auftrag in Pipeline-Spalte `Neu`
- **Hauptablauf:**
    1. User öffnet Auftragsliste, navigiert zu neue Aufträge
    2. Öffnet Detailansicht (Tab *Übersicht*), prüft Auftrags-/Stammdaten
    3. Wechselt in den Tab *Menü* zur Zusammenstellung
    4. Kam der Auftrag über Telegram: von n8n vorgeschlagene Menüartikel sind bereits zugeordnet und erscheinen in der Menükarte — User prüft, ergänzt oder entfernt Gerichte
    5. Kam der Auftrag direkt per Frontend: User stellt das Menü aus dem durchsuch-/filterbaren Katalog zusammen. Ungeeignete Gerichte (Allergen-Konflikt mit den Auftragsangaben oder Einzelgericht über Budget) werden als *Ungeeignet* gekennzeichnet und lassen sich ausblenden. Die Menükarte zeigt live Warenwert (netto), Budget-Differenz und internen Deckungsbeitrag
    6. Sobald mindestens ein Gericht zugeordnet ist, setzt der User den Status → `Geprüft`
- **Nachbedingung:** Auftrag bereit für Angebotserstellung

> **Hinweis:** Solange einem neuen Auftrag noch kein Gericht zugeordnet ist, führt die Primäraktion zuerst in den Tab *Menü*; erst danach erscheint „Als geprüft markieren".

---

### UC-03: Angebot generieren

- **Akteur:** User
- **Auslöser:** Auftrag im Status `Geprüft`, Gerichte zugeordnet
- **Hauptablauf:**
    1. User klickt im Auftrag auf `Angebot erstellen`
    2. System berechnet Anhand der Stücklisten die Kosten je Gericht × Personenanzahl. Zusätzlich wird eine Verwaltungpauschale und Gewinnmarge draufgerechnet.
    3. Berechnet USt. (10% Speisen, 20% alkoholische Getränke nach AT-Logik), Zwischensumme, Gesamtbetrag
    4. Generiert Angebot, zeigt es zur Prüfung an
    5. User kann manuelle Änderungen vornehmen
    6. User gibt Auftrag frei → Status springt auf `Angebot erstellt`
    7. PDF wird generiert und User versendet PDF
- **Nachbedingung:** Angebot-PDF verfügbar

---

### UC-04: Auftrag bestätigen und Beschaffung anstoßen

- **Akteur:** User
- **Auslöser:** Kunde nimmt Angebot an
- **Hauptablauf:**
    1. User setzt Status auf `Bestätigt`
    2. System aggregiert alle Zutaten aus Stücklisten der zugeordneten Menüartikel
    3. Skaliert Mengen mit Personenanzahl × Sicherheitsaufschlag (z. B. 10%)
    4. Erstellt Einkaufsliste, gruppiert nach Warengruppen
    5. Status springt auf `In Beschaffung`
- **Nachbedingung:** Druckbare, gruppierte Einkaufsliste vorhanden

---

### UC-05: Eingangsrechnung erfassen und Stammdaten aktualisieren

- **Akteur:** User
- **Auslöser:** Lieferantenrechnung liegt vor
- **Hauptablauf:**
    1. User scannt/fotografiert Eingangsrechnung
    2. KI extrahiert Positionen mit Preisen
    3. System vergleicht mit EK-Preisen im Zutaten-Stammdaten und schlägt Preisänderungen vor
    4. User prüft Vorschläge Position-für-Position und bestätigt/lehnt ab
    5. Bestätigte Preise werden in Stammdaten übernommen
- **Nachbedingung:** EK-Kosten aktuell → realistische DB-Kalkulation in Folgeangeboten

---

### UC-06: Beschaffung abschließen und Auftrag in Vorbereitung

- **Akteur:** User
- **Auslöser:** Alle Zutaten wurden eingekauft
- **Hauptablauf:**
    1. User setzt Auftrag Status auf  `In Vorbereitung`

### UC-07: Event durchführen und Rechnung stellen

- **Akteur:** User
- **Auslöser:** Auftrag im Status `In Vorbereitung`, Eventdatum erreicht
- **Hauptablauf:**
    1. Nach Event setzt User Status auf `Durchgeführt`
    2. Klickt auf `Rechnung erstellen`
    3. System übernimmt alle Positionen aus dem freigegebenen Angebot, vergibt fortlaufende Rechnungsnummer, setzt Rechnungsdatum und Zahlungsziel (14 Tage)
    4. Druckansicht der Rechnung wird erzeugt; Auftragsstatus verbleibt auf `Durchgeführt`
    5. User versendet Rechnung an Kunden und wartet auf Zahlungseingang
    6. User bestätigt Zahlungseingang über `Zahlungseingang bestätigen` → Status wechselt auf `Abgerechnet`
- **Nachbedingung:** Formal korrekte Rechnung verfügbar, Zahlungseingang im System hinterlegt, Auftrag vollständig abgeschlossen

---

### UC-08: Geschäft steuern über Kennzahlen-Dashboard

- **Akteur:** User
- **Auslöser:** Wöchentliche Steuerung
- **Hauptablauf:**
    1. User öffnet Dashboard
    2. Sieht: offene Aufträge (nach Pipeline-Phase), Umsatz pro Monat, Top-Kunden, etc.
    3. Drill-down per Klick in Auftragsliste mit passendem Filter
- **Nachbedingung:** Entscheidungsgrundlage für Priorisierung und Vertrieb

---

### UC-09: Stammdaten pflegen

- **Akteur:** User
- **Auslöser:** Neues Gericht aufnehmen oder bestehendes anpassen
- **Hauptablauf:**
    1. User öffnet Gericht-Katalog
    2. Legt Artikel an: Bezeichnung, Kategorie, Allergene
    3. Hinterlegt Stückliste mit Zutaten und Mengen aus Zutaten-Katalog
    4. Speichert – Artikel steht für Auftragszuordnung bereit
- **Nachbedingung:** Artikel kann in Angeboten und Einkaufslisten verwendet werden

---

### UC-10: Auftrag wiedereröffnen oder stornieren

- **Akteur:** User
- **Auslöser:** Kunde hat Änderungswünsche, lehnt das Angebot ab oder springt ganz ab

**Wiedereröffnen (Änderungswünsche / Ablehnung):**
1. Auftrag befindet sich in `AngebotErstellt` oder `InBeschaffung` (Menü/Stammdaten gesperrt)
2. User klickt `Wiedereröffnen` → Status springt zurück auf `Geprüft`
3. Menü-Tab und Stammdaten sind wieder editierbar; das bestehende Angebot bleibt erhalten (weiter herunterladbar/versendbar)
4. Nach Anpassung erzeugt „Angebot erstellen" eine überschriebene, aktuelle Version; bei erneuter Bestätigung wird die Einkaufsliste neu aufgebaut
- **Nachbedingung:** Auftrag erneut im aktiven Workflow, Daten konsistent

**Stornieren (Absprung):**
1. Auftrag in einer offenen Phase (`Neu` … `InVorbereitung`)
2. User klickt `Stornieren` → Status `Storniert`
3. Auftrag verschwindet aus der aktiven Liste (per Status-Filter weiterhin auffindbar) und zählt nicht mehr in Dashboard-Kennzahlen
4. Bei Bedarf kann der Auftrag über `Wiedereröffnen` reaktiviert werden (→ `Geprüft`)
- **Nachbedingung:** Stornierter Auftrag ist sauber abgebildet, Daten bleiben für Audit erhalten
