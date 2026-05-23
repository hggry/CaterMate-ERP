USE catermate_db;

-- ============================================================
-- Additional Ingredients (64-68)
-- ============================================================

INSERT INTO Ingredients (Name, Unit, PurchasePricePerUnit, Category) VALUES
('Senf',              'kg',    3.0000, 'Gewürze'),
('Penne',             'kg',    1.8000, 'Trockenware'),
('Lauch',             'kg',    1.5000, 'Gemüse'),
('Schinken, gekocht', 'kg',    7.0000, 'Fleisch'),
('Kräuter, gemischt', 'kg',    8.0000, 'Gewürze');

-- ============================================================
-- Additional MenuItems (31-50)
-- ============================================================

INSERT INTO MenuItems (Name, Category, SalesPricePerPerson, PurchaseCostPerPerson, Allergens, Tags, Eignung, Beschreibung) VALUES
(
  'Zucchinicremesuppe',
  'Vorspeise', 8.00, 2.40, 'Milch',
  'warm, vegetarisch, leicht, Suppe, Sommer',
  'Mittag, Abend, Buffet, Sommer',
  'Samtige Cremesuppe aus frischen Zucchini, abgerundet mit einem Schuss Schlagobers.'
),
(
  'Brokkolicremesuppe',
  'Vorspeise', 8.00, 2.50, 'Milch',
  'warm, vegetarisch, gesund, Suppe',
  'Mittag, Abend, Buffet',
  'Feine Cremesuppe aus frischem Brokkoli – leicht, grün und vollwertig.'
),
(
  'Avocadocreme auf Schwarzbrot',
  'Vorspeise', 9.00, 3.20, 'Gluten, Milch',
  'kalt, vegetarisch, modern, Fingerfood',
  'Buffet, Business, Empfang',
  'Cremige Avocadocreme mit Frischkäse auf dunklem Schwarzbrot – frisch und unkompliziert.'
),
(
  'Grüner Salat mit Balsamico',
  'Vorspeise', 7.00, 2.00, NULL,
  'kalt, vegan, leicht, Salat, Sommer',
  'Mittag, Buffet, Sommer, Business',
  'Frischer Blattsalat mit Tomaten, Gurke und einem klassischen Balsamico-Dressing.'
),
(
  'Lauchcremesuppe',
  'Vorspeise', 8.50, 2.60, 'Milch',
  'warm, vegetarisch, Suppe, cremig',
  'Mittag, Abend, Herbst, Winter',
  'Milde Cremesuppe aus Lauch und Kartoffeln – aromatisch und wärmend.'
),
(
  'Rindsgulasch mit Erdäpfeln',
  'Hauptgang', 22.00, 8.50, NULL,
  'warm, österreichisch, traditionell, herzhaft, würzig',
  'Mittag, Abend, Festlich, Herbst',
  'Zartes, geschmortes Rindsgulasch nach Wiener Art mit Paprika, serviert mit rustikalen Erdäpfeln.'
),
(
  'Kürbisrisotto',
  'Hauptgang', 17.00, 5.80, 'Milch',
  'warm, vegetarisch, cremig, herbstlich, Risotto',
  'Mittag, Abend, Herbst, Buffet',
  'Cremiges Risotto mit muskatartigem Kürbis, Parmesan und einem Schuss Weißwein.'
),
(
  'Gemüsecurry vegan mit Basmatireis',
  'Hauptgang', 15.00, 4.20, NULL,
  'warm, vegan, asiatisch, würzig, gesund',
  'Mittag, Abend, Buffet, Vegetarisch',
  'Buntes Gemüsecurry aus Brokkoli, Süßkartoffel und Paprika in Kokosmilch, mit Basmatireis.'
),
(
  'Lachspasta mit Schlagobers',
  'Hauptgang', 23.00, 8.50, 'Fisch, Gluten, Milch',
  'warm, Fisch, cremig, italienisch',
  'Mittag, Abend, Business, Festlich',
  'Spaghetti in cremiger Lachssauce mit Schlagobers und Parmesan – elegant und unkompliziert.'
),
(
  'Spaghetti Carbonara',
  'Hauptgang', 17.00, 5.50, 'Gluten, Ei, Milch',
  'warm, italienisch, Pasta, klassisch, cremig',
  'Mittag, Abend, Buffet',
  'Klassische Carbonara mit Ei, Parmesan und knusprigem gekochtem Schinken – ohne Sahne, dafür mit Technik.'
),
(
  'Hühnerfilet in Senfsauce',
  'Hauptgang', 19.00, 6.50, 'Milch',
  'warm, klassisch, herzhaft, Geflügel',
  'Mittag, Abend, Business',
  'Zartes Hühnerfilet in einer würzigen Senfsauce auf Schlagobersbasis, serviert mit Erdäpfeln.'
),
(
  'Beef Stroganoff',
  'Hauptgang', 24.00, 9.50, 'Gluten, Milch',
  'warm, russisch, cremig, Rind, herzhaft',
  'Abend, Festlich, Business',
  'Zartes Rindfleisch in cremiger Senf-Schlagobers-Sauce, serviert mit Spaghetti oder Reis.'
),
(
  'Käsefondue',
  'Hauptgang', 20.00, 7.00, 'Milch, Gluten',
  'warm, Käse, gesellig, winterlich, Schweizer',
  'Abend, Festlich, Winter',
  'Klassisches Käsefondue mit gemischten Käsesorten und Weißwein, serviert mit Brot und Kartoffeln.'
),
(
  'Penne Arrabbiata',
  'Hauptgang', 14.00, 4.00, 'Gluten',
  'warm, vegan, italienisch, würzig, Pasta, scharf',
  'Mittag, Abend, Buffet, Vegetarisch',
  'Penne in pikanter Tomatensauce mit Knoblauch und Chili – simpel, schnell und voller Geschmack.'
),
(
  'Schokoladenkuchen',
  'Dessert', 6.00, 1.80, 'Gluten, Ei, Milch',
  'warm, süß, Schokolade, klassisch',
  'Abend, Buffet, Nachmittag, Festlich',
  'Saftiger Schokoladenkuchen aus dunkler Kuvertüre – ein zeitloser Klassiker für alle Schokofans.'
),
(
  'Walnuss-Baklava',
  'Dessert', 5.50, 1.60, 'Gluten, Nüsse',
  'kalt, süß, orientalisch, knusprig',
  'Buffet, Nachmittag, Festlich',
  'Knusprige Strudelteig-Schichten mit gehackten Walnüssen und Zuckersirup – ein orientalischer Klassiker.'
),
(
  'Beerenparfait',
  'Dessert', 7.50, 2.40, 'Milch, Ei',
  'kalt, süß, fruchtig, elegant, Sommer',
  'Abend, Festlich, Buffet, Sommer',
  'Cremiges halbgefrorenes Parfait mit frischen gemischten Beeren – leicht und erfrischend.'
),
(
  'Fingerfood-Platte herzhaft',
  'Buffet', 9.00, 3.20, 'Gluten, Milch',
  'kalt, herzhaft, Buffet, Empfang, Fingerfood',
  'Buffet, Business, Empfang',
  'Vielfältige herzhafte Fingerfood-Auswahl mit Aufschnitt, Käse, Baguette und frischem Gemüse.'
),
(
  'Antipasti-Platte',
  'Buffet', 9.50, 3.50, 'Gluten, Milch',
  'kalt, italienisch, Buffet, vegetarisch, mediterran',
  'Buffet, Business, Empfang, Sommer',
  'Mediterrane Antipasti mit Mozzarella, Tomaten, gegrilltem Paprika und Olivenöl auf Baguette.'
),
(
  'Kräuterquark-Buffet',
  'Buffet', 6.00, 2.00, 'Milch, Gluten',
  'kalt, vegetarisch, frisch, Buffet, Frühstück',
  'Buffet, Business, Frühstück, Empfang',
  'Cremiger Kräuterquark mit Frischkäse, serviert mit Laugengebäck und frischem Gemüse zum Dippen.'
);

-- ============================================================
-- MenuItemIngredients for items 31-50
-- ============================================================

INSERT INTO MenuItemIngredients (MenuItemId, IngredientId, QuantityPerPerson) VALUES
-- Zucchinicremesuppe (31)
((SELECT Id FROM MenuItems WHERE Name='Zucchinicremesuppe'),                    (SELECT Id FROM Ingredients WHERE Name='Zucchini'),          0.150),
((SELECT Id FROM MenuItems WHERE Name='Zucchinicremesuppe'),                    (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),          0.040),
((SELECT Id FROM MenuItems WHERE Name='Zucchinicremesuppe'),                    (SELECT Id FROM Ingredients WHERE Name='Butter'),            0.020),
((SELECT Id FROM MenuItems WHERE Name='Zucchinicremesuppe'),                    (SELECT Id FROM Ingredients WHERE Name='Gemüsebrühe'),       0.200),
((SELECT Id FROM MenuItems WHERE Name='Zucchinicremesuppe'),                    (SELECT Id FROM Ingredients WHERE Name='Schlagobers'),       0.050),
-- Brokkolicremesuppe (32)
((SELECT Id FROM MenuItems WHERE Name='Brokkolicremesuppe'),                    (SELECT Id FROM Ingredients WHERE Name='Brokkoli'),          0.150),
((SELECT Id FROM MenuItems WHERE Name='Brokkolicremesuppe'),                    (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),          0.040),
((SELECT Id FROM MenuItems WHERE Name='Brokkolicremesuppe'),                    (SELECT Id FROM Ingredients WHERE Name='Butter'),            0.020),
((SELECT Id FROM MenuItems WHERE Name='Brokkolicremesuppe'),                    (SELECT Id FROM Ingredients WHERE Name='Gemüsebrühe'),       0.200),
((SELECT Id FROM MenuItems WHERE Name='Brokkolicremesuppe'),                    (SELECT Id FROM Ingredients WHERE Name='Schlagobers'),       0.050),
-- Avocadocreme auf Schwarzbrot (33)
((SELECT Id FROM MenuItems WHERE Name='Avocadocreme auf Schwarzbrot'),          (SELECT Id FROM Ingredients WHERE Name='Avocado'),           0.500),
((SELECT Id FROM MenuItems WHERE Name='Avocadocreme auf Schwarzbrot'),          (SELECT Id FROM Ingredients WHERE Name='Frischkäse'),        0.030),
((SELECT Id FROM MenuItems WHERE Name='Avocadocreme auf Schwarzbrot'),          (SELECT Id FROM Ingredients WHERE Name='Schwarzbrot-Scheiben'), 2.000),
((SELECT Id FROM MenuItems WHERE Name='Avocadocreme auf Schwarzbrot'),          (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),          0.020),
-- Grüner Salat mit Balsamico (34)
((SELECT Id FROM MenuItems WHERE Name='Grüner Salat mit Balsamico'),            (SELECT Id FROM Ingredients WHERE Name='Tomaten'),           0.080),
((SELECT Id FROM MenuItems WHERE Name='Grüner Salat mit Balsamico'),            (SELECT Id FROM Ingredients WHERE Name='Gurke'),             0.080),
((SELECT Id FROM MenuItems WHERE Name='Grüner Salat mit Balsamico'),            (SELECT Id FROM Ingredients WHERE Name='Olivenöl'),          0.015),
((SELECT Id FROM MenuItems WHERE Name='Grüner Salat mit Balsamico'),            (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),          0.025),
-- Lauchcremesuppe (35)
((SELECT Id FROM MenuItems WHERE Name='Lauchcremesuppe'),                       (SELECT Id FROM Ingredients WHERE Name='Lauch'),             0.150),
((SELECT Id FROM MenuItems WHERE Name='Lauchcremesuppe'),                       (SELECT Id FROM Ingredients WHERE Name='Kartoffeln'),        0.100),
((SELECT Id FROM MenuItems WHERE Name='Lauchcremesuppe'),                       (SELECT Id FROM Ingredients WHERE Name='Butter'),            0.020),
((SELECT Id FROM MenuItems WHERE Name='Lauchcremesuppe'),                       (SELECT Id FROM Ingredients WHERE Name='Gemüsebrühe'),       0.200),
((SELECT Id FROM MenuItems WHERE Name='Lauchcremesuppe'),                       (SELECT Id FROM Ingredients WHERE Name='Schlagobers'),       0.050),
-- Rindsgulasch mit Erdäpfeln (36)
((SELECT Id FROM MenuItems WHERE Name='Rindsgulasch mit Erdäpfeln'),            (SELECT Id FROM Ingredients WHERE Name='Rindsnacken'),       0.200),
((SELECT Id FROM MenuItems WHERE Name='Rindsgulasch mit Erdäpfeln'),            (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),          0.080),
((SELECT Id FROM MenuItems WHERE Name='Rindsgulasch mit Erdäpfeln'),            (SELECT Id FROM Ingredients WHERE Name='Paprika'),           0.040),
((SELECT Id FROM MenuItems WHERE Name='Rindsgulasch mit Erdäpfeln'),            (SELECT Id FROM Ingredients WHERE Name='Kartoffeln'),        0.200),
((SELECT Id FROM MenuItems WHERE Name='Rindsgulasch mit Erdäpfeln'),            (SELECT Id FROM Ingredients WHERE Name='Rotwein'),           0.060),
-- Kürbisrisotto (37)
((SELECT Id FROM MenuItems WHERE Name='Kürbisrisotto'),                         (SELECT Id FROM Ingredients WHERE Name='Kürbis'),            0.150),
((SELECT Id FROM MenuItems WHERE Name='Kürbisrisotto'),                         (SELECT Id FROM Ingredients WHERE Name='Risotto-Reis'),      0.100),
((SELECT Id FROM MenuItems WHERE Name='Kürbisrisotto'),                         (SELECT Id FROM Ingredients WHERE Name='Parmesan'),          0.025),
((SELECT Id FROM MenuItems WHERE Name='Kürbisrisotto'),                         (SELECT Id FROM Ingredients WHERE Name='Butter'),            0.025),
((SELECT Id FROM MenuItems WHERE Name='Kürbisrisotto'),                         (SELECT Id FROM Ingredients WHERE Name='Weißwein'),          0.050),
((SELECT Id FROM MenuItems WHERE Name='Kürbisrisotto'),                         (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),          0.040),
((SELECT Id FROM MenuItems WHERE Name='Kürbisrisotto'),                         (SELECT Id FROM Ingredients WHERE Name='Gemüsebrühe'),       0.200),
-- Gemüsecurry vegan mit Basmatireis (38)
((SELECT Id FROM MenuItems WHERE Name='Gemüsecurry vegan mit Basmatireis'),     (SELECT Id FROM Ingredients WHERE Name='Brokkoli'),          0.100),
((SELECT Id FROM MenuItems WHERE Name='Gemüsecurry vegan mit Basmatireis'),     (SELECT Id FROM Ingredients WHERE Name='Süßkartoffel'),      0.100),
((SELECT Id FROM MenuItems WHERE Name='Gemüsecurry vegan mit Basmatireis'),     (SELECT Id FROM Ingredients WHERE Name='Paprika'),           0.080),
((SELECT Id FROM MenuItems WHERE Name='Gemüsecurry vegan mit Basmatireis'),     (SELECT Id FROM Ingredients WHERE Name='Kokosmilch'),        0.150),
((SELECT Id FROM MenuItems WHERE Name='Gemüsecurry vegan mit Basmatireis'),     (SELECT Id FROM Ingredients WHERE Name='Currypulver'),       0.010),
((SELECT Id FROM MenuItems WHERE Name='Gemüsecurry vegan mit Basmatireis'),     (SELECT Id FROM Ingredients WHERE Name='Basmatireis'),       0.100),
-- Lachspasta mit Schlagobers (39)
((SELECT Id FROM MenuItems WHERE Name='Lachspasta mit Schlagobers'),            (SELECT Id FROM Ingredients WHERE Name='Lachs, frisch'),     0.150),
((SELECT Id FROM MenuItems WHERE Name='Lachspasta mit Schlagobers'),            (SELECT Id FROM Ingredients WHERE Name='Spaghetti'),         0.120),
((SELECT Id FROM MenuItems WHERE Name='Lachspasta mit Schlagobers'),            (SELECT Id FROM Ingredients WHERE Name='Schlagobers'),       0.080),
((SELECT Id FROM MenuItems WHERE Name='Lachspasta mit Schlagobers'),            (SELECT Id FROM Ingredients WHERE Name='Butter'),            0.020),
((SELECT Id FROM MenuItems WHERE Name='Lachspasta mit Schlagobers'),            (SELECT Id FROM Ingredients WHERE Name='Parmesan'),          0.020),
-- Spaghetti Carbonara (40)
((SELECT Id FROM MenuItems WHERE Name='Spaghetti Carbonara'),                   (SELECT Id FROM Ingredients WHERE Name='Spaghetti'),         0.120),
((SELECT Id FROM MenuItems WHERE Name='Spaghetti Carbonara'),                   (SELECT Id FROM Ingredients WHERE Name='Eier'),              1.500),
((SELECT Id FROM MenuItems WHERE Name='Spaghetti Carbonara'),                   (SELECT Id FROM Ingredients WHERE Name='Parmesan'),          0.040),
((SELECT Id FROM MenuItems WHERE Name='Spaghetti Carbonara'),                   (SELECT Id FROM Ingredients WHERE Name='Schinken, gekocht'), 0.060),
-- Hühnerfilet in Senfsauce (41)
((SELECT Id FROM MenuItems WHERE Name='Hühnerfilet in Senfsauce'),              (SELECT Id FROM Ingredients WHERE Name='Hühnerfilet'),       0.200),
((SELECT Id FROM MenuItems WHERE Name='Hühnerfilet in Senfsauce'),              (SELECT Id FROM Ingredients WHERE Name='Senf'),              0.020),
((SELECT Id FROM MenuItems WHERE Name='Hühnerfilet in Senfsauce'),              (SELECT Id FROM Ingredients WHERE Name='Schlagobers'),       0.080),
((SELECT Id FROM MenuItems WHERE Name='Hühnerfilet in Senfsauce'),              (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),          0.050),
((SELECT Id FROM MenuItems WHERE Name='Hühnerfilet in Senfsauce'),              (SELECT Id FROM Ingredients WHERE Name='Kartoffeln'),        0.200),
-- Beef Stroganoff (42)
((SELECT Id FROM MenuItems WHERE Name='Beef Stroganoff'),                       (SELECT Id FROM Ingredients WHERE Name='Rindsnacken'),       0.200),
((SELECT Id FROM MenuItems WHERE Name='Beef Stroganoff'),                       (SELECT Id FROM Ingredients WHERE Name='Schlagobers'),       0.100),
((SELECT Id FROM MenuItems WHERE Name='Beef Stroganoff'),                       (SELECT Id FROM Ingredients WHERE Name='Senf'),              0.015),
((SELECT Id FROM MenuItems WHERE Name='Beef Stroganoff'),                       (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),          0.060),
((SELECT Id FROM MenuItems WHERE Name='Beef Stroganoff'),                       (SELECT Id FROM Ingredients WHERE Name='Spaghetti'),         0.100),
-- Käsefondue (43)
((SELECT Id FROM MenuItems WHERE Name='Käsefondue'),                            (SELECT Id FROM Ingredients WHERE Name='Käse, gemischt'),    0.150),
((SELECT Id FROM MenuItems WHERE Name='Käsefondue'),                            (SELECT Id FROM Ingredients WHERE Name='Weißwein'),          0.080),
((SELECT Id FROM MenuItems WHERE Name='Käsefondue'),                            (SELECT Id FROM Ingredients WHERE Name='Baguette'),          2.000),
((SELECT Id FROM MenuItems WHERE Name='Käsefondue'),                            (SELECT Id FROM Ingredients WHERE Name='Kartoffeln'),        0.150),
-- Penne Arrabbiata (44)
((SELECT Id FROM MenuItems WHERE Name='Penne Arrabbiata'),                      (SELECT Id FROM Ingredients WHERE Name='Penne'),             0.120),
((SELECT Id FROM MenuItems WHERE Name='Penne Arrabbiata'),                      (SELECT Id FROM Ingredients WHERE Name='Dosentomaten'),      0.200),
((SELECT Id FROM MenuItems WHERE Name='Penne Arrabbiata'),                      (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),          0.040),
((SELECT Id FROM MenuItems WHERE Name='Penne Arrabbiata'),                      (SELECT Id FROM Ingredients WHERE Name='Olivenöl'),          0.020),
-- Schokoladenkuchen (45)
((SELECT Id FROM MenuItems WHERE Name='Schokoladenkuchen'),                     (SELECT Id FROM Ingredients WHERE Name='Schokolade, dunkel'), 0.080),
((SELECT Id FROM MenuItems WHERE Name='Schokoladenkuchen'),                     (SELECT Id FROM Ingredients WHERE Name='Mehl'),              0.060),
((SELECT Id FROM MenuItems WHERE Name='Schokoladenkuchen'),                     (SELECT Id FROM Ingredients WHERE Name='Eier'),              1.000),
((SELECT Id FROM MenuItems WHERE Name='Schokoladenkuchen'),                     (SELECT Id FROM Ingredients WHERE Name='Butter'),            0.060),
((SELECT Id FROM MenuItems WHERE Name='Schokoladenkuchen'),                     (SELECT Id FROM Ingredients WHERE Name='Zucker'),            0.060),
-- Walnuss-Baklava (46)
((SELECT Id FROM MenuItems WHERE Name='Walnuss-Baklava'),                       (SELECT Id FROM Ingredients WHERE Name='Strudelteig'),       0.060),
((SELECT Id FROM MenuItems WHERE Name='Walnuss-Baklava'),                       (SELECT Id FROM Ingredients WHERE Name='Walnüsse'),          0.050),
((SELECT Id FROM MenuItems WHERE Name='Walnuss-Baklava'),                       (SELECT Id FROM Ingredients WHERE Name='Zucker'),            0.040),
((SELECT Id FROM MenuItems WHERE Name='Walnuss-Baklava'),                       (SELECT Id FROM Ingredients WHERE Name='Butter'),            0.030),
-- Beerenparfait (47)
((SELECT Id FROM MenuItems WHERE Name='Beerenparfait'),                         (SELECT Id FROM Ingredients WHERE Name='Schlagobers'),       0.120),
((SELECT Id FROM MenuItems WHERE Name='Beerenparfait'),                         (SELECT Id FROM Ingredients WHERE Name='Beeren, gemischt'),  0.100),
((SELECT Id FROM MenuItems WHERE Name='Beerenparfait'),                         (SELECT Id FROM Ingredients WHERE Name='Zucker'),            0.040),
((SELECT Id FROM MenuItems WHERE Name='Beerenparfait'),                         (SELECT Id FROM Ingredients WHERE Name='Eier'),              1.000),
-- Fingerfood-Platte herzhaft (48)
((SELECT Id FROM MenuItems WHERE Name='Fingerfood-Platte herzhaft'),            (SELECT Id FROM Ingredients WHERE Name='Aufschnitt, gemischt'), 0.080),
((SELECT Id FROM MenuItems WHERE Name='Fingerfood-Platte herzhaft'),            (SELECT Id FROM Ingredients WHERE Name='Käse, gemischt'),    0.060),
((SELECT Id FROM MenuItems WHERE Name='Fingerfood-Platte herzhaft'),            (SELECT Id FROM Ingredients WHERE Name='Baguette'),          1.500),
((SELECT Id FROM MenuItems WHERE Name='Fingerfood-Platte herzhaft'),            (SELECT Id FROM Ingredients WHERE Name='Gurke'),             0.040),
((SELECT Id FROM MenuItems WHERE Name='Fingerfood-Platte herzhaft'),            (SELECT Id FROM Ingredients WHERE Name='Tomaten'),           0.040),
-- Antipasti-Platte (49)
((SELECT Id FROM MenuItems WHERE Name='Antipasti-Platte'),                      (SELECT Id FROM Ingredients WHERE Name='Tomaten'),           0.080),
((SELECT Id FROM MenuItems WHERE Name='Antipasti-Platte'),                      (SELECT Id FROM Ingredients WHERE Name='Mozzarella'),        0.080),
((SELECT Id FROM MenuItems WHERE Name='Antipasti-Platte'),                      (SELECT Id FROM Ingredients WHERE Name='Olivenöl'),          0.020),
((SELECT Id FROM MenuItems WHERE Name='Antipasti-Platte'),                      (SELECT Id FROM Ingredients WHERE Name='Baguette'),          1.500),
((SELECT Id FROM MenuItems WHERE Name='Antipasti-Platte'),                      (SELECT Id FROM Ingredients WHERE Name='Paprika'),           0.060),
-- Kräuterquark-Buffet (50)
((SELECT Id FROM MenuItems WHERE Name='Kräuterquark-Buffet'),                   (SELECT Id FROM Ingredients WHERE Name='Frischkäse'),        0.080),
((SELECT Id FROM MenuItems WHERE Name='Kräuterquark-Buffet'),                   (SELECT Id FROM Ingredients WHERE Name='Kräuter, gemischt'), 0.020),
((SELECT Id FROM MenuItems WHERE Name='Kräuterquark-Buffet'),                   (SELECT Id FROM Ingredients WHERE Name='Gurke'),             0.060),
((SELECT Id FROM MenuItems WHERE Name='Kräuterquark-Buffet'),                   (SELECT Id FROM Ingredients WHERE Name='Tomaten'),           0.060),
((SELECT Id FROM MenuItems WHERE Name='Kräuterquark-Buffet'),                   (SELECT Id FROM Ingredients WHERE Name='Laugengebäck'),      1.000);
