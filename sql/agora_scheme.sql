
CREATE SCHEMA IF NOT EXISTS agora DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE agora;
SET storage_engine=INNODB;

DROP TABLE IF EXISTS agora.connections;
DROP TABLE IF EXISTS agora.arguments;
DROP TABLE IF EXISTS agora.connection_types;
DROP TABLE IF EXISTS agora.nodetext;
DROP TABLE IF EXISTS agora.textboxes;
DROP TABLE IF EXISTS agora.nodes;
DROP TABLE IF EXISTS agora.nodetypes;
DROP TABLE IF EXISTS agora.maps;
DROP TABLE IF EXISTS agora.users;

-- -----------------------------------------------------
-- Table agora.users
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS agora.users (
  user_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  is_deleted TINYINT(1)  NULL DEFAULT 0,
  firstname VARCHAR(30) NULL,
  lastname VARCHAR(30) NULL,
  username VARCHAR(32) NOT NULL,
  password VARCHAR(32) NOT NULL,
  email VARCHAR(255) NOT NULL,
  url VARCHAR(255) NULL,
  user_level TINYINT(1) UNSIGNED NULL DEFAULT 1 COMMENT '1 = Standard user, 9 = Administrator',
  created_date DATETIME NOT NULL,
  last_login DATETIME NULL,	
  PRIMARY KEY (user_id),
  UNIQUE INDEX username_UNIQUE (username ASC),
  UNIQUE INDEX email_UNIQUE (email ASC));


-- -----------------------------------------------------
-- Table agora.maps
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS agora.maps (
  map_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NULL,
  title VARCHAR(100) NULL,
  description VARCHAR(255) NULL,
  created_date DATETIME NOT NULL,
  modified_date DATETIME NOT NULL,
  PRIMARY KEY (map_id),
  INDEX user_id (user_id ASC),
  FOREIGN KEY (user_id)
    REFERENCES agora.users (user_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

-- -------------------------------------------------------
-- Table agora.node_types
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS agora.node_types (
  nodetype_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  type VARCHAR(30) NOT NULL,
  PRIMARY KEY (nodetype_id));

INSERT INTO node_types (type) VALUES ("Standard"), ("Inference"), ("Objection"), ("Question"), ("Amendment"), ("Comment");
-- A standard node is a claim/reason.

-- -------------------------------------------------------
-- Table agora.nodes
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS agora.nodes (
  node_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  node_tid INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  map_id INT UNSIGNED NULL, 
  nodetype_id INT UNSIGNED NOT NULL,
  created_date DATETIME NOT NULL,
  modified_date DATETIME NOT NULL,
  x_coord INT NULL,
  y_coord INT NULL,
  is_deleted TINYINT(1)  NULL DEFAULT 0,
  PRIMARY KEY (node_id),
  INDEX user_id (user_id ASC),
  INDEX map_id (map_id ASC),
  INDEX nodetype_id (nodetype_id ASC),
  FOREIGN KEY (user_id)
	REFERENCES agora.users (user_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY (map_id)
	REFERENCES agora.maps (map_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY(nodetype_id)
    REFERENCES agora.node_types (nodetype_id)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION);

-- -----------------------------------------------------
-- Table agora.textboxes
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS agora.textboxes (
  textbox_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  textbox_tid INT UNSIGNED NOT NULL,
  map_id INT UNSIGNED NOT NULL,
  text TEXT,
  created_date DATETIME NOT NULL,
  modified_date DATETIME NOT NULL,
  is_deleted TINYINT(1)  NULL DEFAULT 0,
  PRIMARY KEY (textbox_id),
  INDEX map_id (map_id ASC),
  FOREIGN KEY (map_id)
    REFERENCES agora.maps (map_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

-- -----------------------------------------------------
-- Table agora.nodetext
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS agora.nodetext (
  nodetext_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nodetext_tid INT UNSIGNED NOT NULL,
  node_id INT UNSIGNED NOT NULL,
  textbox_id INT UNSIGNED NOT NULL,
  position INT UNSIGNED NOT NULL,
  created_date DATETIME NOT NULL,
  modified_date DATETIME NOT NULL,
  is_deleted TINYINT(1)  NULL DEFAULT 0,
  PRIMARY KEY (nodetext_id),
  INDEX node_id (node_id ASC),
  INDEX textbox_id (textbox_id ASC),
  INDEX position (position ASC),
  FOREIGN KEY(node_id)
    REFERENCES agora.nodes (node_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY(textbox_id)
    REFERENCES agora.textboxes (textbox_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

-- -----------------------------------------------------
-- Table agora.connection_types
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS agora.connection_types (
  type_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  conn_name VARCHAR(60) NOT NULL,
  description VARCHAR(255) NULL,
  PRIMARY KEY (type_id));
  
INSERT INTO connection_types (conn_name, description) VALUES 
	("Commentary", "A comment on another node"), ("Objection", "An objection to another node"), ("Refutation", "A refutation of another node"), ("Amendment", "Proposed amendment for another node");
INSERT INTO connection_types(conn_name, description) VALUES ("MPtherefore", "Modus Ponens - Therefore phrasing, in English.");
INSERT INTO connection_types(conn_name, description) VALUES ("ConSyllogism", "Constructive Syllogism - Therefore phrasing, in English.");

-- -----------------------------------------------------
-- Table agora.arguments
-- -----------------------------------------------------

CREATE  TABLE IF NOT EXISTS agora.arguments (
  argument_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  arg_tid INT UNSIGNED NOT NULL,
  map_id INT UNSIGNED NULL,
  node_id INT UNSIGNED NULL,
  type_id INT UNSIGNED NULL,
  created_date DATETIME NOT NULL,
  modified_date DATETIME NOT NULL,
  is_deleted TINYINT(1)  NULL DEFAULT 0,
  PRIMARY KEY (argument_id),
  INDEX map_id (map_id ASC),
  INDEX node_id (node_id ASC),
  INDEX type_id (type_id ASC),
  FOREIGN KEY (map_id)
    REFERENCES agora.maps (map_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY (node_id)
    REFERENCES agora.nodes (node_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY (type_id)
    REFERENCES agora.connection_types (type_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
-- The node_id is the claim.

-- -----------------------------------------------------
-- Table agora.connections
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS agora.connections (
  connection_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  conn_tid INT UNSIGNED NOT NULL,
  argument_id INT UNSIGNED NOT NULL,
  node_id INT UNSIGNED NOT NULL,
  created_date DATETIME NOT NULL,
  modified_date DATETIME NOT NULL,
  is_deleted TINYINT(1)  NULL DEFAULT 0,
  PRIMARY KEY (connection_id),
  INDEX argument_id (argument_id ASC),
  INDEX node_id (node_id ASC),
  FOREIGN KEY (argument_id)
    REFERENCES agora.arguments (argument_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY (node_id)
    REFERENCES agora.nodes (node_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);