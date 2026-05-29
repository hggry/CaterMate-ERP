-- ============================================================
-- CaterMate-ERP: Vokabular-Migration – Schritt 2
-- Datenmigration (Transaktion mit Verifikation vor COMMIT)
-- Datum: 2026-05-29
-- ============================================================
--
-- Mapping-Regeln (zusammengefasst):
--   Category: nur lowercase; 'Buffet' → 'gebäck' (Id=8 via Bäckerei-Tag)
--   Eignung:  lowercase, Tokens ohne Leerzeichen; 'Vegetarisch' → Tags
--   Tags:     lowercase, Tokens ohne Leerzeichen;
--             'Klassiker' → 'klassisch'
--             'Strudel'   → entfernen
--             'Bäckerei'  → entfernen (+ Category='gebäck' wenn passend)
--             'Buffet'    → entfernen (+ in Eignung)
--             'Suppe'     → entfernen (Category bleibt 'hauptgang' bei Tafelspitz)
-- ============================================================

SET NAMES utf8mb4;

START TRANSACTION;

-- ---- Hauptgänge -------------------------------------------------------

-- Id=1: Wiener Schnitzel mit Erdäpfelsalat
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'mittag,abend,business',
  Tags     = 'warm,traditionell,österreichisch'
WHERE Id = 1;

-- Id=2: Tafelspitz — Tags: 'Suppe' entfernt (Tafelspitz ist kein Suppengang)
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'abend,business,festlich',
  Tags     = 'warm,traditionell,österreichisch'
WHERE Id = 2;

-- Id=3: Gemüse-Risotto — Eignung 'Vegetarisch' → Tags (war dort bereits; dedupliziert)
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'mittag,abend,buffet',
  Tags     = 'warm,vegetarisch,italienisch,cremig'
WHERE Id = 3;

-- Id=9: Rinderfilet mit Kartoffelgratin
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'abend,business,festlich'
WHERE Id = 9;

-- Id=10: Lammkeule mit Polenta
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'abend,festlich'
WHERE Id = 10;

-- Id=11: Entenbrust mit Orangensoße
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'abend,festlich,business'
WHERE Id = 11;

-- Id=12: Schweinebauch mit Kartoffelpüree
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'mittag,abend'
WHERE Id = 12;

-- Id=13: Zanderfilet auf Spinatbett
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'mittag,abend,business'
WHERE Id = 13;

-- Id=14: Garnelen-Risotto
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'mittag,abend,business,sommer'
WHERE Id = 14;

-- Id=15: Pasta Bolognese
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'mittag,business'
WHERE Id = 15;

-- Id=16: Tagliatelle mit Lachs und Spinat
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'mittag,abend'
WHERE Id = 16;

-- Id=17: Linsen-Eintopf mit Speck
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'mittag,buffet'
WHERE Id = 17;

-- Id=18: Kürbis-Gnocchi mit Salbeibutter — Eignung 'Vegetarisch' → Tags
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'mittag,abend',
  Tags     = 'vegetarisch'
WHERE Id = 18;

-- Id=19: Hühnerbrust in Champignonrahmsoße
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'mittag,abend,business'
WHERE Id = 19;

-- Id=20: Paprikahühnchen mit Reis
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'mittag,abend,buffet'
WHERE Id = 20;

-- Id=21: Kalbsbäckchen geschmort
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'abend,festlich'
WHERE Id = 21;

-- Id=22: Forelle Müllerin
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'mittag,abend'
WHERE Id = 22;

-- Id=23: Veganer Gemüsestrudel — Eignung 'Vegetarisch' → Tags
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'mittag,abend,buffet',
  Tags     = 'vegetarisch'
WHERE Id = 23;

-- Id=24: Rindsgulasch mit Semmelknödel
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'mittag,abend,business'
WHERE Id = 24;

-- Id=25: Spargel-Risotto mit Parmesan — Eignung 'Vegetarisch' → Tags
UPDATE MenuItems SET
  Category = 'hauptgang',
  Eignung  = 'mittag,abend,sommer',
  Tags     = 'vegetarisch'
WHERE Id = 25;

-- ---- Vorspeisen -------------------------------------------------------

-- Id=4: Lachstatar auf Brioche
UPDATE MenuItems SET
  Category = 'vorspeise',
  Eignung  = 'buffet,business,abend,empfang',
  Tags     = 'kalt,fisch,elegant,modern'
WHERE Id = 4;

-- Id=5: Caprese-Spieß
UPDATE MenuItems SET
  Category = 'vorspeise',
  Eignung  = 'buffet,empfang,mittag,sommer',
  Tags     = 'kalt,vegetarisch,italienisch,fingerfood'
WHERE Id = 5;

-- Id=26: Avocado-Toast mit Räucherlachs
UPDATE MenuItems SET
  Category = 'vorspeise',
  Eignung  = 'buffet,business,empfang,sommer'
WHERE Id = 26;

-- Id=27: Bruschetta mit Tomaten und Rucola
UPDATE MenuItems SET
  Category = 'vorspeise',
  Eignung  = 'buffet,empfang,sommer'
WHERE Id = 27;

-- Id=28: Garnelencocktail
UPDATE MenuItems SET
  Category = 'vorspeise',
  Eignung  = 'buffet,business,empfang,abend'
WHERE Id = 28;

-- Id=29: Kürbiscremesuppe
-- Kein 'Suppe'-Tag vorhanden → Regel greift nicht automatisch.
-- Category bleibt 'vorspeise' (zur manuellen Klärung im Report).
UPDATE MenuItems SET
  Category = 'vorspeise',
  Eignung  = 'mittag,abend,buffet'
WHERE Id = 29;

-- Id=30: Beef Carpaccio mit Rucola und Parmesan
UPDATE MenuItems SET
  Category = 'vorspeise',
  Eignung  = 'abend,business,festlich'
WHERE Id = 30;

-- Id=31: Räucherlachs auf Toast
UPDATE MenuItems SET
  Category = 'vorspeise',
  Eignung  = 'buffet,business,empfang,abend'
WHERE Id = 31;

-- ---- Desserts ---------------------------------------------------------

-- Id=6: Sachertorte — Tags: 'Klassiker' → 'klassisch'
UPDATE MenuItems SET
  Category = 'dessert',
  Eignung  = 'abend,buffet,festlich,nachmittag',
  Tags     = 'kalt,süß,österreichisch,klassisch'
WHERE Id = 6;

-- Id=7: Topfenstrudel — Tags: 'Strudel' entfernt
UPDATE MenuItems SET
  Category = 'dessert',
  Eignung  = 'mittag,abend,buffet,nachmittag',
  Tags     = 'warm,süß,österreichisch'
WHERE Id = 7;

-- Id=32: Crème Brûlée
UPDATE MenuItems SET
  Category = 'dessert',
  Eignung  = 'abend,festlich,business'
WHERE Id = 32;

-- Id=33: Mousse au Chocolat
UPDATE MenuItems SET
  Category = 'dessert',
  Eignung  = 'abend,buffet,festlich'
WHERE Id = 33;

-- Id=34: Erdbeer-Panna-Cotta
UPDATE MenuItems SET
  Category = 'dessert',
  Eignung  = 'abend,buffet,sommer'
WHERE Id = 34;

-- Id=35: Apfelstrudel
UPDATE MenuItems SET
  Category = 'dessert',
  Eignung  = 'mittag,abend,buffet,nachmittag'
WHERE Id = 35;

-- ---- Gebäck -----------------------------------------------------------

-- Id=8: Laugenbäck-Assortment
--   Category 'Buffet' → 'gebäck'  (Bäckerei-Tag → gebäck-Regel)
--   Tags: 'Buffet' + 'Bäckerei' entfernt; 'buffet' war bereits in Eignung
UPDATE MenuItems SET
  Category = 'gebäck',
  Eignung  = 'buffet,business,empfang,mittag',
  Tags     = 'kalt,herzhaft'
WHERE Id = 8;


-- ============================================================
-- VERIFIKATION VOR COMMIT
-- ============================================================

SELECT 'CHECK 1: Ungueltige Categories (erwartet: 0 Zeilen)' AS check_name;
SELECT m.Id, m.Name, m.Category AS ungueltige_category
FROM MenuItems m
LEFT JOIN FilterVocabulary fv ON fv.field = 'category' AND fv.value = m.Category
WHERE fv.value IS NULL;

SELECT 'CHECK 2: Ungueltige Eignung-Tokens (erwartet: 0 Zeilen)' AS check_name;
WITH RECURSIVE nums AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 15
),
etokens AS (
  SELECT
    m.Id, m.Name,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(m.Eignung, ',', n.n), ',', -1)) AS tok
  FROM MenuItems m
  JOIN nums n ON n.n <= 1 + LENGTH(m.Eignung) - LENGTH(REPLACE(m.Eignung, ',', ''))
  WHERE m.Eignung IS NOT NULL
)
SELECT et.Id, et.Name, et.tok AS ungueltig
FROM etokens et
LEFT JOIN FilterVocabulary fv ON fv.field = 'eignung' AND fv.value = et.tok
WHERE fv.value IS NULL AND et.tok != '';

SELECT 'CHECK 3: Ungueltige Tag-Tokens (erwartet: 0 Zeilen)' AS check_name;
WITH RECURSIVE nums AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 15
),
ttokens AS (
  SELECT
    m.Id, m.Name,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(m.Tags, ',', n.n), ',', -1)) AS tok
  FROM MenuItems m
  JOIN nums n ON n.n <= 1 + LENGTH(m.Tags) - LENGTH(REPLACE(m.Tags, ',', ''))
  WHERE m.Tags IS NOT NULL
)
SELECT tt.Id, tt.Name, tt.tok AS ungueltig
FROM ttokens tt
LEFT JOIN FilterVocabulary fv ON fv.field = 'tag' AND fv.value = tt.tok
WHERE fv.value IS NULL AND tt.tok != '';

SELECT 'ALLE ZEILEN NACH MIGRATION' AS check_name;
SELECT Id, Name, Category, Eignung, Tags FROM MenuItems ORDER BY Id;

COMMIT;
SELECT 'COMMIT erfolgreich — Migration abgeschlossen.' AS status;
