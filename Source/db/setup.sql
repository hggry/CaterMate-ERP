SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS `catermate_db`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `catermate_db`;

-- ============================================================
-- Tables without foreign key dependencies
-- ============================================================

CREATE TABLE Users (
    Id           INT          NOT NULL AUTO_INCREMENT,
    Username     VARCHAR(100) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    CreatedAt    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Id),
    UNIQUE KEY uq_users_username (Username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Customers (
    Id        INT          NOT NULL AUTO_INCREMENT,
    Name      VARCHAR(200) NOT NULL,
    Phone     VARCHAR(50)  NULL,
    CreatedAt DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Ingredients (
    Id                   INT            NOT NULL AUTO_INCREMENT,
    Name                 VARCHAR(200)   NOT NULL,
    Unit                 VARCHAR(20)    NOT NULL,
    PurchasePricePerUnit DECIMAL(10,4)  NOT NULL,
    Category             VARCHAR(100)   NULL,
    CreatedAt            DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt            DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Id),
    UNIQUE KEY uq_ingredient_name (Name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE MenuItems (
    Id                    INT            NOT NULL AUTO_INCREMENT,
    Name                  VARCHAR(200)   NOT NULL,
    Category              VARCHAR(50)    NOT NULL,
    SalesPricePerPerson   DECIMAL(10,2)  NOT NULL,
    PurchaseCostPerPerson DECIMAL(10,2)  NOT NULL,
    Allergens             VARCHAR(500)   NULL,
    Tags                  VARCHAR(500)   NULL,
    Eignung               VARCHAR(300)   NULL,
    Beschreibung          TEXT           NULL,
    CreatedAt             DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tables with foreign key dependencies
-- ============================================================

CREATE TABLE Orders (
    Id           INT            NOT NULL AUTO_INCREMENT,
    CustomerId   INT            NOT NULL,
    EventDate    DATETIME       NOT NULL,
    EventType    VARCHAR(100)   NULL,
    Location     VARCHAR(300)   NOT NULL,
    GuestCount   INT            NOT NULL,
    Budget       DECIMAL(10,2)  NULL,
    SpecialWishes TEXT           NULL,
    Allergies    TEXT           NULL,
    DishWishes   TEXT           NULL,
    Status       VARCHAR(50)    NOT NULL DEFAULT 'Neu',
    CreatedAt    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (Id),
    CONSTRAINT fk_orders_customer FOREIGN KEY (CustomerId) REFERENCES Customers (Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE MenuItemIngredients (
    Id                INT            NOT NULL AUTO_INCREMENT,
    MenuItemId        INT            NOT NULL,
    IngredientId      INT            NOT NULL,
    QuantityPerPerson DECIMAL(10,3)  NOT NULL,
    PRIMARY KEY (Id),
    UNIQUE KEY uq_menuitem_ingredient (MenuItemId, IngredientId),
    CONSTRAINT fk_mii_menuitem    FOREIGN KEY (MenuItemId)   REFERENCES MenuItems   (Id),
    CONSTRAINT fk_mii_ingredient  FOREIGN KEY (IngredientId) REFERENCES Ingredients (Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE OrderMenuItems (
    Id         INT NOT NULL AUTO_INCREMENT,
    OrderId    INT NOT NULL,
    MenuItemId INT NOT NULL,
    PRIMARY KEY (Id),
    UNIQUE KEY uq_order_menuitem (OrderId, MenuItemId),
    CONSTRAINT fk_omi_order    FOREIGN KEY (OrderId)    REFERENCES Orders    (Id),
    CONSTRAINT fk_omi_menuitem FOREIGN KEY (MenuItemId) REFERENCES MenuItems (Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Quotes (
    Id               INT            NOT NULL AUTO_INCREMENT,
    OrderId          INT            NOT NULL,
    AdminFee         DECIMAL(10,2)  NOT NULL DEFAULT 0,
    ProfitMarginRate DECIMAL(5,4)   NOT NULL DEFAULT 0.1500,
    TotalNet         DECIMAL(10,2)  NOT NULL,
    TotalVat         DECIMAL(10,2)  NOT NULL,
    TotalGross       DECIMAL(10,2)  NOT NULL,
    CreatedAt        DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Id),
    UNIQUE KEY uq_quotes_order (OrderId),
    CONSTRAINT fk_quotes_order FOREIGN KEY (OrderId) REFERENCES Orders (Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE QuotePositions (
    Id           INT            NOT NULL AUTO_INCREMENT,
    QuoteId      INT            NOT NULL,
    MenuItemId   INT            NOT NULL,
    MenuItemName VARCHAR(200)   NOT NULL,
    Quantity     INT            NOT NULL,
    UnitPrice    DECIMAL(10,2)  NOT NULL,
    TotalNet     DECIMAL(10,2)  NOT NULL,
    VatRate      DECIMAL(5,4)   NOT NULL,
    VatAmount    DECIMAL(10,2)  NOT NULL,
    TotalGross   DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (Id),
    CONSTRAINT fk_qp_quote    FOREIGN KEY (QuoteId)    REFERENCES Quotes    (Id),
    CONSTRAINT fk_qp_menuitem FOREIGN KEY (MenuItemId) REFERENCES MenuItems (Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE PurchaseLists (
    Id           INT           NOT NULL AUTO_INCREMENT,
    OrderId      INT           NOT NULL,
    SafetyMargin DECIMAL(5,4)  NOT NULL DEFAULT 0.1000,
    CreatedAt    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Id),
    UNIQUE KEY uq_purchaselists_order (OrderId),
    CONSTRAINT fk_pl_order FOREIGN KEY (OrderId) REFERENCES Orders (Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE PurchaseListItems (
    Id               INT            NOT NULL AUTO_INCREMENT,
    PurchaseListId   INT            NOT NULL,
    IngredientId     INT            NOT NULL,
    IngredientName   VARCHAR(200)   NOT NULL,
    RequiredQuantity DECIMAL(10,3)  NOT NULL,
    Unit             VARCHAR(20)    NOT NULL,
    Category         VARCHAR(100)   NULL,
    IsDone           TINYINT(1)     NOT NULL DEFAULT 0,
    PRIMARY KEY (Id),
    CONSTRAINT fk_pli_purchaselist FOREIGN KEY (PurchaseListId) REFERENCES PurchaseLists (Id),
    CONSTRAINT fk_pli_ingredient   FOREIGN KEY (IngredientId)   REFERENCES Ingredients   (Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Invoices (
    Id            INT            NOT NULL AUTO_INCREMENT,
    OrderId       INT            NOT NULL,
    InvoiceNumber VARCHAR(20)    NOT NULL,
    CustomerName  VARCHAR(200)   NOT NULL,
    IssueDate     DATE           NOT NULL,
    DueDate       DATE           NOT NULL,
    TotalNet      DECIMAL(10,2)  NOT NULL,
    TotalVat      DECIMAL(10,2)  NOT NULL,
    TotalGross    DECIMAL(10,2)  NOT NULL,
    CreatedAt     DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Id),
    UNIQUE KEY uq_invoices_order  (OrderId),
    UNIQUE KEY uq_invoice_number  (InvoiceNumber),
    CONSTRAINT fk_invoices_order FOREIGN KEY (OrderId) REFERENCES Orders (Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE InvoicePositions (
    Id           INT            NOT NULL AUTO_INCREMENT,
    InvoiceId    INT            NOT NULL,
    MenuItemId   INT            NOT NULL,
    MenuItemName VARCHAR(200)   NOT NULL,
    Quantity     INT            NOT NULL,
    UnitPrice    DECIMAL(10,2)  NOT NULL,
    TotalNet     DECIMAL(10,2)  NOT NULL,
    VatRate      DECIMAL(5,4)   NOT NULL,
    VatAmount    DECIMAL(10,2)  NOT NULL,
    TotalGross   DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (Id),
    CONSTRAINT fk_ip_invoice  FOREIGN KEY (InvoiceId)  REFERENCES Invoices  (Id),
    CONSTRAINT fk_ip_menuitem FOREIGN KEY (MenuItemId) REFERENCES MenuItems (Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IncomingInvoices (
    Id          INT          NOT NULL AUTO_INCREMENT,
    FilePath    VARCHAR(500) NOT NULL,
    Status      VARCHAR(50)  NOT NULL DEFAULT 'Pending',
    CreatedAt   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ProcessedAt DATETIME     NULL,
    PRIMARY KEY (Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IncomingInvoiceSuggestions (
    Id                 INT            NOT NULL AUTO_INCREMENT,
    IncomingInvoiceId  INT            NOT NULL,
    IngredientId       INT            NOT NULL,
    IngredientName     VARCHAR(200)   NOT NULL,
    CurrentPrice       DECIMAL(10,4)  NOT NULL,
    SuggestedPrice     DECIMAL(10,4)  NOT NULL,
    Accepted           TINYINT(1)     NULL,
    PRIMARY KEY (Id),
    CONSTRAINT fk_iis_incominginvoice FOREIGN KEY (IncomingInvoiceId) REFERENCES IncomingInvoices (Id),
    CONSTRAINT fk_iis_ingredient      FOREIGN KEY (IngredientId)      REFERENCES Ingredients      (Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Additional indexes
-- ============================================================

CREATE INDEX idx_orders_customer   ON Orders (CustomerId);
CREATE INDEX idx_orders_status     ON Orders (Status);
CREATE INDEX idx_orders_event_date ON Orders (EventDate);

-- ============================================================
-- Seed data
-- ============================================================

INSERT INTO Ingredients (Name, Unit, PurchasePricePerUnit, Category) VALUES
('Kalbsschnitzel',        'kg',  18.0000, 'Fleisch'),
('Rindfleisch Tafelspitz','kg',  14.0000, 'Fleisch'),
('Lachs, frisch',         'kg',  22.0000, 'Fisch'),
('Hühnerfilet',           'kg',   8.0000, 'Fleisch'),
('Kartoffeln',            'kg',   0.8000, 'Gemüse'),
('Zwiebeln',              'kg',   0.6000, 'Gemüse'),
('Tomaten',               'kg',   2.0000, 'Gemüse'),
('Karotten',              'kg',   0.9000, 'Gemüse'),
('Sellerie',              'kg',   1.2000, 'Gemüse'),
('Zucchini',              'kg',   1.8000, 'Gemüse'),
('Spinat',                'kg',   2.5000, 'Gemüse'),
('Risotto-Reis',          'kg',   3.0000, 'Trockenware'),
('Butter',                'kg',   6.0000, 'Milchprodukte'),
('Schlagobers',           'Liter',2.5000, 'Milchprodukte'),
('Mozzarella',            'kg',   8.0000, 'Milchprodukte'),
('Topfen',                'kg',   3.5000, 'Milchprodukte'),
('Parmesan',              'kg',  18.0000, 'Milchprodukte'),
('Laugengebäck',          'Stk',  0.6000, 'Backwaren'),
('Brioche-Scheiben',      'Stk',  0.8000, 'Backwaren'),
('Strudelteig',           'kg',   2.5000, 'Backwaren'),
('Paniermehl',            'kg',   1.5000, 'Trockenware'),
('Eier',                  'Stk',  0.3000, 'Sonstiges'),
('Olivenöl',              'Liter',8.0000, 'Sonstiges'),
('Gemüsebrühe',           'Liter',1.5000, 'Sonstiges'),
('Weißwein',              'Liter',5.0000, 'Getränke'),
('Schokolade, dunkel',    'kg',  12.0000, 'Sonstiges'),
('Aprikosenmarmelade',    'kg',   4.0000, 'Sonstiges');

INSERT INTO MenuItems (Name, Category, SalesPricePerPerson, PurchaseCostPerPerson, Allergens, Tags, Eignung, Beschreibung) VALUES
(
  'Wiener Schnitzel mit Erdäpfelsalat',
  'Hauptgang',
  24.00, 9.50,
  'Gluten, Ei, Milch',
  'warm, traditionell, österreichisch',
  'Mittag, Abend, Business',
  'Knusprig paniertes Kalbsschnitzel nach Wiener Art, serviert mit hausgemachtem Erdäpfelsalat in Essig-Öl-Marinade.'
),
(
  'Tafelspitz mit Wurzelgemüse',
  'Hauptgang',
  28.00, 8.50,
  NULL,
  'warm, traditionell, österreichisch, Suppe',
  'Abend, Business, Festlich',
  'Zartes, in Wurzelgemüse gesottenes Rindfleisch – ein Klassiker der Wiener Küche, serviert mit Bouillonkartoffeln und frisch geriebenem Kren.'
),
(
  'Gemüse-Risotto',
  'Hauptgang',
  18.00, 5.50,
  'Milch',
  'warm, vegetarisch, italienisch, cremig',
  'Mittag, Abend, Buffet, Vegetarisch',
  'Cremiges Risotto mit saisonalem Gemüse, verfeinert mit Parmesan und einem Schuss Weißwein.'
),
(
  'Lachstatar auf Brioche',
  'Vorspeise',
  12.00, 4.50,
  'Fisch, Gluten',
  'kalt, Fisch, elegant, modern',
  'Buffet, Business, Abend, Empfang',
  'Fein gewürztes Lachstatar auf geröstetem Brioche – eine elegante Fingerfood-Vorspeise für gehobene Anlässe.'
),
(
  'Caprese-Spieß',
  'Vorspeise',
  8.00, 2.80,
  'Milch',
  'kalt, vegetarisch, italienisch, Fingerfood',
  'Buffet, Empfang, Mittag, Sommer',
  'Klassischer Caprese-Spieß mit frischen Tomaten, cremigem Mozzarella und Olivenöl – leicht, frisch und vielseitig.'
),
(
  'Sachertorte',
  'Dessert',
  8.00, 2.50,
  'Gluten, Ei, Milch',
  'kalt, süß, österreichisch, Klassiker',
  'Abend, Buffet, Festlich, Nachmittag',
  'Die weltberühmte Wiener Sachertorte – feiner Schokoladenbiskuit mit Aprikosenmarmelade und zarter Schokoladeglasur.'
),
(
  'Topfenstrudel',
  'Dessert',
  7.00, 2.20,
  'Gluten, Ei, Milch',
  'warm, süß, österreichisch, Strudel',
  'Mittag, Abend, Buffet, Nachmittag',
  'Knusprig gebackener Strudel mit cremiger Topfenfüllung – ein warmes Dessert nach österreichischer Tradition.'
),
(
  'Laugengebäck-Assortment',
  'Buffet',
  4.00, 1.50,
  'Gluten, Milch',
  'kalt, Buffet, Bäckerei, herzhaft',
  'Buffet, Business, Empfang, Mittag',
  'Auswahl an frisch gebackenem Laugengebäck – ideal für Stehbuffets, Business-Lunches und Empfänge.'
);

-- MenuItemIngredients: QuantityPerPerson in der jeweiligen Einheit der Zutat
INSERT INTO MenuItemIngredients (MenuItemId, IngredientId, QuantityPerPerson) VALUES
-- Wiener Schnitzel mit Erdäpfelsalat (MenuItemId=1)
(1, (SELECT Id FROM Ingredients WHERE Name='Kalbsschnitzel'),  0.200),
(1, (SELECT Id FROM Ingredients WHERE Name='Kartoffeln'),      0.250),
(1, (SELECT Id FROM Ingredients WHERE Name='Paniermehl'),      0.050),
(1, (SELECT Id FROM Ingredients WHERE Name='Eier'),            1.000),
(1, (SELECT Id FROM Ingredients WHERE Name='Butter'),          0.050),
(1, (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),        0.050),
-- Tafelspitz mit Wurzelgemüse (MenuItemId=2)
(2, (SELECT Id FROM Ingredients WHERE Name='Rindfleisch Tafelspitz'), 0.250),
(2, (SELECT Id FROM Ingredients WHERE Name='Karotten'),        0.100),
(2, (SELECT Id FROM Ingredients WHERE Name='Sellerie'),        0.080),
(2, (SELECT Id FROM Ingredients WHERE Name='Zwiebeln'),        0.060),
(2, (SELECT Id FROM Ingredients WHERE Name='Kartoffeln'),      0.150),
-- Gemüse-Risotto (MenuItemId=3)
(3, (SELECT Id FROM Ingredients WHERE Name='Risotto-Reis'),    0.100),
(3, (SELECT Id FROM Ingredients WHERE Name='Zucchini'),        0.080),
(3, (SELECT Id FROM Ingredients WHERE Name='Spinat'),          0.060),
(3, (SELECT Id FROM Ingredients WHERE Name='Parmesan'),        0.030),
(3, (SELECT Id FROM Ingredients WHERE Name='Butter'),          0.020),
(3, (SELECT Id FROM Ingredients WHERE Name='Gemüsebrühe'),     0.250),
(3, (SELECT Id FROM Ingredients WHERE Name='Weißwein'),        0.050),
-- Lachstatar auf Brioche (MenuItemId=4)
(4, (SELECT Id FROM Ingredients WHERE Name='Lachs, frisch'),   0.080),
(4, (SELECT Id FROM Ingredients WHERE Name='Brioche-Scheiben'),1.000),
(4, (SELECT Id FROM Ingredients WHERE Name='Olivenöl'),        0.010),
-- Caprese-Spieß (MenuItemId=5)
(5, (SELECT Id FROM Ingredients WHERE Name='Tomaten'),         0.060),
(5, (SELECT Id FROM Ingredients WHERE Name='Mozzarella'),      0.050),
(5, (SELECT Id FROM Ingredients WHERE Name='Olivenöl'),        0.005),
-- Sachertorte (MenuItemId=6)
(6, (SELECT Id FROM Ingredients WHERE Name='Schokolade, dunkel'),  0.040),
(6, (SELECT Id FROM Ingredients WHERE Name='Aprikosenmarmelade'),  0.020),
(6, (SELECT Id FROM Ingredients WHERE Name='Eier'),            0.500),
(6, (SELECT Id FROM Ingredients WHERE Name='Butter'),          0.020),
-- Topfenstrudel (MenuItemId=7)
(7, (SELECT Id FROM Ingredients WHERE Name='Strudelteig'),     0.060),
(7, (SELECT Id FROM Ingredients WHERE Name='Topfen'),          0.100),
(7, (SELECT Id FROM Ingredients WHERE Name='Eier'),            0.500),
(7, (SELECT Id FROM Ingredients WHERE Name='Butter'),          0.015),
-- Laugengebäck-Assortment (MenuItemId=8)
(8, (SELECT Id FROM Ingredients WHERE Name='Laugengebäck'),    2.000),
(8, (SELECT Id FROM Ingredients WHERE Name='Butter'),          0.020);

-- ============================================================
-- Test database (same schema, no seed data)
-- ============================================================

CREATE DATABASE IF NOT EXISTS `catermate_test`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `catermate_test`;

CREATE TABLE IF NOT EXISTS Users (Id INT NOT NULL AUTO_INCREMENT, Username VARCHAR(100) NOT NULL, PasswordHash VARCHAR(255) NOT NULL, CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (Id), UNIQUE KEY uq_users_username (Username)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS Customers (Id INT NOT NULL AUTO_INCREMENT, Name VARCHAR(200) NOT NULL, Phone VARCHAR(50) NULL, CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (Id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS Ingredients (Id INT NOT NULL AUTO_INCREMENT, Name VARCHAR(200) NOT NULL, Unit VARCHAR(20) NOT NULL, PurchasePricePerUnit DECIMAL(10,4) NOT NULL, Category VARCHAR(100) NULL, CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY (Id), UNIQUE KEY uq_ingredient_name (Name)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS MenuItems (Id INT NOT NULL AUTO_INCREMENT, Name VARCHAR(200) NOT NULL, Category VARCHAR(50) NOT NULL, SalesPricePerPerson DECIMAL(10,2) NOT NULL, PurchaseCostPerPerson DECIMAL(10,2) NOT NULL, Allergens VARCHAR(500) NULL, Tags VARCHAR(500) NULL, Eignung VARCHAR(300) NULL, Beschreibung TEXT NULL, CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (Id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS Orders (Id INT NOT NULL AUTO_INCREMENT, CustomerId INT NOT NULL, EventDate DATETIME NOT NULL, EventType VARCHAR(100) NULL, Location VARCHAR(300) NOT NULL, GuestCount INT NOT NULL, Budget DECIMAL(10,2) NULL, SpecialWishes TEXT NULL, Allergies TEXT NULL, DishWishes TEXT NULL, Status VARCHAR(50) NOT NULL DEFAULT 'Neu', CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY (Id), CONSTRAINT fk_t_orders_customer FOREIGN KEY (CustomerId) REFERENCES Customers (Id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS MenuItemIngredients (Id INT NOT NULL AUTO_INCREMENT, MenuItemId INT NOT NULL, IngredientId INT NOT NULL, QuantityPerPerson DECIMAL(10,3) NOT NULL, PRIMARY KEY (Id), UNIQUE KEY uq_t_menuitem_ingredient (MenuItemId, IngredientId), CONSTRAINT fk_t_mii_menuitem FOREIGN KEY (MenuItemId) REFERENCES MenuItems (Id), CONSTRAINT fk_t_mii_ingredient FOREIGN KEY (IngredientId) REFERENCES Ingredients (Id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS OrderMenuItems (Id INT NOT NULL AUTO_INCREMENT, OrderId INT NOT NULL, MenuItemId INT NOT NULL, PRIMARY KEY (Id), UNIQUE KEY uq_t_order_menuitem (OrderId, MenuItemId), CONSTRAINT fk_t_omi_order FOREIGN KEY (OrderId) REFERENCES Orders (Id), CONSTRAINT fk_t_omi_menuitem FOREIGN KEY (MenuItemId) REFERENCES MenuItems (Id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS Quotes (Id INT NOT NULL AUTO_INCREMENT, OrderId INT NOT NULL, AdminFee DECIMAL(10,2) NOT NULL DEFAULT 0, ProfitMarginRate DECIMAL(5,4) NOT NULL DEFAULT 0.1500, TotalNet DECIMAL(10,2) NOT NULL, TotalVat DECIMAL(10,2) NOT NULL, TotalGross DECIMAL(10,2) NOT NULL, CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (Id), UNIQUE KEY uq_t_quotes_order (OrderId), CONSTRAINT fk_t_quotes_order FOREIGN KEY (OrderId) REFERENCES Orders (Id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS QuotePositions (Id INT NOT NULL AUTO_INCREMENT, QuoteId INT NOT NULL, MenuItemId INT NOT NULL, MenuItemName VARCHAR(200) NOT NULL, Quantity INT NOT NULL, UnitPrice DECIMAL(10,2) NOT NULL, TotalNet DECIMAL(10,2) NOT NULL, VatRate DECIMAL(5,4) NOT NULL, VatAmount DECIMAL(10,2) NOT NULL, TotalGross DECIMAL(10,2) NOT NULL, PRIMARY KEY (Id), CONSTRAINT fk_t_qp_quote FOREIGN KEY (QuoteId) REFERENCES Quotes (Id), CONSTRAINT fk_t_qp_menuitem FOREIGN KEY (MenuItemId) REFERENCES MenuItems (Id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS PurchaseLists (Id INT NOT NULL AUTO_INCREMENT, OrderId INT NOT NULL, SafetyMargin DECIMAL(5,4) NOT NULL DEFAULT 0.1000, CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (Id), UNIQUE KEY uq_t_purchaselists_order (OrderId), CONSTRAINT fk_t_pl_order FOREIGN KEY (OrderId) REFERENCES Orders (Id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS PurchaseListItems (Id INT NOT NULL AUTO_INCREMENT, PurchaseListId INT NOT NULL, IngredientId INT NOT NULL, IngredientName VARCHAR(200) NOT NULL, RequiredQuantity DECIMAL(10,3) NOT NULL, Unit VARCHAR(20) NOT NULL, Category VARCHAR(100) NULL, IsDone TINYINT(1) NOT NULL DEFAULT 0, PRIMARY KEY (Id), CONSTRAINT fk_t_pli_purchaselist FOREIGN KEY (PurchaseListId) REFERENCES PurchaseLists (Id), CONSTRAINT fk_t_pli_ingredient FOREIGN KEY (IngredientId) REFERENCES Ingredients (Id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS Invoices (Id INT NOT NULL AUTO_INCREMENT, OrderId INT NOT NULL, InvoiceNumber VARCHAR(20) NOT NULL, CustomerName VARCHAR(200) NOT NULL, IssueDate DATE NOT NULL, DueDate DATE NOT NULL, TotalNet DECIMAL(10,2) NOT NULL, TotalVat DECIMAL(10,2) NOT NULL, TotalGross DECIMAL(10,2) NOT NULL, CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (Id), UNIQUE KEY uq_t_invoices_order (OrderId), UNIQUE KEY uq_t_invoice_number (InvoiceNumber), CONSTRAINT fk_t_invoices_order FOREIGN KEY (OrderId) REFERENCES Orders (Id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS InvoicePositions (Id INT NOT NULL AUTO_INCREMENT, InvoiceId INT NOT NULL, MenuItemId INT NOT NULL, MenuItemName VARCHAR(200) NOT NULL, Quantity INT NOT NULL, UnitPrice DECIMAL(10,2) NOT NULL, TotalNet DECIMAL(10,2) NOT NULL, VatRate DECIMAL(5,4) NOT NULL, VatAmount DECIMAL(10,2) NOT NULL, TotalGross DECIMAL(10,2) NOT NULL, PRIMARY KEY (Id), CONSTRAINT fk_t_ip_invoice FOREIGN KEY (InvoiceId) REFERENCES Invoices (Id), CONSTRAINT fk_t_ip_menuitem FOREIGN KEY (MenuItemId) REFERENCES MenuItems (Id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS IncomingInvoices (Id INT NOT NULL AUTO_INCREMENT, FilePath VARCHAR(500) NOT NULL, Status VARCHAR(50) NOT NULL DEFAULT 'Pending', CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, ProcessedAt DATETIME NULL, PRIMARY KEY (Id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS IncomingInvoiceSuggestions (Id INT NOT NULL AUTO_INCREMENT, IncomingInvoiceId INT NOT NULL, IngredientId INT NOT NULL, IngredientName VARCHAR(200) NOT NULL, CurrentPrice DECIMAL(10,4) NOT NULL, SuggestedPrice DECIMAL(10,4) NOT NULL, Accepted TINYINT(1) NULL, PRIMARY KEY (Id), CONSTRAINT fk_t_iis_incominginvoice FOREIGN KEY (IncomingInvoiceId) REFERENCES IncomingInvoices (Id), CONSTRAINT fk_t_iis_ingredient FOREIGN KEY (IngredientId) REFERENCES Ingredients (Id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
