
CREATE SCHEMA IF NOT EXISTS connectionTypesagoraconnectionTypes DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE connectionTypesagoraconnectionTypes ;
SET storage_engine=INNODB;

DROP TABLE IF EXISTS connectionTypesagoraconnectionTypes.connectionTypesconnectionsconnectionTypes;
DROP TABLE IF EXISTS connectionTypesagoraconnectionTypes.connectionTypesargumentsconnectionTypes;
DROP TABLE IF EXISTS connectionTypesagoraconnectionTypes.connectionTypesconnection_typesconnectionTypes;
DROP TABLE IF EXISTS connectionTypesagoraconnectionTypes.connectionTypesnodetextconnectionTypes;
DROP TABLE IF EXISTS connectionTypesagoraconnectionTypes.connectionTypestextboxesconnectionTypes;
DROP TABLE IF EXISTS connectionTypesagoraconnectionTypes.connectionTypesnodesconnectionTypes;
DROP TABLE IF EXISTS connectionTypesagoraconnectionTypes.connectionTypesnodetypesconnectionTypes;
DROP TABLE IF EXISTS connectionTypesagoraconnectionTypes.connectionTypesmapsconnectionTypes;
DROP TABLE IF EXISTS connectionTypesagoraconnectionTypes.connectionTypesusersconnectionTypes;

-- -----------------------------------------------------
-- Table connectionTypesagoraconnectionTypes.connectionTypesusersconnectionTypes
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS connectionTypesagoraconnectionTypes.connectionTypesusersconnectionTypes (
  connectionTypesuser_idconnectionTypes INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  connectionTypesisDeletedconnectionTypes TINYINT(1)  NULL DEFAULT 1 ,
  connectionTypesfirstNameconnectionTypes VARCHAR(30) NULL ,
  connectionTypeslastNameconnectionTypes VARCHAR(30) NULL ,
  connectionTypesuserNameconnectionTypes VARCHAR(32) NOT NULL ,
  connectionTypespasswordconnectionTypes VARCHAR(32) NOT NULL ,
  connectionTypesemailconnectionTypes VARCHAR(255) NOT NULL ,
  connectionTypesurlconnectionTypes VARCHAR(255) NULL ,
  connectionTypesuserLevelconnectionTypes TINYINT(1) UNSIGNED NULL DEFAULT 1 COMMENT '1 = Standard user\n9 = Administrator' ,
  connectionTypescreatedDateconnectionTypes DATETIME NULL ,
  connectionTypeslastLoginconnectionTypes DATETIME NULL ,	
  PRIMARY KEY (connectionTypesuser_idconnectionTypes) ,
  UNIQUE INDEX connectionTypesuserName_UNIQUEconnectionTypes (connectionTypesuserNameconnectionTypes ASC) ,
  UNIQUE INDEX connectionTypesemail_UNIQUEconnectionTypes (connectionTypesemailconnectionTypes ASC));


-- -----------------------------------------------------
-- Table connectionTypesagoraconnectionTypes.connectionTypesmapsconnectionTypes
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS connectionTypesagoraconnectionTypes.connectionTypesmapsconnectionTypes (
  connectionTypesmap_idconnectionTypes INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  connectionTypesuser_idconnectionTypes INT UNSIGNED NULL ,
  connectionTypestitleconnectionTypes VARCHAR(100) NULL ,
  connectionTypesdescriptionconnectionTypes VARCHAR(255) NULL ,
  connectionTypescreatedDateconnectionTypes DATETIME NULL ,
  connectionTypesmodifiedDateconnectionTypes DATETIME NULL ,
  PRIMARY KEY (connectionTypesmap_idconnectionTypes) ,
  INDEX connectionTypesuser_idconnectionTypes (connectionTypesuser_idconnectionTypes ASC) ,
  FOREIGN KEY (connectionTypesuser_idconnectionTypes)
    REFERENCES connectionTypesagoraconnectionTypes.connectionTypesusersconnectionTypes (connectionTypesuser_idconnectionTypes)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

-- -------------------------------------------------------
-- Table connectionTypesagoraconnectionTypes.connectionTypesnode_typesconnectionTypes
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS connectionTypesagoraconnectionTypes.connectionTypesnode_typesconnectionTypes (
  connectionTypesnodetype_idconnectionTypes INT UNSIGNED NOT NULL AUTO_INCREMENT,
  connectionTypesnameconnectionTypes VARCHAR(30) NOT NULL,
  PRIMARY KEY (connectionTypesnodetype_idconnectionTypes));

INSERT INTO node_types (name) VALUES ("Standard"), ("Inference"), ("Objection"), ("Amendment"), ("Comment");
-- -------------------------------------------------------
-- Table connectionTypesagoraconnectionTypes.connectionTypesnodesconnectionTypes
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS connectionTypesagoraconnectionTypes.connectionTypesnodesconnectionTypes (
  connectionTypesnode_idconnectionTypes INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  connectionTypesuser_idconnectionTypes INT UNSIGNED NOT NULL ,
  connectionTypesmap_idconnectionTypes INT UNSIGNED NULL , 
  connectionTypesnode_typeconnectionTypes INT UNSIGNED NOT NULL,
  connectionTypescreatedDateconnectionTypes DATETIME NULL ,
  connectionTypesmodifiedDateconnectionTypes DATETIME NULL ,
  connectionTypesx_coordconnectionTypes INT NULL,
  connectionTypesy_coordconnectionTypes INT NULL,
  connectionTypeswidthconnectionTypes INT NULL,
  connectionTypesheightconnectionTypes INT NULL,
  PRIMARY KEY (connectionTypesnode_idconnectionTypes) ,
  INDEX connectionTypesuser_idconnectionTypes (connectionTypesuser_idconnectionTypes ASC) ,
  INDEX connectionTypesmap_idconnectionTypes (connectionTypesmap_idconnectionTypes ASC) ,
  INDEX connectionTypesnode_typeconnectionTypes (connectionTypesnode_typeconnectionTypes ASC) ,
  FOREIGN KEY (connectionTypesuser_idconnectionTypes)
	REFERENCES connectionTypesagoraconnectionTypes.connectionTypesusersconnectionTypes (connectionTypesuser_idconnectionTypes)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY (connectionTypesmap_idconnectionTypes)
	REFERENCES connectionTypesagoraconnectionTypes.connectionTypesmapsconnectionTypes (connectionTypesmap_idconnectionTypes)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY(connectionTypesnode_typeconnectionTypes)
    REFERENCES connectionTypesagoraconnectionTypes.connectionTypesnode_typesconnectionTypes (connectionTypesnodetype_idconnectionTypes)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION);

-- -----------------------------------------------------
-- Table connectionTypesagoraconnectionTypes.connectionTypestextboxesconnectionTypes
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS connectionTypesagoraconnectionTypes.connectionTypestextboxesconnectionTypes (
	connectionTypestextbox_idconnectionTypes INT UNSIGNED NOT NULL AUTO_INCREMENT,
	connectionTypestextconnectionTypes TEXT,
	PRIMARY KEY (connectionTypestextbox_idconnectionTypes));

-- -----------------------------------------------------
-- Table connectionTypesagoraconnectionTypes.connectionTypesnodetextconnectionTypes
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS connectionTypesagoraconnectionTypes.connectionTypesnodetextconnectionTypes (
	connectionTypesnodetext_idconnectionTypes INT UNSIGNED NOT NULL AUTO_INCREMENT,
	connectionTypesnode_idconnectionTypes INT UNSIGNED NOT NULL,
	connectionTypestextbox_idconnectionTypes INT UNSIGNED NOT NULL,
	connectionTypespositionconnectionTypes INT UNSIGNED NOT NULL,
	PRIMARY KEY (connectionTypesnodetext_idconnectionTypes),
	INDEX connectionTypesnode_idconnectionTypes (connectionTypesnode_idconnectionTypes ASC),
	INDEX connectionTypestextbox_idconnectionTypes (connectionTypestextbox_idconnectionTypes ASC),
	FOREIGN KEY(connectionTypesnode_idconnectionTypes)
	  REFERENCES connectionTypesagoraconnectionTypes.connectionTypesnodesconnectionTypes (connectionTypesnode_idconnectionTypes)
	  ON DELETE NO ACTION
	  ON UPDATE NO ACTION,
	FOREIGN KEY(connectionTypestextbox_idconnectionTypes)
	  REFERENCES connectionTypesagoraconnectionTypes.connectionTypestextboxesconnectionTypes (connectionTypestextbox_idconnectionTypes)
	  ON DELETE NO ACTION
	  ON UPDATE NO ACTION);

	
-- -----------------------------------------------------
-- Table connectionTypesagoraconnectionTypes.connectionTypesconnection_typesconnectionTypes
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS connectionTypesagoraconnectionTypes.connectionTypesconnection_typesconnectionTypes (
  connectionTypestype_idconnectionTypes INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  connectionTypesnameconnectionTypes VARCHAR(60) NOT NULL ,
  connectionTypesdescriptionconnectionTypes VARCHAR(255) NULL,
  PRIMARY KEY (connectionTypestype_idconnectionTypes));
  
INSERT INTO connection_types (name, description) VALUES 
	("Commentary", "A comment on another node"), ("Objection", "An objection to another node"), ("Refutation", "A refutation of another node"), ("Amendment", "Proposed amendment for another node");
	
INSERT INTO connection_types(name, description) VALUES ("MPtherefore", "Modus Ponens - Therefore phrasing, in English.");

-- -----------------------------------------------------
-- Table connectionTypesagoraconnectionTypes.connectionTypesargumentsconnectionTypes
-- -----------------------------------------------------

CREATE  TABLE IF NOT EXISTS connectionTypesagoraconnectionTypes.connectionTypesargumentsconnectionTypes (
  connectionTypesargument_idconnectionTypes INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  connectionTypesmap_idconnectionTypes INT UNSIGNED NULL,
  connectionTypesnode_idconnectionTypes INT UNSIGNED NULL ,
  connectionTypestype_idconnectionTypes INT UNSIGNED NULL ,
  PRIMARY KEY (connectionTypesargument_idconnectionTypes) ,
  INDEX connectionTypesmap_idconnectionTypes (connectionTypesmap_idconnectionTypes ASC) ,
  INDEX connectionTypesnode_idconnectionTypes (connectionTypesnode_idconnectionTypes ASC) ,
  INDEX connectionTypestype_idconnectionTypes (connectionTypestype_idconnectionTypes ASC) ,
  FOREIGN KEY (connectionTypesmap_idconnectionTypes)
    REFERENCES connectionTypesagoraconnectionTypes.connectionTypesmapsconnectionTypes (connectionTypesmap_idconnectionTypes)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY (connectionTypesnode_idconnectionTypes)
    REFERENCES connectionTypesagoraconnectionTypes.connectionTypesnodesconnectionTypes (connectionTypesnode_idconnectionTypes)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY (connectionTypestype_idconnectionTypes)
    REFERENCES connectionTypesagoraconnectionTypes.connectionTypesconnection_typesconnectionTypes (connectionTypestype_idconnectionTypes)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
-- The node_id is the claim.

-- -----------------------------------------------------
-- Table connectionTypesagoraconnectionTypes.connectionTypesconnectionsconnectionTypes
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS connectionTypesagoraconnectionTypes.connectionTypesconnectionsconnectionTypes (
	connectionTypesconnection_idconnectionTypes INT UNSIGNED NOT NULL AUTO_INCREMENT,
	connectionTypesargument_idconnectionTypes INT UNSIGNED NOT NULL,
	connectionTypesnode_idconnectionTypes INT UNSIGNED NOT NULL,
	PRIMARY KEY (connectionTypesconnection_idconnectionTypes),
	INDEX connectionTypesargument_idconnectionTypes (connectionTypesargument_idconnectionTypes ASC),
	INDEX connectionTypesnode_idconnectionTypes (connectionTypesnode_idconnectionTypes ASC),
	FOREIGN KEY (connectionTypesargument_idconnectionTypes)
	  REFERENCES connectionTypesagoraconnectionTypes.connectionTypesargumentsconnectionTypes (connectionTypesargument_idconnectionTypes)
	  ON DELETE NO ACTION
	  ON UPDATE NO ACTION,
	FOREIGN KEY (connectionTypesnode_idconnectionTypes)
	  REFERENCES connectionTypesagoraconnectionTypes.connectionTypesnodesconnectionTypes (connectionTypesnode_idconnectionTypes)
	  ON DELETE NO ACTION
	  ON UPDATE NO ACTION);