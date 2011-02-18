USE `agora` ;

INSERT INTO users (user_id, isDeleted, firstName, lastName, userName, password, email, url, userlevel, createdDate, lastLogin) VALUES (DEFAULT, FALSE, "Joshua", "Justice", "JoshJ", "password", "joshj777@gmail.com", "http://github.com/joshjgt", 9, NOW(), NOW());

INSERT INTO maps (map_id, user_id, title, description, createdDate, modifiedDate) VALUES (DEFAULT, 0, "Basic Argument", "A basic argument for testing the database layout.", NOW(), NOW());