-- ============================================================
-- CaterMate-ERP: Vokabular-Migration – Schritt 4
-- Trigger-Tests
-- ============================================================
--
-- Test A: INSERT mit ungültigem Tag → MUSS scheitern
-- Test B: INSERT mit ungültiger Category → MUSS scheitern
-- Test C: INSERT mit gültigen Werten → MUSS durchgehen
-- Test D: Test-Zeile wieder entfernen
-- ============================================================

SET NAMES utf8mb4;

-- ---- Test A: Ungültiger Tag-Wert 'quatsch' ----------------
-- Erwartetes Ergebnis: ERROR 1644 (45000) — Ungültiger Tag-Wert: 'quatsch'
SELECT '--- Test A: INSERT mit ungültigem Tag (erwartet: FEHLER) ---' AS '';
INSERT INTO MenuItems (Name, Category, SalesPricePerPerson, PurchaseCostPerPerson, Eignung, Tags)
VALUES ('_Test_Invalid_Tag', 'dessert', 10.00, 5.00, 'abend', 'süß,quatsch');

-- ---- Test B: Ungültige Category ---------------------------
-- Erwartetes Ergebnis: ERROR 1644 (45000) — Ungültige Category: 'mittagstisch'
SELECT '--- Test B: INSERT mit ungültiger Category (erwartet: FEHLER) ---' AS '';
INSERT INTO MenuItems (Name, Category, SalesPricePerPerson, PurchaseCostPerPerson)
VALUES ('_Test_Invalid_Category', 'mittagstisch', 10.00, 5.00);

-- ---- Test C: Gültige Werte + Normalisierung ---------------
-- Trigger soll " Mittag , Abend " → 'mittag,abend' normalisieren
-- Erwartetes Ergebnis: INSERT erfolgreich
SELECT '--- Test C: INSERT mit gültigen Werten + Leerzeichen (erwartet: OK) ---' AS '';
INSERT INTO MenuItems (Name, Category, SalesPricePerPerson, PurchaseCostPerPerson, Eignung, Tags)
VALUES ('_Test_Valid', 'dessert', 8.00, 3.00, ' Mittag , Abend ', ' süß , klassisch ');

-- Normalisierung prüfen: Eignung/Tags müssen ohne Leerzeichen gespeichert sein
SELECT Id, Name, Category, Eignung, Tags
FROM MenuItems
WHERE Name = '_Test_Valid';

-- ---- Test D: Test-Zeilen aufräumen ------------------------
DELETE FROM MenuItems WHERE Name IN ('_Test_Valid', '_Test_Invalid_Tag', '_Test_Invalid_Category');
SELECT 'Test-Zeilen entfernt.' AS status;

-- Abschluss-Zählung
SELECT COUNT(*) AS produktive_zeilen FROM MenuItems WHERE Name NOT LIKE '_Test_%';
