-- ============================================================
-- CaterMate-ERP: Allergen-Migration – Schritt 5
-- Backup + FilterVocabulary + Datenmigration (Allergens)
-- Datum: 2026-05-29
-- ============================================================

SET NAMES utf8mb4;

-- ==== BACKUP ====
CREATE TABLE IF NOT EXISTS MenuItems_backup_allergens_20260529
  AS SELECT * FROM MenuItems;

SELECT CONCAT('Backup erstellt: ', COUNT(*), ' Zeilen') AS info
FROM MenuItems_backup_allergens_20260529;

-- ==== FilterVocabulary: 14 LMIV-Allergene ====
INSERT IGNORE INTO FilterVocabulary (field, value, group_label, sort_order) VALUES
  ('allergen', 'gluten',     'lmiv',  1),
  ('allergen', 'krebstiere', 'lmiv',  2),
  ('allergen', 'ei',         'lmiv',  3),
  ('allergen', 'fisch',      'lmiv',  4),
  ('allergen', 'erdnuss',    'lmiv',  5),
  ('allergen', 'soja',       'lmiv',  6),
  ('allergen', 'laktose',    'lmiv',  7),
  ('allergen', 'nuss',       'lmiv',  8),
  ('allergen', 'sellerie',   'lmiv',  9),
  ('allergen', 'senf',       'lmiv', 10),
  ('allergen', 'sesam',      'lmiv', 11),
  ('allergen', 'sulfite',    'lmiv', 12),
  ('allergen', 'lupinen',    'lmiv', 13),
  ('allergen', 'weichtiere', 'lmiv', 14);

SELECT field, COUNT(*) AS anzahl
FROM FilterVocabulary
GROUP BY field
ORDER BY field;

-- ==== DATENMIGRATION ====
-- Mapping-Regeln (angewendet):
--   Gluten       → gluten
--   Ei           → ei
--   Milch        → laktose   (Milch ist Sammelwert für Milchprodukte/Laktose)
--   Fisch        → fisch
--   Krustentiere → krebstiere (dt. Synonym für Krebstiere, LMIV #2)
--   Sellerie     → sellerie
--   Nüsse        → nuss
-- NULL bleibt NULL.

START TRANSACTION;

UPDATE MenuItems SET Allergens = 'gluten,ei,laktose'      WHERE Id = 1;
UPDATE MenuItems SET Allergens = NULL                      WHERE Id = 2;
UPDATE MenuItems SET Allergens = 'laktose'                 WHERE Id = 3;
UPDATE MenuItems SET Allergens = 'fisch,gluten'            WHERE Id = 4;
UPDATE MenuItems SET Allergens = 'laktose'                 WHERE Id = 5;
UPDATE MenuItems SET Allergens = 'gluten,ei,laktose'       WHERE Id = 6;
UPDATE MenuItems SET Allergens = 'gluten,ei,laktose'       WHERE Id = 7;
UPDATE MenuItems SET Allergens = 'gluten,laktose'          WHERE Id = 8;
UPDATE MenuItems SET Allergens = 'laktose'                 WHERE Id = 9;
UPDATE MenuItems SET Allergens = 'laktose'                 WHERE Id = 10;
UPDATE MenuItems SET Allergens = 'laktose'                 WHERE Id = 11;
UPDATE MenuItems SET Allergens = 'laktose'                 WHERE Id = 12;
UPDATE MenuItems SET Allergens = 'fisch,laktose'           WHERE Id = 13;
-- Id=14: 'Krustentiere' → krebstiere (Synonym)
UPDATE MenuItems SET Allergens = 'laktose,krebstiere'      WHERE Id = 14;
UPDATE MenuItems SET Allergens = 'gluten'                  WHERE Id = 15;
UPDATE MenuItems SET Allergens = 'gluten,fisch,laktose'    WHERE Id = 16;
UPDATE MenuItems SET Allergens = 'sellerie'                WHERE Id = 17;
UPDATE MenuItems SET Allergens = 'gluten,laktose,ei'       WHERE Id = 18;
UPDATE MenuItems SET Allergens = 'laktose'                 WHERE Id = 19;
UPDATE MenuItems SET Allergens = 'laktose'                 WHERE Id = 20;
UPDATE MenuItems SET Allergens = NULL                      WHERE Id = 21;
UPDATE MenuItems SET Allergens = 'fisch,gluten,laktose'    WHERE Id = 22;
UPDATE MenuItems SET Allergens = 'gluten'                  WHERE Id = 23;
UPDATE MenuItems SET Allergens = 'gluten,laktose,ei'       WHERE Id = 24;
UPDATE MenuItems SET Allergens = 'laktose'                 WHERE Id = 25;
UPDATE MenuItems SET Allergens = 'fisch,gluten'            WHERE Id = 26;
UPDATE MenuItems SET Allergens = 'gluten'                  WHERE Id = 27;
-- Id=28: 'Krustentiere' → krebstiere (Synonym)
UPDATE MenuItems SET Allergens = 'krebstiere,laktose'      WHERE Id = 28;
UPDATE MenuItems SET Allergens = 'laktose'                 WHERE Id = 29;
UPDATE MenuItems SET Allergens = 'laktose'                 WHERE Id = 30;
UPDATE MenuItems SET Allergens = 'fisch,gluten,laktose'    WHERE Id = 31;
UPDATE MenuItems SET Allergens = 'laktose,ei'              WHERE Id = 32;
UPDATE MenuItems SET Allergens = 'laktose,ei'              WHERE Id = 33;
UPDATE MenuItems SET Allergens = 'laktose'                 WHERE Id = 34;
-- Id=35: 'Nüsse' → nuss
UPDATE MenuItems SET Allergens = 'gluten,laktose,nuss'     WHERE Id = 35;

-- ==== VERIFIKATION VOR COMMIT ====
SELECT 'CHECK: Ungueltige Allergen-Tokens (erwartet: 0 Zeilen)' AS check_name;
WITH RECURSIVE nums AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 10
),
atokens AS (
  SELECT
    m.Id, m.Name,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(m.Allergens, ',', n.n), ',', -1)) AS tok
  FROM MenuItems m
  JOIN nums n ON n.n <= 1 + LENGTH(m.Allergens) - LENGTH(REPLACE(m.Allergens, ',', ''))
  WHERE m.Allergens IS NOT NULL AND m.Allergens != ''
)
SELECT at2.Id, at2.Name, at2.tok AS ungueltig
FROM atokens at2
LEFT JOIN FilterVocabulary fv ON fv.field = 'allergen' AND fv.value = at2.tok
WHERE fv.value IS NULL AND at2.tok != '';

SELECT 'ALLE ZEILEN NACH MIGRATION' AS check_name;
SELECT Id, Name, Allergens FROM MenuItems ORDER BY Id;

COMMIT;
SELECT 'COMMIT erfolgreich.' AS status;
