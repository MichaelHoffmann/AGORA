USE agora;

INSERT INTO users (isDeleted, firstName, lastName, userName, password, email, url, userlevel, createdDate, lastLogin) VALUES (FALSE, "Joshua", "Justice", "JoshJ", "password", "joshj777@gmail.com", "http://github.com/joshjgt", 9, NOW(), NOW());

INSERT INTO maps (user_id, title, description, createdDate, modifiedDate) VALUES ((SELECT user_id FROM users WHERE userName="JoshJ"), "Default", "A basic argument for testing the database layout.", NOW(), NOW());

INSERT INTO nodes (user_id, map_id, node_type, createdDate, modifiedDate) VALUES (1,1,1,NOW(), NOW()), (1,1,1,NOW(), NOW()), (1,1,2,NOW(), NOW());

INSERT INTO textboxes (text) VALUES ("FOO"), ("BAR");

INSERT INTO nodetext (node_id, textbox_id, position) VALUES
	(1, 1, 1), (2, 2, 1), (3,1,1), (3, 2, 2);
-- This is something like:
--
--        MP
-- BAR -------- FOO
--        |
--        |
--        |
-- FOO therefore BAR
--
-- Of course, we don't yet have the connection so it's sort of nonsensical.