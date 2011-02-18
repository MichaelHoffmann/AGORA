USE agora;

INSERT INTO users (isDeleted, firstName, lastName, userName, password, email, url, userlevel, createdDate, lastLogin) VALUES (FALSE, "Joshua", "Justice", "JoshJ", "password", "joshj777@gmail.com", "http://github.com/joshjgt", 9, NOW(), NOW());

INSERT INTO maps (user_id, title, description, createdDate, modifiedDate) VALUES ((SELECT user_id FROM users WHERE userName="JoshJ"), "Basic Argument", "A basic argument for testing the database layout.", NOW(), NOW());

