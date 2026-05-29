-- ============================================================
-- CaterMate-ERP: Datenbereicherung – Schritt 8
-- Tags (komplett), Allergens (Korrekturen), Eignung (Ergänzungen)
-- Datum: 2026-05-29
-- ============================================================
--
-- Änderungsübersicht:
--
-- TAGS (25 Zeilen neu befüllt / ergänzt):
--   Id 1,2   + fleisch (Kalbs-/Rindfleisch)
--   Id 8     + österreichisch
--   Id 9-35  vollständig befüllt (waren alle NULL oder nur 1 Wert)
--   Id 23,27 + vegan  (Name/Beschreibung eindeutig vegan)
--
-- ALLERGENS (5 Korrekturen):
--   Id 2  NULL     → sellerie         (Wurzelgemüse enthält Sellerie)
--   Id 4  +ei,laktose                 (Brioche: Butter + Eier)
--   Id 15 +ei,laktose                 (Frische Pasta + Parmesan)
--   Id 16 +ei                         (Tagliatelle = Ei-Pasta)
--   Id 21 NULL     → sellerie,laktose (Mirepoix enthält Sellerie; Butter-Finish)
--
-- EIGNUNG (3 Ergänzungen):
--   Id 8  + frühstück (Laugengebäck ist klassisch ein Frühstücksgebäck)
--   Id 17 + abend     (Eintopf passt auch zum Abendessen)
--   Id 29 + winter    (Kürbis ist Herbst-/Winter-Saisongemüse)
-- ============================================================

SET NAMES utf8mb4;

START TRANSACTION;

-- ============================================================
-- TAGS
-- ============================================================

-- Id=1: + fleisch
UPDATE MenuItems SET Tags = 'warm,traditionell,österreichisch,fleisch'
WHERE Id = 1;

-- Id=2: + fleisch
UPDATE MenuItems SET Tags = 'warm,traditionell,österreichisch,fleisch'
WHERE Id = 2;

-- Id=8: + österreichisch
UPDATE MenuItems SET Tags = 'kalt,herzhaft,österreichisch'
WHERE Id = 8;

-- Id=9: Rinderfilet mit Kartoffelgratin — Premium-Rindfleisch, elegantes Gericht
UPDATE MenuItems SET Tags = 'fleisch,warm,elegant'
WHERE Id = 9;

-- Id=10: Lammkeule mit Polenta — mediterrane Einflüsse (Polenta, Lamm mit Kräutern)
UPDATE MenuItems SET Tags = 'fleisch,warm,mediterran'
WHERE Id = 10;

-- Id=11: Entenbrust mit Orangensoße — Geflügel, elegant, moderne Klassiker
UPDATE MenuItems SET Tags = 'geflügel,warm,elegant,modern'
WHERE Id = 11;

-- Id=12: Schweinebauch mit Kartoffelpüree — herzhaft, traditionell
UPDATE MenuItems SET Tags = 'fleisch,warm,herzhaft,traditionell'
WHERE Id = 12;

-- Id=13: Zanderfilet auf Spinatbett — Fisch, leicht und elegant
UPDATE MenuItems SET Tags = 'fisch,warm,elegant'
WHERE Id = 13;

-- Id=14: Garnelen-Risotto — kein Fisch-Tag (Garnelen = Krebstiere), cremig, mediterran
-- Hinweis: krebstiere ist kein Tag-Vokabular-Wert; nur über Allergens erfasst
UPDATE MenuItems SET Tags = 'warm,cremig,mediterran'
WHERE Id = 14;

-- Id=15: Pasta Bolognese — Fleisch, Herzhafte italienische Küche
UPDATE MenuItems SET Tags = 'fleisch,warm,herzhaft,italienisch'
WHERE Id = 15;

-- Id=16: Tagliatelle mit Lachs und Spinat — Fisch, cremig, italienisch
UPDATE MenuItems SET Tags = 'fisch,warm,cremig,italienisch'
WHERE Id = 16;

-- Id=17: Linsen-Eintopf mit Speck — Fleisch (Speck), herzhaft, traditionell
UPDATE MenuItems SET Tags = 'fleisch,warm,herzhaft,traditionell'
WHERE Id = 17;

-- Id=18: Kürbis-Gnocchi mit Salbeibutter — vegetarisch (bereits), herzhaft, warm ergänzen
UPDATE MenuItems SET Tags = 'vegetarisch,warm,herzhaft'
WHERE Id = 18;

-- Id=19: Hühnerbrust in Champignonrahmsoße — Geflügel, cremig
UPDATE MenuItems SET Tags = 'geflügel,warm,herzhaft,cremig'
WHERE Id = 19;

-- Id=20: Paprikahühnchen mit Reis — Geflügel, traditionell (ungarisch/österreichische Tradition)
UPDATE MenuItems SET Tags = 'geflügel,warm,herzhaft,traditionell'
WHERE Id = 20;

-- Id=21: Kalbsbäckchen geschmort — Fleisch, Schmorgerichte = traditionell + elegant
UPDATE MenuItems SET Tags = 'fleisch,warm,elegant,traditionell'
WHERE Id = 21;

-- Id=22: Forelle Müllerin — Österreichischer Klassiker mit Fisch
UPDATE MenuItems SET Tags = 'fisch,warm,traditionell,österreichisch'
WHERE Id = 22;

-- Id=23: Veganer Gemüsestrudel — explizit vegan laut Name + Beschreibung
UPDATE MenuItems SET Tags = 'vegetarisch,vegan,warm,österreichisch'
WHERE Id = 23;

-- Id=24: Rindsgulasch mit Semmelknödel — Wiener Klassiker
UPDATE MenuItems SET Tags = 'fleisch,warm,herzhaft,österreichisch,traditionell'
WHERE Id = 24;

-- Id=25: Spargel-Risotto — vegetarisch, Risotto = italienisch
UPDATE MenuItems SET Tags = 'vegetarisch,warm,cremig,italienisch'
WHERE Id = 25;

-- Id=26: Avocado-Toast mit Räucherlachs — modern, Fisch, kalt
UPDATE MenuItems SET Tags = 'fisch,kalt,modern,elegant'
WHERE Id = 26;

-- Id=27: Bruschetta mit Tomaten und Rucola — vegan (kein tierisches Produkt), italienisch
UPDATE MenuItems SET Tags = 'vegetarisch,vegan,kalt,italienisch,fingerfood'
WHERE Id = 27;

-- Id=28: Garnelencocktail — kalt, elegant; kein Fisch-Tag (Garnelen ≠ Fisch)
UPDATE MenuItems SET Tags = 'kalt,elegant,modern'
WHERE Id = 28;

-- Id=29: Kürbiscremesuppe — vegetarisch, warm, cremig, österreichisch
UPDATE MenuItems SET Tags = 'vegetarisch,warm,cremig,österreichisch'
WHERE Id = 29;

-- Id=30: Beef Carpaccio — Fleisch, kalt, modern
UPDATE MenuItems SET Tags = 'fleisch,kalt,elegant,modern'
WHERE Id = 30;

-- Id=31: Räucherlachs auf Toast — Fisch, kalt, elegant
UPDATE MenuItems SET Tags = 'fisch,kalt,elegant,modern'
WHERE Id = 31;

-- Id=32: Crème Brûlée — klassisches Dessert, kalt
UPDATE MenuItems SET Tags = 'kalt,süß,cremig,elegant,klassisch'
WHERE Id = 32;

-- Id=33: Mousse au Chocolat — international (franz. Dessert), kalt
UPDATE MenuItems SET Tags = 'kalt,süß,cremig,elegant,international'
WHERE Id = 33;

-- Id=34: Erdbeer-Panna-Cotta — Panna Cotta = italienisch, kalt
UPDATE MenuItems SET Tags = 'kalt,süß,cremig,elegant,italienisch'
WHERE Id = 34;

-- Id=35: Apfelstrudel — österreichischer Klassiker
UPDATE MenuItems SET Tags = 'warm,süß,österreichisch,traditionell,klassisch'
WHERE Id = 35;

-- ============================================================
-- ALLERGENS
-- ============================================================

-- Id=2: Wurzelgemüse enthält Sellerie
UPDATE MenuItems SET Allergens = 'sellerie'
WHERE Id = 2;

-- Id=4: Brioche enthält Butter (laktose) und Eier (ei)
UPDATE MenuItems SET Allergens = 'fisch,gluten,ei,laktose'
WHERE Id = 4;

-- Id=15: Frische Pasta (ei) + Parmesan (laktose)
UPDATE MenuItems SET Allergens = 'gluten,ei,laktose'
WHERE Id = 15;

-- Id=16: Tagliatelle ist Ei-Pasta
UPDATE MenuItems SET Allergens = 'gluten,fisch,laktose,ei'
WHERE Id = 16;

-- Id=21: Mirepoix (sellerie) + Butter-Finish Rotweinsoße (laktose)
UPDATE MenuItems SET Allergens = 'sellerie,laktose'
WHERE Id = 21;

-- ============================================================
-- EIGNUNG
-- ============================================================

-- Id=8: Laugengebäck ist klassisch ein Frühstücksgebäck
UPDATE MenuItems SET Eignung = 'frühstück,mittag,buffet,business,empfang'
WHERE Id = 8;

-- Id=17: Eintopf passt auch zum Abendessen; + winter
UPDATE MenuItems SET Eignung = 'mittag,abend,buffet,winter'
WHERE Id = 17;

-- Id=29: Kürbis ist Herbst-/Wintersaison
UPDATE MenuItems SET Eignung = 'mittag,abend,buffet,winter'
WHERE Id = 29;

-- ============================================================
-- VERIFIKATION VOR COMMIT
-- ============================================================

SELECT 'CHECK 1: Ungueltige Tag-Tokens (erwartet: 0)' AS check_name;
WITH RECURSIVE nums AS (SELECT 1 n UNION ALL SELECT n+1 FROM nums WHERE n<10),
t AS (
  SELECT m.Id, m.Name,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(m.Tags,',',n.n),',',-1)) tok
  FROM MenuItems m
  JOIN nums n ON n.n <= 1+LENGTH(m.Tags)-LENGTH(REPLACE(m.Tags,',',''))
  WHERE m.Tags IS NOT NULL
)
SELECT t.Id, t.Name, t.tok FROM t
LEFT JOIN FilterVocabulary fv ON fv.field='tag' AND fv.value=t.tok
WHERE fv.value IS NULL AND t.tok != '';

SELECT 'CHECK 2: Ungueltige Allergen-Tokens (erwartet: 0)' AS check_name;
WITH RECURSIVE nums AS (SELECT 1 n UNION ALL SELECT n+1 FROM nums WHERE n<10),
a AS (
  SELECT m.Id, m.Name,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(m.Allergens,',',n.n),',',-1)) tok
  FROM MenuItems m
  JOIN nums n ON n.n <= 1+LENGTH(m.Allergens)-LENGTH(REPLACE(m.Allergens,',',''))
  WHERE m.Allergens IS NOT NULL AND m.Allergens != ''
)
SELECT a.Id, a.Name, a.tok FROM a
LEFT JOIN FilterVocabulary fv ON fv.field='allergen' AND fv.value=a.tok
WHERE fv.value IS NULL AND a.tok != '';

SELECT 'CHECK 3: Ungueltige Eignung-Tokens (erwartet: 0)' AS check_name;
WITH RECURSIVE nums AS (SELECT 1 n UNION ALL SELECT n+1 FROM nums WHERE n<10),
e AS (
  SELECT m.Id, m.Name,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(m.Eignung,',',n.n),',',-1)) tok
  FROM MenuItems m
  JOIN nums n ON n.n <= 1+LENGTH(m.Eignung)-LENGTH(REPLACE(m.Eignung,',',''))
  WHERE m.Eignung IS NOT NULL
)
SELECT e.Id, e.Name, e.tok FROM e
LEFT JOIN FilterVocabulary fv ON fv.field='eignung' AND fv.value=e.tok
WHERE fv.value IS NULL AND e.tok != '';

SELECT 'CHECK 4: Zeilen mit NULL Tags (erwartet: 0)' AS check_name;
SELECT Id, Name FROM MenuItems WHERE Tags IS NULL;

COMMIT;
SELECT 'COMMIT erfolgreich.' AS status;
