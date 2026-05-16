### UC-01: Anfrage über WhatsApp-Bot erfassen

- **Akteur:** Endkunde (Anfragesteller)
- **Auslöser:** Kunde schreibt WhatsApp-Nachricht an Catering-Nummer
- **Vorbedingung:** WhatsApp-Bot aktiv, Nummer veröffentlicht
- **Hauptablauf:**
    1. Kunde startet Chat mit beliebiger Eingangsnachricht
    2. Bot begrüßt und fragt strukturiert ab: Eventdatum, Uhrzeit, Personenanzahl, Eventtyp, Ort, Budget, Sonderwünsche, Allergien
    3. Bot validiert Plausibilität (Datum in Zukunft, Personenanzahl > 0)
    4. Bot checkt Verfügbarkeit mit bereits geplanten Events
    5. Bot fasst Daten zusammen und lässt Kunden bestätigen
    6. System legt neuen Auftrag im Status `Neu` an, Originalchat wird gespeichert
- **Alternativablauf:** Kunde gibt unvollständige/widersprüchliche Daten → Bot fragt gezielt nach
- **Nachbedingung:** Auftrag erscheint in Auftragsliste

---

### UC-02: Auftrag bearbeiten und qualifizieren

- **Akteur:** User
- **Auslöser:** Neuer Auftrag in Pipeline-Spalte `Neu`
- **Hauptablauf:**
    1. User öffnet Auftragsliste, navigiert zu neue Aufträge
    2. Öffnet Detailansicht, prüft Originalanfrage aus WhatsApp
    3. Überprüft Auftragsdaten
    4. System schlägt Gerichte (mit Kosten und Gewinn) vor, anhand der Sonderwünsche. User ordnet Gerichte zu.
    5. Speichert neuen Status →  `Geprüft`
- **Nachbedingung:** Auftrag bereit für Angebotserstellung

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
    3. System übernimmt alle Positionen aus Angebot, vergibt fortlaufende Rechnungsnummer, Datum, Zahlungsziel
    4. Druckansicht der Rechnung wird erzeugt
    5. Status springt auf `Abgerechnet`
- **Nachbedingung:** Formal korrekte Rechnung verfügbar, Auftrag abgeschlossen

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
