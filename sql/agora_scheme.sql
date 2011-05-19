
CREATE SCHEMA IF NOT EXISTS agora DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE agora;
SET storage_engine=INNODB;

DROP TABLE IF EXISTS agora.sourcenodes;
DROP TABLE IF EXISTS agora.connections;
DROP TABLE IF EXISTS agora.connection_types;
DROP TABLE IF EXISTS agora.nodetext;
DROP TABLE IF EXISTS agora.textboxes;
DROP TABLE IF EXISTS agora.nodes;
DROP TABLE IF EXISTS agora.node_types;
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
  lang VARCHAR(10) NOT NULL,
  PRIMARY KEY (map_id),
  INDEX user_id (user_id ASC),
  FOREIGN KEY (user_id)
    REFERENCES agora.users (user_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

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
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (map_id)
	REFERENCES agora.maps (map_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY(nodetype_id)
    REFERENCES agora.node_types (nodetype_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE);

-- -----------------------------------------------------
-- Table agora.textboxes
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS agora.textboxes (
  textbox_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  textbox_tid INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  map_id INT UNSIGNED NOT NULL,
  text TEXT,
  created_date DATETIME NOT NULL,
  modified_date DATETIME NOT NULL,
  is_deleted TINYINT(1)  NULL DEFAULT 0,
  PRIMARY KEY (textbox_id),
  INDEX user_id (user_id ASC),
  INDEX map_id (map_id ASC),
  FOREIGN KEY (user_id)
	REFERENCES agora.users (user_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (map_id)
    REFERENCES agora.maps (map_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

-- -----------------------------------------------------
-- Table agora.nodetext
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS agora.nodetext (
  nodetext_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
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
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY(textbox_id)
    REFERENCES agora.textboxes (textbox_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

-- -----------------------------------------------------
-- Table agora.connection_types
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS agora.connection_types (
  type_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  conn_name VARCHAR(60) NOT NULL,
  description VARCHAR(255) NULL,
  PRIMARY KEY (type_id));
  
INSERT INTO connection_types (conn_name, description) VALUES 
	("Unset", "A type of connection which has not yet been set."), ("Commentary", "A comment on another node"), ("Objection", "An objection to another node"), ("Refutation", "A refutation of another node"), ("Amendment", "Proposed amendment for another node");
	
-- NOTE: Argument types that only have one sort of expansion do not need disambiguation

-- ENGLISH

-- Modus Ponens
INSERT INTO connection_types(conn_name, description) VALUES ("MPifthen",       "Modus Ponens: if-then phrasing, in English.");
INSERT INTO connection_types(conn_name, description) VALUES ("MPimplies",       "Modus Ponens: implies phrasing, in English.");
INSERT INTO connection_types(conn_name, description) VALUES ("MPwhenever",     "Modus Ponens: whenever phrasing, in English.");
INSERT INTO connection_types(conn_name, description) VALUES ("MPonlyif",       "Modus Ponens: only-if phrasing, in English.");
INSERT INTO connection_types(conn_name, description) VALUES ("MPprovidedthat", "Modus Ponens: provided-that phrasing, in English.");
INSERT INTO connection_types(conn_name, description) VALUES ("MPsufficient",   "Modus Ponens: sufficient phrasing, in English.");
INSERT INTO connection_types(conn_name, description) VALUES ("MPnecessary",    "Modus Ponens: necessary phrasing, in English.");
-- Modus Tollens
INSERT INTO connection_types(conn_name, description) VALUES ("MTifthen",       "Modus Tollens: if-then phrasing, in English.");
INSERT INTO connection_types(conn_name, description) VALUES ("MTimplies",      "Modus Tollens: implies phrasing, in English.");
INSERT INTO connection_types(conn_name, description) VALUES ("MTwhenever",     "Modus Tollens: whenever phrasing, in English.");
INSERT INTO connection_types(conn_name, description) VALUES ("MTonlyif",       "Modus Tollens: only-if phrasing, in English.");
INSERT INTO connection_types(conn_name, description) VALUES ("MTonlyifand",    "Modus Tollens: only-if phrasing, expanded with 'and', in English.");
INSERT INTO connection_types(conn_name, description) VALUES ("MTonlyifor",     "Modus Tollens: only-if phrasing, expanded with 'or', in English.");
INSERT INTO connection_types(conn_name, description) VALUES ("MTprovidedthat", "Modus Tollens: provided-that phrasing, in English.");
INSERT INTO connection_types(conn_name, description) VALUES ("MTsufficient",   "Modus Tollens: sufficient phrasing, in English.");
INSERT INTO connection_types(conn_name, description) VALUES ("MTnecessary",    "Modus Tollens: necessary phrasing, in English.");
-- Miscellaneous Syllogisms
INSERT INTO connection_types(conn_name, description) VALUES ("DisjSyl",        "Disjunctive Syllogism, in English");
INSERT INTO connection_types(conn_name, description) VALUES ("NotAllSyl",      "Not-all Syllogism, in English");
-- Equivalence (Note that while these can have negatives on both sides, the difference isn't necessary on the server)
INSERT INTO connection_types(conn_name, description) VALUES ("EQiff",          "Equivalence: if-and-only-if phrasing, in English");
INSERT INTO connection_types(conn_name, description) VALUES ("EQnecsuf",       "Equivalence: necessary-and-sufficient phrasing, in English");
INSERT INTO connection_types(conn_name, description) VALUES ("EQ",             "Equivalence: equivalent phrasing, in English");
-- Conditional Syllogism
INSERT INTO connection_types(conn_name, description) VALUES ("CSifthen",       "Conditional Syllogism: if-then phrasing, in English.");
INSERT INTO connection_types(conn_name, description) VALUES ("CSimplies",      "Conditional Syllogism: implies phrasing, in English.");
-- Constructive Dilemma
INSERT INTO connection_types(conn_name, description) VALUES ("CDaltclaim",     "Constructive Dilemma: alternate as claim, in English.");
INSERT INTO connection_types(conn_name, description) VALUES ("CDpropclaim",    "Constructive Dilemma: proposition as claim, in English.");




-- -----------------------------------------------------
-- Table agora.connections
-- -----------------------------------------------------

CREATE  TABLE IF NOT EXISTS agora.connections (
  connection_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  arg_tid INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  map_id INT UNSIGNED NOT NULL,
  node_id INT UNSIGNED NOT NULL,
  type_id INT UNSIGNED NOT NULL,
  x_coord INT NULL,
  y_coord INT NULL,
  created_date DATETIME NOT NULL,
  modified_date DATETIME NOT NULL,
  is_deleted TINYINT(1)  NULL DEFAULT 0,
  PRIMARY KEY (connection_id),
  INDEX user_id (user_id ASC),
  INDEX map_id (map_id ASC),
  INDEX node_id (node_id ASC),
  INDEX type_id (type_id ASC),
  FOREIGN KEY (user_id)
	REFERENCES agora.users (user_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (map_id)
    REFERENCES agora.maps (map_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (node_id)
    REFERENCES agora.nodes (node_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (type_id)
    REFERENCES agora.connection_types (type_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE);
-- The node_id is the claim.

-- -----------------------------------------------------
-- Table agora.sourcenodes
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS agora.sourcenodes (
  sn_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  connection_id INT UNSIGNED NOT NULL,
  node_id INT UNSIGNED NOT NULL,
  created_date DATETIME NOT NULL,
  modified_date DATETIME NOT NULL,
  is_deleted TINYINT(1)  NULL DEFAULT 0,
  PRIMARY KEY (sn_id),
  INDEX connection_id (connection_id ASC),
  INDEX node_id (node_id ASC),
  FOREIGN KEY (connection_id)
    REFERENCES agora.connections (connection_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (node_id)
    REFERENCES agora.nodes (node_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE);
	
-- -----------------------------------------------------
-- Triggers
-- -----------------------------------------------------
DELIMITER //
CREATE TRIGGER nodedel AFTER UPDATE ON nodes
	FOR EACH ROW
	BEGIN
		IF NEW.is_deleted = 1 THEN
			UPDATE nodetext SET is_deleted=1, modified_date=NOW() WHERE node_id=NEW.node_id;
			UPDATE connections SET is_deleted=1, modified_date=NOW() WHERE node_id=NEW.node_id;
			UPDATE sourcenodes SET is_deleted=1, modified_date=NOW() WHERE node_id=NEW.node_id;
		END IF;
	END;
//
	
CREATE TRIGGER ntdel AFTER UPDATE ON nodetext
	FOR EACH ROW
	BEGIN
		IF NEW.is_deleted = 1 THEN
			UPDATE textboxes SET is_deleted=1, modified_date=NOW() WHERE textbox_id=NEW.textbox_id;
		END IF;
	END;
//

CREATE TRIGGER conndel AFTER UPDATE ON connections
	FOR EACH ROW
	BEGIN
		IF NEW.is_deleted = 1 THEN
			UPDATE sourcenodes SET is_deleted=1, modified_date=NOW() WHERE connection_id=NEW.connection_id;
		END IF;
	END;
//
DELIMITER ;