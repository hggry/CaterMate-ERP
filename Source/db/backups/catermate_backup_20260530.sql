-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: catermate_db
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Customers`
--

DROP TABLE IF EXISTS `Customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Customers` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Phone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Customers`
--

LOCK TABLES `Customers` WRITE;
/*!40000 ALTER TABLE `Customers` DISABLE KEYS */;
INSERT INTO `Customers` VALUES (1,'Ben','7539208775','2026-05-30 07:56:25');
/*!40000 ALTER TABLE `Customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `FilterVocabulary`
--

DROP TABLE IF EXISTS `FilterVocabulary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `FilterVocabulary` (
  `field` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `group_label` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`field`,`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `FilterVocabulary`
--

LOCK TABLES `FilterVocabulary` WRITE;
/*!40000 ALTER TABLE `FilterVocabulary` DISABLE KEYS */;
INSERT INTO `FilterVocabulary` VALUES ('allergen','ei','lmiv',3),('allergen','erdnuss','lmiv',5),('allergen','fisch','lmiv',4),('allergen','gluten','lmiv',1),('allergen','krebstiere','lmiv',2),('allergen','laktose','lmiv',7),('allergen','lupinen','lmiv',13),('allergen','nuss','lmiv',8),('allergen','sellerie','lmiv',9),('allergen','senf','lmiv',10),('allergen','sesam','lmiv',11),('allergen','soja','lmiv',6),('allergen','sulfite','lmiv',12),('allergen','weichtiere','lmiv',14),('category','beilage','gang',4),('category','dessert','gang',5),('category','gebäck','gang',6),('category','getränk','gang',7),('category','hauptgang','gang',3),('category','suppe','gang',2),('category','vorspeise','gang',1),('eignung','abend','tageszeit',4),('eignung','buffet','servierform',9),('eignung','business','anlass',5),('eignung','casual','anlass',8),('eignung','empfang','anlass',7),('eignung','festlich','anlass',6),('eignung','frühstück','tageszeit',1),('eignung','mittag','tageszeit',2),('eignung','nachmittag','tageszeit',3),('eignung','sommer','saison',10),('eignung','winter','saison',11),('tag','asiatisch','küche',4),('tag','cremig','geschmack',14),('tag','elegant','stil',18),('tag','fingerfood','format',19),('tag','fisch','hauptzutat',20),('tag','fleisch','hauptzutat',21),('tag','geflügel','hauptzutat',22),('tag','glutenfrei','diät',10),('tag','herzhaft','geschmack',13),('tag','international','küche',5),('tag','italienisch','küche',2),('tag','kalt','temperatur',7),('tag','klassisch','stil',16),('tag','laktosefrei','diät',11),('tag','mediterran','küche',3),('tag','meeresfrüchte','hauptzutat',23),('tag','modern','stil',17),('tag','österreichisch','küche',1),('tag','süß','geschmack',12),('tag','traditionell','stil',15),('tag','vegan','diät',9),('tag','vegetarisch','diät',8),('tag','warm','temperatur',6);
/*!40000 ALTER TABLE `FilterVocabulary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `IncomingInvoiceSuggestions`
--

DROP TABLE IF EXISTS `IncomingInvoiceSuggestions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `IncomingInvoiceSuggestions` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `IncomingInvoiceId` int NOT NULL,
  `IngredientId` int NOT NULL,
  `IngredientName` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `CurrentPrice` decimal(10,4) NOT NULL,
  `SuggestedPrice` decimal(10,4) NOT NULL,
  `Accepted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`Id`),
  KEY `fk_iis_incominginvoice` (`IncomingInvoiceId`),
  KEY `fk_iis_ingredient` (`IngredientId`),
  CONSTRAINT `fk_iis_incominginvoice` FOREIGN KEY (`IncomingInvoiceId`) REFERENCES `IncomingInvoices` (`Id`),
  CONSTRAINT `fk_iis_ingredient` FOREIGN KEY (`IngredientId`) REFERENCES `Ingredients` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `IncomingInvoiceSuggestions`
--

LOCK TABLES `IncomingInvoiceSuggestions` WRITE;
/*!40000 ALTER TABLE `IncomingInvoiceSuggestions` DISABLE KEYS */;
/*!40000 ALTER TABLE `IncomingInvoiceSuggestions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `IncomingInvoices`
--

DROP TABLE IF EXISTS `IncomingInvoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `IncomingInvoices` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `FilePath` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pending',
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ProcessedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `IncomingInvoices`
--

LOCK TABLES `IncomingInvoices` WRITE;
/*!40000 ALTER TABLE `IncomingInvoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `IncomingInvoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Ingredients`
--

DROP TABLE IF EXISTS `Ingredients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Ingredients` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Unit` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `PurchasePricePerUnit` decimal(10,4) NOT NULL,
  `Category` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `consecutive_over_count` int NOT NULL DEFAULT '0',
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `uq_ingredient_name` (`Name`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Ingredients`
--

LOCK TABLES `Ingredients` WRITE;
/*!40000 ALTER TABLE `Ingredients` DISABLE KEYS */;
INSERT INTO `Ingredients` VALUES (1,'Kalbsschnitzel','kg',18.0000,'Fleisch',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(2,'Rindfleisch Tafelspitz','kg',14.0000,'Fleisch',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(3,'Lachs, frisch','kg',22.0000,'Fisch',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(4,'Hühnerfilet','kg',8.0000,'Fleisch',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(5,'Kartoffeln','kg',0.8000,'Gemüse',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(6,'Zwiebeln','kg',0.6000,'Gemüse',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(7,'Tomaten','kg',2.0000,'Gemüse',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(8,'Karotten','kg',0.9000,'Gemüse',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(9,'Sellerie','kg',1.2000,'Gemüse',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(10,'Zucchini','kg',1.8000,'Gemüse',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(11,'Spinat','kg',2.5000,'Gemüse',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(12,'Risotto-Reis','kg',3.0000,'Trockenware',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(13,'Butter','kg',6.0000,'Milchprodukte',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(14,'Schlagobers','Liter',2.5000,'Milchprodukte',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(15,'Mozzarella','kg',8.0000,'Milchprodukte',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(16,'Topfen','kg',3.5000,'Milchprodukte',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(17,'Parmesan','kg',18.0000,'Milchprodukte',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(18,'Laugengebäck','Stk',0.6000,'Backwaren',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(19,'Brioche-Scheiben','Stk',0.8000,'Backwaren',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(20,'Strudelteig','kg',2.5000,'Backwaren',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(21,'Paniermehl','kg',1.5000,'Trockenware',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(22,'Eier','Stk',0.3000,'Sonstiges',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(23,'Olivenöl','Liter',8.0000,'Sonstiges',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(24,'Gemüsebrühe','Liter',1.5000,'Sonstiges',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(25,'Weißwein','Liter',5.0000,'Getränke',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(26,'Schokolade, dunkel','kg',12.0000,'Sonstiges',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(27,'Aprikosenmarmelade','kg',4.0000,'Sonstiges',0,'2026-05-26 16:25:54','2026-05-26 16:25:54'),(28,'Rinderfilet','kg',32.0000,'Fleisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(29,'Lammkeule','kg',20.0000,'Fleisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(30,'Entenbrust','kg',16.0000,'Fleisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(31,'Schweinebauch','kg',8.0000,'Fleisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(32,'Zanderfilet','kg',18.0000,'Fisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(33,'Garnelen','kg',24.0000,'Fisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(34,'Forelle','kg',14.0000,'Fisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(35,'Avocado','Stk',1.5000,'Gemüse',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(36,'Paprika','kg',2.2000,'Gemüse',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(37,'Champignons','kg',4.5000,'Gemüse',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(38,'Kürbis','kg',1.8000,'Gemüse',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(39,'Spargel','kg',8.0000,'Gemüse',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(40,'Rucola','kg',6.0000,'Gemüse',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(41,'Knoblauch','kg',4.0000,'Gemüse',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(42,'Rotkraut','kg',1.5000,'Gemüse',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(43,'Pasta','kg',2.5000,'Trockenware',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(44,'Mehl','kg',0.8000,'Trockenware',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(45,'Linsen','kg',2.0000,'Trockenware',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(46,'Polenta','kg',1.5000,'Trockenware',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(47,'Gnocchi','kg',3.0000,'Trockenware',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(48,'Semmeln','Stk',0.4000,'Backwaren',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(49,'Frischkäse','kg',8.0000,'Milchprodukte',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(50,'Rotwein','Liter',6.0000,'Getränke',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(51,'Orangensaft','Liter',2.5000,'Getränke',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(52,'Speck','kg',10.0000,'Fleisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(53,'Räucherlachs','kg',28.0000,'Fisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(54,'Rinderschulter','kg',12.0000,'Fleisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(55,'Kalbsbäckchen','kg',22.0000,'Fleisch',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(56,'Erdbeeren','kg',5.0000,'Sonstiges',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(57,'Zucker','kg',1.0000,'Sonstiges',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(58,'Vanilleschote','Stk',2.0000,'Sonstiges',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(59,'Zitrone','Stk',0.5000,'Sonstiges',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(60,'Honig','kg',8.0000,'Sonstiges',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(61,'Salbei','kg',25.0000,'Sonstiges',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(62,'Walnüsse','kg',12.0000,'Sonstiges',0,'2026-05-27 22:49:42','2026-05-27 22:49:42'),(63,'Äpfel','kg',1.5000,'Sonstiges',0,'2026-05-27 22:49:42','2026-05-27 22:49:42');
/*!40000 ALTER TABLE `Ingredients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `InvoicePositions`
--

DROP TABLE IF EXISTS `InvoicePositions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `InvoicePositions` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `InvoiceId` int NOT NULL,
  `MenuItemId` int NOT NULL,
  `MenuItemName` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Quantity` int NOT NULL,
  `UnitPrice` decimal(10,2) NOT NULL,
  `TotalNet` decimal(10,2) NOT NULL,
  `VatRate` decimal(5,4) NOT NULL,
  `VatAmount` decimal(10,2) NOT NULL,
  `TotalGross` decimal(10,2) NOT NULL,
  PRIMARY KEY (`Id`),
  KEY `fk_ip_invoice` (`InvoiceId`),
  KEY `fk_ip_menuitem` (`MenuItemId`),
  CONSTRAINT `fk_ip_invoice` FOREIGN KEY (`InvoiceId`) REFERENCES `Invoices` (`Id`),
  CONSTRAINT `fk_ip_menuitem` FOREIGN KEY (`MenuItemId`) REFERENCES `MenuItems` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `InvoicePositions`
--

LOCK TABLES `InvoicePositions` WRITE;
/*!40000 ALTER TABLE `InvoicePositions` DISABLE KEYS */;
/*!40000 ALTER TABLE `InvoicePositions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Invoices`
--

DROP TABLE IF EXISTS `Invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Invoices` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `OrderId` int NOT NULL,
  `InvoiceNumber` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `CustomerName` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `IssueDate` date NOT NULL,
  `DueDate` date NOT NULL,
  `TotalNet` decimal(10,2) NOT NULL,
  `TotalVat` decimal(10,2) NOT NULL,
  `TotalGross` decimal(10,2) NOT NULL,
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `uq_invoices_order` (`OrderId`),
  UNIQUE KEY `uq_invoice_number` (`InvoiceNumber`),
  CONSTRAINT `fk_invoices_order` FOREIGN KEY (`OrderId`) REFERENCES `Orders` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Invoices`
--

LOCK TABLES `Invoices` WRITE;
/*!40000 ALTER TABLE `Invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `Invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MenuItemIngredients`
--

DROP TABLE IF EXISTS `MenuItemIngredients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `MenuItemIngredients` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `MenuItemId` int NOT NULL,
  `IngredientId` int NOT NULL,
  `QuantityPerPerson` decimal(10,3) NOT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `uq_menuitem_ingredient` (`MenuItemId`,`IngredientId`),
  KEY `fk_mii_ingredient` (`IngredientId`),
  CONSTRAINT `fk_mii_ingredient` FOREIGN KEY (`IngredientId`) REFERENCES `Ingredients` (`Id`),
  CONSTRAINT `fk_mii_menuitem` FOREIGN KEY (`MenuItemId`) REFERENCES `MenuItems` (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=177 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MenuItemIngredients`
--

LOCK TABLES `MenuItemIngredients` WRITE;
/*!40000 ALTER TABLE `MenuItemIngredients` DISABLE KEYS */;
INSERT INTO `MenuItemIngredients` VALUES (1,1,1,0.200),(2,1,5,0.250),(3,1,21,0.050),(4,1,22,1.000),(5,1,13,0.050),(6,1,6,0.050),(7,2,2,0.250),(8,2,8,0.100),(9,2,9,0.080),(10,2,6,0.060),(11,2,5,0.150),(12,3,12,0.100),(13,3,10,0.080),(14,3,11,0.060),(15,3,17,0.030),(16,3,13,0.020),(17,3,24,0.250),(18,3,25,0.050),(19,4,3,0.080),(20,4,19,1.000),(21,4,23,0.010),(22,5,7,0.060),(23,5,15,0.050),(24,5,23,0.005),(25,6,26,0.040),(26,6,27,0.020),(27,6,22,0.500),(28,6,13,0.020),(29,7,20,0.060),(30,7,16,0.100),(31,7,22,0.500),(32,7,13,0.015),(33,8,18,2.000),(34,8,13,0.020),(35,9,28,0.200),(36,9,5,0.200),(37,9,14,0.050),(38,9,13,0.020),(39,9,41,0.010),(40,10,29,0.220),(41,10,46,0.080),(42,10,13,0.020),(43,10,23,0.010),(44,10,8,0.060),(45,10,41,0.010),(46,11,30,0.200),(47,11,42,0.100),(48,11,51,0.050),(49,11,13,0.020),(50,11,60,0.010),(51,12,31,0.220),(52,12,5,0.200),(53,12,13,0.050),(54,12,14,0.040),(55,12,6,0.030),(56,13,32,0.180),(57,13,11,0.080),(58,13,13,0.020),(59,13,23,0.010),(60,13,59,0.500),(61,14,33,0.150),(62,14,12,0.100),(63,14,25,0.050),(64,14,17,0.020),(65,14,13,0.020),(66,14,6,0.020),(67,15,43,0.120),(68,15,54,0.150),(69,15,7,0.060),(70,15,6,0.040),(71,15,8,0.020),(72,15,23,0.010),(73,15,17,0.020),(74,16,43,0.120),(75,16,3,0.100),(76,16,11,0.060),(77,16,14,0.050),(78,16,13,0.020),(79,17,45,0.100),(80,17,52,0.080),(81,17,8,0.060),(82,17,9,0.050),(83,17,6,0.040),(84,17,23,0.010),(85,18,47,0.180),(86,18,38,0.080),(87,18,13,0.040),(88,18,61,0.005),(89,18,17,0.020),(90,19,4,0.200),(91,19,37,0.100),(92,19,14,0.060),(93,19,6,0.030),(94,19,13,0.020),(95,20,4,0.200),(96,20,36,0.080),(97,20,6,0.040),(98,20,14,0.050),(99,20,23,0.010),(100,20,12,0.100),(101,21,55,0.200),(102,21,8,0.060),(103,21,9,0.050),(104,21,50,0.050),(105,21,5,0.100),(106,21,13,0.020),(107,22,34,0.250),(108,22,44,0.050),(109,22,13,0.040),(110,22,59,1.000),(111,22,5,0.100),(112,23,20,0.080),(113,23,11,0.080),(114,23,10,0.060),(115,23,36,0.040),(116,23,7,0.050),(117,23,23,0.010),(118,24,54,0.200),(119,24,36,0.060),(120,24,6,0.060),(121,24,23,0.020),(122,24,48,2.000),(123,24,13,0.050),(124,24,22,1.000),(125,25,39,0.100),(126,25,12,0.100),(127,25,25,0.050),(128,25,17,0.030),(129,25,13,0.020),(130,25,6,0.020),(131,26,35,0.500),(132,26,53,0.040),(133,26,18,1.000),(134,26,59,0.500),(135,27,48,1.000),(136,27,7,0.080),(137,27,40,0.020),(138,27,23,0.010),(139,27,41,0.010),(140,28,33,0.080),(141,28,40,0.020),(142,28,59,0.500),(143,28,49,0.010),(144,29,38,0.150),(145,29,24,0.200),(146,29,14,0.030),(147,29,6,0.020),(148,29,23,0.010),(149,30,28,0.080),(150,30,40,0.020),(151,30,17,0.015),(152,30,23,0.010),(153,30,59,0.500),(154,31,53,0.060),(155,31,49,0.040),(156,31,18,2.000),(157,31,59,0.500),(158,32,14,0.150),(159,32,22,2.000),(160,32,57,0.050),(161,32,58,0.500),(162,33,26,0.060),(163,33,22,2.000),(164,33,14,0.080),(165,33,57,0.020),(166,33,13,0.020),(167,34,14,0.150),(168,34,56,0.080),(169,34,57,0.030),(170,34,58,0.500),(171,35,20,0.080),(172,35,63,0.150),(173,35,57,0.040),(174,35,13,0.040),(175,35,62,0.030),(176,35,27,0.020);
/*!40000 ALTER TABLE `MenuItemIngredients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MenuItems`
--

DROP TABLE IF EXISTS `MenuItems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `MenuItems` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Category` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `SalesPricePerPerson` decimal(10,2) NOT NULL,
  `PurchaseCostPerPerson` decimal(10,2) NOT NULL,
  `Allergens` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Tags` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Eignung` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Beschreibung` text COLLATE utf8mb4_unicode_ci,
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MenuItems`
--

LOCK TABLES `MenuItems` WRITE;
/*!40000 ALTER TABLE `MenuItems` DISABLE KEYS */;
INSERT INTO `MenuItems` VALUES (1,'Wiener Schnitzel mit Erdäpfelsalat','hauptgang',24.00,9.50,'gluten,ei,laktose','warm,traditionell,österreichisch,fleisch','mittag,abend,business','Knusprig paniertes Kalbsschnitzel nach Wiener Art, serviert mit hausgemachtem Erdäpfelsalat in Essig-Öl-Marinade.','2026-05-26 16:25:54'),(2,'Tafelspitz mit Wurzelgemüse','hauptgang',28.00,8.50,'sellerie','warm,traditionell,österreichisch,fleisch','abend,business,festlich','Zartes, in Wurzelgemüse gesottenes Rindfleisch – ein Klassiker der Wiener Küche, serviert mit Bouillonkartoffeln und frisch geriebenem Kren.','2026-05-26 16:25:54'),(3,'Gemüse-Risotto','hauptgang',18.00,5.50,'laktose','warm,vegetarisch,italienisch,cremig','mittag,abend,buffet','Cremiges Risotto mit saisonalem Gemüse, verfeinert mit Parmesan und einem Schuss Weißwein.','2026-05-26 16:25:54'),(4,'Lachstatar auf Brioche','vorspeise',12.00,4.50,'fisch,gluten,ei,laktose','kalt,fisch,elegant,modern','buffet,business,abend,empfang','Fein gewürztes Lachstatar auf geröstetem Brioche – eine elegante Fingerfood-Vorspeise für gehobene Anlässe.','2026-05-26 16:25:54'),(5,'Caprese-Spieß','vorspeise',8.00,2.80,'laktose','kalt,vegetarisch,italienisch,fingerfood','buffet,empfang,mittag,sommer','Klassischer Caprese-Spieß mit frischen Tomaten, cremigem Mozzarella und Olivenöl – leicht, frisch und vielseitig.','2026-05-26 16:25:54'),(6,'Sachertorte','dessert',8.00,2.50,'gluten,ei,laktose','kalt,süß,österreichisch,klassisch','abend,buffet,festlich,nachmittag','Die weltberühmte Wiener Sachertorte – feiner Schokoladenbiskuit mit Aprikosenmarmelade und zarter Schokoladeglasur.','2026-05-26 16:25:54'),(7,'Topfenstrudel','dessert',7.00,2.20,'gluten,ei,laktose','warm,süß,österreichisch','mittag,abend,buffet,nachmittag','Knusprig gebackener Strudel mit cremiger Topfenfüllung – ein warmes Dessert nach österreichischer Tradition.','2026-05-26 16:25:54'),(8,'Laugengebäck-Assortment','gebäck',4.00,1.50,'gluten,laktose','kalt,herzhaft,österreichisch','frühstück,mittag,buffet,business,empfang','Auswahl an frisch gebackenem Laugengebäck – ideal für Stehbuffets, Business-Lunches und Empfänge.','2026-05-26 16:25:54'),(9,'Rinderfilet mit Kartoffelgratin','hauptgang',34.00,7.00,'laktose','fleisch,warm,elegant','abend,business,festlich','Zartes Rinderfilet auf cremigem Kartoffelgratin mit Knoblauchbutter','2026-05-27 22:49:42'),(10,'Lammkeule mit Polenta','hauptgang',26.00,5.00,'laktose','fleisch,warm,mediterran','abend,festlich','Geschmorte Lammkeule mit Kräutern auf cremiger Polenta','2026-05-27 22:49:42'),(11,'Entenbrust mit Orangensoße','hauptgang',22.00,4.00,'laktose','geflügel,warm,elegant,modern','abend,festlich,business','Knusprige Entenbrust mit feiner Orangensoße und Rotkraut','2026-05-27 22:49:42'),(12,'Schweinebauch mit Kartoffelpüree','hauptgang',19.00,2.50,'laktose','fleisch,warm,herzhaft,traditionell','mittag,abend','Langsam gegarter Schweinebauch auf samtigem Kartoffelpüree','2026-05-27 22:49:42'),(13,'Zanderfilet auf Spinatbett','hauptgang',22.00,4.00,'fisch,laktose','fisch,warm,elegant','mittag,abend,business','Gebratenes Zanderfilet auf frischem Blattspinat mit Zitronenbutter','2026-05-27 22:49:42'),(14,'Garnelen-Risotto','hauptgang',24.00,5.00,'laktose,krebstiere','warm,cremig,mediterran,meeresfrüchte','mittag,abend,business,sommer','Cremiges Risotto mit frischen Garnelen und Weißwein','2026-05-27 22:49:42'),(15,'Pasta Bolognese','hauptgang',18.00,3.00,'gluten,ei,laktose','fleisch,warm,herzhaft,italienisch','mittag,business','Klassische Bolognese mit frischer Pasta und Parmesan','2026-05-27 22:49:42'),(16,'Tagliatelle mit Lachs und Spinat','hauptgang',19.00,3.00,'gluten,fisch,laktose,ei','fisch,warm,cremig,italienisch','mittag,abend','Breite Pasta mit Lachsfilet in cremiger Spinatsoße','2026-05-27 22:49:42'),(17,'Linsen-Eintopf mit Speck','hauptgang',15.00,1.50,'sellerie','fleisch,warm,herzhaft,traditionell','mittag,abend,buffet,winter','Herzhafter Linseneintopf mit geräuchertem Speck und Wurzelgemüse','2026-05-27 22:49:42'),(18,'Kürbis-Gnocchi mit Salbeibutter','hauptgang',17.00,1.50,'gluten,laktose,ei','vegetarisch,warm,herzhaft','mittag,abend','Handgemachte Kürbis-Gnocchi in goldener Salbeibutter mit Parmesan','2026-05-27 22:49:42'),(19,'Hühnerbrust in Champignonrahmsoße','hauptgang',18.00,2.50,'laktose','geflügel,warm,herzhaft,cremig','mittag,abend,business','Saftige Hühnerbrust in aromatischer Champignonrahmsoße','2026-05-27 22:49:42'),(20,'Paprikahühnchen mit Reis','hauptgang',18.00,2.50,'laktose','geflügel,warm,herzhaft,traditionell','mittag,abend,buffet','Ungarisches Paprikahühnchen mit Schlagobers auf lockerem Reis','2026-05-27 22:49:42'),(21,'Kalbsbäckchen geschmort','hauptgang',28.00,5.50,'sellerie,laktose','fleisch,warm,elegant,traditionell','abend,festlich','Zart geschmorte Kalbsbäckchen in Rotweinsoße mit Gemüse','2026-05-27 22:49:42'),(22,'Forelle Müllerin','hauptgang',24.00,4.50,'fisch,gluten,laktose','fisch,warm,traditionell,österreichisch','mittag,abend','Gebratene Forelle nach Müllerinart mit Buttersoße und Zitrone','2026-05-27 22:49:42'),(23,'Veganer Gemüsestrudel','hauptgang',15.00,1.00,'gluten','vegetarisch,vegan,warm,österreichisch','mittag,abend,buffet','Knuspriger Strudel gefüllt mit saisonalem Gemüse und Kräutern','2026-05-27 22:49:42'),(24,'Rindsgulasch mit Semmelknödel','hauptgang',20.00,4.50,'gluten,laktose,ei','fleisch,warm,herzhaft,österreichisch,traditionell','mittag,abend,business','Würziges Rindsgulasch mit luftigen Semmelknödeln','2026-05-27 22:49:42'),(25,'Spargel-Risotto mit Parmesan','hauptgang',20.00,2.50,'laktose','vegetarisch,warm,cremig,italienisch','mittag,abend,sommer','Cremiges Spargelrisotto mit frisch gehobeltem Parmesan','2026-05-27 22:49:42'),(26,'Avocado-Toast mit Räucherlachs','vorspeise',11.00,3.00,'fisch,gluten','fisch,kalt,modern,elegant','buffet,business,empfang,sommer','Cremige Avocado auf geröstetem Brot mit hauchdünnem Räucherlachs','2026-05-27 22:49:42'),(27,'Bruschetta mit Tomaten und Rucola','vorspeise',7.00,1.00,'gluten','vegetarisch,vegan,kalt,italienisch,fingerfood','buffet,empfang,sommer','Knuspriges Brot mit frischen Tomaten, Rucola und Olivenöl','2026-05-27 22:49:42'),(28,'Garnelencocktail','vorspeise',10.00,2.50,'krebstiere,laktose','kalt,elegant,modern,meeresfrüchte','buffet,business,empfang,abend','Klassischer Garnelencocktail mit feiner Frischkäsesoße','2026-05-27 22:49:42'),(29,'Kürbiscremesuppe','suppe',7.00,1.00,'laktose','vegetarisch,warm,cremig,österreichisch','mittag,abend,buffet,winter','Samtige Kürbiscremesuppe mit Schlagobers und Kürbiskernöl','2026-05-27 22:49:42'),(30,'Beef Carpaccio mit Rucola und Parmesan','vorspeise',13.00,3.50,'laktose','fleisch,kalt,elegant,modern','abend,business,festlich','Hauchdünn geschnittenes Rinderfilet mit Rucola, Parmesan und Olivenöl','2026-05-27 22:49:42'),(31,'Räucherlachs auf Toast','vorspeise',11.00,3.50,'fisch,gluten,laktose','fisch,kalt,elegant,modern','buffet,business,empfang,abend','Aromatischer Räucherlachs mit Frischkäse auf knusprigem Toast','2026-05-27 22:49:42'),(32,'Crème Brûlée','dessert',8.00,2.00,'laktose,ei','kalt,süß,cremig,elegant,klassisch','abend,festlich,business','Klassische Crème Brûlée mit karamellisierter Zuckerkruste','2026-05-27 22:49:42'),(33,'Mousse au Chocolat','dessert',7.50,2.00,'laktose,ei','kalt,süß,cremig,elegant,international','abend,buffet,festlich','Luftige Schokoladenmousse aus dunkler Schokolade','2026-05-27 22:49:42'),(34,'Erdbeer-Panna-Cotta','dessert',8.00,2.00,'laktose','kalt,süß,cremig,elegant,italienisch','abend,buffet,sommer','Zarte Panna Cotta mit frischem Erdbeerkompott','2026-05-27 22:49:42'),(35,'Apfelstrudel','dessert',7.00,1.50,'gluten,laktose,nuss','warm,süß,österreichisch,traditionell,klassisch','mittag,abend,buffet,nachmittag','Klassischer Apfelstrudel mit Walnüssen und Aprikosenmarmelade','2026-05-27 22:49:42');
/*!40000 ALTER TABLE `MenuItems` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_menuitems_bi` BEFORE INSERT ON `MenuItems` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_menuitems_bu` BEFORE UPDATE ON `MenuItems` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `MenuItems_backup_20260529`
--

DROP TABLE IF EXISTS `MenuItems_backup_20260529`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `MenuItems_backup_20260529` (
  `Id` int NOT NULL DEFAULT '0',
  `Name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `Category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `SalesPricePerPerson` decimal(10,2) NOT NULL,
  `PurchaseCostPerPerson` decimal(10,2) NOT NULL,
  `Allergens` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Tags` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Eignung` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Beschreibung` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MenuItems_backup_20260529`
--

LOCK TABLES `MenuItems_backup_20260529` WRITE;
/*!40000 ALTER TABLE `MenuItems_backup_20260529` DISABLE KEYS */;
INSERT INTO `MenuItems_backup_20260529` VALUES (1,'Wiener Schnitzel mit Erdäpfelsalat','Hauptgang',24.00,9.50,'Gluten, Ei, Milch','warm, traditionell, österreichisch','Mittag, Abend, Business','Knusprig paniertes Kalbsschnitzel nach Wiener Art, serviert mit hausgemachtem Erdäpfelsalat in Essig-Öl-Marinade.','2026-05-26 16:25:54'),(2,'Tafelspitz mit Wurzelgemüse','Hauptgang',28.00,8.50,NULL,'warm, traditionell, österreichisch, Suppe','Abend, Business, Festlich','Zartes, in Wurzelgemüse gesottenes Rindfleisch – ein Klassiker der Wiener Küche, serviert mit Bouillonkartoffeln und frisch geriebenem Kren.','2026-05-26 16:25:54'),(3,'Gemüse-Risotto','Hauptgang',18.00,5.50,'Milch','warm, vegetarisch, italienisch, cremig','Mittag, Abend, Buffet, Vegetarisch','Cremiges Risotto mit saisonalem Gemüse, verfeinert mit Parmesan und einem Schuss Weißwein.','2026-05-26 16:25:54'),(4,'Lachstatar auf Brioche','Vorspeise',12.00,4.50,'Fisch, Gluten','kalt, Fisch, elegant, modern','Buffet, Business, Abend, Empfang','Fein gewürztes Lachstatar auf geröstetem Brioche – eine elegante Fingerfood-Vorspeise für gehobene Anlässe.','2026-05-26 16:25:54'),(5,'Caprese-Spieß','Vorspeise',8.00,2.80,'Milch','kalt, vegetarisch, italienisch, Fingerfood','Buffet, Empfang, Mittag, Sommer','Klassischer Caprese-Spieß mit frischen Tomaten, cremigem Mozzarella und Olivenöl – leicht, frisch und vielseitig.','2026-05-26 16:25:54'),(6,'Sachertorte','Dessert',8.00,2.50,'Gluten, Ei, Milch','kalt, süß, österreichisch, Klassiker','Abend, Buffet, Festlich, Nachmittag','Die weltberühmte Wiener Sachertorte – feiner Schokoladenbiskuit mit Aprikosenmarmelade und zarter Schokoladeglasur.','2026-05-26 16:25:54'),(7,'Topfenstrudel','Dessert',7.00,2.20,'Gluten, Ei, Milch','warm, süß, österreichisch, Strudel','Mittag, Abend, Buffet, Nachmittag','Knusprig gebackener Strudel mit cremiger Topfenfüllung – ein warmes Dessert nach österreichischer Tradition.','2026-05-26 16:25:54'),(8,'Laugengebäck-Assortment','Buffet',4.00,1.50,'Gluten, Milch','kalt, Buffet, Bäckerei, herzhaft','Buffet, Business, Empfang, Mittag','Auswahl an frisch gebackenem Laugengebäck – ideal für Stehbuffets, Business-Lunches und Empfänge.','2026-05-26 16:25:54'),(9,'Rinderfilet mit Kartoffelgratin','Hauptgang',34.00,7.00,'Milch',NULL,'Abend, Business, Festlich','Zartes Rinderfilet auf cremigem Kartoffelgratin mit Knoblauchbutter','2026-05-27 22:49:42'),(10,'Lammkeule mit Polenta','Hauptgang',26.00,5.00,'Milch',NULL,'Abend, Festlich','Geschmorte Lammkeule mit Kräutern auf cremiger Polenta','2026-05-27 22:49:42'),(11,'Entenbrust mit Orangensoße','Hauptgang',22.00,4.00,'Milch',NULL,'Abend, Festlich, Business','Knusprige Entenbrust mit feiner Orangensoße und Rotkraut','2026-05-27 22:49:42'),(12,'Schweinebauch mit Kartoffelpüree','Hauptgang',19.00,2.50,'Milch',NULL,'Mittag, Abend','Langsam gegarter Schweinebauch auf samtigem Kartoffelpüree','2026-05-27 22:49:42'),(13,'Zanderfilet auf Spinatbett','Hauptgang',22.00,4.00,'Fisch, Milch',NULL,'Mittag, Abend, Business','Gebratenes Zanderfilet auf frischem Blattspinat mit Zitronenbutter','2026-05-27 22:49:42'),(14,'Garnelen-Risotto','Hauptgang',24.00,5.00,'Milch, Krustentiere',NULL,'Mittag, Abend, Business, Sommer','Cremiges Risotto mit frischen Garnelen und Weißwein','2026-05-27 22:49:42'),(15,'Pasta Bolognese','Hauptgang',18.00,3.00,'Gluten',NULL,'Mittag, Business','Klassische Bolognese mit frischer Pasta und Parmesan','2026-05-27 22:49:42'),(16,'Tagliatelle mit Lachs und Spinat','Hauptgang',19.00,3.00,'Gluten, Fisch, Milch',NULL,'Mittag, Abend','Breite Pasta mit Lachsfilet in cremiger Spinatsoße','2026-05-27 22:49:42'),(17,'Linsen-Eintopf mit Speck','Hauptgang',15.00,1.50,'Sellerie',NULL,'Mittag, Buffet','Herzhafter Linseneintopf mit geräuchertem Speck und Wurzelgemüse','2026-05-27 22:49:42'),(18,'Kürbis-Gnocchi mit Salbeibutter','Hauptgang',17.00,1.50,'Gluten, Milch, Ei',NULL,'Mittag, Abend, Vegetarisch','Handgemachte Kürbis-Gnocchi in goldener Salbeibutter mit Parmesan','2026-05-27 22:49:42'),(19,'Hühnerbrust in Champignonrahmsoße','Hauptgang',18.00,2.50,'Milch',NULL,'Mittag, Abend, Business','Saftige Hühnerbrust in aromatischer Champignonrahmsoße','2026-05-27 22:49:42'),(20,'Paprikahühnchen mit Reis','Hauptgang',18.00,2.50,'Milch',NULL,'Mittag, Abend, Buffet','Ungarisches Paprikahühnchen mit Schlagobers auf lockerem Reis','2026-05-27 22:49:42'),(21,'Kalbsbäckchen geschmort','Hauptgang',28.00,5.50,NULL,NULL,'Abend, Festlich','Zart geschmorte Kalbsbäckchen in Rotweinsoße mit Gemüse','2026-05-27 22:49:42'),(22,'Forelle Müllerin','Hauptgang',24.00,4.50,'Fisch, Gluten, Milch',NULL,'Mittag, Abend','Gebratene Forelle nach Müllerinart mit Buttersoße und Zitrone','2026-05-27 22:49:42'),(23,'Veganer Gemüsestrudel','Hauptgang',15.00,1.00,'Gluten',NULL,'Mittag, Abend, Buffet, Vegetarisch','Knuspriger Strudel gefüllt mit saisonalem Gemüse und Kräutern','2026-05-27 22:49:42'),(24,'Rindsgulasch mit Semmelknödel','Hauptgang',20.00,4.50,'Gluten, Milch, Ei',NULL,'Mittag, Abend, Business','Würziges Rindsgulasch mit luftigen Semmelknödeln','2026-05-27 22:49:42'),(25,'Spargel-Risotto mit Parmesan','Hauptgang',20.00,2.50,'Milch',NULL,'Mittag, Abend, Vegetarisch, Sommer','Cremiges Spargelrisotto mit frisch gehobeltem Parmesan','2026-05-27 22:49:42'),(26,'Avocado-Toast mit Räucherlachs','Vorspeise',11.00,3.00,'Fisch, Gluten',NULL,'Buffet, Business, Empfang, Sommer','Cremige Avocado auf geröstetem Brot mit hauchdünnem Räucherlachs','2026-05-27 22:49:42'),(27,'Bruschetta mit Tomaten und Rucola','Vorspeise',7.00,1.00,'Gluten',NULL,'Buffet, Empfang, Sommer','Knuspriges Brot mit frischen Tomaten, Rucola und Olivenöl','2026-05-27 22:49:42'),(28,'Garnelencocktail','Vorspeise',10.00,2.50,'Krustentiere, Milch',NULL,'Buffet, Business, Empfang, Abend','Klassischer Garnelencocktail mit feiner Frischkäsesoße','2026-05-27 22:49:42'),(29,'Kürbiscremesuppe','Vorspeise',7.00,1.00,'Milch',NULL,'Mittag, Abend, Buffet','Samtige Kürbiscremesuppe mit Schlagobers und Kürbiskernöl','2026-05-27 22:49:42'),(30,'Beef Carpaccio mit Rucola und Parmesan','Vorspeise',13.00,3.50,'Milch',NULL,'Abend, Business, Festlich','Hauchdünn geschnittenes Rinderfilet mit Rucola, Parmesan und Olivenöl','2026-05-27 22:49:42'),(31,'Räucherlachs auf Toast','Vorspeise',11.00,3.50,'Fisch, Gluten, Milch',NULL,'Buffet, Business, Empfang, Abend','Aromatischer Räucherlachs mit Frischkäse auf knusprigem Toast','2026-05-27 22:49:42'),(32,'Crème Brûlée','Dessert',8.00,2.00,'Milch, Ei',NULL,'Abend, Festlich, Business','Klassische Crème Brûlée mit karamellisierter Zuckerkruste','2026-05-27 22:49:42'),(33,'Mousse au Chocolat','Dessert',7.50,2.00,'Milch, Ei',NULL,'Abend, Buffet, Festlich','Luftige Schokoladenmousse aus dunkler Schokolade','2026-05-27 22:49:42'),(34,'Erdbeer-Panna-Cotta','Dessert',8.00,2.00,'Milch',NULL,'Abend, Buffet, Sommer','Zarte Panna Cotta mit frischem Erdbeerkompott','2026-05-27 22:49:42'),(35,'Apfelstrudel','Dessert',7.00,1.50,'Gluten, Milch, Nüsse',NULL,'Mittag, Abend, Buffet, Nachmittag','Klassischer Apfelstrudel mit Walnüssen und Aprikosenmarmelade','2026-05-27 22:49:42');
/*!40000 ALTER TABLE `MenuItems_backup_20260529` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MenuItems_backup_allergens_20260529`
--

DROP TABLE IF EXISTS `MenuItems_backup_allergens_20260529`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `MenuItems_backup_allergens_20260529` (
  `Id` int NOT NULL DEFAULT '0',
  `Name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `Category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `SalesPricePerPerson` decimal(10,2) NOT NULL,
  `PurchaseCostPerPerson` decimal(10,2) NOT NULL,
  `Allergens` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Tags` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Eignung` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Beschreibung` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MenuItems_backup_allergens_20260529`
--

LOCK TABLES `MenuItems_backup_allergens_20260529` WRITE;
/*!40000 ALTER TABLE `MenuItems_backup_allergens_20260529` DISABLE KEYS */;
INSERT INTO `MenuItems_backup_allergens_20260529` VALUES (1,'Wiener Schnitzel mit Erdäpfelsalat','hauptgang',24.00,9.50,'Gluten, Ei, Milch','warm,traditionell,österreichisch','mittag,abend,business','Knusprig paniertes Kalbsschnitzel nach Wiener Art, serviert mit hausgemachtem Erdäpfelsalat in Essig-Öl-Marinade.','2026-05-26 16:25:54'),(2,'Tafelspitz mit Wurzelgemüse','hauptgang',28.00,8.50,NULL,'warm,traditionell,österreichisch','abend,business,festlich','Zartes, in Wurzelgemüse gesottenes Rindfleisch – ein Klassiker der Wiener Küche, serviert mit Bouillonkartoffeln und frisch geriebenem Kren.','2026-05-26 16:25:54'),(3,'Gemüse-Risotto','hauptgang',18.00,5.50,'Milch','warm,vegetarisch,italienisch,cremig','mittag,abend,buffet','Cremiges Risotto mit saisonalem Gemüse, verfeinert mit Parmesan und einem Schuss Weißwein.','2026-05-26 16:25:54'),(4,'Lachstatar auf Brioche','vorspeise',12.00,4.50,'Fisch, Gluten','kalt,fisch,elegant,modern','buffet,business,abend,empfang','Fein gewürztes Lachstatar auf geröstetem Brioche – eine elegante Fingerfood-Vorspeise für gehobene Anlässe.','2026-05-26 16:25:54'),(5,'Caprese-Spieß','vorspeise',8.00,2.80,'Milch','kalt,vegetarisch,italienisch,fingerfood','buffet,empfang,mittag,sommer','Klassischer Caprese-Spieß mit frischen Tomaten, cremigem Mozzarella und Olivenöl – leicht, frisch und vielseitig.','2026-05-26 16:25:54'),(6,'Sachertorte','dessert',8.00,2.50,'Gluten, Ei, Milch','kalt,süß,österreichisch,klassisch','abend,buffet,festlich,nachmittag','Die weltberühmte Wiener Sachertorte – feiner Schokoladenbiskuit mit Aprikosenmarmelade und zarter Schokoladeglasur.','2026-05-26 16:25:54'),(7,'Topfenstrudel','dessert',7.00,2.20,'Gluten, Ei, Milch','warm,süß,österreichisch','mittag,abend,buffet,nachmittag','Knusprig gebackener Strudel mit cremiger Topfenfüllung – ein warmes Dessert nach österreichischer Tradition.','2026-05-26 16:25:54'),(8,'Laugengebäck-Assortment','gebäck',4.00,1.50,'Gluten, Milch','kalt,herzhaft','buffet,business,empfang,mittag','Auswahl an frisch gebackenem Laugengebäck – ideal für Stehbuffets, Business-Lunches und Empfänge.','2026-05-26 16:25:54'),(9,'Rinderfilet mit Kartoffelgratin','hauptgang',34.00,7.00,'Milch',NULL,'abend,business,festlich','Zartes Rinderfilet auf cremigem Kartoffelgratin mit Knoblauchbutter','2026-05-27 22:49:42'),(10,'Lammkeule mit Polenta','hauptgang',26.00,5.00,'Milch',NULL,'abend,festlich','Geschmorte Lammkeule mit Kräutern auf cremiger Polenta','2026-05-27 22:49:42'),(11,'Entenbrust mit Orangensoße','hauptgang',22.00,4.00,'Milch',NULL,'abend,festlich,business','Knusprige Entenbrust mit feiner Orangensoße und Rotkraut','2026-05-27 22:49:42'),(12,'Schweinebauch mit Kartoffelpüree','hauptgang',19.00,2.50,'Milch',NULL,'mittag,abend','Langsam gegarter Schweinebauch auf samtigem Kartoffelpüree','2026-05-27 22:49:42'),(13,'Zanderfilet auf Spinatbett','hauptgang',22.00,4.00,'Fisch, Milch',NULL,'mittag,abend,business','Gebratenes Zanderfilet auf frischem Blattspinat mit Zitronenbutter','2026-05-27 22:49:42'),(14,'Garnelen-Risotto','hauptgang',24.00,5.00,'Milch, Krustentiere',NULL,'mittag,abend,business,sommer','Cremiges Risotto mit frischen Garnelen und Weißwein','2026-05-27 22:49:42'),(15,'Pasta Bolognese','hauptgang',18.00,3.00,'Gluten',NULL,'mittag,business','Klassische Bolognese mit frischer Pasta und Parmesan','2026-05-27 22:49:42'),(16,'Tagliatelle mit Lachs und Spinat','hauptgang',19.00,3.00,'Gluten, Fisch, Milch',NULL,'mittag,abend','Breite Pasta mit Lachsfilet in cremiger Spinatsoße','2026-05-27 22:49:42'),(17,'Linsen-Eintopf mit Speck','hauptgang',15.00,1.50,'Sellerie',NULL,'mittag,buffet','Herzhafter Linseneintopf mit geräuchertem Speck und Wurzelgemüse','2026-05-27 22:49:42'),(18,'Kürbis-Gnocchi mit Salbeibutter','hauptgang',17.00,1.50,'Gluten, Milch, Ei','vegetarisch','mittag,abend','Handgemachte Kürbis-Gnocchi in goldener Salbeibutter mit Parmesan','2026-05-27 22:49:42'),(19,'Hühnerbrust in Champignonrahmsoße','hauptgang',18.00,2.50,'Milch',NULL,'mittag,abend,business','Saftige Hühnerbrust in aromatischer Champignonrahmsoße','2026-05-27 22:49:42'),(20,'Paprikahühnchen mit Reis','hauptgang',18.00,2.50,'Milch',NULL,'mittag,abend,buffet','Ungarisches Paprikahühnchen mit Schlagobers auf lockerem Reis','2026-05-27 22:49:42'),(21,'Kalbsbäckchen geschmort','hauptgang',28.00,5.50,NULL,NULL,'abend,festlich','Zart geschmorte Kalbsbäckchen in Rotweinsoße mit Gemüse','2026-05-27 22:49:42'),(22,'Forelle Müllerin','hauptgang',24.00,4.50,'Fisch, Gluten, Milch',NULL,'mittag,abend','Gebratene Forelle nach Müllerinart mit Buttersoße und Zitrone','2026-05-27 22:49:42'),(23,'Veganer Gemüsestrudel','hauptgang',15.00,1.00,'Gluten','vegetarisch','mittag,abend,buffet','Knuspriger Strudel gefüllt mit saisonalem Gemüse und Kräutern','2026-05-27 22:49:42'),(24,'Rindsgulasch mit Semmelknödel','hauptgang',20.00,4.50,'Gluten, Milch, Ei',NULL,'mittag,abend,business','Würziges Rindsgulasch mit luftigen Semmelknödeln','2026-05-27 22:49:42'),(25,'Spargel-Risotto mit Parmesan','hauptgang',20.00,2.50,'Milch','vegetarisch','mittag,abend,sommer','Cremiges Spargelrisotto mit frisch gehobeltem Parmesan','2026-05-27 22:49:42'),(26,'Avocado-Toast mit Räucherlachs','vorspeise',11.00,3.00,'Fisch, Gluten',NULL,'buffet,business,empfang,sommer','Cremige Avocado auf geröstetem Brot mit hauchdünnem Räucherlachs','2026-05-27 22:49:42'),(27,'Bruschetta mit Tomaten und Rucola','vorspeise',7.00,1.00,'Gluten',NULL,'buffet,empfang,sommer','Knuspriges Brot mit frischen Tomaten, Rucola und Olivenöl','2026-05-27 22:49:42'),(28,'Garnelencocktail','vorspeise',10.00,2.50,'Krustentiere, Milch',NULL,'buffet,business,empfang,abend','Klassischer Garnelencocktail mit feiner Frischkäsesoße','2026-05-27 22:49:42'),(29,'Kürbiscremesuppe','suppe',7.00,1.00,'Milch',NULL,'mittag,abend,buffet','Samtige Kürbiscremesuppe mit Schlagobers und Kürbiskernöl','2026-05-27 22:49:42'),(30,'Beef Carpaccio mit Rucola und Parmesan','vorspeise',13.00,3.50,'Milch',NULL,'abend,business,festlich','Hauchdünn geschnittenes Rinderfilet mit Rucola, Parmesan und Olivenöl','2026-05-27 22:49:42'),(31,'Räucherlachs auf Toast','vorspeise',11.00,3.50,'Fisch, Gluten, Milch',NULL,'buffet,business,empfang,abend','Aromatischer Räucherlachs mit Frischkäse auf knusprigem Toast','2026-05-27 22:49:42'),(32,'Crème Brûlée','dessert',8.00,2.00,'Milch, Ei',NULL,'abend,festlich,business','Klassische Crème Brûlée mit karamellisierter Zuckerkruste','2026-05-27 22:49:42'),(33,'Mousse au Chocolat','dessert',7.50,2.00,'Milch, Ei',NULL,'abend,buffet,festlich','Luftige Schokoladenmousse aus dunkler Schokolade','2026-05-27 22:49:42'),(34,'Erdbeer-Panna-Cotta','dessert',8.00,2.00,'Milch',NULL,'abend,buffet,sommer','Zarte Panna Cotta mit frischem Erdbeerkompott','2026-05-27 22:49:42'),(35,'Apfelstrudel','dessert',7.00,1.50,'Gluten, Milch, Nüsse',NULL,'mittag,abend,buffet,nachmittag','Klassischer Apfelstrudel mit Walnüssen und Aprikosenmarmelade','2026-05-27 22:49:42');
/*!40000 ALTER TABLE `MenuItems_backup_allergens_20260529` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `OrderMenuItems`
--

DROP TABLE IF EXISTS `OrderMenuItems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `OrderMenuItems` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `OrderId` int NOT NULL,
  `MenuItemId` int NOT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `uq_order_menuitem` (`OrderId`,`MenuItemId`),
  KEY `fk_omi_menuitem` (`MenuItemId`),
  CONSTRAINT `fk_omi_menuitem` FOREIGN KEY (`MenuItemId`) REFERENCES `MenuItems` (`Id`),
  CONSTRAINT `fk_omi_order` FOREIGN KEY (`OrderId`) REFERENCES `Orders` (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `OrderMenuItems`
--

LOCK TABLES `OrderMenuItems` WRITE;
/*!40000 ALTER TABLE `OrderMenuItems` DISABLE KEYS */;
INSERT INTO `OrderMenuItems` VALUES (5,1,23),(4,1,25),(2,1,27),(3,1,29),(1,1,30),(6,1,32);
/*!40000 ALTER TABLE `OrderMenuItems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Orders`
--

DROP TABLE IF EXISTS `Orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Orders` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `CustomerId` int NOT NULL,
  `EventDate` datetime NOT NULL,
  `EventType` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Location` varchar(300) COLLATE utf8mb4_unicode_ci NOT NULL,
  `GuestCount` int NOT NULL,
  `Budget` decimal(10,2) DEFAULT NULL,
  `SpecialWishes` text COLLATE utf8mb4_unicode_ci,
  `Allergies` text COLLATE utf8mb4_unicode_ci,
  `DishWishes` text COLLATE utf8mb4_unicode_ci,
  `Status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Neu',
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  KEY `idx_orders_customer` (`CustomerId`),
  KEY `idx_orders_status` (`Status`),
  KEY `idx_orders_event_date` (`EventDate`),
  CONSTRAINT `fk_orders_customer` FOREIGN KEY (`CustomerId`) REFERENCES `Customers` (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Orders`
--

LOCK TABLES `Orders` WRITE;
/*!40000 ALTER TABLE `Orders` DISABLE KEYS */;
INSERT INTO `Orders` VALUES (1,1,'2026-08-26 22:00:00','Geburtstagsfeier','München',35,2100.00,'Hauptgericht soll etwas Italienisches sein','5 Vegetarier, 3 Personen mit Laktose-Intoleranz, 1 Person mit Nussallergie','4-Gang-Menü','Geprüft','2026-05-30 07:56:25','2026-05-30 07:57:23');
/*!40000 ALTER TABLE `Orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PurchaseListItems`
--

DROP TABLE IF EXISTS `PurchaseListItems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PurchaseListItems` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `PurchaseListId` int NOT NULL,
  `IngredientId` int NOT NULL,
  `IngredientName` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `RequiredQuantity` decimal(10,3) NOT NULL,
  `Unit` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Category` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `IsDone` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Id`),
  KEY `fk_pli_purchaselist` (`PurchaseListId`),
  KEY `fk_pli_ingredient` (`IngredientId`),
  CONSTRAINT `fk_pli_ingredient` FOREIGN KEY (`IngredientId`) REFERENCES `Ingredients` (`Id`),
  CONSTRAINT `fk_pli_purchaselist` FOREIGN KEY (`PurchaseListId`) REFERENCES `PurchaseLists` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PurchaseListItems`
--

LOCK TABLES `PurchaseListItems` WRITE;
/*!40000 ALTER TABLE `PurchaseListItems` DISABLE KEYS */;
/*!40000 ALTER TABLE `PurchaseListItems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PurchaseLists`
--

DROP TABLE IF EXISTS `PurchaseLists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PurchaseLists` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `OrderId` int NOT NULL,
  `SafetyMargin` decimal(5,4) NOT NULL DEFAULT '0.1000',
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `uq_purchaselists_order` (`OrderId`),
  CONSTRAINT `fk_pl_order` FOREIGN KEY (`OrderId`) REFERENCES `Orders` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PurchaseLists`
--

LOCK TABLES `PurchaseLists` WRITE;
/*!40000 ALTER TABLE `PurchaseLists` DISABLE KEYS */;
/*!40000 ALTER TABLE `PurchaseLists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `QuotePositions`
--

DROP TABLE IF EXISTS `QuotePositions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `QuotePositions` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `QuoteId` int NOT NULL,
  `MenuItemId` int NOT NULL,
  `MenuItemName` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Quantity` int NOT NULL,
  `UnitPrice` decimal(10,2) NOT NULL,
  `TotalNet` decimal(10,2) NOT NULL,
  `VatRate` decimal(5,4) NOT NULL,
  `VatAmount` decimal(10,2) NOT NULL,
  `TotalGross` decimal(10,2) NOT NULL,
  PRIMARY KEY (`Id`),
  KEY `fk_qp_quote` (`QuoteId`),
  KEY `fk_qp_menuitem` (`MenuItemId`),
  CONSTRAINT `fk_qp_menuitem` FOREIGN KEY (`MenuItemId`) REFERENCES `MenuItems` (`Id`),
  CONSTRAINT `fk_qp_quote` FOREIGN KEY (`QuoteId`) REFERENCES `Quotes` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `QuotePositions`
--

LOCK TABLES `QuotePositions` WRITE;
/*!40000 ALTER TABLE `QuotePositions` DISABLE KEYS */;
/*!40000 ALTER TABLE `QuotePositions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Quotes`
--

DROP TABLE IF EXISTS `Quotes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Quotes` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `OrderId` int NOT NULL,
  `AdminFee` decimal(10,2) NOT NULL DEFAULT '0.00',
  `ProfitMarginRate` decimal(5,4) NOT NULL DEFAULT '0.1500',
  `TotalNet` decimal(10,2) NOT NULL,
  `TotalVat` decimal(10,2) NOT NULL,
  `TotalGross` decimal(10,2) NOT NULL,
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `uq_quotes_order` (`OrderId`),
  CONSTRAINT `fk_quotes_order` FOREIGN KEY (`OrderId`) REFERENCES `Orders` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Quotes`
--

LOCK TABLES `Quotes` WRITE;
/*!40000 ALTER TABLE `Quotes` DISABLE KEYS */;
/*!40000 ALTER TABLE `Quotes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Users`
--

DROP TABLE IF EXISTS `Users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Users` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `Username` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `PasswordHash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `uq_users_username` (`Username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Users`
--

LOCK TABLES `Users` WRITE;
/*!40000 ALTER TABLE `Users` DISABLE KEYS */;
INSERT INTO `Users` VALUES (1,'admin','$2a$11$AU6kk92bXKLcPmvaabSGRuKqkAWNXiy3QP6zEZQj0kBR2dTS4xusy','2026-05-26 16:26:04');
/*!40000 ALTER TABLE `Users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'catermate_db'
--

--
-- Dumping routines for database 'catermate_db'
--
/*!50003 DROP FUNCTION IF EXISTS `csv_invalid_value` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `csv_invalid_value`(
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
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-30  8:34:20
