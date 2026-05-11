## Funktionaler Scope

### 1.1 MVP-Funktionen

**1.1.1 Whatsapp Bot (KI)**

- Whatsapp Bot der für Kunden jederzeit erreichbar ist
- Durch Dialog werden folgende Informationen extrahiert:
    - Eventdatum, Eventuhrzeit, Personenanzahl, Eventtyp (Hochzeit/Firmenfeier/Geburtstag/Sonstiges), Eventort, Budget, Sonderwünsche und Allergien.

**1.1.2 Auftragsverwaltung**

- Übersichtsliste aller Aufträge mit Filter nach Status und Datum.
- Status-Pipeline mit klar definierten Phasen: Neu → Angebot erstellt → Bestätigt → In Beschaffung → In Vorbereitung → Durchgeführt → Abgerechnet.
- Detailansicht je Auftrag mit allen Stammdaten, Originalanfrage und Bearbeitungshistorie.
- Bearbeitung aller Felder mit Validierung (z. B. Personenanzahl > 0, Datum in der Zukunft).

**1.1.3 Menü- und Artikelverwaltung (Stammdaten)**

- Zentraler Menüartikel-Katalog mit Bezeichnung, Kategorie (Vorspeise/Hauptgang/Dessert/Getränk), Verkaufspreis pro Person, Einkaufskosten und Allergen-Kennzeichnung.
- Hinterlegung von Stücklisten(Zutaten) je Gericht als Grundlage der Einkaufsliste.
- Zutaten-Stammdatenkatalog (rein als Referenz, ohne Bestandsführung).

**1.1.4 Angebotserstellung**

- Generierung eines Angebots (PDF) aus einem Auftrag heraus per Knopfdruck.
- Automatische Berechnung der Positionen aus zugeordneten Menüartikeln und Personenanzahl.
- Anzeige von Zwischensumme, USt. (10%/20% nach österreichischer Logik) und Gesamtbetrag.
- Kostenkalkulation und Deckungsbeitrag pro Auftrag (Einkaufskosten vs. Angebotssumme).

**1.1.5 Auftragsbezogene Einkaufsliste**

- Automatische erstellung einer Einkaufsliste anhand der Zutaten aus allen zugeordneten Menüartikeln eines bestätigten Auftrags.
- Skalierung der Mengen anhand der Personenanzahl mit konfigurierbarem Sicherheitsaufschlag (z. B. 10%).
- Druckansicht der Einkaufsliste, gruppiert nach Warengruppen (Fleisch, Gemüse, Getränke …).
- Tracking des Beschaffungsstatus pro Einkaufsliste: Offen → In Beschaffung → Erledigt.
- Position-für-Position-Häkchen: einzelne Zutaten als "besorgt" markieren.

**1.1.6 Rechnungsstellung**

- Erzeugung einer Rechnung aus einem durchgeführten Auftrag.
- Übernahme aller Positionen aus dem Angebot, optional mit nachträglichen Korrekturen.
- Fortlaufende Rechnungsnummer, Rechnungsdatum, Zahlungsziel.
- Druckansicht im Layout einer einfachen, formal korrekten Rechnung.

**1.1.7 Eingangsrechnung Verwaltung**

- Einkaufsrechnungen werden eingescannt → KI wertet die Positionen (Preise) aus und macht einen Vorschlag für Preisänderung in den Stammdaten
- User muss eine Bestätigung machen.

**1.1.8 Dashboard mit Kennzahlen**

- offene Aufträge Umsatz pro Monat, Top-Kunden

### 1.2 Nice-to-have-Funktionen

- Verwaltung von allen Eingangsrechnungen für Controlling Auswertungen
- Kundenverwaltung mit Auftragshistorie und Stammdaten.

### 1.3 Bewusste Abgrenzungen

- **Keine Lager- oder Bestandsverwaltung**: Beschaffung ist rein auftragsbezogen.
- **Keine KI-generierten Gerichte**: Die KI arbeitet ausschließlich mit dem vorhandenen Stammdatenkatalog.
- **Nur Deutsch als UI-Sprache**: Keine Mehrsprachigkeit im MVP.
