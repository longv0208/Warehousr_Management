-- MySQL dump 10.13  Distrib 8.0.36, for Win64 (x86_64)
--
-- Host: localhost    Database: swp391_quanlykhohang
-- ------------------------------------------------------
-- Server version	8.0.37
create database swp391_quanlykhohang;
use swp391_quanlykhohang;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `adjustmentreasons`
--

DROP TABLE IF EXISTS `adjustmentreasons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `adjustmentreasons` (
  `reason_id` int NOT NULL AUTO_INCREMENT,
  `reason_description` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reason_id`),
  UNIQUE KEY `reason_description` (`reason_description`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `adjustmentreasons`
--

LOCK TABLES `adjustmentreasons` WRITE;
/*!40000 ALTER TABLE `adjustmentreasons` DISABLE KEYS */;
/*!40000 ALTER TABLE `adjustmentreasons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (1,'Áo','2025-06-04 14:41:20'),(2,'Quần','2025-06-04 14:41:20'),(3,'Váy','2025-06-04 14:41:20'),(4,'Bộ đồ','2025-06-04 14:41:20'),(5,'Phụ kiện','2025-06-04 14:41:20');
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category-product`
--

DROP TABLE IF EXISTS `category-product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category-product` (
  `id` int NOT NULL,
  `product_id` varchar(45) NOT NULL,
  `category_id` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category-product`
--

LOCK TABLES `category-product` WRITE;
/*!40000 ALTER TABLE `category-product` DISABLE KEYS */;
INSERT INTO `category-product` VALUES (1,'21','1'),(2,'22','1'),(3,'23','2'),(4,'24','3'),(5,'25','1'),(6,'26','2'),(7,'27','1'),(8,'28','1'),(9,'29','3'),(10,'30','1'),(11,'31','4'),(12,'32','1'),(13,'33','2'),(14,'34','1'),(15,'35','5'),(16,'36','5'),(17,'37','5'),(18,'38','1'),(19,'39','2'),(20,'40','1'),(21,'45','5'),(24,'47','3'),(25,'46','1');
/*!40000 ALTER TABLE `category-product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory` (
  `inventory_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `quantity_on_hand` int NOT NULL DEFAULT '0',
  `last_updated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`inventory_id`),
  UNIQUE KEY `product_id` (`product_id`),
  CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `product_code` varchar(50) NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `description` text,
  `unit` varchar(20) DEFAULT NULL,
  `purchase_price` float DEFAULT '0',
  `sale_price` float DEFAULT '0',
  `supplier_id` int DEFAULT NULL,
  `low_stock_threshold` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`product_id`),
  UNIQUE KEY `product_code` (`product_code`),
  KEY `supplier_id` (`supplier_id`),
  CONSTRAINT `products_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (21,'CL001','Áo sơ mi trắng nam','Áo sơ mi trắng tay dài, chất cotton','cái',150000,250000,1,5,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(22,'CL002','Áo thun nữ in họa tiết','Chất thun co giãn, thoáng mát','cái',100000,180000,2,10,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(23,'CL003','Quần jeans nam','Quần jean xanh đậm, form slim-fit','cái',200000,350000,3,15,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(24,'CL004','Chân váy xếp ly','Chân váy nữ dáng ngắn, chất voan','cái',180000,290000,2,7,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(25,'CL005','Áo khoác bomber nam','Áo khoác thời trang, chất kaki lót dù','cái',300000,450000,4,4,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(26,'CL006','Quần short nữ','Quần short lưng cao, phối túi','cái',120000,210000,4,8,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(27,'CL007','Áo hoodie unisex','Áo nỉ chui đầu có nón, freesize','cái',250000,400000,5,6,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(28,'CL008','Áo len cổ lọ nữ','Áo giữ ấm mùa đông, chất len dày','cái',220000,370000,6,5,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(29,'CL009','Váy maxi dạo phố','Váy dáng dài, hoa nhí nhẹ nhàng','cái',250000,380000,6,6,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(30,'CL010','Áo ba lỗ nam','Áo thể thao nam chất thun lạnh','cái',80000,150000,7,12,'2025-06-04 14:32:17','2025-06-04 21:07:30',1),(31,'CL011','Bộ pijama nữ','Bộ ngủ nữ, chất lụa mềm mát','bộ',180000,280000,4,10,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(32,'CL012','Áo vest nam công sở','Vest đen lịch sự, vải tuyết mưa','cái',400000,600000,8,2,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(33,'CL013','Quần tây nam','Quần tây công sở, form chuẩn','cái',250000,370000,5,6,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(34,'CL014','Áo thun croptop nữ','Áo croptop trẻ trung năng động','cái',90000,160000,9,15,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(35,'CL015','Khăn quàng cổ len','Khăn choàng len giữ ấm','cái',50000,120000,9,20,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(36,'CL016','Tất vớ cotton','Vớ ngắn thoáng khí, size free','đôi',20000,40000,10,40,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(37,'CL017','Mũ bucket unisex','Mũ vải chống nắng thời trang','cái',60000,110000,9,25,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(38,'CL018','Áo gió 2 lớp nam','Áo chống nước, có mũ trùm đầu','cái',270000,420000,9,10,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(39,'CL019','Quần legging nữ','Quần tập gym, chất co giãn tốt','cái',130000,200000,7,12,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(40,'CL020','Áo sơ mi caro','Áo sơ mi nam nữ unisex, tay dài','cái',180000,300000,9,14,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(45,'CL999','Sản phẩm test','Test mô tả','cái',100000,120000,2,1,'2025-06-04 14:32:17','2025-06-04 14:32:17',1),(46,'test','123','12','thanh',123,123,1,123,'2025-06-04 19:45:39','2025-06-04 22:30:14',1);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchaserequestdetails`
--

DROP TABLE IF EXISTS `purchaserequestdetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchaserequestdetails` (
  `request_detail_id` int NOT NULL AUTO_INCREMENT,
  `request_id` int NOT NULL,
  `product_id` int NOT NULL,
  `requested_quantity` int NOT NULL,
  `supplier_id_suggested` int DEFAULT NULL,
  PRIMARY KEY (`request_detail_id`),
  KEY `request_id` (`request_id`),
  KEY `product_id` (`product_id`),
  KEY `supplier_id_suggested` (`supplier_id_suggested`),
  CONSTRAINT `purchaserequestdetails_ibfk_1` FOREIGN KEY (`request_id`) REFERENCES `purchaserequests` (`request_id`) ON DELETE CASCADE,
  CONSTRAINT `purchaserequestdetails_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  CONSTRAINT `purchaserequestdetails_ibfk_3` FOREIGN KEY (`supplier_id_suggested`) REFERENCES `suppliers` (`supplier_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchaserequestdetails`
--

LOCK TABLES `purchaserequestdetails` WRITE;
/*!40000 ALTER TABLE `purchaserequestdetails` DISABLE KEYS */;
/*!40000 ALTER TABLE `purchaserequestdetails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchaserequests`
--

DROP TABLE IF EXISTS `purchaserequests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchaserequests` (
  `request_id` int NOT NULL AUTO_INCREMENT,
  `request_code` varchar(50) DEFAULT NULL,
  `user_id_requester` int NOT NULL,
  `request_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('pending_approval','approved','rejected','ordered','partially_received','received') DEFAULT 'pending_approval',
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`request_id`),
  UNIQUE KEY `request_code` (`request_code`),
  KEY `user_id_requester` (`user_id_requester`),
  CONSTRAINT `purchaserequests_ibfk_1` FOREIGN KEY (`user_id_requester`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchaserequests`
--

LOCK TABLES `purchaserequests` WRITE;
/*!40000 ALTER TABLE `purchaserequests` DISABLE KEYS */;
/*!40000 ALTER TABLE `purchaserequests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salesorderdetails`
--

DROP TABLE IF EXISTS `salesorderdetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salesorderdetails` (
  `order_detail_id` int NOT NULL AUTO_INCREMENT,
  `sales_order_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity_ordered` int NOT NULL,
  `unit_sale_price` decimal(12,2) NOT NULL,
  PRIMARY KEY (`order_detail_id`),
  KEY `sales_order_id` (`sales_order_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `salesorderdetails_ibfk_1` FOREIGN KEY (`sales_order_id`) REFERENCES `salesorders` (`sales_order_id`) ON DELETE CASCADE,
  CONSTRAINT `salesorderdetails_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salesorderdetails`
--

LOCK TABLES `salesorderdetails` WRITE;
/*!40000 ALTER TABLE `salesorderdetails` DISABLE KEYS */;
/*!40000 ALTER TABLE `salesorderdetails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salesorders`
--

DROP TABLE IF EXISTS `salesorders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salesorders` (
  `sales_order_id` int NOT NULL AUTO_INCREMENT,
  `order_code` varchar(50) DEFAULT NULL,
  `customer_name` varchar(100) DEFAULT NULL,
  `user_id` int NOT NULL,
  `order_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('pending_stock_check','awaiting_shipment','shipped','completed','cancelled') DEFAULT 'pending_stock_check',
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`sales_order_id`),
  UNIQUE KEY `order_code` (`order_code`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `salesorders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salesorders`
--

LOCK TABLES `salesorders` WRITE;
/*!40000 ALTER TABLE `salesorders` DISABLE KEYS */;
/*!40000 ALTER TABLE `salesorders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `setting`
--

DROP TABLE IF EXISTS `setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `setting` (
  `id` int NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key_UNIQUE` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `setting`
--

LOCK TABLES `setting` WRITE;
/*!40000 ALTER TABLE `setting` DISABLE KEYS */;
INSERT INTO `setting` VALUES (1,'SETTING_KEY_EMAIL_APP_USERNAME','123'),(2,'SETTING_KEY_EMAIL_APP_PASSWORD',NULL),(3,'test','12');
/*!40000 ALTER TABLE `setting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stockinwarddetails`
--

DROP TABLE IF EXISTS `stockinwarddetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stockinwarddetails` (
  `inward_detail_id` int NOT NULL AUTO_INCREMENT,
  `stock_inward_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity_received` int NOT NULL,
  `unit_purchase_price` decimal(12,2) NOT NULL,
  PRIMARY KEY (`inward_detail_id`),
  KEY `stock_inward_id` (`stock_inward_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `stockinwarddetails_ibfk_1` FOREIGN KEY (`stock_inward_id`) REFERENCES `stockinwards` (`stock_inward_id`) ON DELETE CASCADE,
  CONSTRAINT `stockinwarddetails_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stockinwarddetails`
--

LOCK TABLES `stockinwarddetails` WRITE;
/*!40000 ALTER TABLE `stockinwarddetails` DISABLE KEYS */;
/*!40000 ALTER TABLE `stockinwarddetails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stockinwards`
--

DROP TABLE IF EXISTS `stockinwards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stockinwards` (
  `stock_inward_id` int NOT NULL AUTO_INCREMENT,
  `inward_code` varchar(50) DEFAULT NULL,
  `supplier_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  `inward_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`stock_inward_id`),
  UNIQUE KEY `inward_code` (`inward_code`),
  KEY `supplier_id` (`supplier_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `stockinwards_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`) ON DELETE SET NULL,
  CONSTRAINT `stockinwards_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stockinwards`
--

LOCK TABLES `stockinwards` WRITE;
/*!40000 ALTER TABLE `stockinwards` DISABLE KEYS */;
/*!40000 ALTER TABLE `stockinwards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stockoutwarddetails`
--

DROP TABLE IF EXISTS `stockoutwarddetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stockoutwarddetails` (
  `outward_detail_id` int NOT NULL AUTO_INCREMENT,
  `stock_outward_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity_shipped` int NOT NULL,
  PRIMARY KEY (`outward_detail_id`),
  KEY `stock_outward_id` (`stock_outward_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `stockoutwarddetails_ibfk_1` FOREIGN KEY (`stock_outward_id`) REFERENCES `stockoutwards` (`stock_outward_id`) ON DELETE CASCADE,
  CONSTRAINT `stockoutwarddetails_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stockoutwarddetails`
--

LOCK TABLES `stockoutwarddetails` WRITE;
/*!40000 ALTER TABLE `stockoutwarddetails` DISABLE KEYS */;
/*!40000 ALTER TABLE `stockoutwarddetails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stockoutwards`
--

DROP TABLE IF EXISTS `stockoutwards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stockoutwards` (
  `stock_outward_id` int NOT NULL AUTO_INCREMENT,
  `outward_code` varchar(50) DEFAULT NULL,
  `sales_order_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  `outward_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `reason` enum('sale','internal_transfer','damage','loss','other') NOT NULL,
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`stock_outward_id`),
  UNIQUE KEY `outward_code` (`outward_code`),
  KEY `sales_order_id` (`sales_order_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `stockoutwards_ibfk_1` FOREIGN KEY (`sales_order_id`) REFERENCES `salesorders` (`sales_order_id`) ON DELETE SET NULL,
  CONSTRAINT `stockoutwards_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stockoutwards`
--

LOCK TABLES `stockoutwards` WRITE;
/*!40000 ALTER TABLE `stockoutwards` DISABLE KEYS */;
/*!40000 ALTER TABLE `stockoutwards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stocktakedetails`
--

DROP TABLE IF EXISTS `stocktakedetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stocktakedetails` (
  `stock_take_detail_id` int NOT NULL AUTO_INCREMENT,
  `stock_take_id` int NOT NULL,
  `product_id` int NOT NULL,
  `system_quantity` int NOT NULL,
  `counted_quantity` int DEFAULT NULL,
  `discrepancy` int GENERATED ALWAYS AS ((`counted_quantity` - `system_quantity`)) STORED,
  PRIMARY KEY (`stock_take_detail_id`),
  KEY `stock_take_id` (`stock_take_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `stocktakedetails_ibfk_1` FOREIGN KEY (`stock_take_id`) REFERENCES `stocktakes` (`stock_take_id`) ON DELETE CASCADE,
  CONSTRAINT `stocktakedetails_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stocktakedetails`
--

LOCK TABLES `stocktakedetails` WRITE;
/*!40000 ALTER TABLE `stocktakedetails` DISABLE KEYS */;
/*!40000 ALTER TABLE `stocktakedetails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stocktakes`
--

DROP TABLE IF EXISTS `stocktakes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stocktakes` (
  `stock_take_id` int NOT NULL AUTO_INCREMENT,
  `stock_take_code` varchar(50) DEFAULT NULL,
  `user_id` int NOT NULL,
  `stock_take_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('pending','in_progress','completed','reconciled') DEFAULT 'pending',
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`stock_take_id`),
  UNIQUE KEY `stock_take_code` (`stock_take_code`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `stocktakes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stocktakes`
--

LOCK TABLES `stocktakes` WRITE;
/*!40000 ALTER TABLE `stocktakes` DISABLE KEYS */;
/*!40000 ALTER TABLE `stocktakes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `suppliers` (
  `supplier_id` int NOT NULL AUTO_INCREMENT,
  `supplier_name` varchar(100) NOT NULL,
  `contact_person` varchar(100) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `address` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`supplier_id`),
  UNIQUE KEY `supplier_name` (`supplier_name`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
INSERT INTO `suppliers` VALUES
 (1,'Công ty TNHH Thời Trang Ánh Sao','Nguyễn Thị Lan','0901234567','contact@anhsaofashion.com','123 Đường Lê Lợi, Quận 1, TP.HCM','2025-05-25 18:28:45','2025-05-25 18:28:45'),
 (2,'Công ty Cổ phần Dệt May Sài Gòn','Trần Văn Hùng','0912345678','info@saigontextile.vn','456 Đường Trần Hưng Đạo, Quận 5, TP.HCM','2025-05-25 18:28:45','2025-05-25 18:28:45'),
 (3,'Công ty TNHH Phụ Kiện Thời Trang','Lê Thị Mai','0923456789','support@fashionaccessories.com','789 Đường Nguyễn Huệ, Quận 3, TP.HCM','2025-05-25 18:28:45','2025-05-25 18:28:45'),
 (4,'Công ty TNHH Quần Áo Thể Thao','Phạm Văn Nam','0934567890','sales@sportswear.vn','321 Đường Hai Bà Trưng, Quận 10, TP.HCM','2025-05-25 18:28:45','2025-05-25 18:28:45'),
 (5,'Công ty TNHH Thời Trang Nhật Bản','Nguyễn Thị Hồng','0945678901','contact@japanfashion.jp','654 Đường Phạm Ngũ Lão, Quận 1, TP.HCM','2025-05-25 18:28:45','2025-05-25 18:28:45'),
 (6,'Công ty TNHH Dệt May Cao Cấp','Trần Thị Ngọc','0956789012','info@premiumtextile.vn','987 Đường Lý Thường Kiệt, Quận Tân Bình, TP.HCM','2025-05-25 18:28:45','2025-05-25 18:28:45'),
 (7,'Công ty TNHH Phụ Kiện Da','Lê Văn Tâm','0967890123','support@leatheraccessories.vn','123 Đường Cách Mạng Tháng 8, Quận 10, TP.HCM','2025-05-25 18:28:45','2025-05-25 18:28:45'),
 (8,'Công ty TNHH Thời Trang Trẻ Em','Phạm Thị Hà','0978901234','sales@kidsfashion.vn','456 Đường Nguyễn Trãi, Quận 5, TP.HCM','2025-05-25 18:28:45','2025-05-25 18:28:45'),
 (9,'Công ty TNHH Vải May Mặc','Nguyễn Văn Long','0989012345','contact@fabricvn.com','789 Đường Điện Biên Phủ, Quận Bình Thạnh, TP.HCM','2025-05-25 18:28:45','2025-05-25 18:28:45'),
 (10,'Công ty TNHH Thời Trang Bền Vững','Trần Thị Thanh','0990123456','info@sustainablefashion.vn','321 Đường Võ Thị Sáu, Quận 3, TP.HCM','2025-05-25 18:28:45','2025-05-25 18:28:45');
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(10) DEFAULT NULL,
  `role` enum('admin','warehouse_staff','sales_staff','purchasing_staff') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','wlk7zsJAjC+d85JPwrpQuw==:Uvf348WQty+H2KHtZOg/xTlrwS1stk9A7SqppCSE3fs=','admin','a@hunght1890.com','0325910819','admin','2025-06-03 14:24:57','2025-06-03 14:24:57',1);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-06-05  5:39:08
