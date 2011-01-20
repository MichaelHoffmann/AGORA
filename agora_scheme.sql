SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `agora` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `agora` ;

-- -----------------------------------------------------
-- Table `agora`.`users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `agora`.`users` ;

CREATE  TABLE IF NOT EXISTS `agora`.`users` (
  `user_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `isDeleted` TINYINT(1)  NULL DEFAULT 1 ,
  `firstName` VARCHAR(30) NULL ,
  `lastName` VARCHAR(30) NULL ,
  `userName` VARCHAR(32) NOT NULL ,
  `password` VARCHAR(32) NOT NULL ,
  `email` VARCHAR(50) NOT NULL ,
  `url` VARCHAR(50) NULL ,
  `userLevel` TINYINT(1) UNSIGNED NULL DEFAULT 1 COMMENT '1 = Standard user\n9 = Administrator' ,
  `createdDate` DATETIME NULL ,
  `lastLogin` DATETIME NULL ,
  PRIMARY KEY (`user_id`) ,
  UNIQUE INDEX `userName_UNIQUE` (`userName` ASC) ,
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) )
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci
COMMENT = 'Stores all the users';


-- -----------------------------------------------------
-- Table `agora`.`maps`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `agora`.`maps` ;

CREATE  TABLE IF NOT EXISTS `agora`.`maps` (
  `map_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` INT UNSIGNED NULL ,
  `title` VARCHAR(100) NULL ,
  `createdDate` DATETIME NULL ,
  `modifiedDate` DATETIME NULL ,
  PRIMARY KEY (`map_id`) ,
  INDEX `user_id` (`user_id` ASC) ,
  CONSTRAINT `user_id`
    FOREIGN KEY (`user_id` )
    REFERENCES `agora`.`users` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci
COMMENT = 'Stores all maps created by users';


-- -----------------------------------------------------
-- Table `agora`.`claims`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `agora`.`claims` ;

CREATE  TABLE IF NOT EXISTS `agora`.`claims` (
  `claim_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` INT UNSIGNED NOT NULL ,
  `map_id` INT UNSIGNED NULL ,
  `text` VARCHAR(45) NULL ,
  `createdDate` DATETIME NULL ,
  `modifiedDate` DATETIME NULL ,
  PRIMARY KEY (`claim_id`) ,
  INDEX `user_id` (`user_id` ASC) ,
  INDEX `map_id` (`map_id` ASC) ,
  CONSTRAINT `user_id`
    FOREIGN KEY (`user_id` )
    REFERENCES `agora`.`users` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `map_id`
    FOREIGN KEY (`map_id` )
    REFERENCES `agora`.`maps` (`map_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci
COMMENT = 'Stores the claims, the conclusions of all arguments';


-- -----------------------------------------------------
-- Table `agora`.`reasons`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `agora`.`reasons` ;

CREATE  TABLE IF NOT EXISTS `agora`.`reasons` (
  `reason_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` INT UNSIGNED NOT NULL ,
  `claim_id` INT UNSIGNED NULL ,
  `parentReason` INT UNSIGNED NULL ,
  `isUniversal` TINYINT(1)  NOT NULL ,
  `text` VARCHAR(45) NULL ,
  PRIMARY KEY (`reason_id`) ,
  INDEX `user_id` (`user_id` ASC) ,
  INDEX `claim_id` (`claim_id` ASC) ,
  INDEX `parentReason` (`parentReason` ASC) ,
  CONSTRAINT `user_id`
    FOREIGN KEY (`user_id` )
    REFERENCES `agora`.`users` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `claim_id`
    FOREIGN KEY (`claim_id` )
    REFERENCES `agora`.`claims` (`claim_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `parentReason`
    FOREIGN KEY (`parentReason` )
    REFERENCES `agora`.`reasons` (`reason_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci
COMMENT = 'Stores the reasons of all reasons and claims';


-- -----------------------------------------------------
-- Table `agora`.`argumentSchemes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `agora`.`argumentSchemes` ;

CREATE  TABLE IF NOT EXISTS `agora`.`argumentSchemes` (
  `scheme_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(30) NULL ,
  PRIMARY KEY (`scheme_id`) )
ENGINE = MyISAM
COMMENT = 'Stores the different argument schemes, e.g. modus ponens';


-- -----------------------------------------------------
-- Table `agora`.`inferenceTypes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `agora`.`inferenceTypes` ;

CREATE  TABLE IF NOT EXISTS `agora`.`inferenceTypes` (
  `type_id` INT UNSIGNED NOT NULL ,
  `typeName` VARCHAR(45) NULL ,
  PRIMARY KEY (`type_id`) )
ENGINE = MyISAM
COMMENT = 'The types of inferences (factual instantiation, et al)';


-- -----------------------------------------------------
-- Table `agora`.`inferences`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `agora`.`inferences` ;

CREATE  TABLE IF NOT EXISTS `agora`.`inferences` (
  `inference_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` INT UNSIGNED NOT NULL ,
  `scheme_id` INT UNSIGNED NULL ,
  `claim_id` INT UNSIGNED NULL ,
  `reason_id` INT UNSIGNED NULL ,
  `type_id` INT UNSIGNED NULL ,
  PRIMARY KEY (`inference_id`) ,
  INDEX `user_id` (`user_id` ASC) ,
  INDEX `claim_id` (`claim_id` ASC) ,
  INDEX `reason_id` (`reason_id` ASC) ,
  INDEX `scheme_id` (`scheme_id` ASC) ,
  INDEX `type_id` (`type_id` ASC) ,
  CONSTRAINT `user_id`
    FOREIGN KEY (`user_id` )
    REFERENCES `agora`.`users` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `claim_id`
    FOREIGN KEY (`claim_id` )
    REFERENCES `agora`.`claims` (`claim_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `reason_id`
    FOREIGN KEY (`reason_id` )
    REFERENCES `agora`.`reasons` (`reason_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `scheme_id`
    FOREIGN KEY (`scheme_id` )
    REFERENCES `agora`.`argumentSchemes` (`scheme_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `type_id`
    FOREIGN KEY (`type_id` )
    REFERENCES `agora`.`inferenceTypes` (`type_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM
COMMENT = 'Stores the \"enablers\" for all claims or reasons';


-- -----------------------------------------------------
-- Table `agora`.`objections`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `agora`.`objections` ;

CREATE  TABLE IF NOT EXISTS `agora`.`objections` (
  `objection_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` INT UNSIGNED NOT NULL ,
  `claim_id` INT UNSIGNED NULL ,
  `reason_id` INT UNSIGNED NULL ,
  `inference_id` INT UNSIGNED NULL ,
  PRIMARY KEY (`objection_id`) ,
  INDEX `user_id` (`user_id` ASC) ,
  INDEX `claim_id` (`claim_id` ASC) ,
  INDEX `reason_id` (`reason_id` ASC) ,
  INDEX `inference_id` (`inference_id` ASC) ,
  CONSTRAINT `user_id`
    FOREIGN KEY (`user_id` )
    REFERENCES `agora`.`users` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `claim_id`
    FOREIGN KEY (`claim_id` )
    REFERENCES `agora`.`claims` (`claim_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `reason_id`
    FOREIGN KEY (`reason_id` )
    REFERENCES `agora`.`reasons` (`reason_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `inference_id`
    FOREIGN KEY (`inference_id` )
    REFERENCES `agora`.`inferences` (`inference_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM
COMMENT = 'Stores all objections to claims, reasons, and inferences';


-- -----------------------------------------------------
-- Table `agora`.`comments`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `agora`.`comments` ;

CREATE  TABLE IF NOT EXISTS `agora`.`comments` (
  `comment_id` INT UNSIGNED NOT NULL ,
  `user_id` INT UNSIGNED NOT NULL ,
  `map_id` INT UNSIGNED NULL ,
  `claim_id` INT UNSIGNED NULL ,
  `reason_id` INT UNSIGNED NULL ,
  `inference_id` INT UNSIGNED NULL ,
  `objection_id` INT UNSIGNED NULL ,
  PRIMARY KEY (`comment_id`) ,
  INDEX `user_id` (`user_id` ASC) ,
  INDEX `map_id` (`map_id` ASC) ,
  INDEX `claim_id` (`claim_id` ASC) ,
  INDEX `reason_id` (`reason_id` ASC) ,
  INDEX `inference_id` (`inference_id` ASC) ,
  INDEX `objection_id` (`objection_id` ASC) ,
  CONSTRAINT `user_id`
    FOREIGN KEY (`user_id` )
    REFERENCES `agora`.`users` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `map_id`
    FOREIGN KEY (`map_id` )
    REFERENCES `agora`.`maps` (`map_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `claim_id`
    FOREIGN KEY (`claim_id` )
    REFERENCES `agora`.`claims` (`claim_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `reason_id`
    FOREIGN KEY (`reason_id` )
    REFERENCES `agora`.`reasons` (`reason_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `inference_id`
    FOREIGN KEY (`inference_id` )
    REFERENCES `agora`.`inferences` (`inference_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `objection_id`
    FOREIGN KEY (`objection_id` )
    REFERENCES `agora`.`objections` (`objection_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM
COMMENT = 'Stores comments created by users for maps, claims, reasons, inferences, and objections';


-- -----------------------------------------------------
-- Table `agora`.`activeGuests`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `agora`.`activeGuests` ;

CREATE  TABLE IF NOT EXISTS `agora`.`activeGuests` (
  `ip` VARCHAR(15) NULL ,
  `timeStamp` DATETIME NULL ,
  PRIMARY KEY (`ip`) )
ENGINE = MyISAM
COMMENT = 'For tracking guest users who\'ve yet to login';


-- -----------------------------------------------------
-- Table `agora`.`activeUsers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `agora`.`activeUsers` ;

CREATE  TABLE IF NOT EXISTS `agora`.`activeUsers` (
  `user_id` INT UNSIGNED NOT NULL ,
  `timeStamp` DATETIME NULL ,
  PRIMARY KEY (`user_id`) ,
  INDEX `user_id` (`user_id` ASC) ,
  CONSTRAINT `user_id`
    FOREIGN KEY (`user_id` )
    REFERENCES `agora`.`users` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM
COMMENT = 'For tracking users who are logged in';


-- -----------------------------------------------------
-- Table `agora`.`bannedUsers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `agora`.`bannedUsers` ;

CREATE  TABLE IF NOT EXISTS `agora`.`bannedUsers` (
  `user_id` INT UNSIGNED NOT NULL ,
  `timeStamp` DATETIME NULL ,
  PRIMARY KEY (`user_id`) ,
  INDEX `user_id` (`user_id` ASC) ,
  CONSTRAINT `user_id`
    FOREIGN KEY (`user_id` )
    REFERENCES `agora`.`users` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM
COMMENT = 'Stores users forbidden from logging in or signing up';


-- -----------------------------------------------------
-- Table `agora`.`activeUsersMaps`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `agora`.`activeUsersMaps` ;

CREATE  TABLE IF NOT EXISTS `agora`.`activeUsersMaps` (
  `activeUserMap_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` INT UNSIGNED NOT NULL ,
  `map_id` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`activeUserMap_id`) ,
  INDEX `user_id` (`user_id` ASC) ,
  INDEX `map_id` (`map_id` ASC) ,
  CONSTRAINT `user_id`
    FOREIGN KEY (`user_id` )
    REFERENCES `agora`.`activeUsers` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `map_id`
    FOREIGN KEY (`map_id` )
    REFERENCES `agora`.`maps` (`map_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM
COMMENT = 'The maps being edited by active users';



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
