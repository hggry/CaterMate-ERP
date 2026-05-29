-- ============================================================
-- CaterMate-ERP: Vokabular-Migration – Schritt 1
-- Backup + FilterVocabulary anlegen und befüllen
-- Datum: 2026-05-29
-- ============================================================

SET NAMES utf8mb4;

-- ==== BACKUP ====
CREATE TABLE IF NOT EXISTS MenuItems_backup_20260529
  AS SELECT * FROM MenuItems;

SELECT CONCAT('Backup erstellt: ', COUNT(*), ' Zeilen') AS info
FROM MenuItems_backup_20260529;

-- ==== FilterVocabulary ====
CREATE TABLE IF NOT EXISTS FilterVocabulary (
  field        VARCHAR(20)  NOT NULL,
  value        VARCHAR(50)  NOT NULL,
  group_label  VARCHAR(50)  NULL,
  sort_order   INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (field, value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO FilterVocabulary (field, value, group_label, sort_order) VALUES
  -- Category
  ('category', 'vorspeise',     'gang',       1),
  ('category', 'suppe',         'gang',       2),
  ('category', 'hauptgang',     'gang',       3),
  ('category', 'beilage',       'gang',       4),
  ('category', 'dessert',       'gang',       5),
  ('category', 'gebäck',        'gang',       6),
  ('category', 'getränk',       'gang',       7),
  -- Eignung: Tageszeit
  ('eignung',  'frühstück',     'tageszeit',  1),
  ('eignung',  'mittag',        'tageszeit',  2),
  ('eignung',  'nachmittag',    'tageszeit',  3),
  ('eignung',  'abend',         'tageszeit',  4),
  -- Eignung: Anlass
  ('eignung',  'business',      'anlass',     5),
  ('eignung',  'festlich',      'anlass',     6),
  ('eignung',  'empfang',       'anlass',     7),
  ('eignung',  'casual',        'anlass',     8),
  -- Eignung: Servierform / Saison
  ('eignung',  'buffet',        'servierform',9),
  ('eignung',  'sommer',        'saison',    10),
  ('eignung',  'winter',        'saison',    11),
  -- Tags: Küche
  ('tag',      'österreichisch','küche',      1),
  ('tag',      'italienisch',   'küche',      2),
  ('tag',      'mediterran',    'küche',      3),
  ('tag',      'asiatisch',     'küche',      4),
  ('tag',      'international', 'küche',      5),
  -- Tags: Temperatur
  ('tag',      'warm',          'temperatur', 6),
  ('tag',      'kalt',          'temperatur', 7),
  -- Tags: Diät
  ('tag',      'vegetarisch',   'diät',       8),
  ('tag',      'vegan',         'diät',       9),
  ('tag',      'glutenfrei',    'diät',      10),
  ('tag',      'laktosefrei',   'diät',      11),
  -- Tags: Geschmack
  ('tag',      'süß',           'geschmack', 12),
  ('tag',      'herzhaft',      'geschmack', 13),
  ('tag',      'cremig',        'geschmack', 14),
  -- Tags: Stil
  ('tag',      'traditionell',  'stil',      15),
  ('tag',      'klassisch',     'stil',      16),
  ('tag',      'modern',        'stil',      17),
  ('tag',      'elegant',       'stil',      18),
  -- Tags: Format
  ('tag',      'fingerfood',    'format',    19),
  -- Tags: Hauptzutat
  ('tag',      'fisch',         'hauptzutat',20),
  ('tag',      'fleisch',       'hauptzutat',21),
  ('tag',      'geflügel',      'hauptzutat',22);

SELECT field, COUNT(*) AS anzahl
FROM FilterVocabulary
GROUP BY field
ORDER BY field;
