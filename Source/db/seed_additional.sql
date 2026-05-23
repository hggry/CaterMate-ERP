USE catermate_db;

-- ============================================================
-- Additional Ingredients (28-63)
-- ============================================================

INSERT INTO Ingredients (Name, Unit, PurchasePricePerUnit, Category) VALUES
('Kürbis',                'kg',    1.5000, 'Gemüse'),
('Forellenfilet',         'kg',   14.0000, 'Fisch'),
('Schwarzbrot-Scheiben',  'Stk',   0.3000, 'Backwaren'),
('Frischkäse',            'kg',    5.0000, 'Milchprodukte'),
('Rindsuppe',             'Liter', 2.0000, 'Sonstiges'),
('Leberknödel',           'Stk',   1.2000, 'Sonstiges'),
('Baguette',              'Stk',   1.2000, 'Backwaren'),
('Schweinskragen',        'kg',    8.0000, 'Fleisch'),
('Semmelknödel',          'Stk',   0.8000, 'Backwaren'),
('Mehl',                  'kg',    0.8000, 'Trockenware'),
('Kokosmilch',            'Liter', 2.0000, 'Sonstiges'),
('Currypulver',           'kg',   15.0000, 'Gewürze'),
('Basmatireis',           'kg',    2.5000, 'Trockenware'),
('Rindshackfleisch',      'kg',    9.0000, 'Fleisch'),
('Spaghetti',             'kg',    1.8000, 'Trockenware'),
('Dosentomaten',          'kg',    1.5000, 'Sonstiges'),
('Kichererbsen, gekocht', 'kg',    2.0000, 'Trockenware'),
('Avocado',               'Stk',   1.5000, 'Gemüse'),
('Süßkartoffel',          'kg',    2.0000, 'Gemüse'),
('Rindsnacken',           'kg',   12.0000, 'Fleisch'),
('Paprika',               'kg',    2.5000, 'Gemüse'),
('Reibekäse',             'kg',   10.0000, 'Milchprodukte'),
('Spätzle, frisch',       'kg',    2.0000, 'Trockenware'),
('Äpfel',                 'kg',    1.2000, 'Obst'),
('Zucker',                'kg',    1.0000, 'Sonstiges'),
('Beeren, gemischt',      'kg',    6.0000, 'Obst'),
('Zwetschken',            'kg',    2.0000, 'Obst'),
('Käse, gemischt',        'kg',   12.0000, 'Milchprodukte'),
('Walnüsse',              'kg',   12.0000, 'Sonstiges'),
('Trauben',               'kg',    3.5000, 'Obst'),
('Aufschnitt, gemischt',  'kg',    8.0000, 'Fleisch'),
('Gurke',                 'kg',    1.2000, 'Gemüse'),
('Brokkoli',              'kg',    2.0000, 'Gemüse'),
('Rotwein',               'Liter', 5.0000, 'Getränke'),
('Vanilleschote',         'Stk',   1.5000, 'Gewürze'),
('Gelatine',              'kg',   20.0000, 'Sonstiges');

-- ============================================================
-- Additional MenuItems (9-30)
-- ============================================================

INSERT INTO MenuItems (Name, Category, SalesPricePerPerson, PurchaseCostPerPerson, Allergens, Tags, Eignung, Beschreibung) VALUES
(
  'Kürbiscremesuppe',
  'Vorspeise', 9.00, 2.80, NULL,
  'warm, vegetarisch, Suppe, herbstlich',
  'Mittag, Abend, Buffet',
  'Samtweiche Cremesuppe aus Muskatkürbis, verfeinert mit Schlagobers und einer Prise Muskat.'
),
(
  'Leberknödelsuppe',
  'Vorspeise', 7.00, 2.50, 'Gluten, Ei',
  'warm, traditionell, österreichisch, Suppe',
  'Mittag, Abend, Festlich',
  'Kräftige Rindssuppe mit hausgemachten Leberknödeln – ein traditionelles österreichisches Suppengericht.'
),
(
  'Bruschetta mit Tomaten und Basilikum',
  'Vorspeise', 6.00, 2.00, 'Gluten',
  'kalt, vegetarisch, italienisch, Fingerfood',
  'Buffet, Empfang, Sommer, Mittag',
  'Knuspriges Baguette mit frischen Tomaten, Knoblauch und Olivenöl – unkompliziert und aromatisch.'
),
(
  'Geräucherter Forellenaufstrich auf Schwarzbrot',
  'Vorspeise', 10.00, 3.50, 'Fisch, Gluten, Milch',
  'kalt, Fisch, österreichisch, Aufstrich',
  'Buffet, Business, Empfang, Mittag',
  'Cremiger Forellenaufstrich mit Frischkäse auf dunklem Schwarzbrot – eine regionale Delikatesse.'
),
(
  'Gulaschsuppe',
  'Vorspeise', 8.00, 2.80, NULL,
  'warm, traditionell, österreichisch, Suppe, würzig',
  'Mittag, Abend, Buffet, Herbst',
  'Würzige Gulaschsuppe nach Wiener Art mit zartem Rindfleisch, Paprika und Kartoffeln.'
),
(
  'Backhendl mit Erdäpfelsalat',
  'Hauptgang', 22.00, 8.00, 'Gluten, Ei, Milch',
  'warm, traditionell, österreichisch',
  'Mittag, Abend, Business',
  'Knuspriges paniertes Backhendl nach Wiener Tradition, begleitet von einem frischen Erdäpfelsalat.'
),
(
  'Schweinsbraten mit Semmelknödel',
  'Hauptgang', 20.00, 7.50, 'Gluten, Ei',
  'warm, traditionell, österreichisch, herzhaft',
  'Mittag, Abend, Festlich, Business',
  'Saftiger Schweinsbraten mit goldbrauner Kruste, serviert mit Semmelknödeln und mildem Sauerkraut.'
),
(
  'Lachsfilet auf Blattspinat',
  'Hauptgang', 26.00, 10.00, 'Fisch, Milch',
  'warm, Fisch, leicht, modern',
  'Abend, Business, Festlich',
  'Zartes Lachsfilet auf cremigem Blattspinat, begleitet von Buttererdäpfeln – leicht und elegant.'
),
(
  'Hühnercurry mit Basmatireis',
  'Hauptgang', 18.00, 6.00, NULL,
  'warm, asiatisch, würzig, exotisch',
  'Mittag, Abend, Buffet',
  'Aromatisches Hühnercurry mit Kokosmilch und buntem Gemüse, serviert mit duftendem Basmatireis.'
),
(
  'Spaghetti Bolognese',
  'Hauptgang', 16.00, 5.50, 'Gluten',
  'warm, italienisch, Pasta, klassisch',
  'Mittag, Abend, Buffet',
  'Klassische Bolognese-Sauce mit Rinderhack und Tomaten, serviert zu al dente gekochten Spaghetti.'
),
(
  'Vegane Buddha Bowl',
  'Hauptgang', 16.00, 4.50, NULL,
  'warm, vegan, gesund, bunt, modern',
  'Mittag, Buffet, Vegetarisch, Business',
  'Nährstoffreiche Bowl mit geröstetem Gemüse, Kichererbsen, Avocado und Basmatireis.'
),
(
  'Gegrillte Rindsspieße mit Grillgemüse',
  'Hauptgang', 24.00, 9.00, NULL,
  'warm, Grill, sommerlich, österreichisch',
  'Sommer, Outdoor, Buffet, Abend',
  'Saftige Rindsspieße vom Grill mit buntem Grillgemüse – perfekt für sommerliche Outdoor-Events.'
),
(
  'Käsespätzle',
  'Hauptgang', 14.00, 4.50, 'Gluten, Milch, Ei',
  'warm, vegetarisch, österreichisch, herzhaft, Käse',
  'Mittag, Abend, Buffet',
  'Goldbraune hausgemachte Spätzle mit kräftigem Bergkäse und karamellisierten Röstzwiebeln.'
),
(
  'Pasta Primavera',
  'Hauptgang', 15.00, 4.20, 'Gluten, Milch',
  'warm, vegetarisch, italienisch, leicht, Frühling',
  'Mittag, Buffet, Vegetarisch, Sommer',
  'Leichte Pasta mit frischem Frühlingsgemüse, verfeinert mit Olivenöl und Parmesan.'
),
(
  'Palatschinken mit Aprikosenmarmelade',
  'Dessert', 6.50, 1.80, 'Gluten, Ei, Milch',
  'warm, süß, österreichisch, Klassiker',
  'Mittag, Abend, Buffet, Nachmittag',
  'Hauchdünne österreichische Palatschinken, gefüllt mit sonniger Aprikosenmarmelade.'
),
(
  'Apfelstrudel',
  'Dessert', 6.50, 1.80, 'Gluten, Milch',
  'warm, süß, österreichisch, Klassiker, Strudel',
  'Mittag, Abend, Buffet, Nachmittag',
  'Knuspriger Apfelstrudel mit aromatischer Zimtfüllung und einer Haube Schlagobers – untrennbar mit der österreichischen Küche verbunden.'
),
(
  'Mousse au Chocolat',
  'Dessert', 7.00, 2.20, 'Milch, Ei',
  'kalt, süß, Schokolade, elegant, französisch',
  'Abend, Festlich, Buffet, Nachmittag',
  'Luftige Schokolademousse aus dunkler Kuvertüre – ein elegantes Dessert für besondere Anlässe.'
),
(
  'Kaiserschmarrn mit Zwetschkenröster',
  'Dessert', 8.00, 2.50, 'Gluten, Ei, Milch',
  'warm, süß, österreichisch, Klassiker, rustikal',
  'Mittag, Abend, Buffet, Festlich',
  'Flaumiger zerrissener Pfannkuchen mit Staubzucker, serviert mit hausgemachtem Zwetschkenröster.'
),
(
  'Panna Cotta mit Beerensauce',
  'Dessert', 7.50, 2.50, 'Milch',
  'kalt, süß, italienisch, elegant, cremig',
  'Abend, Festlich, Buffet, Nachmittag',
  'Cremige Panna Cotta aus Schlagobers und Vanille, serviert mit einer fruchtigen Beerensauce.'
),
(
  'Käseplatte mit Trauben und Nüssen',
  'Buffet', 8.00, 2.80, 'Milch, Nüsse',
  'kalt, Käse, Buffet, elegant',
  'Buffet, Empfang, Abend, Business',
  'Auswahl heimischer und internationaler Käsesorten, garniert mit frischen Trauben und Walnüssen.'
),
(
  'Aufschnittplatte mit Gebäck',
  'Buffet', 7.00, 2.50, 'Gluten, Milch',
  'kalt, herzhaft, Buffet, österreichisch',
  'Buffet, Business, Empfang, Mittag',
  'Reichhaltige Aufschnittplatte mit einer Auswahl an Wurst- und Schinkensorten, serviert mit frischem Gebäck.'
),
(
  'Gemüsesticks mit Kräuterdip',
  'Buffet', 5.00, 1.80, 'Milch',
  'kalt, vegan, gesund, Fingerfood, Buffet',
  'Buffet, Business, Empfang, Sommer',
  'Frische Gemüsesticks aus Gurke, Karotten und Paprika mit einem cremigen Kräuterdip – die leichte Alternative für gesundheitsbewusste Gäste.'
);

-- ============================================================
-- MenuItemIngredients for new items (9-30)
-- ============================================================

INSERT INTO MenuItemIngredients (MenuItemId, IngredientId, QuantityPerPerson) VALUES
-- Kürbiscremesuppe (9)
((SELECT Id FROM MenuItems WHERE Name='Kürbiscremesuppe'),                        (SELECT Id FROM Ingredients WHERE Name='Kürbis'),          0.150),
((SELECT Id FROM MenuItems WHERE Name='Kürbiscremesuppe'),                        (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),        0.040),
((SELECT Id FROM MenuItems WHERE Name='Kürbiscremesuppe'),                        (SELECT Id FROM Ingredients WHERE Name='Butter'),          0.020),
((SELECT Id FROM MenuItems WHERE Name='Kürbiscremesuppe'),                        (SELECT Id FROM Ingredients WHERE Name='Schlagobers'),     0.050),
((SELECT Id FROM MenuItems WHERE Name='Kürbiscremesuppe'),                        (SELECT Id FROM Ingredients WHERE Name='Gemüsebrühe'),     0.200),
-- Leberknödelsuppe (10)
((SELECT Id FROM MenuItems WHERE Name='Leberknödelsuppe'),                        (SELECT Id FROM Ingredients WHERE Name='Leberknödel'),     2.000),
((SELECT Id FROM MenuItems WHERE Name='Leberknödelsuppe'),                        (SELECT Id FROM Ingredients WHERE Name='Rindsuppe'),       0.300),
((SELECT Id FROM MenuItems WHERE Name='Leberknödelsuppe'),                        (SELECT Id FROM Ingredients WHERE Name='Karotten'),        0.030),
-- Bruschetta mit Tomaten und Basilikum (11)
((SELECT Id FROM MenuItems WHERE Name='Bruschetta mit Tomaten und Basilikum'),    (SELECT Id FROM Ingredients WHERE Name='Baguette'),        2.000),
((SELECT Id FROM MenuItems WHERE Name='Bruschetta mit Tomaten und Basilikum'),    (SELECT Id FROM Ingredients WHERE Name='Tomaten'),         0.080),
((SELECT Id FROM MenuItems WHERE Name='Bruschetta mit Tomaten und Basilikum'),    (SELECT Id FROM Ingredients WHERE Name='Olivenöl'),        0.015),
((SELECT Id FROM MenuItems WHERE Name='Bruschetta mit Tomaten und Basilikum'),    (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),        0.020),
-- Geräucherter Forellenaufstrich auf Schwarzbrot (12)
((SELECT Id FROM MenuItems WHERE Name='Geräucherter Forellenaufstrich auf Schwarzbrot'), (SELECT Id FROM Ingredients WHERE Name='Forellenfilet'),       0.060),
((SELECT Id FROM MenuItems WHERE Name='Geräucherter Forellenaufstrich auf Schwarzbrot'), (SELECT Id FROM Ingredients WHERE Name='Frischkäse'),          0.040),
((SELECT Id FROM MenuItems WHERE Name='Geräucherter Forellenaufstrich auf Schwarzbrot'), (SELECT Id FROM Ingredients WHERE Name='Schwarzbrot-Scheiben'),2.000),
-- Gulaschsuppe (13)
((SELECT Id FROM MenuItems WHERE Name='Gulaschsuppe'),                            (SELECT Id FROM Ingredients WHERE Name='Rindshackfleisch'),0.080),
((SELECT Id FROM MenuItems WHERE Name='Gulaschsuppe'),                            (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),        0.060),
((SELECT Id FROM MenuItems WHERE Name='Gulaschsuppe'),                            (SELECT Id FROM Ingredients WHERE Name='Paprika'),         0.040),
((SELECT Id FROM MenuItems WHERE Name='Gulaschsuppe'),                            (SELECT Id FROM Ingredients WHERE Name='Kartoffeln'),      0.080),
((SELECT Id FROM MenuItems WHERE Name='Gulaschsuppe'),                            (SELECT Id FROM Ingredients WHERE Name='Tomaten'),         0.050),
-- Backhendl mit Erdäpfelsalat (14)
((SELECT Id FROM MenuItems WHERE Name='Backhendl mit Erdäpfelsalat'),             (SELECT Id FROM Ingredients WHERE Name='Hühnerfilet'),     0.200),
((SELECT Id FROM MenuItems WHERE Name='Backhendl mit Erdäpfelsalat'),             (SELECT Id FROM Ingredients WHERE Name='Paniermehl'),      0.060),
((SELECT Id FROM MenuItems WHERE Name='Backhendl mit Erdäpfelsalat'),             (SELECT Id FROM Ingredients WHERE Name='Eier'),            1.000),
((SELECT Id FROM MenuItems WHERE Name='Backhendl mit Erdäpfelsalat'),             (SELECT Id FROM Ingredients WHERE Name='Mehl'),            0.040),
((SELECT Id FROM MenuItems WHERE Name='Backhendl mit Erdäpfelsalat'),             (SELECT Id FROM Ingredients WHERE Name='Kartoffeln'),      0.250),
((SELECT Id FROM MenuItems WHERE Name='Backhendl mit Erdäpfelsalat'),             (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),        0.050),
((SELECT Id FROM MenuItems WHERE Name='Backhendl mit Erdäpfelsalat'),             (SELECT Id FROM Ingredients WHERE Name='Butter'),          0.030),
-- Schweinsbraten mit Semmelknödel (15)
((SELECT Id FROM MenuItems WHERE Name='Schweinsbraten mit Semmelknödel'),         (SELECT Id FROM Ingredients WHERE Name='Schweinskragen'),  0.220),
((SELECT Id FROM MenuItems WHERE Name='Schweinsbraten mit Semmelknödel'),         (SELECT Id FROM Ingredients WHERE Name='Semmelknödel'),    2.000),
((SELECT Id FROM MenuItems WHERE Name='Schweinsbraten mit Semmelknödel'),         (SELECT Id FROM Ingredients WHERE Name='Karotten'),        0.080),
((SELECT Id FROM MenuItems WHERE Name='Schweinsbraten mit Semmelknödel'),         (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),        0.060),
-- Lachsfilet auf Blattspinat (16)
((SELECT Id FROM MenuItems WHERE Name='Lachsfilet auf Blattspinat'),              (SELECT Id FROM Ingredients WHERE Name='Lachs, frisch'),   0.180),
((SELECT Id FROM MenuItems WHERE Name='Lachsfilet auf Blattspinat'),              (SELECT Id FROM Ingredients WHERE Name='Spinat'),          0.100),
((SELECT Id FROM MenuItems WHERE Name='Lachsfilet auf Blattspinat'),              (SELECT Id FROM Ingredients WHERE Name='Butter'),          0.030),
((SELECT Id FROM MenuItems WHERE Name='Lachsfilet auf Blattspinat'),              (SELECT Id FROM Ingredients WHERE Name='Schlagobers'),     0.050),
((SELECT Id FROM MenuItems WHERE Name='Lachsfilet auf Blattspinat'),              (SELECT Id FROM Ingredients WHERE Name='Kartoffeln'),      0.150),
-- Hühnercurry mit Basmatireis (17)
((SELECT Id FROM MenuItems WHERE Name='Hühnercurry mit Basmatireis'),             (SELECT Id FROM Ingredients WHERE Name='Hühnerfilet'),     0.180),
((SELECT Id FROM MenuItems WHERE Name='Hühnercurry mit Basmatireis'),             (SELECT Id FROM Ingredients WHERE Name='Kokosmilch'),      0.150),
((SELECT Id FROM MenuItems WHERE Name='Hühnercurry mit Basmatireis'),             (SELECT Id FROM Ingredients WHERE Name='Currypulver'),     0.010),
((SELECT Id FROM MenuItems WHERE Name='Hühnercurry mit Basmatireis'),             (SELECT Id FROM Ingredients WHERE Name='Basmatireis'),     0.100),
((SELECT Id FROM MenuItems WHERE Name='Hühnercurry mit Basmatireis'),             (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),        0.050),
((SELECT Id FROM MenuItems WHERE Name='Hühnercurry mit Basmatireis'),             (SELECT Id FROM Ingredients WHERE Name='Paprika'),         0.080),
-- Spaghetti Bolognese (18)
((SELECT Id FROM MenuItems WHERE Name='Spaghetti Bolognese'),                     (SELECT Id FROM Ingredients WHERE Name='Spaghetti'),       0.120),
((SELECT Id FROM MenuItems WHERE Name='Spaghetti Bolognese'),                     (SELECT Id FROM Ingredients WHERE Name='Rindshackfleisch'),0.150),
((SELECT Id FROM MenuItems WHERE Name='Spaghetti Bolognese'),                     (SELECT Id FROM Ingredients WHERE Name='Dosentomaten'),    0.200),
((SELECT Id FROM MenuItems WHERE Name='Spaghetti Bolognese'),                     (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),        0.050),
((SELECT Id FROM MenuItems WHERE Name='Spaghetti Bolognese'),                     (SELECT Id FROM Ingredients WHERE Name='Rotwein'),         0.050),
((SELECT Id FROM MenuItems WHERE Name='Spaghetti Bolognese'),                     (SELECT Id FROM Ingredients WHERE Name='Parmesan'),        0.020),
-- Vegane Buddha Bowl (19)
((SELECT Id FROM MenuItems WHERE Name='Vegane Buddha Bowl'),                      (SELECT Id FROM Ingredients WHERE Name='Basmatireis'),     0.100),
((SELECT Id FROM MenuItems WHERE Name='Vegane Buddha Bowl'),                      (SELECT Id FROM Ingredients WHERE Name='Kichererbsen, gekocht'), 0.080),
((SELECT Id FROM MenuItems WHERE Name='Vegane Buddha Bowl'),                      (SELECT Id FROM Ingredients WHERE Name='Avocado'),         0.500),
((SELECT Id FROM MenuItems WHERE Name='Vegane Buddha Bowl'),                      (SELECT Id FROM Ingredients WHERE Name='Süßkartoffel'),    0.120),
((SELECT Id FROM MenuItems WHERE Name='Vegane Buddha Bowl'),                      (SELECT Id FROM Ingredients WHERE Name='Brokkoli'),        0.100),
((SELECT Id FROM MenuItems WHERE Name='Vegane Buddha Bowl'),                      (SELECT Id FROM Ingredients WHERE Name='Olivenöl'),        0.015),
-- Gegrillte Rindsspieße mit Grillgemüse (20)
((SELECT Id FROM MenuItems WHERE Name='Gegrillte Rindsspieße mit Grillgemüse'),   (SELECT Id FROM Ingredients WHERE Name='Rindsnacken'),     0.180),
((SELECT Id FROM MenuItems WHERE Name='Gegrillte Rindsspieße mit Grillgemüse'),   (SELECT Id FROM Ingredients WHERE Name='Zucchini'),        0.080),
((SELECT Id FROM MenuItems WHERE Name='Gegrillte Rindsspieße mit Grillgemüse'),   (SELECT Id FROM Ingredients WHERE Name='Paprika'),         0.080),
((SELECT Id FROM MenuItems WHERE Name='Gegrillte Rindsspieße mit Grillgemüse'),   (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),        0.060),
((SELECT Id FROM MenuItems WHERE Name='Gegrillte Rindsspieße mit Grillgemüse'),   (SELECT Id FROM Ingredients WHERE Name='Olivenöl'),        0.020),
-- Käsespätzle (21)
((SELECT Id FROM MenuItems WHERE Name='Käsespätzle'),                             (SELECT Id FROM Ingredients WHERE Name='Spätzle, frisch'), 0.200),
((SELECT Id FROM MenuItems WHERE Name='Käsespätzle'),                             (SELECT Id FROM Ingredients WHERE Name='Reibekäse'),       0.080),
((SELECT Id FROM MenuItems WHERE Name='Käsespätzle'),                             (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),        0.060),
((SELECT Id FROM MenuItems WHERE Name='Käsespätzle'),                             (SELECT Id FROM Ingredients WHERE Name='Butter'),          0.030),
-- Pasta Primavera (22)
((SELECT Id FROM MenuItems WHERE Name='Pasta Primavera'),                         (SELECT Id FROM Ingredients WHERE Name='Spaghetti'),       0.120),
((SELECT Id FROM MenuItems WHERE Name='Pasta Primavera'),                         (SELECT Id FROM Ingredients WHERE Name='Zucchini'),        0.060),
((SELECT Id FROM MenuItems WHERE Name='Pasta Primavera'),                         (SELECT Id FROM Ingredients WHERE Name='Karotten'),        0.040),
((SELECT Id FROM MenuItems WHERE Name='Pasta Primavera'),                         (SELECT Id FROM Ingredients WHERE Name='Spinat'),          0.050),
((SELECT Id FROM MenuItems WHERE Name='Pasta Primavera'),                         (SELECT Id FROM Ingredients WHERE Name='Parmesan'),        0.025),
((SELECT Id FROM MenuItems WHERE Name='Pasta Primavera'),                         (SELECT Id FROM Ingredients WHERE Name='Olivenöl'),        0.020),
((SELECT Id FROM MenuItems WHERE Name='Pasta Primavera'),                         (SELECT Id FROM Ingredients WHERE Name='Butter'),          0.015),
-- Palatschinken mit Aprikosenmarmelade (23)
((SELECT Id FROM MenuItems WHERE Name='Palatschinken mit Aprikosenmarmelade'),    (SELECT Id FROM Ingredients WHERE Name='Mehl'),            0.040),
((SELECT Id FROM MenuItems WHERE Name='Palatschinken mit Aprikosenmarmelade'),    (SELECT Id FROM Ingredients WHERE Name='Eier'),            1.000),
((SELECT Id FROM MenuItems WHERE Name='Palatschinken mit Aprikosenmarmelade'),    (SELECT Id FROM Ingredients WHERE Name='Butter'),          0.020),
((SELECT Id FROM MenuItems WHERE Name='Palatschinken mit Aprikosenmarmelade'),    (SELECT Id FROM Ingredients WHERE Name='Aprikosenmarmelade'), 0.040),
-- Apfelstrudel (24)
((SELECT Id FROM MenuItems WHERE Name='Apfelstrudel'),                            (SELECT Id FROM Ingredients WHERE Name='Strudelteig'),     0.080),
((SELECT Id FROM MenuItems WHERE Name='Apfelstrudel'),                            (SELECT Id FROM Ingredients WHERE Name='Äpfel'),           0.200),
((SELECT Id FROM MenuItems WHERE Name='Apfelstrudel'),                            (SELECT Id FROM Ingredients WHERE Name='Zucker'),          0.030),
((SELECT Id FROM MenuItems WHERE Name='Apfelstrudel'),                            (SELECT Id FROM Ingredients WHERE Name='Butter'),          0.020),
((SELECT Id FROM MenuItems WHERE Name='Apfelstrudel'),                            (SELECT Id FROM Ingredients WHERE Name='Schlagobers'),     0.040),
-- Mousse au Chocolat (25)
((SELECT Id FROM MenuItems WHERE Name='Mousse au Chocolat'),                      (SELECT Id FROM Ingredients WHERE Name='Schokolade, dunkel'), 0.060),
((SELECT Id FROM MenuItems WHERE Name='Mousse au Chocolat'),                      (SELECT Id FROM Ingredients WHERE Name='Schlagobers'),     0.100),
((SELECT Id FROM MenuItems WHERE Name='Mousse au Chocolat'),                      (SELECT Id FROM Ingredients WHERE Name='Eier'),            1.000),
((SELECT Id FROM MenuItems WHERE Name='Mousse au Chocolat'),                      (SELECT Id FROM Ingredients WHERE Name='Butter'),          0.015),
-- Kaiserschmarrn mit Zwetschkenröster (26)
((SELECT Id FROM MenuItems WHERE Name='Kaiserschmarrn mit Zwetschkenröster'),     (SELECT Id FROM Ingredients WHERE Name='Mehl'),            0.060),
((SELECT Id FROM MenuItems WHERE Name='Kaiserschmarrn mit Zwetschkenröster'),     (SELECT Id FROM Ingredients WHERE Name='Eier'),            1.500),
((SELECT Id FROM MenuItems WHERE Name='Kaiserschmarrn mit Zwetschkenröster'),     (SELECT Id FROM Ingredients WHERE Name='Butter'),          0.030),
((SELECT Id FROM MenuItems WHERE Name='Kaiserschmarrn mit Zwetschkenröster'),     (SELECT Id FROM Ingredients WHERE Name='Zucker'),          0.030),
((SELECT Id FROM MenuItems WHERE Name='Kaiserschmarrn mit Zwetschkenröster'),     (SELECT Id FROM Ingredients WHERE Name='Zwetschken'),      0.120),
((SELECT Id FROM MenuItems WHERE Name='Kaiserschmarrn mit Zwetschkenröster'),     (SELECT Id FROM Ingredients WHERE Name='Schlagobers'),     0.030),
-- Panna Cotta mit Beerensauce (27)
((SELECT Id FROM MenuItems WHERE Name='Panna Cotta mit Beerensauce'),             (SELECT Id FROM Ingredients WHERE Name='Schlagobers'),     0.150),
((SELECT Id FROM MenuItems WHERE Name='Panna Cotta mit Beerensauce'),             (SELECT Id FROM Ingredients WHERE Name='Gelatine'),        0.005),
((SELECT Id FROM MenuItems WHERE Name='Panna Cotta mit Beerensauce'),             (SELECT Id FROM Ingredients WHERE Name='Zucker'),          0.030),
((SELECT Id FROM MenuItems WHERE Name='Panna Cotta mit Beerensauce'),             (SELECT Id FROM Ingredients WHERE Name='Vanilleschote'),   0.500),
((SELECT Id FROM MenuItems WHERE Name='Panna Cotta mit Beerensauce'),             (SELECT Id FROM Ingredients WHERE Name='Beeren, gemischt'),0.080),
-- Käseplatte mit Trauben und Nüssen (28)
((SELECT Id FROM MenuItems WHERE Name='Käseplatte mit Trauben und Nüssen'),       (SELECT Id FROM Ingredients WHERE Name='Käse, gemischt'), 0.100),
((SELECT Id FROM MenuItems WHERE Name='Käseplatte mit Trauben und Nüssen'),       (SELECT Id FROM Ingredients WHERE Name='Trauben'),         0.060),
((SELECT Id FROM MenuItems WHERE Name='Käseplatte mit Trauben und Nüssen'),       (SELECT Id FROM Ingredients WHERE Name='Walnüsse'),        0.020),
-- Aufschnittplatte mit Gebäck (29)
((SELECT Id FROM MenuItems WHERE Name='Aufschnittplatte mit Gebäck'),             (SELECT Id FROM Ingredients WHERE Name='Aufschnitt, gemischt'), 0.100),
((SELECT Id FROM MenuItems WHERE Name='Aufschnittplatte mit Gebäck'),             (SELECT Id FROM Ingredients WHERE Name='Laugengebäck'),    1.000),
((SELECT Id FROM MenuItems WHERE Name='Aufschnittplatte mit Gebäck'),             (SELECT Id FROM Ingredients WHERE Name='Butter'),          0.015),
-- Gemüsesticks mit Kräuterdip (30)
((SELECT Id FROM MenuItems WHERE Name='Gemüsesticks mit Kräuterdip'),             (SELECT Id FROM Ingredients WHERE Name='Karotten'),        0.060),
((SELECT Id FROM MenuItems WHERE Name='Gemüsesticks mit Kräuterdip'),             (SELECT Id FROM Ingredients WHERE Name='Gurke'),           0.060),
((SELECT Id FROM MenuItems WHERE Name='Gemüsesticks mit Kräuterdip'),             (SELECT Id FROM Ingredients WHERE Name='Paprika'),         0.060),
((SELECT Id FROM MenuItems WHERE Name='Gemüsesticks mit Kräuterdip'),             (SELECT Id FROM Ingredients WHERE Name='Frischkäse'),      0.050);
