-- ============================================================
-- CaterMate-ERP: Allergen-Migration – Schritt 7
-- Trigger-Tests für Allergens
-- ============================================================
--
-- Test A: UPDATE mit ungültigem Allergen 'quatsch' → MUSS scheitern
-- Test B: UPDATE mit gültigen Allergen-Werten → MUSS durchgehen + normalisieren
-- Test C: UPDATE mit Allergens=NULL → MUSS durchgehen
-- Alle Änderungen danach rückgängig gemacht (UPDATE zurück auf Originalwert)
-- ============================================================

SET NAMES utf8mb4;

-- ---- Test A: Ungültiger Allergen-Token -------------------------
-- Id=17 (Sellerie) bekommt 'quatsch' als Allergen-Wert
-- Erwartetes Ergebnis: ERROR 1644 (45000)
SELECT '--- Test A: UPDATE mit ungültigem Allergen (erwartet: FEHLER) ---' AS '';
UPDATE MenuItems SET Allergens = 'sellerie,quatsch' WHERE Id = 17;

-- ---- Test B: Gültige Werte + Leerzeichen (Normalisierung) ------
-- Trigger soll ' Gluten , Ei ' → 'gluten,ei' normalisieren
-- Erwartetes Ergebnis: UPDATE erfolgreich
SELECT '--- Test B: UPDATE mit gültigen Werten + Leerzeichen (erwartet: OK) ---' AS '';
UPDATE MenuItems SET Allergens = ' Gluten , Ei ' WHERE Id = 17;
SELECT Id, Name, Allergens FROM MenuItems WHERE Id = 17;
-- Zurücksetzen auf den migrierten Wert
UPDATE MenuItems SET Allergens = 'sellerie' WHERE Id = 17;

-- ---- Test C: Allergens=NULL ------------------------------------
-- Erwartetes Ergebnis: UPDATE erfolgreich
SELECT '--- Test C: UPDATE mit Allergens=NULL (erwartet: OK) ---' AS '';
UPDATE MenuItems SET Allergens = NULL WHERE Id = 17;
SELECT Id, Name, Allergens FROM MenuItems WHERE Id = 17;
-- Zurücksetzen
UPDATE MenuItems SET Allergens = 'sellerie' WHERE Id = 17;

-- Abschlusskontrolle
SELECT '--- Abschlusskontrolle Id=17 ---' AS '';
SELECT Id, Name, Allergens FROM MenuItems WHERE Id = 17;
