-- MySQL dump 10.13  Distrib 5.1.37, for apple-darwin8.11.1 (i386)
--
-- Host: localhost    Database: agora
-- ------------------------------------------------------
-- Server version	5.1.37

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `argschemes`
--

DROP TABLE IF EXISTS `argschemes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `argschemes` (
  `arg_scheme_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL,
  `class_name` varchar(25) NOT NULL,
  `claimStart` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`arg_scheme_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `argschemes`
--

LOCK TABLES `argschemes` WRITE;
/*!40000 ALTER TABLE `argschemes` DISABLE KEYS */;
INSERT INTO `argschemes` VALUES (1,'Modus Ponens','ModusPonens',1),(2,'Modus Tollens','ModusTollens',0),(3,'Equivalence','Equivalence',1),(4,'Disjunctive Syllogism','DisjunctiveSyllogism',0),(5,'Not Both Syllogism','NotBothSyllogism',0),(6,'XOR Syllogism','XORSyllogism',0);
/*!40000 ALTER TABLE `argschemes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `claim`
--

DROP TABLE IF EXISTS `claim`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `claim` (
  `claim_id` int(11) NOT NULL AUTO_INCREMENT,
  `claim_text` text NOT NULL,
  `x` int(11) NOT NULL,
  `y` int(11) NOT NULL,
  `claim_map_id` int(11) NOT NULL,
  `claim_index` int(11) NOT NULL,
  `id` int(11) DEFAULT NULL,
  PRIMARY KEY (`claim_id`),
  KEY `is_part_of_map` (`claim_map_id`),
  KEY `makes_claim` (`id`),
  CONSTRAINT `is_part_of_map` FOREIGN KEY (`claim_map_id`) REFERENCES `maps` (`map_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `makes_claim` FOREIGN KEY (`id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `claim`
--

LOCK TABLES `claim` WRITE;
/*!40000 ALTER TABLE `claim` DISABLE KEYS */;
/*!40000 ALTER TABLE `claim` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inference`
--

DROP TABLE IF EXISTS `inference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inference` (
  `inference_id` int(11) NOT NULL AUTO_INCREMENT,
  `inference_text` text NOT NULL,
  `arg_scheme_id` int(11) NOT NULL,
  `lang_id` int(11) NOT NULL,
  `inference_index` int(11) NOT NULL,
  `id` int(11) DEFAULT NULL,
  `map_id` int(11) DEFAULT NULL,
  `claim_index` int(11) NOT NULL,
  `x` int(11) DEFAULT NULL,
  `y` int(11) DEFAULT NULL,
  PRIMARY KEY (`inference_id`),
  KEY `defined_by_argscheme` (`arg_scheme_id`),
  KEY `defined_by_language_form` (`lang_id`),
  KEY `receives_inference` (`id`),
  KEY `is_part_of` (`map_id`),
  CONSTRAINT `defined_by_argscheme` FOREIGN KEY (`arg_scheme_id`) REFERENCES `argschemes` (`arg_scheme_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `defined_by_language_form` FOREIGN KEY (`lang_id`) REFERENCES `langtypes` (`lang_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `is_part_of` FOREIGN KEY (`map_id`) REFERENCES `maps` (`map_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `receives_inference` FOREIGN KEY (`id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inference`
--

LOCK TABLES `inference` WRITE;
/*!40000 ALTER TABLE `inference` DISABLE KEYS */;
/*!40000 ALTER TABLE `inference` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inferencedescriptor`
--

DROP TABLE IF EXISTS `inferencedescriptor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inferencedescriptor` (
  `inference_descriptor_id` int(11) NOT NULL AUTO_INCREMENT,
  `claim_id` int(11) NOT NULL,
  `reason_id` int(11) NOT NULL,
  `inference_id` int(11) NOT NULL,
  PRIMARY KEY (`inference_descriptor_id`),
  KEY `contains_claim` (`claim_id`),
  KEY `contains_reason` (`reason_id`),
  KEY `for_inference` (`inference_id`),
  CONSTRAINT `contains_claim` FOREIGN KEY (`claim_id`) REFERENCES `claim` (`claim_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `contains_reason` FOREIGN KEY (`reason_id`) REFERENCES `reason` (`reason_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `for_inference` FOREIGN KEY (`inference_id`) REFERENCES `inference` (`inference_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inferencedescriptor`
--

LOCK TABLES `inferencedescriptor` WRITE;
/*!40000 ALTER TABLE `inferencedescriptor` DISABLE KEYS */;
/*!40000 ALTER TABLE `inferencedescriptor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `langtypes`
--

DROP TABLE IF EXISTS `langtypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `langtypes` (
  `lang_id` int(11) NOT NULL AUTO_INCREMENT,
  `function_id` varchar(30) NOT NULL,
  `language_forms` text,
  `arg_scheme_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`lang_id`),
  KEY `has_language_forms` (`arg_scheme_id`),
  CONSTRAINT `has_language_forms` FOREIGN KEY (`arg_scheme_id`) REFERENCES `argschemes` (`arg_scheme_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `langtypes`
--

LOCK TABLES `langtypes` WRITE;
/*!40000 ALTER TABLE `langtypes` DISABLE KEYS */;
INSERT INTO `langtypes` VALUES (1,'ifThen','If P, then Q',1),(2,'implies','P implies Q',1),(3,'whenever','Whenever P, Q',1),(4,'onlyIf','P only if Q',1),(5,'providedThat','P provided that Q',1),(6,'sufficientCondition','P is a sufficient condition for Q',1),(7,'necessaryCondition','P is a necessary condition for Q',1),(8,'ifThen','if P, then Q',2),(9,'implies','P implies Q',2),(10,'onlyIf','P only if Q',2),(11,'whenever','Whenever P, Q',2),(12,'providedThat','P provided that Q',2),(13,'sufficientCondition','P is a sufficient condition for Q',2),(14,'necessaryCondition','P is a necessary condition for Q',2),(20,'notQ','Either P or Q, but maybe both, if you reason from not-Q',4),(21,'notP','Either P or Q, but maybe both, if you reason from not-P',4),(22,'alternateP','P unless Q, if you reason from not-P',4),(23,'alternateQ','P unless Q, if you reason from not-Q',4),(24,'notP','Not both P and Q, but maybe none of both, if you reason from P',5),(25,'notQ','Not both P and Q, but maybe none of both, if you reason from Q',5),(26,'notP','Either P or Q, but not both, if you reason from P',6),(27,'notQ','Either P or Q, but not both, if you reason from Q',6),(28,'alternateP','Either P or Q, but not both, if you reason from not-P',6),(29,'alternateQ','Either P or Q, but not both, if you reason from not-Q',6),(46,'ifOnlyIfP','P if and only if Q, if you reason from P',3),(47,'ifOnlyIfQ','P if and only if Q, if you reason from Q',3),(48,'ifOnlyIfNotP','P if and only if Q, if you reason from not-P',3),(49,'ifOnlyIfNotQ','P if and only if Q, if you reason from not-Q',3),(50,'justInCaseP','P just in case Q, if you reason from P',3),(51,'justInCaseQ','P just in case Q, if you reason from Q',3),(53,'justInCaseNotP','P just in case Q, if you reason from Not-P',3),(54,'justInCaseNotQ','P just in case Q, if you reason from Not-Q',3),(55,'necessaryP','P is a necessary and sufficient condition for Q, if you reason from P',3),(56,'necessaryQ','P is a necessary and sufficient condition for Q, if you reason from Q',3),(57,'necessaryNotP','P is a necessary and sufficient condition for Q, if you reason from not-P',3),(58,'necessaryNotQ','P is a necessary and sufficient condition for Q, if you reason from not-Q',3),(59,'equivalentP','P and Q are equivalent, if you reason from P',3),(60,'equivalentQ','P and Q are equivalent, if you reason from Q',3),(61,'equivalentNotP','P and Q are equivalent, if you reason from not-P',3),(62,'equivalentNotQ','P and Q are equivalent, if you reason from not-Q',3);
/*!40000 ALTER TABLE `langtypes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `maps`
--

DROP TABLE IF EXISTS `maps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `maps` (
  `map_id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `creation_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_modified` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id` int(11) NOT NULL,
  PRIMARY KEY (`map_id`),
  KEY `has_maps` (`id`),
  CONSTRAINT `has_maps` FOREIGN KEY (`id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maps`
--

LOCK TABLES `maps` WRITE;
/*!40000 ALTER TABLE `maps` DISABLE KEYS */;
INSERT INTO `maps` VALUES (1,'Default','2010-02-02 07:41:32','0000-00-00 00:00:00',1);
/*!40000 ALTER TABLE `maps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reason`
--

DROP TABLE IF EXISTS `reason`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reason` (
  `reason_id` int(11) NOT NULL AUTO_INCREMENT,
  `reason_text` text NOT NULL,
  `x` int(11) NOT NULL,
  `y` int(11) NOT NULL,
  `reason_map_id` int(11) NOT NULL,
  `reason_index` int(11) NOT NULL,
  `id` int(11) DEFAULT NULL,
  `claim_index` int(11) NOT NULL,
  PRIMARY KEY (`reason_id`),
  KEY `is_part_of_map_1` (`reason_map_id`),
  KEY `gives_reason` (`id`),
  CONSTRAINT `gives_reason` FOREIGN KEY (`id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `is_part_of_map_1` FOREIGN KEY (`reason_map_id`) REFERENCES `maps` (`map_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reason`
--

LOCK TABLES `reason` WRITE;
/*!40000 ALTER TABLE `reason` DISABLE KEYS */;
/*!40000 ALTER TABLE `reason` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource`
--

DROP TABLE IF EXISTS `resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource` (
  `resource_id` int(11) NOT NULL AUTO_INCREMENT,
  `resource_name` varchar(85) NOT NULL,
  `resource_type` enum('internal','external') NOT NULL,
  `resource_location` text NOT NULL,
  `claim_id` int(11) NOT NULL,
  `reason_id` int(11) NOT NULL,
  PRIMARY KEY (`resource_id`),
  KEY `has_resource` (`claim_id`),
  KEY `has_resource_1` (`reason_id`),
  CONSTRAINT `has_resource` FOREIGN KEY (`claim_id`) REFERENCES `claim` (`claim_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `has_resource_1` FOREIGN KEY (`reason_id`) REFERENCES `reason` (`reason_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource`
--

LOCK TABLES `resource` WRITE;
/*!40000 ALTER TABLE `resource` DISABLE KEYS */;
/*!40000 ALTER TABLE `resource` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `webpage` text,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(25) NOT NULL,
  `last_name` varchar(25) NOT NULL,
  `user_id` varchar(20) NOT NULL,
  `password` varchar(41) NOT NULL,
  `organization` varchar(40) DEFAULT NULL,
  `info` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UserID` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('http://cc.gatech.edu/~krangara',1,'Karthik','Rangarajan','krangarajan','76724310efafd1c7b981b657064ef15870c3db27',NULL,'Administrator'),('http://www.prism.gatech.edu/~mh327/',2,'Michael','Hoffman','mhoffman','39a44d0c0ce6d446594daea7700e8b6200719c42','Georgia Institute of Technology','Creator of Agora');
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

-- Dump completed on 2010-04-08  0:10:26
