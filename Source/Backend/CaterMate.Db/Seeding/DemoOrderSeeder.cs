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
