using Dapper;

namespace CaterMate.Db.Seeding;

public static class DemoOrderSeeder
{
    private static readonly string[] Statements =
    [
        """
        INSERT INTO Customers (Id, Name, Phone, CreatedAt) VALUES
        (901, 'Demo Auftrag Neu GmbH', '+43 660 1000001', CURRENT_TIMESTAMP),
        (902, 'Demo Geprueft KG', '+43 660 1000002', CURRENT_TIMESTAMP),
        (903, 'Demo Angebot AG', '+43 660 1000003', CURRENT_TIMESTAMP),
        (904, 'Demo Bestaetigt GmbH', '+43 660 1000004', CURRENT_TIMESTAMP),
        (905, 'Demo Beschaffung e.U.', '+43 660 1000005', CURRENT_TIMESTAMP),
        (906, 'Demo Vorbereitung OG', '+43 660 1000006', CURRENT_TIMESTAMP),
        (907, 'Demo Durchgefuehrt Verein', '+43 660 1000007', CURRENT_TIMESTAMP),
        (908, 'Demo Abgerechnet Holding', '+43 660 1000008', CURRENT_TIMESTAMP),
        (909, 'Demo Storniert Privat', '+43 660 1000009', CURRENT_TIMESTAMP)
        ON DUPLICATE KEY UPDATE
            Name = VALUES(Name),
            Phone = VALUES(Phone)
        """,
        """
        INSERT INTO Orders (
            Id, CustomerId, EventDate, EventType, Location, GuestCount, Budget,
            SpecialWishes, Allergies, DishWishes, Status, CreatedAt, UpdatedAt
        ) VALUES
        (901, 901, DATE_ADD(CURRENT_DATE(), INTERVAL 14 DAY) + INTERVAL 10 HOUR, 'Business-Fruehstueck', 'Salzburg, Coworking Lounge', 18, 650.00, 'Kompakter Aufbau, Kaffee durchgehend', '2x laktosefrei', 'Gebaeck, vegetarische Optionen', 'Neu', DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 2 DAY), CURRENT_TIMESTAMP),
        (902, 902, DATE_ADD(CURRENT_DATE(), INTERVAL 21 DAY) + INTERVAL 18 HOUR, 'Sommerempfang', 'Hallein, Innenhof', 42, 1800.00, 'Fingerfood und kalte Vorspeisen', '1x Nussallergie', 'Leichtes Buffet mit Fischoption', 'Geprüft', DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 5 DAY), CURRENT_TIMESTAMP),
        (903, 903, DATE_ADD(CURRENT_DATE(), INTERVAL 35 DAY) + INTERVAL 19 HOUR, 'Gala Dinner', 'Salzburg, Altstadtpalais', 96, 7800.00, 'Festliche Tischfolge, Service am Platz', 'Glutenfreie Alternative', 'Rinderfilet, Dessertvariation', 'AngebotErstellt', DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 9 DAY), CURRENT_TIMESTAMP),
        (904, 904, DATE_ADD(CURRENT_DATE(), INTERVAL 45 DAY) + INTERVAL 12 HOUR, 'Firmenjubilaeum', 'Wals, Eventhalle', 150, 11250.00, 'Buffet mit vegetarischer Linie', 'Sellerie vermeiden', 'Oesterreichisch, herzhaft', 'Bestätigt', DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 12 DAY), CURRENT_TIMESTAMP),
        (905, 905, DATE_ADD(CURRENT_DATE(), INTERVAL 6 DAY) + INTERVAL 15 HOUR, 'Workshop Catering', 'FH Salzburg, Seminarraum B', 34, 1450.00, 'Lunch in zwei Pausen', '3x vegetarisch', 'Risotto und Salatanteil', 'InBeschaffung', DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 14 DAY), CURRENT_TIMESTAMP),
        (906, 906, DATE_ADD(CURRENT_DATE(), INTERVAL 2 DAY) + INTERVAL 17 HOUR, 'Abendbuffet', 'Seekirchen, Vereinsheim', 58, 3200.00, 'Rustikales Buffet, kurze Aufbauzeit', 'Keine Meeresfruechte', 'Gulasch, Strudel, Gebaeck', 'InVorbereitung', DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 18 DAY), CURRENT_TIMESTAMP),
        (907, 907, DATE_SUB(CURRENT_DATE(), INTERVAL 3 DAY) + INTERVAL 18 HOUR, 'Produktpraesentation', 'Salzburg, Showroom Nord', 75, 5200.00, 'Bereits durchgefuehrt, Rechnung offen', '2x glutenfrei', 'Modernes Flying Buffet', 'Durchgeführt', DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 28 DAY), CURRENT_TIMESTAMP),
        (908, 908, DATE_SUB(CURRENT_DATE(), INTERVAL 24 DAY) + INTERVAL 13 HOUR, 'Konferenz Lunch', 'Puch, Campus Aula', 120, 6900.00, 'Abgeschlossener Auftrag mit Rechnung', '1x vegan, 4x vegetarisch', 'Business Lunch und Dessert', 'Abgerechnet', DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 45 DAY), CURRENT_TIMESTAMP),
        (909, 909, DATE_ADD(CURRENT_DATE(), INTERVAL 12 DAY) + INTERVAL 16 HOUR, 'Private Feier', 'Anif, Gartenlocation', 40, 2100.00, 'Kunde hat Termin abgesagt', 'Keine Angaben', 'Mediterranes Buffet', 'Storniert', DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 7 DAY), CURRENT_TIMESTAMP)
        ON DUPLICATE KEY UPDATE
            CustomerId = VALUES(CustomerId),
            EventDate = VALUES(EventDate),
            EventType = VALUES(EventType),
            Location = VALUES(Location),
            GuestCount = VALUES(GuestCount),
            Budget = VALUES(Budget),
            SpecialWishes = VALUES(SpecialWishes),
            Allergies = VALUES(Allergies),
            DishWishes = VALUES(DishWishes),
            Status = VALUES(Status),
            UpdatedAt = VALUES(UpdatedAt)
        """,
        """
        INSERT INTO OrderMenuItems (OrderId, MenuItemId, `Count`) VALUES
        (902, 4, 42),
        (902, 5, 42),
        (903, 9, 96),
        (903, 32, 96),
        (904, 1, 150),
        (904, 7, 150),
        (905, 3, 34),
        (905, 25, 34),
        (906, 24, 58),
        (906, 35, 58),
        (907, 26, 75),
        (907, 33, 75),
        (908, 15, 120),
        (908, 34, 120),
        (909, 14, 40),
        (909, 27, 40)
        ON DUPLICATE KEY UPDATE
            `Count` = VALUES(`Count`)
        """,
        """
        INSERT INTO Quotes (Id, OrderId, AdminFee, ProfitMarginRate, TotalNet, TotalVat, TotalGross, CreatedAt) VALUES
        (903, 903, 350.00, 0.1800, 6240.00, 624.00, 6864.00, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 8 DAY)),
        (904, 904, 420.00, 0.1600, 10350.00, 1035.00, 11385.00, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 11 DAY)),
        (905, 905, 200.00, 0.1500, 1360.00, 136.00, 1496.00, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 12 DAY)),
        (906, 906, 240.00, 0.1500, 3016.00, 301.60, 3317.60, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 16 DAY)),
        (907, 907, 300.00, 0.1700, 4800.00, 480.00, 5280.00, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 25 DAY)),
        (908, 908, 380.00, 0.1600, 6360.00, 636.00, 6996.00, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 40 DAY)),
        (909, 909, 220.00, 0.1500, 1960.00, 196.00, 2156.00, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 6 DAY))
        ON DUPLICATE KEY UPDATE
            AdminFee = VALUES(AdminFee),
            ProfitMarginRate = VALUES(ProfitMarginRate),
            TotalNet = VALUES(TotalNet),
            TotalVat = VALUES(TotalVat),
            TotalGross = VALUES(TotalGross)
        """,
        """
        INSERT INTO QuotePositions (Id, QuoteId, MenuItemId, MenuItemName, Quantity, UnitPrice, TotalNet, VatRate, VatAmount, TotalGross) VALUES
        (9031, 903, 9, 'Rinderfilet mit Kartoffelgratin', 96, 34.00, 3264.00, 0.1000, 326.40, 3590.40),
        (9032, 903, 32, 'Creme Brulee', 96, 8.00, 768.00, 0.1000, 76.80, 844.80),
        (9041, 904, 1, 'Wiener Schnitzel mit Erdaepfelsalat', 150, 24.00, 3600.00, 0.1000, 360.00, 3960.00),
        (9042, 904, 7, 'Topfenstrudel', 150, 7.00, 1050.00, 0.1000, 105.00, 1155.00),
        (9051, 905, 3, 'Gemuese-Risotto', 34, 18.00, 612.00, 0.1000, 61.20, 673.20),
        (9052, 905, 25, 'Spargel-Risotto mit Parmesan', 34, 20.00, 680.00, 0.1000, 68.00, 748.00),
        (9061, 906, 24, 'Rindsgulasch mit Semmelknoedel', 58, 20.00, 1160.00, 0.1000, 116.00, 1276.00),
        (9062, 906, 35, 'Apfelstrudel', 58, 7.00, 406.00, 0.1000, 40.60, 446.60),
        (9071, 907, 26, 'Avocado-Toast mit Raeucherlachs', 75, 11.00, 825.00, 0.1000, 82.50, 907.50),
        (9072, 907, 33, 'Mousse au Chocolat', 75, 7.50, 562.50, 0.1000, 56.25, 618.75),
        (9081, 908, 15, 'Pasta Bolognese', 120, 18.00, 2160.00, 0.1000, 216.00, 2376.00),
        (9082, 908, 34, 'Erdbeer-Panna-Cotta', 120, 8.00, 960.00, 0.1000, 96.00, 1056.00),
        (9091, 909, 14, 'Garnelen-Risotto', 40, 24.00, 960.00, 0.1000, 96.00, 1056.00),
        (9092, 909, 27, 'Bruschetta mit Tomaten und Rucola', 40, 7.00, 280.00, 0.1000, 28.00, 308.00)
        ON DUPLICATE KEY UPDATE
            Quantity = VALUES(Quantity),
            UnitPrice = VALUES(UnitPrice),
            TotalNet = VALUES(TotalNet),
            VatAmount = VALUES(VatAmount),
            TotalGross = VALUES(TotalGross)
        """,
        """
        INSERT INTO PurchaseLists (Id, OrderId, SafetyMargin, CreatedAt) VALUES
        (905, 905, 0.1000, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 5 DAY)),
        (906, 906, 0.1000, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 4 DAY)),
        (907, 907, 0.1000, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 10 DAY)),
        (908, 908, 0.1000, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 32 DAY))
        ON DUPLICATE KEY UPDATE
            SafetyMargin = VALUES(SafetyMargin)
        """,
        """
        INSERT INTO PurchaseListItems (Id, PurchaseListId, IngredientId, IngredientName, RequiredQuantity, Unit, Category, IsDone) VALUES
        (9051, 905, 12, 'Risotto-Reis', 7.480, 'kg', 'Trockenware', 0),
        (9052, 905, 17, 'Parmesan', 1.870, 'kg', 'Milchprodukte', 0),
        (9061, 906, 54, 'Rinderschulter', 12.760, 'kg', 'Fleisch', 1),
        (9062, 906, 48, 'Semmeln', 127.600, 'Stk', 'Backwaren', 1),
        (9071, 907, 53, 'Raeucherlachs', 3.300, 'kg', 'Fisch', 1),
        (9072, 907, 26, 'Schokolade, dunkel', 4.950, 'kg', 'Sonstiges', 1),
        (9081, 908, 43, 'Pasta', 15.840, 'kg', 'Trockenware', 1),
        (9082, 908, 56, 'Erdbeeren', 10.560, 'kg', 'Sonstiges', 1)
        ON DUPLICATE KEY UPDATE
            RequiredQuantity = VALUES(RequiredQuantity),
            IsDone = VALUES(IsDone)
        """,
        """
        INSERT INTO Invoices (Id, OrderId, InvoiceNumber, CustomerName, IssueDate, DueDate, TotalNet, TotalVat, TotalGross, CreatedAt) VALUES
        (908, 908, 'DEMO-0001', 'Demo Abgerechnet Holding', DATE_SUB(CURRENT_DATE(), INTERVAL 20 DAY), DATE_SUB(CURRENT_DATE(), INTERVAL 6 DAY), 6360.00, 636.00, 6996.00, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 20 DAY))
        ON DUPLICATE KEY UPDATE
            CustomerName = VALUES(CustomerName),
            IssueDate = VALUES(IssueDate),
            DueDate = VALUES(DueDate),
            TotalNet = VALUES(TotalNet),
            TotalVat = VALUES(TotalVat),
            TotalGross = VALUES(TotalGross)
        """,
        """
        INSERT INTO Customers (Id, Name, Phone, CreatedAt) VALUES
        (910,'Bergkristall Events GmbH','+43 662 5000010',CURRENT_TIMESTAMP),
        (911,'Mayer & Partner KG','+43 662 5000011',CURRENT_TIMESTAMP),
        (912,'Salzburg Tagungshaus','+43 662 5000012',CURRENT_TIMESTAMP),
        (913,'Alpenrose Catering OG','+43 662 5000013',CURRENT_TIMESTAMP),
        (914,'TechStart Austria GmbH','+43 662 5000014',CURRENT_TIMESTAMP),
        (915,'Musikverein Hallein','+43 662 5000015',CURRENT_TIMESTAMP),
        (916,'Hotel Sacher Events','+43 662 5000016',CURRENT_TIMESTAMP),
        (917,'Universität Salzburg','+43 662 5000017',CURRENT_TIMESTAMP),
        (918,'BioMarkt Gruppe','+43 662 5000018',CURRENT_TIMESTAMP),
        (919,'Sportzentrum Nord','+43 662 5000019',CURRENT_TIMESTAMP),
        (920,'Weinbau Huber','+43 662 5000020',CURRENT_TIMESTAMP),
        (921,'Kinderhaus Sonnenschein','+43 662 5000021',CURRENT_TIMESTAMP),
        (922,'Architekturbüro Zell','+43 662 5000022',CURRENT_TIMESTAMP),
        (923,'Feuerwehr Grödig','+43 662 5000023',CURRENT_TIMESTAMP),
        (924,'Pharma AG Salzburg','+43 662 5000024',CURRENT_TIMESTAMP),
        (925,'Messezentrum Salzburg','+43 662 5000025',CURRENT_TIMESTAMP),
        (926,'Kulturzentrum ARGEkultur','+43 662 5000026',CURRENT_TIMESTAMP),
        (927,'Autohaus Stadler','+43 662 5000027',CURRENT_TIMESTAMP),
        (928,'Seniorenheim Aigen','+43 662 5000028',CURRENT_TIMESTAMP),
        (929,'StartUp Hub Salzburg','+43 662 5000029',CURRENT_TIMESTAMP),
        (930,'Brauerei Kaltenhausen','+43 662 5000030',CURRENT_TIMESTAMP),
        (931,'Immobilien Eder GmbH','+43 662 5000031',CURRENT_TIMESTAMP),
        (932,'Volksschule Maxglan','+43 662 5000032',CURRENT_TIMESTAMP),
        (933,'Golfclub Salzburg','+43 662 5000033',CURRENT_TIMESTAMP),
        (934,'Rotes Kreuz OV Hallein','+43 662 5000034',CURRENT_TIMESTAMP),
        (935,'ORF Landesstudio','+43 662 5000035',CURRENT_TIMESTAMP),
        (936,'Versicherung Allgemein','+43 662 5000036',CURRENT_TIMESTAMP),
        (937,'Reisebüro Fernweh','+43 662 5000037',CURRENT_TIMESTAMP),
        (938,'Kunsthaus Salzburg','+43 662 5000038',CURRENT_TIMESTAMP),
        (939,'IT Consulting Wieser','+43 662 5000039',CURRENT_TIMESTAMP),
        (940,'Handwerk Meister GmbH','+43 662 5000040',CURRENT_TIMESTAMP),
        (941,'Yoga Studio Balance','+43 662 5000041',CURRENT_TIMESTAMP),
        (942,'Bergbahn AG','+43 662 5000042',CURRENT_TIMESTAMP),
        (943,'Steuerberatung Kern','+43 662 5000043',CURRENT_TIMESTAMP),
        (944,'Tennisclub Nonntal','+43 662 5000044',CURRENT_TIMESTAMP),
        (945,'Galerie Rupertinum','+43 662 5000045',CURRENT_TIMESTAMP),
        (946,'Bauunternehmen Hofer','+43 662 5000046',CURRENT_TIMESTAMP),
        (947,'Landwirtschaft Kogler','+43 662 5000047',CURRENT_TIMESTAMP),
        (948,'Fitness First Salzburg','+43 662 5000048',CURRENT_TIMESTAMP),
        (949,'Anwaltskanzlei Huber','+43 662 5000049',CURRENT_TIMESTAMP),
        (950,'Modeatelier Klein','+43 662 5000050',CURRENT_TIMESTAMP),
        (951,'Stadttheater Salzburg','+43 662 5000051',CURRENT_TIMESTAMP),
        (952,'Biohotel Erika','+43 662 5000052',CURRENT_TIMESTAMP),
        (953,'Digitalagentur Pulse','+43 662 5000053',CURRENT_TIMESTAMP),
        (954,'Klinikum Salzburg','+43 662 5000054',CURRENT_TIMESTAMP),
        (955,'Sportverein ASKÖ','+43 662 5000055',CURRENT_TIMESTAMP),
        (956,'Eventlocation Schloss','+43 662 5000056',CURRENT_TIMESTAMP),
        (957,'Kindergarten Regenbogen','+43 662 5000057',CURRENT_TIMESTAMP),
        (958,'Werbung & Design GmbH','+43 662 5000058',CURRENT_TIMESTAMP),
        (959,'Musikschule Liefering','+43 662 5000059',CURRENT_TIMESTAMP)
        ON DUPLICATE KEY UPDATE Name=VALUES(Name), Phone=VALUES(Phone)
        """,
        """
        INSERT INTO Orders (Id, CustomerId, EventDate, EventType, Location, GuestCount, Budget, SpecialWishes, Allergies, DishWishes, Status, CreatedAt, UpdatedAt) VALUES
        (910,910, DATE_ADD(CURRENT_DATE(),INTERVAL 8 DAY)+INTERVAL 18 HOUR, 'Jahresempfang','Salzburg Altstadt',85,5200.00,'Stehtisch-Setup','Keine Nüsse','Häppchen & Wein','Geprüft',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 4 DAY),CURRENT_TIMESTAMP),
        (911,911, DATE_ADD(CURRENT_DATE(),INTERVAL 18 DAY)+INTERVAL 12 HOUR, 'Betriebsfeier','Salzburg, Firmengelände',60,3400.00,'Grillbuffet gewünscht','2x laktosefrei','BBQ & Salate','Neu',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 1 DAY),CURRENT_TIMESTAMP),
        (912,912, DATE_ADD(CURRENT_DATE(),INTERVAL 25 DAY)+INTERVAL 9 HOUR, 'Konferenz-Lunch','Salzburg Tagungshaus',120,6800.00,'3-Gang, Service','1x vegan','Österr. Klassiker','AngebotErstellt',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 8 DAY),CURRENT_TIMESTAMP),
        (913,913, DATE_ADD(CURRENT_DATE(),INTERVAL 32 DAY)+INTERVAL 16 HOUR, 'Hochzeit','Schloss Mirabell Garten',140,14000.00,'5-Gang Dinner, Torte','4x vegetarisch','Wiener Küche, Premium','Bestätigt',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 15 DAY),CURRENT_TIMESTAMP),
        (914,914, DATE_ADD(CURRENT_DATE(),INTERVAL 40 DAY)+INTERVAL 11 HOUR, 'Launch Event','Techpark Salzburg',200,12000.00,'Fingerfood & Networking','3x glutenfrei','Modern & International','InBeschaffung',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 22 DAY),CURRENT_TIMESTAMP),
        (915,915, DATE_ADD(CURRENT_DATE(),INTERVAL 3 DAY)+INTERVAL 20 HOUR, 'Konzert-Empfang','Festspielhaus Foyer',55,3100.00,'Sektspalier, kurze Stehzeit','Keine Meeresfrüchte','Fingerfood & Pralinen','InVorbereitung',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 20 DAY),CURRENT_TIMESTAMP),
        (916,916, DATE_ADD(CURRENT_DATE(),INTERVAL 55 DAY)+INTERVAL 19 HOUR, 'Gala-Dinner','Hotel Sacher Salzburg',180,22000.00,'Weinkarte koordinieren','2x Sellerie-Allergie','Haute Cuisine 7 Gänge','AngebotErstellt',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 10 DAY),CURRENT_TIMESTAMP),
        (917,917, DATE_ADD(CURRENT_DATE(),INTERVAL 62 DAY)+INTERVAL 12 HOUR, 'Uni-Fest','Unipark Nonntal',300,9500.00,'Studentisches Budget','5x vegan','International & günstig','Neu',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 2 DAY),CURRENT_TIMESTAMP),
        (918,918, DATE_ADD(CURRENT_DATE(),INTERVAL 70 DAY)+INTERVAL 10 HOUR, 'Bio-Messe','Messezentrum Halle 3',250,11000.00,'Nur Bio-Produkte','Alles bio, keine Kompromisse','Regional & saisonal','Geprüft',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 6 DAY),CURRENT_TIMESTAMP),
        (919,919, DATE_ADD(CURRENT_DATE(),INTERVAL 78 DAY)+INTERVAL 15 HOUR, 'Sportgala','Sportzentrum Nord',90,4200.00,'Sportlerernährung beachten','Keine Laktose','High-Protein Buffet','Neu',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 1 DAY),CURRENT_TIMESTAMP),
        (920,920, DATE_ADD(CURRENT_DATE(),INTERVAL 85 DAY)+INTERVAL 17 HOUR, 'Weinverkostung','Weingut Huber Keller',40,2800.00,'Weinbegleitung 6 Gänge','1x Histaminintoleranz','Regionalküche','Bestätigt',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 18 DAY),CURRENT_TIMESTAMP),
        (921,921, DATE_ADD(CURRENT_DATE(),INTERVAL 92 DAY)+INTERVAL 11 HOUR, 'Sommerfest Kinder','Kinderhaus Garten',80,2400.00,'Kinderfreundlich, bunt','Diverse Allergien beachten','Pizza, Nudeln, Eis','Geprüft',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 3 DAY),CURRENT_TIMESTAMP),
        (922,922, DATE_ADD(CURRENT_DATE(),INTERVAL 100 DAY)+INTERVAL 18 HOUR, 'Büro-Opening','Zell Architektur HQ',35,1800.00,'Modern & stilvoll','1x vegan','Tapas & Cocktail-Food','Neu',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 2 DAY),CURRENT_TIMESTAMP),
        (923,923, DATE_ADD(CURRENT_DATE(),INTERVAL 108 DAY)+INTERVAL 14 HOUR, 'Vereinsfeier','Feuerwehrhaus Grödig',70,2600.00,'Rustikal, herzlich','Keine Beschränkungen','Gulasch, Knödel, Bier','Geprüft',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 5 DAY),CURRENT_TIMESTAMP),
        (924,924, DATE_ADD(CURRENT_DATE(),INTERVAL 115 DAY)+INTERVAL 12 HOUR, 'Pharma-Kongress','Congress Salzburg',400,28000.00,'Business Lunch 3 Tage','Diverse','International Premium','AngebotErstellt',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 9 DAY),CURRENT_TIMESTAMP),
        (925,925, DATE_ADD(CURRENT_DATE(),INTERVAL 122 DAY)+INTERVAL 9 HOUR, 'Messeeröffnung','Messezentrum Halle 1',600,35000.00,'Buffet & Empfang','6x glutenfrei, 4x vegan','Internationales Buffet','Neu',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 1 DAY),CURRENT_TIMESTAMP),
        -- Past events for Heatmap density (abgerechnet & durchgeführt)
        (926,926, DATE_SUB(CURRENT_DATE(),INTERVAL 5 DAY)+INTERVAL 20 HOUR, 'Kultur-Vernissage','ARGEkultur Salzburg',65,2900.00,'Abgeschlossen','1x Nussallergie','Käse, Wein, Häppchen','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 30 DAY),CURRENT_TIMESTAMP),
        (927,927, DATE_SUB(CURRENT_DATE(),INTERVAL 8 DAY)+INTERVAL 17 HOUR, 'Autohaus Event','Autohaus Stadler',50,2200.00,'Abgeschlossen','Keine','Häppchen & Sekt','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 35 DAY),CURRENT_TIMESTAMP),
        (928,928, DATE_SUB(CURRENT_DATE(),INTERVAL 12 DAY)+INTERVAL 12 HOUR, 'Senioren-Nachmittag','Seniorenheim Aigen',45,1400.00,'Abgeschlossen','3x Diabetes-gerecht','Kaffee, Kuchen, Kleinigkeiten','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 40 DAY),CURRENT_TIMESTAMP),
        (929,929, DATE_SUB(CURRENT_DATE(),INTERVAL 15 DAY)+INTERVAL 18 HOUR, 'Pitch Night','StartUp Hub',30,900.00,'Abgeschlossen','1x vegan','Fingerfood & Softdrinks','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 42 DAY),CURRENT_TIMESTAMP),
        (930,930, DATE_SUB(CURRENT_DATE(),INTERVAL 18 DAY)+INTERVAL 14 HOUR, 'Brauerei-Fest','Kaltenhausen Brauereigelände',200,8500.00,'Abgeschlossen','Keine','Brotzeiten & Bier','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 50 DAY),CURRENT_TIMESTAMP),
        (931,931, DATE_SUB(CURRENT_DATE(),INTERVAL 22 DAY)+INTERVAL 17 HOUR, 'Immobilien-Abend','Eder GmbH Showroom',40,2100.00,'Abgeschlossen','1x laktosefrei','Champagner & Häppchen','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 55 DAY),CURRENT_TIMESTAMP),
        (932,932, DATE_SUB(CURRENT_DATE(),INTERVAL 28 DAY)+INTERVAL 11 HOUR, 'Schulabschluss','Volksschule Maxglan',60,1200.00,'Abgeschlossen','5x Nussallergie','Kinderfreundliches Buffet','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 60 DAY),CURRENT_TIMESTAMP),
        (933,933, DATE_SUB(CURRENT_DATE(),INTERVAL 35 DAY)+INTERVAL 14 HOUR, 'Golf-Turnier','Golfclub Clubhaus',80,5600.00,'Abgeschlossen','2x glutenfrei','Elegantes Lunch-Buffet','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 65 DAY),CURRENT_TIMESTAMP),
        (934,934, DATE_SUB(CURRENT_DATE(),INTERVAL 40 DAY)+INTERVAL 12 HOUR, 'Blaulicht-Fest','Rotes Kreuz Halle',120,3800.00,'Abgeschlossen','Keine','Gemischtes Buffet','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 70 DAY),CURRENT_TIMESTAMP),
        (935,935, DATE_SUB(CURRENT_DATE(),INTERVAL 45 DAY)+INTERVAL 19 HOUR, 'ORF-Jahresfest','Landesstudio Garten',90,6500.00,'Abgeschlossen','3x vegetarisch','Flying Buffet Premium','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 75 DAY),CURRENT_TIMESTAMP),
        (936,936, DATE_SUB(CURRENT_DATE(),INTERVAL 50 DAY)+INTERVAL 17 HOUR, 'Versicherungs-Tag','Versicherung Konferenzraum',55,2800.00,'Abgeschlossen','1x vegan','Mittagsbuffet','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 80 DAY),CURRENT_TIMESTAMP),
        (937,937, DATE_SUB(CURRENT_DATE(),INTERVAL 56 DAY)+INTERVAL 18 HOUR, 'Reise-Abend','Fernweh Filiale Salzburg',35,1600.00,'Abgeschlossen','Keine','Internationale Snacks','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 85 DAY),CURRENT_TIMESTAMP),
        (938,938, DATE_SUB(CURRENT_DATE(),INTERVAL 62 DAY)+INTERVAL 19 HOUR, 'Galerie-Opening','Kunsthaus Salzburg',70,4200.00,'Abgeschlossen','1x Histamin','Wein & Käse, Fine Dining','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 90 DAY),CURRENT_TIMESTAMP),
        (939,939, DATE_SUB(CURRENT_DATE(),INTERVAL 68 DAY)+INTERVAL 17 HOUR, 'IT-Meetup','Wieser Büro Rooftop',25,800.00,'Abgeschlossen','1x vegan, 1x vegetarisch','Pizza & Craft Beer','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 95 DAY),CURRENT_TIMESTAMP),
        (940,940, DATE_SUB(CURRENT_DATE(),INTERVAL 74 DAY)+INTERVAL 16 HOUR, 'Handwerker-Fest','Meister GmbH Werkshalle',90,3100.00,'Abgeschlossen','Keine','Hausmannskost Buffet','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 100 DAY),CURRENT_TIMESTAMP),
        (941,941, DATE_SUB(CURRENT_DATE(),INTERVAL 80 DAY)+INTERVAL 10 HOUR, 'Yoga-Retreat','Balance Studio',20,600.00,'Abgeschlossen','2x vegan, alle vegetarisch','Gesundes Brunch-Buffet','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 105 DAY),CURRENT_TIMESTAMP),
        (942,942, DATE_SUB(CURRENT_DATE(),INTERVAL 86 DAY)+INTERVAL 12 HOUR, 'Saisoneröffnung','Bergbahn Talstation',150,7200.00,'Abgeschlossen','3x laktosefrei','Alpen-Buffet','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 110 DAY),CURRENT_TIMESTAMP),
        (943,943, DATE_SUB(CURRENT_DATE(),INTERVAL 92 DAY)+INTERVAL 18 HOUR, 'Mandanten-Abend','Kern Steuerberatung Kanzlei',30,2000.00,'Abgeschlossen','1x glutenfrei','Fingerfood & Wein','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 115 DAY),CURRENT_TIMESTAMP),
        (944,944, DATE_SUB(CURRENT_DATE(),INTERVAL 98 DAY)+INTERVAL 14 HOUR, 'Tennis-Saison-Abschluss','Tennisclub Clubhaus',50,2400.00,'Abgeschlossen','2x Nussallergie','Grill-Buffet','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 120 DAY),CURRENT_TIMESTAMP),
        (945,945, DATE_SUB(CURRENT_DATE(),INTERVAL 104 DAY)+INTERVAL 19 HOUR, 'Finissage','Galerie Rupertinum',60,3600.00,'Abgeschlossen','1x Histamin','Sekt & Häppchen, Patisserie','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 125 DAY),CURRENT_TIMESTAMP),
        (946,946, DATE_SUB(CURRENT_DATE(),INTERVAL 110 DAY)+INTERVAL 12 HOUR, 'Richtfest','Hofer Bau Baustelle Zentrum',100,4000.00,'Abgeschlossen','Keine','Brotzeiten & Bier','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 130 DAY),CURRENT_TIMESTAMP),
        (947,947, DATE_SUB(CURRENT_DATE(),INTERVAL 116 DAY)+INTERVAL 13 HOUR, 'Erntedankfest','Kogler Hof',130,4800.00,'Abgeschlossen','4x vegan','Bäuerliches Buffet','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 135 DAY),CURRENT_TIMESTAMP),
        (948,948, DATE_SUB(CURRENT_DATE(),INTERVAL 122 DAY)+INTERVAL 18 HOUR, 'Fitness-Gala','Fitness First Ballroom',110,5500.00,'Abgeschlossen','5x vegetarisch','Healthy Buffet & Cocktails','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 140 DAY),CURRENT_TIMESTAMP),
        (949,949, DATE_SUB(CURRENT_DATE(),INTERVAL 128 DAY)+INTERVAL 19 HOUR, 'Kanzlei-Jubiläum','Huber Anwälte Penthouse',45,3800.00,'Abgeschlossen','1x vegan','5-Gang-Menü','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 145 DAY),CURRENT_TIMESTAMP),
        (950,950, DATE_SUB(CURRENT_DATE(),INTERVAL 134 DAY)+INTERVAL 18 HOUR, 'Fashion-Show','Modeatelier Klein Showroom',75,6200.00,'Abgeschlossen','2x laktosefrei','Champagner & Amuse-Bouches','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 150 DAY),CURRENT_TIMESTAMP),
        (951,951, DATE_SUB(CURRENT_DATE(),INTERVAL 140 DAY)+INTERVAL 19 HOUR, 'Theaterpremiere','Stadttheater Foyer',160,9000.00,'Abgeschlossen','3x glutenfrei','Fine Dining Flying Buffet','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 155 DAY),CURRENT_TIMESTAMP),
        (952,952, DATE_SUB(CURRENT_DATE(),INTERVAL 146 DAY)+INTERVAL 12 HOUR, 'Bio-Frühstück','Biohotel Erika Terrasse',28,900.00,'Abgeschlossen','Alles bio & vegan','Frühstücksbuffet Regional','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 160 DAY),CURRENT_TIMESTAMP),
        (953,953, DATE_SUB(CURRENT_DATE(),INTERVAL 152 DAY)+INTERVAL 17 HOUR, 'Digital-Summit','Pulse Agentur Dachterrasse',40,2600.00,'Abgeschlossen','2x vegan','Street-Food & Craft Beer','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 165 DAY),CURRENT_TIMESTAMP),
        (954,954, DATE_SUB(CURRENT_DATE(),INTERVAL 158 DAY)+INTERVAL 12 HOUR, 'Ärztekonferenz','Klinikum Konferenzraum A',90,6800.00,'Abgeschlossen','4x verschiedene Allergien','Mittagsbuffet Premium','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 170 DAY),CURRENT_TIMESTAMP),
        (955,955, DATE_SUB(CURRENT_DATE(),INTERVAL 164 DAY)+INTERVAL 15 HOUR, 'ASKÖ Sportfest','Sportzentrum Außenanlage',180,5400.00,'Abgeschlossen','3x vegan','Grill & Salate','Abgerechnet',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 175 DAY),CURRENT_TIMESTAMP),
        (956,956, DATE_ADD(CURRENT_DATE(),INTERVAL 130 DAY)+INTERVAL 18 HOUR, 'Schloss-Hochzeit','Schloss Leopoldskron',250,32000.00,'6-Gang Dinner, Live-Musik','5x vegetarisch, 2x vegan','Haute Cuisine Österreich','Bestätigt',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 20 DAY),CURRENT_TIMESTAMP),
        (957,957, DATE_ADD(CURRENT_DATE(),INTERVAL 138 DAY)+INTERVAL 10 HOUR, 'Kindergarten-Fest','Regenbogen Garten',70,1500.00,'Kindgerecht','Viele Allergien','Pizzabacken & Eis','Neu',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 2 DAY),CURRENT_TIMESTAMP),
        (958,958, DATE_ADD(CURRENT_DATE(),INTERVAL 145 DAY)+INTERVAL 18 HOUR, 'Agentur-Party','Design GmbH Rooftop',55,4500.00,'Kreatives Konzept','1x vegan','Fingerfood, Cocktails','AngebotErstellt',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 7 DAY),CURRENT_TIMESTAMP),
        (959,959, DATE_ADD(CURRENT_DATE(),INTERVAL 152 DAY)+INTERVAL 16 HOUR, 'Jahreskonzert','Musikschule Liefering Saal',100,3200.00,'Buffet nach Konzert','2x laktosefrei','Österreichisches Buffet','Geprüft',DATE_SUB(CURRENT_TIMESTAMP,INTERVAL 4 DAY),CURRENT_TIMESTAMP)
        ON DUPLICATE KEY UPDATE
            CustomerId=VALUES(CustomerId), EventDate=VALUES(EventDate), EventType=VALUES(EventType),
            Location=VALUES(Location), GuestCount=VALUES(GuestCount), Budget=VALUES(Budget),
            SpecialWishes=VALUES(SpecialWishes), Allergies=VALUES(Allergies),
            DishWishes=VALUES(DishWishes), Status=VALUES(Status), UpdatedAt=VALUES(UpdatedAt)
        """,
        """
        INSERT INTO InvoicePositions (Id, InvoiceId, MenuItemId, MenuItemName, Quantity, UnitPrice, TotalNet, VatRate, VatAmount, TotalGross) VALUES
        (9081, 908, 15, 'Pasta Bolognese', 120, 18.00, 2160.00, 0.1000, 216.00, 2376.00),
        (9082, 908, 34, 'Erdbeer-Panna-Cotta', 120, 8.00, 960.00, 0.1000, 96.00, 1056.00)
        ON DUPLICATE KEY UPDATE
            Quantity = VALUES(Quantity),
            UnitPrice = VALUES(UnitPrice),
            TotalNet = VALUES(TotalNet),
            VatAmount = VALUES(VatAmount),
            TotalGross = VALUES(TotalGross)
        """,
    ];

    public static async Task SeedAsync(DapperContext context)
    {
        using var conn = context.CreateConnection();
        await conn.OpenAsync();
        using var tx = await conn.BeginTransactionAsync();

        foreach (var statement in Statements)
        {
            await conn.ExecuteAsync(statement, transaction: tx);
        }

        await tx.CommitAsync();
    }
}
