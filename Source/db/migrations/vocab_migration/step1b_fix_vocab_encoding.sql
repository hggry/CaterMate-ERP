-- ============================================================
-- CaterMate-ERP: FilterVocabulary Encoding-Fix
-- Schritt 1b: Tabelle leeren und korrekt neu befüllen
-- (via docker cp ausführen, nicht PowerShell-Pipe)
-- Datum: 2026-05-29
-- ============================================================

SET NAMES utf8mb4;

TRUNCATE TABLE FilterVocabulary;

INSERT INTO FilterVocabulary (field, value, group_label, sort_order) VALUES
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

-- Verifikation: Hex-Check der Umlaut-Werte
SELECT field, value, HEX(value) AS hex_check
FROM FilterVocabulary
WHERE value IN ('gebäck','getränk','frühstück','österreichisch','süß','geflügel')
ORDER BY field, value;

SELECT field, COUNT(*) AS anzahl
FROM FilterVocabulary
GROUP BY field
ORDER BY field;
