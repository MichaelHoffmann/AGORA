
CREATE SCHEMA IF NOT EXISTS `agora` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `agora` ;
SET storage_engine=INNODB;

DROP TABLE IF EXISTS `agora`.`connections`;
DROP TABLE IF EXISTS `agora`.`arguments`;
DROP TABLE IF EXISTS `agora`.`connectionTypes`;
DROP TABLE IF EXISTS `agora`.`nodetext`;
DROP TABLE IF EXISTS `agora`.`textboxes`;
DROP TABLE IF EXISTS `agora`.`nodes`;
DROP TABLE IF EXISTS `agora`.`nodetypes`;
DROP TABLE IF EXISTS `agora`.`maps`;
DROP TABLE IF EXISTS `agora`.`users`;

-- -----------------------------------------------------
-- Table `agora`.`users`
-- -----------------------------------------------------
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
  UNIQUE INDEX `email_UNIQUE` (`email` ASC));


-- -----------------------------------------------------
-- Table `agora`.`maps`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `agora`.`maps` (
  `map_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` INT UNSIGNED NULL ,
  `title` VARCHAR(100) NULL ,
  `description` VARCHAR(255) NULL ,
  `createdDate` DATETIME NULL ,
  `modifiedDate` DATETIME NULL ,
  PRIMARY KEY (`map_id`) ,
  INDEX `user_id` (`user_id` ASC) ,
  FOREIGN KEY (`user_id`)
    REFERENCES `agora`.`users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

-- -------------------------------------------------------
-- Table `agora`.`node_types`
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS `agora`.`node_types` (
  `nodetype_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`nodetype_id`));
	
-- -------------------------------------------------------
-- Table `agora`.`nodes`
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS `agora`.`nodes` (
  `node_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` INT UNSIGNED NOT NULL ,
  `map_id` INT UNSIGNED NULL , 
  `node_type` INT UNSIGNED NOT NULL,
  `createdDate` DATETIME NULL ,
  `modifiedDate` DATETIME NULL ,
  `x_coord` INT NOT NULL,
  `y_coord` INT NOT NULL,
  `width` INT NOT NULL,
  `height` INT NOT NULL,
  PRIMARY KEY (`node_id`) ,
  INDEX `user_id` (`user_id` ASC) ,
  INDEX `map_id` (`map_id` ASC) ,
  INDEX `node_type` (`node_type` ASC) ,
  FOREIGN KEY (`user_id`)
	REFERENCES `agora`.`users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY (`map_id`)
	REFERENCES `agora`.`maps` (`map_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY(`node_type`)
    REFERENCES `agora`.`node_types` (`nodetype_id`)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION);

-- -----------------------------------------------------
-- Table `agora`.`textboxes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `agora`.`textboxes` (
	`textbox_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`text` TEXT,
	PRIMARY KEY (`textbox_id`));

-- -----------------------------------------------------
-- Table `agora`.`nodetext`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `agora`.`nodetext` (
	`nodetext_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`node_id` INT UNSIGNED NOT NULL,
	`textbox_id` INT UNSIGNED NOT NULL,
	PRIMARY KEY (`nodetext_id`),
	INDEX `node_id` (`node_id` ASC),
	INDEX `textbox_id` (`textbox_id` ASC),
	FOREIGN KEY(`node_id`)
	  REFERENCES `agora`.`nodes` (`node_id`)
	  ON DELETE NO ACTION
	  ON UPDATE NO ACTION,
	FOREIGN KEY(`textbox_id`)
	  REFERENCES `agora`.`textboxes` (`textbox_id`)
	  ON DELETE NO ACTION
	  ON UPDATE NO ACTION);

	
-- -----------------------------------------------------
-- Table `agora`.`connectionTypes`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `agora`.`connectionTypes` (
  `type_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(60) NULL ,
  PRIMARY KEY (`type_id`));
-- Note that one of the connection types is "comments on"
-- Others include "objects to", "refutes", "proposes an amendment", etc.
-- That's why this is "connection types" and not "argument types".


-- -----------------------------------------------------
-- Table `agora`.`arguments`
-- -----------------------------------------------------

CREATE  TABLE IF NOT EXISTS `agora`.`arguments` (
  `argument_id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `map_id` INT UNSIGNED NULL,
  `node_id` INT UNSIGNED NULL ,
  `type_id` INT UNSIGNED NULL ,
  PRIMARY KEY (`argument_id`) ,
  INDEX `map_id` (`map_id` ASC) ,
  INDEX `node_id` (`node_id` ASC) ,
  INDEX `type_id` (`type_id` ASC) ,
  FOREIGN KEY (`map_id`)
    REFERENCES `agora`.`maps` (`map_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY (`node_id`)
    REFERENCES `agora`.`nodes` (`node_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY (`type_id`)
    REFERENCES `agora`.`connectionTypes` (`type_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
-- The node_id is the claim.

-- -----------------------------------------------------
-- Table `agora`.`connections`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `agora`.`connections` (
	`connection_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`argument_id` INT UNSIGNED NOT NULL,
	`node_id` INT UNSIGNED NOT NULL,
	PRIMARY KEY (`connection_id`),
	INDEX `argument_id` (`argument_id` ASC),
	INDEX `node_id` (`node_id` ASC),
	FOREIGN KEY (`argument_id`)
	  REFERENCES `agora`.`arguments` (`argument_id`)
	  ON DELETE NO ACTION
	  ON UPDATE NO ACTION,
	FOREIGN KEY (`node_id`)
	  REFERENCES `agora`.`nodes` (`node_id`)
	  ON DELETE NO ACTION
	  ON UPDATE NO ACTION);