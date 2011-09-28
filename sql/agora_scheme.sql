--	AGORA - an interactive and web-based argument mapping tool that stimulates reasoning, 
--			reflection, critique, deliberation, and creativity in individual argument construction 
--			and in collaborative or adversarial settings. 
--    Copyright (C) 2011 Georgia Institute of Technology
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU Affero General Public License as
--    published by the Free Software Foundation, either version 3 of the
--    License, or (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU Affero General Public License for more details.
--
--    You should have received a copy of the GNU Affero General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.

CREATE SCHEMA IF NOT EXISTS agora DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE agora;
SET storage_engine=INNODB;


-- -----------------------------------------------------
-- Table agora.users
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS agora.users (
  user_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  is_deleted TINYINT(1) NULL DEFAULT 0,
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
CREATE TABLE IF NOT EXISTS agora.maps (
  map_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NULL,
  title VARCHAR(100) NULL,
  description VARCHAR(255) NULL,
  is_deleted TINYINT(1) NULL DEFAULT 0,
  created_date DATETIME NOT NULL,
  modified_date DATETIME NOT NULL,
  lang VARCHAR(10) NOT NULL,
  PRIMARY KEY (map_id),
  INDEX user_id (user_id ASC),
  FOREIGN KEY (user_id)
    REFERENCES agora.users (user_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

-- -----------------------------------------------------
-- Table agora.lastviewed
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS agora.lastviewed (
	user_id INT UNSIGNED NOT NULL,
	map_id INT UNSIGNED NOT NULL,
	lv_date DATETIME NOT NULL,
	PRIMARY KEY (user_id, map_id),
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

-- -------------------------------------------------------
-- Table agora.node_types
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS agora.node_types (
  nodetype_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  type VARCHAR(30) NOT NULL,
  PRIMARY KEY (nodetype_id));

INSERT INTO node_types (type) VALUES ("Particular"), ("Universal"), ("Inference"), ("Objection"), ("Question"), ("Amendment"), ("Comment"), ("Definition"), ("Citation");
-- All inferences are universal statements, but not all universal statements are inferences. As such, these are being separated.
-- It's possible we will want to add more types later.

-- -------------------------------------------------------
-- Table agora.nodes
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS agora.nodes (
  node_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  map_id INT UNSIGNED NOT NULL DEFAULT 0, 
  nodetype_id INT UNSIGNED NOT NULL,
  created_date DATETIME NOT NULL,
  modified_date DATETIME NOT NULL,
  x_coord INT NOT NULL DEFAULT 0,
  y_coord INT NOT NULL DEFAULT 0,
  typed TINYINT(1) NOT NULL DEFAULT 0,
  connected_by ENUM('implication, disjunction') NOT NULL DEFAULT 'implication',
  is_positive TINYINT(1) NOT NULL DEFAULT 1,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
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
  textbox_id INT UNSIGNED NULL,
  target_node_id INT UNSIGNED NULL,
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
CREATE TABLE IF NOT EXISTS agora.connection_types (
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

CREATE TABLE IF NOT EXISTS agora.connections (
  connection_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
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
-- TODO: fix ntdel to check if there are undeleted nodetexts pointing at the same textbox
-- UPDATE textboxes SET is_deleted=1, modified_date=NOW() WHERE textbox_id=NEW.textbox_id;

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
				IF (SELECT COUNT(*) FROM nodetext WHERE is_deleted=0 AND textbox_id=NEW.textbox_id) = 0 THEN
					UPDATE textboxes SET is_deleted=1, modified_date=NOW() WHERE textbox_id=NEW.textbox_id;
				END IF;
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

CREATE TRIGGER sndel AFTER UPDATE ON sourcenodes
	FOR EACH ROW
	BEGIN
		IF NEW.is_deleted = 1 THEN
			IF (SELECT COUNT(*) FROM sourcenodes WHERE is_deleted=0 AND connection_id=NEW.connection_id) = 0 THEN
				UPDATE connections SET is_deleted=1, modified_date=NOW() WHERE connection_id=NEW.connection_id ;
			END IF;			
		END IF;
	END;
//