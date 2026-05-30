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
    consecutive_over_count INT          NOT NULL DEFAULT 0,
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

INSERT INTO `Ingredients` VALUES (1,'Kalbsschnitzel','kg',18.0000,'Fleisch',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(2,'Rindfleisch Tafelspitz','kg',14.0000,'Fleisch',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(3,'Lachs, frisch','kg',22.0000,'Fisch',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(4,'Hühnerfilet','kg',8.0000,'Fleisch',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(5,'Kartoffeln','kg',0.8000,'Gemüse',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(6,'Zwiebeln','kg',0.6000,'Gemüse',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(7,'Tomaten','kg',2.0000,'Gemüse',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(8,'Karotten','kg',0.9000,'Gemüse',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(9,'Sellerie','kg',1.2000,'Gemüse',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(10,'Zucchini','kg',1.8000,'Gemüse',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(11,'Spinat','kg',2.5000,'Gemüse',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(12,'Risotto-Reis','kg',3.0000,'Trockenware',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(13,'Butter','kg',6.0000,'Milchprodukte',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(14,'Schlagobers','Liter',2.5000,'Milchprodukte',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(15,'Mozzarella','kg',8.0000,'Milchprodukte',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(16,'Topfen','kg',3.5000,'Milchprodukte',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(17,'Parmesan','kg',18.0000,'Milchprodukte',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(18,'Laugengebäck','Stk',0.6000,'Backwaren',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(19,'Brioche-Scheiben','Stk',0.8000,'Backwaren',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(20,'Strudelteig','kg',2.5000,'Backwaren',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(21,'Paniermehl','kg',1.5000,'Trockenware',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(22,'Eier','Stk',0.3000,'Sonstiges',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(23,'Olivenöl','Liter',8.0000,'Sonstiges',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(24,'Gemüsebrühe','Liter',1.5000,'Sonstiges',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(25,'Weißwein','Liter',5.0000,'Getränke',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(26,'Schokolade, dunkel','kg',12.0000,'Sonstiges',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(27,'Aprikosenmarmelade','kg',4.0000,'Sonstiges',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(28,'Rinderfilet','kg',32.0000,'Fleisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(29,'Lammkeule','kg',20.0000,'Fleisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(30,'Entenbrust','kg',16.0000,'Fleisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(31,'Schweinebauch','kg',8.0000,'Fleisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(32,'Zanderfilet','kg',18.0000,'Fisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(33,'Garnelen','kg',24.0000,'Fisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(34,'Forelle','kg',14.0000,'Fisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(35,'Avocado','Stk',1.5000,'Gemüse',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(36,'Paprika','kg',2.2000,'Gemüse',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(37,'Champignons','kg',4.5000,'Gemüse',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(38,'Kürbis','kg',1.8000,'Gemüse',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(39,'Spargel','kg',8.0000,'Gemüse',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(40,'Rucola','kg',6.0000,'Gemüse',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(41,'Knoblauch','kg',4.0000,'Gemüse',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(42,'Rotkraut','kg',1.5000,'Gemüse',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(43,'Pasta','kg',2.5000,'Trockenware',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(44,'Mehl','kg',0.8000,'Trockenware',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(45,'Linsen','kg',2.0000,'Trockenware',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(46,'Polenta','kg',1.5000,'Trockenware',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(47,'Gnocchi','kg',3.0000,'Trockenware',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(48,'Semmeln','Stk',0.4000,'Backwaren',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(49,'Frischkäse','kg',8.0000,'Milchprodukte',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(50,'Rotwein','Liter',6.0000,'Getränke',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(51,'Orangensaft','Liter',2.5000,'Getränke',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(52,'Speck','kg',10.0000,'Fleisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(53,'Räucherlachs','kg',28.0000,'Fisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(54,'Rinderschulter','kg',12.0000,'Fleisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(55,'Kalbsbäckchen','kg',22.0000,'Fleisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(56,'Erdbeeren','kg',5.0000,'Sonstiges',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(57,'Zucker','kg',1.0000,'Sonstiges',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(58,'Vanilleschote','Stk',2.0000,'Sonstiges',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(59,'Zitrone','Stk',0.5000,'Sonstiges',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(60,'Honig','kg',8.0000,'Sonstiges',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(61,'Salbei','kg',25.0000,'Sonstiges',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(62,'Walnüsse','kg',12.0000,'Sonstiges',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(63,'Äpfel','kg',1.5000,'Sonstiges',0,'2026-05-27 22:49:42','2026-05-27 22:49:42');

INSERT INTO `MenuItems` VALUES (1,'Wiener Schnitzel mit Erdäpfelsalat','hauptgang',24.00,9.50,'gluten,ei,laktose','warm,traditionell,österreichisch,fleisch','mittag,abend,business','Knusprig paniertes Kalbsschnitzel nach Wiener Art, serviert mit hausgemachtem Erdäpfelsalat in Essig-Öl-Marinade.','2026-05-26 16:25:54'),(2,'Tafelspitz mit Wurzelgemüse','hauptgang',28.00,8.50,'sellerie','warm,traditionell,österreichisch,fleisch','abend,business,festlich','Zartes, in Wurzelgemüse gesottenes Rindfleisch – ein Klassiker der Wiener Küche, serviert mit Bouillonkartoffeln und frisch geriebenem Kren.','2026-05-26 16:25:54'),(3,'Gemüse-Risotto','hauptgang',18.00,5.50,'laktose','warm,vegetarisch,italienisch,cremig','mittag,abend,buffet','Cremiges Risotto mit saisonalem Gemüse, verfeinert mit Parmesan und einem Schuss Weißwein.','2026-05-26 16:25:54'),(4,'Lachstatar auf Brioche','vorspeise',12.00,4.50,'fisch,gluten,ei,laktose','kalt,fisch,elegant,modern','buffet,business,abend,empfang','Fein gewürztes Lachstatar auf geröstetem Brioche – eine elegante Fingerfood-Vorspeise für gehobene Anlässe.','2026-05-26 16:25:54'),(5,'Caprese-Spieß','vorspeise',8.00,2.80,'laktose','kalt,vegetarisch,italienisch,fingerfood','buffet,empfang,mittag,sommer','Klassischer Caprese-Spieß mit frischen Tomaten, cremigem Mozzarella und Olivenöl – leicht, frisch und vielseitig.','2026-05-26 16:25:54'),(6,'Sachertorte','dessert',8.00,2.50,'gluten,ei,laktose','kalt,süß,österreichisch,klassisch','abend,buffet,festlich,nachmittag','Die weltberühmte Wiener Sachertorte – feiner Schokoladenbiskuit mit Aprikosenmarmelade und zarter Schokoladeglasur.','2026-05-26 16:25:54'),(7,'Topfenstrudel','dessert',7.00,2.20,'gluten,ei,laktose','warm,süß,österreichisch','mittag,abend,buffet,nachmittag','Knusprig gebackener Strudel mit cremiger Topfenfüllung – ein warmes Dessert nach österreichischer Tradition.','2026-05-26 16:25:54'),(8,'Laugengebäck-Assortment','gebäck',4.00,1.50,'gluten,laktose','kalt,herzhaft,österreichisch','frühstück,mittag,buffet,business,empfang','Auswahl an frisch gebackenem Laugengebäck – ideal für Stehbuffets, Business-Lunches und Empfänge.','2026-05-26 16:25:54'),(9,'Rinderfilet mit Kartoffelgratin','hauptgang',34.00,7.00,'laktose','fleisch,warm,elegant','abend,business,festlich','Zartes Rinderfilet auf cremigem Kartoffelgratin mit Knoblauchbutter','2026-05-27 22:49:42'),(10,'Lammkeule mit Polenta','hauptgang',26.00,5.00,'laktose','fleisch,warm,mediterran','abend,festlich','Geschmorte Lammkeule mit Kräutern auf cremiger Polenta','2026-05-27 22:49:42'),(11,'Entenbrust mit Orangensoße','hauptgang',22.00,4.00,'laktose','geflügel,warm,elegant,modern','abend,festlich,business','Knusprige Entenbrust mit feiner Orangensoße und Rotkraut','2026-05-27 22:49:42'),(12,'Schweinebauch mit Kartoffelpüree','hauptgang',19.00,2.50,'laktose','fleisch,warm,herzhaft,traditionell','mittag,abend','Langsam gegarter Schweinebauch auf samtigem Kartoffelpüree','2026-05-27 22:49:42'),(13,'Zanderfilet auf Spinatbett','hauptgang',22.00,4.00,'fisch,laktose','fisch,warm,elegant','mittag,abend,business','Gebratenes Zanderfilet auf frischem Blattspinat mit Zitronenbutter','2026-05-27 22:49:42'),(14,'Garnelen-Risotto','hauptgang',24.00,5.00,'laktose,krebstiere','warm,cremig,mediterran,meeresfrüchte','mittag,abend,business,sommer','Cremiges Risotto mit frischen Garnelen und Weißwein','2026-05-27 22:49:42'),(15,'Pasta Bolognese','hauptgang',18.00,3.00,'gluten,ei,laktose','fleisch,warm,herzhaft,italienisch','mittag,business','Klassische Bolognese mit frischer Pasta und Parmesan','2026-05-27 22:49:42'),(16,'Tagliatelle mit Lachs und Spinat','hauptgang',19.00,3.00,'gluten,fisch,laktose,ei','fisch,warm,cremig,italienisch','mittag,abend','Breite Pasta mit Lachsfilet in cremiger Spinatsoße','2026-05-27 22:49:42'),(17,'Linsen-Eintopf mit Speck','hauptgang',15.00,1.50,'sellerie','fleisch,warm,herzhaft,traditionell','mittag,abend,buffet,winter','Herzhafter Linseneintopf mit geräuchertem Speck und Wurzelgemüse','2026-05-27 22:49:42'),(18,'Kürbis-Gnocchi mit Salbeibutter','hauptgang',17.00,1.50,'gluten,laktose,ei','vegetarisch,warm,herzhaft','mittag,abend','Handgemachte Kürbis-Gnocchi in goldener Salbeibutter mit Parmesan','2026-05-27 22:49:42'),(19,'Hühnerbrust in Champignonrahmsoße','hauptgang',18.00,2.50,'laktose','geflügel,warm,herzhaft,cremig','mittag,abend,business','Saftige Hühnerbrust in aromatischer Champignonrahmsoße','2026-05-27 22:49:42'),(20,'Paprikahühnchen mit Reis','hauptgang',18.00,2.50,'laktose','geflügel,warm,herzhaft,traditionell','mittag,abend,buffet','Ungarisches Paprikahühnchen mit Schlagobers auf lockerem Reis','2026-05-27 22:49:42'),(21,'Kalbsbäckchen geschmort','hauptgang',28.00,5.50,'sellerie,laktose','fleisch,warm,elegant,traditionell','abend,festlich','Zart geschmorte Kalbsbäckchen in Rotweinsoße mit Gemüse','2026-05-27 22:49:42'),(22,'Forelle Müllerin','hauptgang',24.00,4.50,'fisch,gluten,laktose','fisch,warm,traditionell,österreichisch','mittag,abend','Gebratene Forelle nach Müllerinart mit Buttersoße und Zitrone','2026-05-27 22:49:42'),(23,'Veganer Gemüsestrudel','hauptgang',15.00,1.00,'gluten','vegetarisch,vegan,warm,österreichisch','mittag,abend,buffet','Knuspriger Strudel gefüllt mit saisonalem Gemüse und Kräutern','2026-05-27 22:49:42'),(24,'Rindsgulasch mit Semmelknödel','hauptgang',20.00,4.50,'gluten,laktose,ei','fleisch,warm,herzhaft,österreichisch,traditionell','mittag,abend,business','Würziges Rindsgulasch mit luftigen Semmelknödeln','2026-05-27 22:49:42'),(25,'Spargel-Risotto mit Parmesan','hauptgang',20.00,2.50,'laktose','vegetarisch,warm,cremig,italienisch','mittag,abend,sommer','Cremiges Spargelrisotto mit frisch gehobeltem Parmesan','2026-05-27 22:49:42'),(26,'Avocado-Toast mit Räucherlachs','vorspeise',11.00,3.00,'fisch,gluten','fisch,kalt,modern,elegant','buffet,business,empfang,sommer','Cremige Avocado auf geröstetem Brot mit hauchdünnem Räucherlachs','2026-05-27 22:49:42'),(27,'Bruschetta mit Tomaten und Rucola','vorspeise',7.00,1.00,'gluten','vegetarisch,vegan,kalt,italienisch,fingerfood','buffet,empfang,sommer','Knuspriges Brot mit frischen Tomaten, Rucola und Olivenöl','2026-05-27 22:49:42'),(28,'Garnelencocktail','vorspeise',10.00,2.50,'krebstiere,laktose','kalt,elegant,modern,meeresfrüchte','buffet,business,empfang,abend','Klassischer Garnelencocktail mit feiner Frischkäsesoße','2026-05-27 22:49:42'),(29,'Kürbiscremesuppe','suppe',7.00,1.00,'laktose','vegetarisch,warm,cremig,österreichisch','mittag,abend,buffet,winter','Samtige Kürbiscremesuppe mit Schlagobers und Kürbiskernöl','2026-05-27 22:49:42'),(30,'Beef Carpaccio mit Rucola und Parmesan','vorspeise',13.00,3.50,'laktose','fleisch,kalt,elegant,modern','abend,business,festlich','Hauchdünn geschnittenes Rinderfilet mit Rucola, Parmesan und Olivenöl','2026-05-27 22:49:42'),(31,'Räucherlachs auf Toast','vorspeise',11.00,3.50,'fisch,gluten,laktose','fisch,kalt,elegant,modern','buffet,business,empfang,abend','Aromatischer Räucherlachs mit Frischkäse auf knusprigem Toast','2026-05-27 22:49:42'),(32,'Crème Brûlée','dessert',8.00,2.00,'laktose,ei','kalt,süß,cremig,elegant,klassisch','abend,festlich,business','Klassische Crème Brûlée mit karamellisierter Zuckerkruste','2026-05-27 22:49:42'),(33,'Mousse au Chocolat','dessert',7.50,2.00,'laktose,ei','kalt,süß,cremig,elegant,international','abend,buffet,festlich','Luftige Schokoladenmousse aus dunkler Schokolade','2026-05-27 22:49:42'),(34,'Erdbeer-Panna-Cotta','dessert',8.00,2.00,'laktose','kalt,süß,cremig,elegant,italienisch','abend,buffet,sommer','Zarte Panna Cotta mit frischem Erdbeerkompott','2026-05-27 22:49:42'),(35,'Apfelstrudel','dessert',7.00,1.50,'gluten,laktose,nuss','warm,süß,österreichisch,traditionell,klassisch','mittag,abend,buffet,nachmittag','Klassischer Apfelstrudel mit Walnüssen und Aprikosenmarmelade','2026-05-27 22:49:42');

-- MenuItemIngredients: QuantityPerPerson in der jeweiligen Einheit der Zutat
INSERT INTO `MenuItemIngredients` VALUES (1,1,1,0.200),(2,1,5,0.250),(3,1,21,0.050),(4,1,22,1.000),(5,1,13,0.050),(6,1,6,0.050),(7,2,2,0.250),(8,2,8,0.100),(9,2,9,0.080),(10,2,6,0.060),(11,2,5,0.150),(12,3,12,0.100),(13,3,10,0.080),(14,3,11,0.060),(15,3,17,0.030),(16,3,13,0.020),(17,3,24,0.250),(18,3,25,0.050),(19,4,3,0.080),(20,4,19,1.000),(21,4,23,0.010),(22,5,7,0.060),(23,5,15,0.050),(24,5,23,0.005),(25,6,26,0.040),(26,6,27,0.020),(27,6,22,0.500),(28,6,13,0.020),(29,7,20,0.060),(30,7,16,0.100),(31,7,22,0.500),(32,7,13,0.015),(33,8,18,2.000),(34,8,13,0.020),(35,9,28,0.200),(36,9,5,0.200),(37,9,14,0.050),(38,9,13,0.020),(39,9,41,0.010),(40,10,29,0.220),(41,10,46,0.080),(42,10,13,0.020),(43,10,23,0.010),(44,10,8,0.060),(45,10,41,0.010),(46,11,30,0.200),(47,11,42,0.100),(48,11,51,0.050),(49,11,13,0.020),(50,11,60,0.010),(51,12,31,0.220),(52,12,5,0.200),(53,12,13,0.050),(54,12,14,0.040),(55,12,6,0.030),(56,13,32,0.180),(57,13,11,0.080),(58,13,13,0.020),(59,13,23,0.010),(60,13,59,0.500),(61,14,33,0.150),(62,14,12,0.100),(63,14,25,0.050),(64,14,17,0.020),(65,14,13,0.020),(66,14,6,0.020),(67,15,43,0.120),(68,15,54,0.150),(69,15,7,0.060),(70,15,6,0.040),(71,15,8,0.020),(72,15,23,0.010),(73,15,17,0.020),(74,16,43,0.120),(75,16,3,0.100),(76,16,11,0.060),(77,16,14,0.050),(78,16,13,0.020),(79,17,45,0.100),(80,17,52,0.080),(81,17,8,0.060),(82,17,9,0.050),(83,17,6,0.040),(84,17,23,0.010),(85,18,47,0.180),(86,18,38,0.080),(87,18,13,0.040),(88,18,61,0.005),(89,18,17,0.020),(90,19,4,0.200),(91,19,37,0.100),(92,19,14,0.060),(93,19,6,0.030),(94,19,13,0.020),(95,20,4,0.200),(96,20,36,0.080),(97,20,6,0.040),(98,20,14,0.050),(99,20,23,0.010),(100,20,12,0.100),(101,21,55,0.200),(102,21,8,0.060),(103,21,9,0.050),(104,21,50,0.050),(105,21,5,0.100),(106,21,13,0.020),(107,22,34,0.250),(108,22,44,0.050),(109,22,13,0.040),(110,22,59,1.000),(111,22,5,0.100),(112,23,20,0.080),(113,23,11,0.080),(114,23,10,0.060),(115,23,36,0.040),(116,23,7,0.050),(117,23,23,0.010),(118,24,54,0.200),(119,24,36,0.060),(120,24,6,0.060),(121,24,23,0.020),(122,24,48,2.000),(123,24,13,0.050),(124,24,22,1.000),(125,25,39,0.100),(126,25,12,0.100),(127,25,25,0.050),(128,25,17,0.030),(129,25,13,0.020),(130,25,6,0.020),(131,26,35,0.500),(132,26,53,0.040),(133,26,18,1.000),(134,26,59,0.500),(135,27,48,1.000),(136,27,7,0.080),(137,27,40,0.020),(138,27,23,0.010),(139,27,41,0.010),(140,28,33,0.080),(141,28,40,0.020),(142,28,59,0.500),(143,28,49,0.010),(144,29,38,0.150),(145,29,24,0.200),(146,29,14,0.030),(147,29,6,0.020),(148,29,23,0.010),(149,30,28,0.080),(150,30,40,0.020),(151,30,17,0.015),(152,30,23,0.010),(153,30,59,0.500),(154,31,53,0.060),(155,31,49,0.040),(156,31,18,2.000),(157,31,59,0.500),(158,32,14,0.150),(159,32,22,2.000),(160,32,57,0.050),(161,32,58,0.500),(162,33,26,0.060),(163,33,22,2.000),(164,33,14,0.080),(165,33,57,0.020),(166,33,13,0.020),(167,34,14,0.150),(168,34,56,0.080),(169,34,57,0.030),(170,34,58,0.500),(171,35,20,0.080),(172,35,63,0.150),(173,35,57,0.040),(174,35,13,0.040),(175,35,62,0.030),(176,35,27,0.020);

-- ============================================================
-- Filter-Vokabular, Validierungs-Function & MenuItems-Triggers
-- (steuern erlaubte Werte fuer Category/Eignung/Tags/Allergens)
-- ============================================================

CREATE TABLE FilterVocabulary (
    field       VARCHAR(20) NOT NULL,
    value       VARCHAR(50) NOT NULL,
    group_label VARCHAR(50) NULL,
    sort_order  INT         NOT NULL DEFAULT 0,
    PRIMARY KEY (field, value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `FilterVocabulary` VALUES ('allergen','ei','lmiv',3),('allergen','erdnuss','lmiv',5),('allergen','fisch','lmiv',4),('allergen','gluten','lmiv',1),('allergen','krebstiere','lmiv',2),('allergen','laktose','lmiv',7),('allergen','lupinen','lmiv',13),('allergen','nuss','lmiv',8),('allergen','sellerie','lmiv',9),('allergen','senf','lmiv',10),('allergen','sesam','lmiv',11),('allergen','soja','lmiv',6),('allergen','sulfite','lmiv',12),('allergen','weichtiere','lmiv',14),('category','beilage','gang',4),('category','dessert','gang',5),('category','gebäck','gang',6),('category','getränk','gang',7),('category','hauptgang','gang',3),('category','suppe','gang',2),('category','vorspeise','gang',1),('eignung','abend','tageszeit',4),('eignung','buffet','servierform',9),('eignung','business','anlass',5),('eignung','casual','anlass',8),('eignung','empfang','anlass',7),('eignung','festlich','anlass',6),('eignung','frühstück','tageszeit',1),('eignung','mittag','tageszeit',2),('eignung','nachmittag','tageszeit',3),('eignung','sommer','saison',10),('eignung','winter','saison',11),('tag','asiatisch','küche',4),('tag','cremig','geschmack',14),('tag','elegant','stil',18),('tag','fingerfood','format',19),('tag','fisch','hauptzutat',20),('tag','fleisch','hauptzutat',21),('tag','geflügel','hauptzutat',22),('tag','glutenfrei','diät',10),('tag','herzhaft','geschmack',13),('tag','international','küche',5),('tag','italienisch','küche',2),('tag','kalt','temperatur',7),('tag','klassisch','stil',16),('tag','laktosefrei','diät',11),('tag','mediterran','küche',3),('tag','meeresfrüchte','hauptzutat',23),('tag','modern','stil',17),('tag','österreichisch','küche',1),('tag','süß','geschmack',12),('tag','traditionell','stil',15),('tag','vegan','diät',9),('tag','vegetarisch','diät',8),('tag','warm','temperatur',6);

-- Function: liefert den ersten ungueltigen CSV-Wert (oder NULL), geprueft gegen FilterVocabulary
DELIMITER ;;
CREATE FUNCTION `csv_invalid_value`(
  p_field VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  p_csv   TEXT        CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
) RETURNS varchar(50) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci
    READS SQL DATA
BEGIN
  DECLARE v_pos   INT     DEFAULT 1;
  DECLARE v_count INT;
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
END ;;
DELIMITER ;

-- Triggers: normalisieren (lowercase/trim) und validieren MenuItems gegen das Vokabular
DELIMITER ;;
CREATE TRIGGER `trg_menuitems_bi` BEFORE INSERT ON `MenuItems` FOR EACH ROW BEGIN
  DECLARE v_bad VARCHAR(50);
  DECLARE v_msg VARCHAR(200);

  SET NEW.Category = LOWER(TRIM(NEW.Category));
  IF NEW.Eignung IS NOT NULL THEN
    SET NEW.Eignung = LOWER(REGEXP_REPLACE(TRIM(NEW.Eignung), '\\s*,\\s*', ','));
  END IF;
  IF NEW.Tags IS NOT NULL THEN
    SET NEW.Tags = LOWER(REGEXP_REPLACE(TRIM(NEW.Tags), '\\s*,\\s*', ','));
  END IF;
  IF NEW.Allergens IS NOT NULL THEN
    SET NEW.Allergens = LOWER(REGEXP_REPLACE(TRIM(NEW.Allergens), '\\s*,\\s*', ','));
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

  IF NEW.Allergens IS NOT NULL AND NEW.Allergens != '' THEN
    SET v_bad = csv_invalid_value('allergen', NEW.Allergens);
    IF v_bad IS NOT NULL THEN
      SET v_msg = CONCAT('Ungültiger Allergen-Wert: ''', v_bad, '''');
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;
  END IF;
END ;;
CREATE TRIGGER `trg_menuitems_bu` BEFORE UPDATE ON `MenuItems` FOR EACH ROW BEGIN
  DECLARE v_bad VARCHAR(50);
  DECLARE v_msg VARCHAR(200);

  SET NEW.Category = LOWER(TRIM(NEW.Category));
  IF NEW.Eignung IS NOT NULL THEN
    SET NEW.Eignung = LOWER(REGEXP_REPLACE(TRIM(NEW.Eignung), '\\s*,\\s*', ','));
  END IF;
  IF NEW.Tags IS NOT NULL THEN
    SET NEW.Tags = LOWER(REGEXP_REPLACE(TRIM(NEW.Tags), '\\s*,\\s*', ','));
  END IF;
  IF NEW.Allergens IS NOT NULL THEN
    SET NEW.Allergens = LOWER(REGEXP_REPLACE(TRIM(NEW.Allergens), '\\s*,\\s*', ','));
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

  IF NEW.Allergens IS NOT NULL AND NEW.Allergens != '' THEN
    SET v_bad = csv_invalid_value('allergen', NEW.Allergens);
    IF v_bad IS NOT NULL THEN
      SET v_msg = CONCAT('Ungültiger Allergen-Wert: ''', v_bad, '''');
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;
  END IF;
END ;;
DELIMITER ;

-- ============================================================
-- Test database (same schema, no seed data)
-- ============================================================

CREATE DATABASE IF NOT EXISTS `catermate_test`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `catermate_test`;

CREATE TABLE IF NOT EXISTS Users (Id INT NOT NULL AUTO_INCREMENT, Username VARCHAR(100) NOT NULL, PasswordHash VARCHAR(255) NOT NULL, CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (Id), UNIQUE KEY uq_users_username (Username)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS Customers (Id INT NOT NULL AUTO_INCREMENT, Name VARCHAR(200) NOT NULL, Phone VARCHAR(50) NULL, CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (Id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS Ingredients (Id INT NOT NULL AUTO_INCREMENT, Name VARCHAR(200) NOT NULL, Unit VARCHAR(20) NOT NULL, PurchasePricePerUnit DECIMAL(10,4) NOT NULL, Category VARCHAR(100) NULL, consecutive_over_count INT NOT NULL DEFAULT 0, CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY (Id), UNIQUE KEY uq_ingredient_name (Name)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
