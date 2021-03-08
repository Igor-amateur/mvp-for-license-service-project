-- MySQL dump 10.13 Distrib 5.7.30, for Linux (x86_64)
--
-- Host: localhost Database: Alex_K_DB
-- ------------------------------------------------------
-- Server version	5.7.30-0ubuntu0.18.04.1

 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT ;
 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS ;
 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION ;
 SET NAMES utf8 ;
 SET @OLD_TIME_ZONE=@@TIME_ZONE ;
 SET TIME_ZONE='+00:00' ;
 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 ;
 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 ;
 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' ;
 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 ;

--
-- Table structure for table `change_log`
--

DROP TABLE IF EXISTS `change_log`;
 SET @saved_cs_client = @@character_set_client ;
 SET character_set_client = utf8 ;
CREATE TABLE `change_log` (
 `change_in_table` varchar(48) NOT NULL,
 `change_user_id` int(11) DEFAULT NULL,
 `change_log` varchar(384) NOT NULL,
 `change_datetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
 SET character_set_client = @saved_cs_client ;

--
-- Dumping data for table `change_log`
--

LOCK TABLES `change_log` WRITE;
 ALTER TABLE `change_log` DISABLE KEYS ;
 ALTER TABLE `change_log` ENABLE KEYS ;
UNLOCK TABLES;

--
-- Table structure for table `key_s`
--

DROP TABLE IF EXISTS `key_s`;
 SET @saved_cs_client = @@character_set_client ;
 SET character_set_client = utf8 ;
CREATE TABLE `key_s` (
 `key_id` int(11) NOT NULL AUTO_INCREMENT,
 `key_license_id` int(11) NOT NULL,
 `key_user_id` int(11) NOT NULL,
 `key_license_key` varchar(128) NOT NULL,
 `key_requested` tinyint(4) NOT NULL DEFAULT '0',
 PRIMARY KEY (`key_id`,`key_license_key`),
 KEY `fk_key_user_id_idx` (`key_user_id`),
 KEY `fk_key_license_id_idx` (`key_license_id`),
 CONSTRAINT `fk_key_license_id` FOREIGN KEY (`key_license_id`) REFERENCES `license` (`license_id`) ON DELETE CASCADE ON UPDATE CASCADE,
 CONSTRAINT `fk_key_user_id` FOREIGN KEY (`key_user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
 SET character_set_client = @saved_cs_client ;

--
-- Dumping data for table `key_s`
--

LOCK TABLES `key_s` WRITE;
 ALTER TABLE `key_s` DISABLE KEYS ;
 ALTER TABLE `key_s` ENABLE KEYS ;
UNLOCK TABLES;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
 CREATE TRIGGER tr_in_key
AFTER INSERT ON key_s FOR EACH ROW
BEGIN

declare varStrLog varchar(384) DEFAULT 'Добавленные значения';
declare varStrLog_ varchar(384);

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' key_id: ', NEW.key_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' key_license_id: ', NEW.key_license_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' key_user_id: ', NEW.key_user_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' key_requested: ', NEW.key_requested);
set varStrLog = varStrLog_;
set varStrLog_ = '';

INSERT INTO change_log(change_in_table, change_user_id, change_log)
VALUES('Добавление в таблицу key_s' , NEW.key_user_id, varStrLog);

INSERT INTO change_log(change_in_table, change_user_id, change_log)
VALUES('Добавлен key_license_key' , NEW.key_user_id, NEW.key_license_key);

END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
 CREATE TRIGGER tr_up_key_b
before UPDATE ON `key_s` FOR EACH ROW
BEGIN

set@current_date = sysdate();
set@lic_status = (select license_status from license WHERE license_id = old.key_license_id);
IF (OLD.key_requested = 0 and NEW.key_requested > 0) and ('new' = @lic_status or 'extended' = @lic_status)
THEN 
update license SET license_status = 'active', license_launch_date = @current_date WHERE license_id = old.key_license_id;
END IF;

set@dur_in_mon = (select duration_in_months from license WHERE license_id = old.key_license_id);
set@result_date = (select license_launch_date from license WHERE license_id = old.key_license_id);
set@result_date_ = date_add(@result_date, interval @dur_in_mon MONTH);
IF(@result_date_ < @current_date)
THEN
update license SET license_status = 'expired', NEW.key_requested = 0 WHERE license_id = old.key_license_id;
END IF;

IF (NEW.key_requested > 1 OR NEW.key_requested < 0)
THEN 
SET NEW.key_requested = OLD.key_requested;
END IF;

END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
 CREATE TRIGGER tr_up_key
AFTER UPDATE ON key_s FOR EACH ROW
BEGIN
declare varStrLog varchar(384) DEFAULT 'Старые значения';
declare varStrLog_ varchar(384);

IF OLD.key_id <> NEW.key_id
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' key_id: ', OLD.key_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.key_license_id <> NEW.key_license_id
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' key_license_id: ', OLD.key_license_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.key_user_id <> NEW.key_user_id 
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' key_user_id: ', OLD.key_user_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;

IF OLD.key_requested <> NEW.key_requested 
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' key_requested: ', OLD.key_requested);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;

set varStrLog_ = CONCAT_WS(' ', varStrLog, 'Новые значения');
set varStrLog = varStrLog_;
set varStrLog_ = '';

IF OLD.key_id <> NEW.key_id
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' key_id: ', NEW.key_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.key_license_id <> NEW.key_license_id
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' key_license_id: ', NEW.key_license_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.key_user_id <> NEW.key_user_id 
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' key_user_id: ', NEW.key_user_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.key_requested <> NEW.key_requested 
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' key_requested: ', NEW.key_requested);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;

INSERT INTO change_log(change_in_table, change_user_id, change_log) 
VALUES('Внесение изменений в таблицу key_s', NEW.key_user_id, varStrLog);


IF OLD.key_license_key <> NEW.key_license_key
THEN

set varStrLog = CONCAT_WS(' ' , ' key_license_key: ', OLD.key_license_key);

INSERT INTO change_log(change_in_table, change_user_id, change_log) 
VALUES('Старое значение ключа в key_s', NEW.key_user_id, varStrLog);


set varStrLog = CONCAT_WS(' ', ' key_license_key: ', NEW.key_license_key);

INSERT INTO change_log(change_in_table, change_user_id, change_log) 
VALUES('Новое значение ключа в key_s', NEW.key_user_id, varStrLog);

END IF;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
 CREATE TRIGGER tr_de_key
AFTER DELETE ON key_s FOR EACH ROW
BEGIN
declare varStrLog varchar(384) DEFAULT 'Удаленные значения';
declare varStrLog_ varchar(384);

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' key_id: ', OLD.key_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' key_license_id: ', OLD.key_license_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' key_user_id: ', OLD.key_user_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' key_license_key: ', OLD.key_license_key);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' key_requested: ', OLD.key_requested);
set varStrLog = varStrLog_;
set varStrLog_ = '';

INSERT INTO change_log(change_in_table, change_user_id, change_log)
VALUES('Удаление из таблицы key_s' , OLD.key_user_id, varStrLog);

INSERT INTO change_log(change_in_table, change_user_id, change_log)
VALUES('Удален key_license_key' , OLD.key_user_id, OLD.key_license_key);

END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;

--
-- Table structure for table `license`
--

DROP TABLE IF EXISTS `license`;
 SET @saved_cs_client = @@character_set_client ;
 SET character_set_client = utf8 ;
CREATE TABLE `license` (
 `license_id` int(11) NOT NULL AUTO_INCREMENT,
 `license_user_id` int(11) NOT NULL,
 `license_order_id` int(11) NOT NULL,
 `license_status` varchar(16) NOT NULL DEFAULT 'new',
 `users_number` tinyint(4) NOT NULL DEFAULT '1',
 `duration_in_months` tinyint(4) NOT NULL DEFAULT '1',
 `license_launch_date` datetime DEFAULT NULL,
 PRIMARY KEY (`license_id`),
 KEY `fk_license_user_id_idx` (`license_user_id`),
 KEY `fk_license_status_idx` (`license_status`),
 KEY `fk_license_order_id_idx` (`license_order_id`),
 CONSTRAINT `fk_license_order_id` FOREIGN KEY (`license_order_id`) REFERENCES `order` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE,
 CONSTRAINT `fk_license_status` FOREIGN KEY (`license_status`) REFERENCES `license_status` (`status_name`) ON DELETE NO ACTION ON UPDATE NO ACTION,
 CONSTRAINT `fk_license_user_id` FOREIGN KEY (`license_user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1536672345 DEFAULT CHARSET=utf8;
 SET character_set_client = @saved_cs_client ;

--
-- Dumping data for table `license`
--

LOCK TABLES `license` WRITE;
 ALTER TABLE `license` DISABLE KEYS ;
 ALTER TABLE `license` ENABLE KEYS ;
UNLOCK TABLES;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
 CREATE TRIGGER tr_in_license
AFTER INSERT ON license FOR EACH ROW
BEGIN

declare varStrLog varchar(256) DEFAULT 'Добавленные значения';
declare varStrLog_ varchar(256);

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' license_id: ', NEW.license_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' license_user_id: ', NEW.license_user_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' license_status: ', NEW.license_status);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' users_number: ', NEW.users_number);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' duration_in_months: ', NEW.duration_in_months);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' license_launch_date: ', NEW.license_launch_date);
set varStrLog = varStrLog_;
set varStrLog_ = '';

INSERT INTO change_log(change_in_table, change_user_id, change_log)
VALUES('Добавление в таблицу license' , NEW.license_user_id, varStrLog);

END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
 CREATE TRIGGER tr_up_license
AFTER UPDATE ON license FOR EACH ROW
BEGIN
declare varStrLog varchar(256) DEFAULT 'Старые значения';
declare varStrLog_ varchar(256);
IF OLD.license_id <> NEW.license_id
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' license_id: ', OLD.license_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.license_user_id <> NEW.license_user_id
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' license_user_id: ', OLD.license_user_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.license_status <> NEW.license_status 
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' license_status: ', OLD.license_status);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.users_number <> NEW.users_number
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' users_number: ', OLD.users_number);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.duration_in_months <> NEW.duration_in_months 
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' duration_in_months: ', OLD.duration_in_months);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.license_launch_date <> NEW.license_launch_date
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' license_launch_date: ', OLD.license_launch_date);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
-- ---------------------------------------------
set varStrLog_ = CONCAT_WS(' ', varStrLog, 'Новые значения');
set varStrLog = varStrLog_;
set varStrLog_ = '';
-- ----------------------------------------------
IF OLD.license_id <> NEW.license_id
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' license_id: ', NEW.license_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.license_user_id <> NEW.license_user_id
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' license_user_id: ', NEW.license_user_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.license_status <> NEW.license_status 
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' license_status: ', NEW.license_status);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.users_number <> NEW.users_number
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' users_number: ', NEW.users_number);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.duration_in_months <> NEW.duration_in_months 
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' duration_in_months: ', NEW.duration_in_months);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.license_launch_date <> NEW.license_launch_date
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' license_launch_date: ', NEW.license_launch_date);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;

INSERT INTO change_log(change_in_table, change_user_id, change_log) 
VALUES('Внесение изменений в таблицу license', NEW.license_user_id, varStrLog);

END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
 CREATE TRIGGER tr_de_license
AFTER DELETE ON license FOR EACH ROW
BEGIN
declare varStrLog varchar(256) DEFAULT 'Удаленные значения';
declare varStrLog_ varchar(256);

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' license_id: ', OLD.license_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' license_user_id: ', OLD.license_user_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' license_status: ', OLD.license_status);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' users_number: ', OLD.users_number);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' duration_in_months: ', OLD.duration_in_months);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' license_launch_date: ', OLD.license_launch_date);
set varStrLog = varStrLog_;
set varStrLog_ = '';

INSERT INTO change_log(change_in_table, change_user_id, change_log)
VALUES('Удаление из таблицы license' , OLD.license_user_id, varStrLog);
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;

--
-- Table structure for table `license_status`
--

DROP TABLE IF EXISTS `license_status`;
 SET @saved_cs_client = @@character_set_client ;
 SET character_set_client = utf8 ;
CREATE TABLE `license_status` (
 `status_name` varchar(16) NOT NULL,
 `status_log` varchar(256) DEFAULT 'null',
 UNIQUE KEY `status_name_UNIQUE` (`status_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
 SET character_set_client = @saved_cs_client ;

--
-- Dumping data for table `license_status`
--

LOCK TABLES `license_status` WRITE;
 ALTER TABLE `license_status` DISABLE KEYS ;
INSERT INTO `license_status` VALUES ('active','This license is activated.'),('expired','This license has expired.'),('extended','This license has been renewed.'),('new','This license is valid but not activated.');
 ALTER TABLE `license_status` ENABLE KEYS ;
UNLOCK TABLES;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
 CREATE TRIGGER tr_in_license_status
AFTER INSERT ON license_status FOR EACH ROW
BEGIN
INSERT INTO change_log(change_in_table, change_log) 
VALUES('Добавление в таблицу order_status', 
CONCAT_WS(' ', 'Добавленные значения status_name: ', NEW.status_name, ' status_log: ' , NEW.status_log));
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
 CREATE TRIGGER tr_up_license_status
AFTER UPDATE ON license_status FOR EACH ROW
BEGIN
IF OLD.status_name <> NEW.status_name OR OLD.status_log <> NEW.status_log
THEN INSERT INTO change_log(change_in_table, change_log) 
VALUES('Внесение изменений в таблицу order_status', 
CONCAT_WS(' ', 'Старые значения status_name: ', OLD.status_name, ' status_log: ' , OLD.status_log, ' ', 
'Новые значения status_name: ', NEW.status_name, ' status_log: ' , NEW.status_log));
END IF;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
 CREATE TRIGGER tr_de_license_status
AFTER DELETE ON license_status FOR EACH ROW
BEGIN
INSERT INTO change_log(change_in_table, change_log) 
VALUES('Удаление из таблицы order_status', 
CONCAT_WS(' ', 'Удаленные значения status_name: ', OLD.status_name, ' status_log: ' , OLD.status_log));
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;

--
-- Table structure for table `order`
--

DROP TABLE IF EXISTS `order`;
 SET @saved_cs_client = @@character_set_client ;
 SET character_set_client = utf8 ;
CREATE TABLE `order` (
 `order_id` int(11) NOT NULL AUTO_INCREMENT,
 `order_user_id` int(11) NOT NULL,
 `order_license_id` int(11) DEFAULT '0',
 `order_date` datetime NOT NULL,
 PRIMARY KEY (`order_id`),
 KEY `fk_order_user_id_idx` (`order_user_id`),
 CONSTRAINT `fk_order_user_id` FOREIGN KEY (`order_user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
 SET character_set_client = @saved_cs_client ;

--
-- Dumping data for table `order`
--

LOCK TABLES `order` WRITE;
 ALTER TABLE `order` DISABLE KEYS ;
 ALTER TABLE `order` ENABLE KEYS ;
UNLOCK TABLES;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
 CREATE TRIGGER tr_in_order
AFTER INSERT ON `order` FOR EACH ROW
BEGIN

declare varStrLog varchar(256) DEFAULT 'Добавленные значения';
declare varStrLog_ varchar(256);

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' order_id: ', NEW.order_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' order_user_id: ', NEW.order_user_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' order_date: ', NEW.order_date);
set varStrLog = varStrLog_;
set varStrLog_ = '';


INSERT INTO change_log(change_in_table, change_user_id, change_log)
VALUES('Добавление в таблицу order' , NEW.order_user_id, varStrLog);

END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
 CREATE TRIGGER tr_up_order
AFTER UPDATE ON `order` FOR EACH ROW
BEGIN
declare varStrLog varchar(256) DEFAULT 'Старые значения';
declare varStrLog_ varchar(256);
IF OLD.order_id <> NEW.order_id
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' order_id: ', OLD.order_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.order_user_id <> NEW.order_user_id
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' order_user_id: ', OLD.order_user_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.order_date <> NEW.order_date
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' order_date: ', OLD.order_date);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
-- -----------------------------------------------
set varStrLog_ = CONCAT_WS(' ', varStrLog, 'Новые значения');
set varStrLog = varStrLog_;
set varStrLog_ = '';
-- ----------------------------------------------------
IF OLD.order_id <> NEW.order_id
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' order_id: ', NEW.order_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.order_user_id <> NEW.order_user_id
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' order_user_id: ', NEW.order_user_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;
IF OLD.order_date <> NEW.order_date
THEN
set varStrLog_ = CONCAT_WS(' ', varStrLog, ' order_date: ', NEW.order_date);
set varStrLog = varStrLog_;
set varStrLog_ = '';
END IF;

INSERT INTO change_log(change_in_table, change_user_id, change_log) 
VALUES('Внесение изменений в таблицу order', NEW.order_user_id, varStrLog);

END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
 CREATE TRIGGER tr_de_order
AFTER DELETE ON `order` FOR EACH ROW
BEGIN
declare varStrLog varchar(256) DEFAULT 'Удаленные значения';
declare varStrLog_ varchar(256);

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' order_id: ', OLD.order_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' order_user_id: ', OLD.order_user_id);
set varStrLog = varStrLog_;
set varStrLog_ = '';

set varStrLog_ = CONCAT_WS(' ', varStrLog, ' order_date: ', OLD.order_date);
set varStrLog = varStrLog_;
set varStrLog_ = '';

INSERT INTO change_log(change_in_table, change_user_id, change_log)
VALUES('Удаление из таблицы order' , OLD.order_user_id, varStrLog);
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
 SET @saved_cs_client = @@character_set_client ;
 SET character_set_client = utf8 ;
CREATE TABLE `user` (
 `user_id` int(11) NOT NULL AUTO_INCREMENT,
 `user_create_date` datetime NOT NULL,
 `user_licenses_caunte` tinyint(4) NOT NULL DEFAULT '0',
 `user_change_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=514365949 DEFAULT CHARSET=utf8;
 SET character_set_client = @saved_cs_client ;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
 ALTER TABLE `user` DISABLE KEYS ;
 ALTER TABLE `user` ENABLE KEYS ;
UNLOCK TABLES;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
 CREATE TRIGGER tr_in_user
AFTER INSERT ON `user` FOR EACH ROW
BEGIN
INSERT INTO change_log(change_in_table, change_user_id, change_log) 
VALUES('Добавление в таблицу user', NEW.user_id, CONCAT_WS(' ', 'Добавленное значение user_id: ', NEW.user_id));
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
 CREATE TRIGGER tr_up_user
AFTER UPDATE ON `user` FOR EACH ROW
BEGIN
IF OLD.user_id <> NEW.user_id
THEN INSERT INTO change_log(change_in_table, change_user_id, change_log) 
VALUES('Внесение изменений в таблицу user', NEW.user_id,
CONCAT_WS(' ', 'Старое значение user_id: ', OLD.user_id, ' ', 
'Новое значение user_id: ', NEW.user_id));
END IF;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
 CREATE TRIGGER tr_de_user
AFTER DELETE ON `user` FOR EACH ROW
BEGIN
INSERT INTO change_log(change_in_table, change_user_id, change_log) 
VALUES('Удаление из таблицы user', OLD.user_id, CONCAT_WS(' ', 'Удаленное значение user_id: ', OLD.user_id));
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;

--
-- Dumping events for database 'Alex_K_DB'
--
 SET @save_time_zone= @@TIME_ZONE ;
 DROP EVENT IF EXISTS `CheckLicenseValidity` ;
DELIMITER ;;
 SET @saved_cs_client = @@character_set_client ;;
 SET @saved_cs_results = @@character_set_results ;;
 SET @saved_col_connection = @@collation_connection ;;
 SET character_set_client = utf8 ;;
 SET character_set_results = utf8 ;;
 SET collation_connection = utf8_general_ci ;;
 SET @saved_sql_mode = @@sql_mode ;;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;;
 SET @saved_time_zone = @@time_zone ;;
 SET time_zone = 'SYSTEM' ;;
 CREATE EVENT `CheckLicenseValidity` ON SCHEDULE EVERY 2 MINUTE STARTS '2020-05-07 12:02:30' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
 update Alex_K_DB.license SET license.license_status = 'expired' 
 WHERE license.license_status = 'active' and (CheckLicenseValidity_licenseId(license.license_id) = 1);
 END ;;
 SET time_zone = @saved_time_zone ;;
 SET sql_mode = @saved_sql_mode ;;
 SET character_set_client = @saved_cs_client ;;
 SET character_set_results = @saved_cs_results ;;
 SET collation_connection = @saved_col_connection ;;
 DROP EVENT IF EXISTS `DeleteExpiredLicense` ;;
DELIMITER ;;
 SET @saved_cs_client = @@character_set_client ;;
 SET @saved_cs_results = @@character_set_results ;;
 SET @saved_col_connection = @@collation_connection ;;
 SET character_set_client = utf8 ;;
 SET character_set_results = utf8 ;;
 SET collation_connection = utf8_general_ci ;;
 SET @saved_sql_mode = @@sql_mode ;;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;;
 SET @saved_time_zone = @@time_zone ;;
 SET time_zone = 'SYSTEM' ;;
 CREATE EVENT `DeleteExpiredLicense` ON SCHEDULE EVERY 5 MINUTE STARTS '2020-05-11 09:28:26' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
 -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 -- https://youtu.be/l67Y1oVJ4Qs
 -- DeleteLicense_LicenseId_UserId
 update `user` inner join license on user_id = license_user_id
 set user_licenses_caunte = user_licenses_caunte - 1
 where user_licenses_caunte > 0 and license.license_status = 'expired' 
 and (CheckLicenseExpiredTime_licenseId_Months(license.license_id, 1) = 1);
 
 delete from Alex_K_DB.license WHERE license.license_status = 'expired' 
 and (CheckLicenseExpiredTime_licenseId_Months(license.license_id, 1) = 1);
 -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 END ;;
 SET time_zone = @saved_time_zone ;;
 SET sql_mode = @saved_sql_mode ;;
 SET character_set_client = @saved_cs_client ;;
 SET character_set_results = @saved_cs_results ;;
 SET collation_connection = @saved_col_connection ;;
 DROP EVENT IF EXISTS `DeleteNotActiveUser` ;;
DELIMITER ;;
 SET @saved_cs_client = @@character_set_client ;;
 SET @saved_cs_results = @@character_set_results ;;
 SET @saved_col_connection = @@collation_connection ;;
 SET character_set_client = utf8 ;;
 SET character_set_results = utf8 ;;
 SET collation_connection = utf8_general_ci ;;
 SET @saved_sql_mode = @@sql_mode ;;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;;
 SET @saved_time_zone = @@time_zone ;;
 SET time_zone = 'SYSTEM' ;;
 CREATE EVENT `DeleteNotActiveUser` ON SCHEDULE EVERY 5 MINUTE STARTS '2020-05-09 20:35:21' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN

 delete `user` from `user` left join license on user_id = license_user_id where license_user_id is null
 and (sysdate() > (select date_add(user_change_date, interval 1 MONTH)));
 
 END ;;
 SET time_zone = @saved_time_zone ;;
 SET sql_mode = @saved_sql_mode ;;
 SET character_set_client = @saved_cs_client ;;
 SET character_set_results = @saved_cs_results ;;
 SET collation_connection = @saved_col_connection ;;
DELIMITER ;
 SET TIME_ZONE= @save_time_zone ;

--
-- Dumping routines for database 'Alex_K_DB'
--
 DROP FUNCTION IF EXISTS `ActiveKeyCheck_UserId_kEY` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `ActiveKeyCheck_UserId_kEY`(p_UserId int(11), p_kEY varchar(128)) RETURNS int(11)
BEGIN

DECLARE t_license_id int(11) default 0;
DECLARE t_result int(11) default 0;
SET t_result = (SELECT count(*) FROM key_s where key_user_id = p_UserId and key_license_key = p_kEY);

if 0 = t_result
then
return 0;
end if;

set t_result = (SELECT key_requested FROM key_s where key_license_key = p_kEY);

if t_result = 0
then
return 0;
end if;

set t_license_id = (select key_license_id from key_s where key_license_key = p_kEY and key_user_id = p_UserId);

set@_result = (SELECT license_status FROM license where license_id = t_license_id);

if @_result = 'active'
then
RETURN t_license_id;
end if;

update key_s set key_requested = 0 where key_license_id = t_license_id;

return 0;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `AddNew_UserId_UsersNumber_DurMonths` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `AddNew_UserId_UsersNumber_DurMonths`(p_UserId INTEGER, p_UsersNumber tinyint, p_DurMonths tinyint) RETURNS double
BEGIN

DECLARE t_UserId INTEGER(11) default 0;
DECLARE t_licenseId REAL default t_UserId;
DECLARE t_orderId INTEGER(11) default 0;
DECLARE t_iter INTEGER(11) default 0;
DECLARE t_KeyId INTEGER(11) default 0;
declare t_iterror integer default 0;

set t_UserId = AddToUser_UserId(p_UserId);

IF t_UserId = 0 
THEN
return 0;-- user id existe then return ziro
END IF;



M1: loop 
set t_orderId = AddToOrder_UserId(t_UserId);
IF t_orderId = 0 and t_iter < 10
then
set@i = t_iter;
set t_iter = @i + 1;
iterate M1;
else
LEAVE M1;
end if;
end loop M1;

if t_orderId = 0 then return t_UserId; end if;


set t_iter = 0;

M2: loop 
set t_licenseId = AddToLicense_userId_orderId_usersNumber_durationInMonths(p_UserId, t_orderId, p_UsersNumber, p_DurMonths);

IF t_licenseId = 0 and t_iter < 10 
then
set@i = t_iter;
set t_iter = @i + 1;
iterate M2;
else
LEAVE M2;
end if;
end loop M2;

if t_licenseId = 0 then 
return t_UserId; 
end if;

-- ===================================================================================
set t_iter = 0;

M4: loop
if t_iter > 10 then LEAVE M4; end if;
set@result = (select AddUserLicensesCaunt_UserId(p_UserId));
if @result = TRUE
THEN
LEAVE M4;
ELSE
set@t_iter_ = t_iter;
set t_iter = t_iter_ + 1;
iterate M4;
END IF;
end loop M4;
-- ===================================================================================

set t_iter = 0;
SET t_iterror = 0;
M3: loop
set t_KeyId = AddToKey_UserId_licenseId(t_UserId, t_licenseId);
if t_KeyId = 0 and t_iterror < 30
then
set@_i = t_iterror;
set t_iterror = @_i + 1;
iterate M3;
else
set t_iterror = 0;
set@_i_ = t_iter;
set t_iter = @_i_ + 1;
if t_iter < p_UsersNumber then iterate M3; else LEAVE M3; end if;
end if;

end loop M3;
-- ----------------------------------------

RETURN t_licenseId;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `AddToKey_UserId_licenseId` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `AddToKey_UserId_licenseId`(p_UserId INTEGER, p_licenseId INTEGER) RETURNS double
BEGIN
DECLARE t_orderId real default 0;
DECLARE t_sha_key varchar(128);
DECLARE lv_error_value INT DEFAULT FALSE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET lv_error_value := TRUE; 

set t_sha_key = SHA2(CONCAT(sysdate(), RAND(), UUID()), 512);
INSERT key_s(key_license_id,key_user_id, key_license_key)
VALUES (p_licenseId, p_UserId, t_sha_key);
IF lv_error_value = TRUE 
THEN
set t_orderId := 0; -- user id existe then return ziro
else
set t_orderId := LAST_INSERT_ID();
END IF;
return t_orderId;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `AddToLicense_userId_orderId_usersNumber_durationInMonths` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `AddToLicense_userId_orderId_usersNumber_durationInMonths`(p_UserId INTEGER, p_OrderId INTEGER, p_UsersNumber TINYINT, p_DurationInMonths TINYINT) RETURNS double
BEGIN
DECLARE t_licenseId REAL;
DECLARE lv_error_value INT DEFAULT FALSE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET lv_error_value := TRUE;

set t_licenseId = FLOOR(1000 + RAND() * 2147483647);

INSERT license(license_id, license_user_id, license_order_id, users_number, duration_in_months) 
VALUES(t_licenseId, p_UserId, p_OrderId, p_UsersNumber, p_DurationInMonths);
IF lv_error_value = TRUE 
THEN
set t_licenseId := 0; -- user id existe then return ziro
END IF;
return t_licenseId;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `AddToOrder_UserId` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `AddToOrder_UserId`(p_UserId INTEGER) RETURNS double
BEGIN
DECLARE t_orderId REAL default p_UserId;
DECLARE lv_error_value INT DEFAULT FALSE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET lv_error_value := TRUE; 

INSERT `order`(order_user_id, order_date) VALUES(p_UserId, sysdate());
IF lv_error_value = TRUE 
THEN
set t_orderId := 0; -- user id existe then return ziro
else
set t_orderId := LAST_INSERT_ID();
END IF;
return t_orderId;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `AddToUser_UserId` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `AddToUser_UserId`(p_UserId INTEGER) RETURNS double
BEGIN
DECLARE t_userId REAL default p_UserId;
DECLARE lv_error_value INT DEFAULT FALSE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET lv_error_value := TRUE; 

INSERT `user`(user_id, user_create_date) VALUES(p_UserId, sysdate());
IF lv_error_value = TRUE 
THEN
set t_userId := 0; -- user id existe then return ziro
END IF;
return t_userId;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `AddUserLicensesCaunt_UserId` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `AddUserLicensesCaunt_UserId`(p_UserId INTEGER) RETURNS tinyint(1)
BEGIN
DECLARE t_count INTEGER default (select user_licenses_caunte from `user` where user_id = p_UserId);
DECLARE lv_error_value INT DEFAULT FALSE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET lv_error_value := TRUE; 

update `user` set user_licenses_caunte = t_count + 1 where user_id = p_UserId;
IF lv_error_value = TRUE 
THEN
RETURN FALSE;
END IF;
RETURN TRUE;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `CheckLicenseExpiredTime_licenseId_Months` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `CheckLicenseExpiredTime_licenseId_Months`(p_licenseId int(11), p_Months int) RETURNS int(1)
BEGIN
set@current_date = sysdate();
set@dur_in_mon = (select duration_in_months from license WHERE license_id = p_licenseId);
set@result_date = (select license_launch_date from license WHERE license_id = p_licenseId);
set@result_date_ = date_add(@result_date, interval @dur_in_mon MONTH);
set@result_date = date_add(@result_date_, interval p_Months MONTH);
IF(@result_date < @current_date)
THEN
return 1;
END IF;
return 0;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `CheckLicenseStatus_licenseId` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `CheckLicenseStatus_licenseId`(p_licenseId int(11)) RETURNS int(11)
BEGIN
set@license_status = (select license_status from license WHERE license_id = p_licenseId);
IF(@license_status = 'expired' )
THEN
return p_licenseId;
END IF;
return 0;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `CheckLicenseValidity_licenseId` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `CheckLicenseValidity_licenseId`(p_licenseId int(11)) RETURNS int(1)
BEGIN
set@current_date = sysdate();
set@dur_in_mon = (select duration_in_months from license WHERE license_id = p_licenseId);
set@result_date = (select license_launch_date from license WHERE license_id = p_licenseId);
set@result_date_ = date_add(@result_date, interval @dur_in_mon MONTH);
IF(@result_date_ < @current_date)
THEN
-- update key_s set key_requested = 0 where key_license_id = p_licenseId;
return 1;
END IF;
return 0;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `DeleteLicense_LicenseId_UserId` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `DeleteLicense_LicenseId_UserId`(p_LicenseId INTEGER, p_UserId INTEGER) RETURNS int(11)
BEGIN

if (select license_status from license where license_id = p_LicenseId) = 'expired'
then
return RemoveLicense_LicenseId_UserId (p_LicenseId, p_UserId);
else
RETURN 0;
end if;
RETURN 0;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `DeleteUser_UserId` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `DeleteUser_UserId`(p_UserId INTEGER) RETURNS int(11)
BEGIN

DECLARE t_result int default 0;
DECLARE lv_error_value INT DEFAULT FALSE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET lv_error_value := TRUE;

set t_result = (select count(*) from `user` where user_id = p_UserId);
if t_result = 0 then
return 0;
end if;

set t_result = (select count(*) from license where license_user_id = p_UserId and 
(license_status = 'new' or license_status = 'active' or license_status= 'extended'));

if t_result > 0 then
return (select license_id from license where license_user_id = p_UserId and 
(license_status = 'new' or license_status = 'active' or license_status= 'extended') 
limit 1);
end if;

delete from user where user_id = p_UserId;
IF lv_error_value = TRUE
THEN
RETURN 0;
END IF;
RETURN p_UserId;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `KeyReplacement_LicenseId_UserId_Key` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `KeyReplacement_LicenseId_UserId_Key`(p_LicenseId INTEGER, p_UserId INTEGER, p_Key varchar(128)) RETURNS varchar(128) CHARSET utf8
BEGIN

DECLARE t_key_id int(11) default 0;
DECLARE t_sha_key varchar(128);


set t_key_id = (select key_s.key_id from key_s 
where key_license_id = p_LicenseId and key_user_id = p_UserId and key_license_key = p_Key);

if t_key_id = null then
return 101;
end if;

set t_sha_key = SHA2(CONCAT(sysdate(), RAND(), UUID()), 512);
begin
DECLARE lv_error_value INT DEFAULT FALSE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET lv_error_value := TRUE;
update key_s set key_license_key = t_sha_key where key_id = t_key_id;
IF lv_error_value = TRUE
THEN
return 102;
RETURN (select key_license_key FROM key_s 
where key_license_id = p_LicenseId and key_user_id = p_UserId and key_license_key = p_Key);
END IF;
end;
RETURN t_sha_key;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `LicenseRenewal_LicenseId_UserId_DurMonths` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `LicenseRenewal_LicenseId_UserId_DurMonths`(p_LicenseId INTEGER, p_UserId INTEGER, p_DurMonths tinyint) RETURNS double
BEGIN

DECLARE t_licenseId REAL default p_LicenseId;
declare t_status varchar(16);

set@_license = (select count(*) from license where license_id = p_LicenseId and license_user_id = p_UserId);

IF @_license = 0 
THEN
return 0;-- user id or license not existe then return ziro
END IF;

set t_status = (select license_status from license where license_id = p_LicenseId and license_user_id = p_UserId);

if t_status = 'new'or t_status = 'active'or t_status = 'extended'
then
set@_months = (select duration_in_months from license where license_id = p_LicenseId and license_user_id = p_UserId);
update license set duration_in_months = (@_months + p_DurMonths) 
where license_id = p_LicenseId and license_user_id = p_UserId;
else
update license set duration_in_months = p_DurMonths, license_status = 'extended' , license_launch_date = null
where license_id = p_LicenseId and license_user_id = p_UserId;
end if;

insert `order`(order_user_id, order_license_id, order_date) 
values( p_UserId, p_LicenseId, sysdate());

RETURN t_licenseId;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `NewLicenseForUser_UserId_UsersNumber_DurMonths` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `NewLicenseForUser_UserId_UsersNumber_DurMonths`(p_UserId INTEGER, p_UsersNumber tinyint, p_DurMonths tinyint) RETURNS double
BEGIN

DECLARE t_UserId INTEGER(11) default 0;
DECLARE t_licenseId REAL default t_UserId;
DECLARE t_orderId INTEGER(11) default 0;
DECLARE t_iter INTEGER(11) default 0;
DECLARE t_KeyId INTEGER(11) default 0;
declare t_iterror integer default 0;

set t_UserId = (select count(*) from `user` where user_id = p_UserId);

IF t_UserId = 0 
THEN
return 0;-- user id existe then return ziro
END IF;

set t_UserId = p_UserId;

M1: loop 
set t_orderId = AddToOrder_UserId(t_UserId);
IF t_orderId = 0 and t_iter < 10
then
set@i = t_iter;
set t_iter = @i + 1;
iterate M1;
else
LEAVE M1;
end if;
end loop M1;

if t_orderId = 0 then return t_UserId; end if;


set t_iter = 0;

M2: loop 
set t_licenseId = AddToLicense_userId_orderId_usersNumber_durationInMonths(p_UserId, t_orderId, p_UsersNumber, p_DurMonths);

IF t_licenseId = 0 and t_iter < 10 
then
set@i = t_iter;
set t_iter = @i + 1;
iterate M2;
else
LEAVE M2;
end if;
end loop M2;

if t_licenseId = 0 then 
return t_UserId; 
end if;

set t_iter = 0;

M3: loop
set t_KeyId = AddToKey_UserId_licenseId(t_UserId, t_licenseId);
if t_KeyId = 0 and t_iterror < 30
then
set@_i = t_iterror;
set t_iterror = @_i + 1;
iterate M3;
else
set t_iterror = 0;
set@_i_ = t_iter;
set t_iter = @_i_ + 1;
if t_iter < p_UsersNumber then iterate M3; else LEAVE M3; end if;
end if;

end loop M3;

set t_iter = 0;

M4: loop
if t_iter > 10 then LEAVE M4; end if;
set@result = (select AddUserLicensesCaunt_UserId(p_UserId));
if @result = TRUE
THEN
LEAVE M4;
ELSE
set@t_iter_ = t_iter;
set t_iter = t_iter_ + 1;
iterate M4;
END IF;
end loop M4;

RETURN t_licenseId;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `NewLicenseToOrderFor_UserId_OrderId_UsersNumber_DurMonths` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `NewLicenseToOrderFor_UserId_OrderId_UsersNumber_DurMonths`(p_UserId INTEGER, p_OrderId INTEGER, p_UsersNumber tinyint, p_DurMonths tinyint) RETURNS double
BEGIN

DECLARE t_UserId INTEGER(11) default 0;
DECLARE t_licenseId REAL default t_UserId;
DECLARE t_orderId INTEGER(11) default 0;
DECLARE t_iter INTEGER(11) default 0;
DECLARE t_KeyId INTEGER(11) default 0;
declare t_iterror integer default 0;

set t_UserId = (select count(*) from `user` where user_id = p_UserId);

IF t_UserId = 0 
THEN
return 0;-- user id existe then return ziro
END IF;

set t_UserId = p_UserId;


set t_orderId = (select count(*) from `order` where order_id = p_OrderId);

if t_orderId = 0 then return t_UserId; end if;

set t_orderId = p_OrderId;

set t_iter = 0;

M2: loop 
set t_licenseId = AddToLicense_userId_orderId_usersNumber_durationInMonths(p_UserId, t_orderId, p_UsersNumber, p_DurMonths);

IF t_licenseId = 0 and t_iter < 10 
then
set@i = t_iter;
set t_iter = @i + 1;
iterate M2;
else
LEAVE M2;
end if;
end loop M2;

if t_licenseId = 0 then 
return t_UserId; 
end if;

set t_iter = 0;

M3: loop
set t_KeyId = AddToKey_UserId_licenseId(t_UserId, t_licenseId);
if t_KeyId = 0 and t_iterror < 30
then
set@_i = t_iterror;
set t_iterror = @_i + 1;
iterate M3;
else
set t_iterror = 0;
set@_i_ = t_iter;
set t_iter = @_i_ + 1;
if t_iter < p_UsersNumber then iterate M3; else LEAVE M3; end if;
end if;

end loop M3;

RETURN t_licenseId;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `ReleaseKey_UserId_Key` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `ReleaseKey_UserId_Key`(p_UserId int(11), p_kEY varchar(128)) RETURNS int(11)
BEGIN


DECLARE t_license_id int(11) default 0;
DECLARE t_result int(11) default 0;

SET t_result = (select count(*) from key_s where key_license_key = p_kEY and key_user_id = p_UserId);
if t_result = 0
then
return 0;
end if;

set t_result = (SELECT key_requested FROM key_s where key_license_key = p_kEY);

if t_result = 0
then
return 0;
end if;

SET t_license_id = (select key_license_id from key_s where key_license_key = p_kEY and key_user_id = p_UserId);

BEGIN
DECLARE lv_error_value INT DEFAULT FALSE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET lv_error_value := TRUE;
UPDATE `Alex_K_DB`.`key_s` SET `key_requested`='0' WHERE `key_user_id` = p_UserId and`key_license_key`= p_kEY;
IF lv_error_value = TRUE
THEN
RETURN 0;
else
return t_license_id;
END IF;
END;

RETURN 0;

END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `RemoveLicense_LicenseId_UserId` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `RemoveLicense_LicenseId_UserId`(p_LicenseId INTEGER, p_UserId INTEGER) RETURNS int(11)
BEGIN

set@license_count = (select count(*) from license where license_id = p_LicenseId and license_user_id = p_UserId);
if(@license_count > 0) then
begin
DECLARE lv_error_value INT DEFAULT FALSE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET lv_error_value := TRUE;
delete from license where license_id = p_LicenseId and license_user_id = p_UserId;
IF lv_error_value = TRUE
THEN
RETURN 0;
END IF;
end;
else 
return 0;
end if;

set@_licenses_caunte = (select user_licenses_caunte from `user` where user_id = p_UserId);
if @_licenses_caunte > 0 then
update `user` set user_licenses_caunte = @_licenses_caunte - 1 where user_id = p_UserId;
end if;


RETURN p_LicenseId;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 DROP FUNCTION IF EXISTS `RequestKey_UserId_Key` ;
 SET @saved_cs_client = @@character_set_client ;
 SET @saved_cs_results = @@character_set_results ;
 SET @saved_col_connection = @@collation_connection ;
 SET character_set_client = utf8 ;
 SET character_set_results = utf8 ;
 SET collation_connection = utf8_general_ci ;
 SET @saved_sql_mode = @@sql_mode ;
 SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' ;
DELIMITER ;;
CREATE FUNCTION `RequestKey_UserId_Key`(p_UserId int(11), p_kEY varchar(128)) RETURNS int(11)
BEGIN

DECLARE t_license_id int(11) default 0;
DECLARE t_result int(11) default 0;

SET t_result = (select count(*) from key_s where key_license_key = p_kEY and key_user_id = p_UserId);
if t_result = 0
then
return 0;
end if;

SET t_license_id = (select key_license_id from key_s where key_license_key = p_kEY and key_user_id = p_UserId);


set@_result = (select license_status from license where license_id = t_license_id);

if @_result = 'expired'
then
RETURN 0;
end if;

set t_result = (SELECT key_requested FROM key_s where key_license_key = p_kEY);

if t_result = 1
then
return 0;
end if;


BEGIN
DECLARE lv_error_value INT DEFAULT FALSE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET lv_error_value := TRUE;
update key_s set key_requested = 1
where key_license_key = p_kEY and key_user_id = p_UserId;
IF lv_error_value = TRUE
THEN
RETURN 0;
else
return t_license_id;
END IF;
END;

RETURN 0;
END ;;
DELIMITER ;
 SET sql_mode = @saved_sql_mode ;
 SET character_set_client = @saved_cs_client ;
 SET character_set_results = @saved_cs_results ;
 SET collation_connection = @saved_col_connection ;
 SET TIME_ZONE=@OLD_TIME_ZONE ;

 SET SQL_MODE=@OLD_SQL_MODE ;
 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS ;
 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS ;
 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT ;
 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS ;
 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION ;
 SET SQL_NOTES=@OLD_SQL_NOTES ;

-- Dump completed on 2020-07-14 8:41:11
