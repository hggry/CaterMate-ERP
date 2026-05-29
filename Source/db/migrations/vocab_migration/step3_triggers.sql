-- ============================================================
-- CaterMate-ERP: Vokabular-Migration – Schritt 3
-- Stored Function + BEFORE INSERT/UPDATE Trigger
-- Datum: 2026-05-29
--
-- Strategie: Der Trigger NORMALISIERT (lowercase, Leerzeichen
-- um Kommas entfernen) UND VALIDIERT. Applikation kann also
-- auch formatierte Werte senden ("Mittag, Abend") — sie werden
-- automatisch zu "mittag,abend" normalisiert und dann geprüft.
-- ============================================================

SET NAMES utf8mb4;

-- FilterVocabulary auf die gleiche Kollation wie MenuItems bringen
ALTER TABLE FilterVocabulary
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

DELIMITER $$

-- ============================================================
-- Hilfsfunktion: gibt ersten ungültigen Token zurück oder NULL
-- Parameter und Rückgabetyp explizit mit utf8mb4_unicode_ci
-- (passend zur MenuItems-Kollation)
-- ============================================================
DROP FUNCTION IF EXISTS csv_invalid_value $$
CREATE FUNCTION csv_invalid_value(
  p_field VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  p_csv   TEXT        CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
)
RETURNS VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
READS SQL DATA
BEGIN
  DECLARE v_pos   INT     DEFAULT 1;
  DECLARE v_count INT;
  -- Explizite Kollation damit der Vergleich mit FilterVocabulary (unicode_ci) klappt
  DECLARE v_token VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

  SET v_count = 1 + LENGTH(p_csv) - LENGTH(REPLACE(p_csv, ',', ''));

  WHILE v_pos <= v_count DO
    SET v_token = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_csv, ',', v_pos), ',', -1));
    IF v_token != '' AND NOT EXISTS (
      SELECT 1 FROM FilterVocabulary
      WHERE field = p_field COLLATE utf8mb4_unicode_ci
        AND value = v_token
    ) THEN
      RETURN v_token;
    END IF;
    SET v_pos = v_pos + 1;
  END WHILE;

  RETURN NULL;
END $$

-- ============================================================
-- BEFORE INSERT Trigger
-- ============================================================
DROP TRIGGER IF EXISTS trg_menuitems_bi $$
CREATE TRIGGER trg_menuitems_bi
BEFORE INSERT ON MenuItems
FOR EACH ROW
BEGIN
  DECLARE v_bad VARCHAR(50);
  DECLARE v_msg VARCHAR(200);

  -- Normalisierung: lowercase + Leerzeichen rund um Kommas entfernen
  SET NEW.Category = LOWER(TRIM(NEW.Category));
  IF NEW.Eignung IS NOT NULL THEN
    SET NEW.Eignung = LOWER(REGEXP_REPLACE(TRIM(NEW.Eignung), '\\s*,\\s*', ','));
  END IF;
  IF NEW.Tags IS NOT NULL THEN
    SET NEW.Tags = LOWER(REGEXP_REPLACE(TRIM(NEW.Tags), '\\s*,\\s*', ','));
  END IF;

  -- Validierung Category
  IF NEW.Category IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM FilterVocabulary WHERE field = 'category' AND value = NEW.Category
  ) THEN
    SET v_msg = CONCAT('Ungültige Category: ''', NEW.Category, '''');
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
  END IF;

  -- Validierung Eignung
  IF NEW.Eignung IS NOT NULL THEN
    SET v_bad = csv_invalid_value('eignung', NEW.Eignung);
    IF v_bad IS NOT NULL THEN
      SET v_msg = CONCAT('Ungültiger Eignung-Wert: ''', v_bad, '''');
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;
  END IF;

  -- Validierung Tags
  IF NEW.Tags IS NOT NULL THEN
    SET v_bad = csv_invalid_value('tag', NEW.Tags);
    IF v_bad IS NOT NULL THEN
      SET v_msg = CONCAT('Ungültiger Tag-Wert: ''', v_bad, '''');
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;
  END IF;
END $$

-- ============================================================
-- BEFORE UPDATE Trigger (identische Logik)
-- ============================================================
DROP TRIGGER IF EXISTS trg_menuitems_bu $$
CREATE TRIGGER trg_menuitems_bu
BEFORE UPDATE ON MenuItems
FOR EACH ROW
BEGIN
  DECLARE v_bad VARCHAR(50);
  DECLARE v_msg VARCHAR(200);

  SET NEW.Category = LOWER(TRIM(NEW.Category));
  IF NEW.Eignung IS NOT NULL THEN
    SET NEW.Eignung = LOWER(REGEXP_REPLACE(TRIM(NEW.Eignung), '\\s*,\\s*', ','));
  END IF;
  IF NEW.Tags IS NOT NULL THEN
    SET NEW.Tags = LOWER(REGEXP_REPLACE(TRIM(NEW.Tags), '\\s*,\\s*', ','));
  END IF;

  IF NEW.Category IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM FilterVocabulary WHERE field = 'category' AND value = NEW.Category
  ) THEN
    SET v_msg = CONCAT('Ungültige Category: ''', NEW.Category, '''');
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
  END IF;

  IF NEW.Eignung IS NOT NULL THEN
    SET v_bad = csv_invalid_value('eignung', NEW.Eignung);
    IF v_bad IS NOT NULL THEN
      SET v_msg = CONCAT('Ungültiger Eignung-Wert: ''', v_bad, '''');
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;
  END IF;

  IF NEW.Tags IS NOT NULL THEN
    SET v_bad = csv_invalid_value('tag', NEW.Tags);
    IF v_bad IS NOT NULL THEN
      SET v_msg = CONCAT('Ungültiger Tag-Wert: ''', v_bad, '''');
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;
  END IF;
END $$

DELIMITER ;

SELECT 'Funktion und Trigger angelegt.' AS status;

SHOW TRIGGERS FROM catermate_db WHERE `Table` = 'MenuItems';
