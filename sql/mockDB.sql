USE agora;

INSERT INTO users (is_deleted, firstname, lastname, username, password, email, url, user_level, created_date, last_login) VALUES
	(FALSE, "Joshua", "Justice", "JoshJ", "password", "joshj777@gmail.com", "http://github.com/joshjgt", 9, NOW(), NOW()),
	(FALSE, "George", "Burdell", "GeorgePBurdell", "YellowJackets", "GeorgeP@mailinator.com", "http://en.wikipedia.org/wiki/George_P_Burdell", 9, NOW(), NOW());

INSERT INTO maps (user_id, title, description, created_date, modified_date) VALUES
	((SELECT user_id FROM users WHERE userName="JoshJ"), "Generic", "A basic argument for testing the database layout.", NOW(), NOW()),
	(1, "Second Map", "A pointless circular argument designed solely to fill space", NOW(), NOW()),
	(1, "Babelfish", "Douglas Adams's proof by contradiction of the nonexistence of god.", NOW(), NOW());

INSERT INTO nodes (user_id, map_id, nodetype_id, created_date, modified_date) VALUES 
	(1,1,1,NOW(), NOW()), (1,1,1,NOW(), NOW()), (1,1,2,NOW(), NOW()), (1,1,1,NOW(), NOW()), (1,1,2,NOW(), NOW());

INSERT INTO textboxes (text, map_id) VALUES ("FOO", 1), ("BAR", 1), ("BAZ", 1);

INSERT INTO nodetext (node_id, textbox_id, position) VALUES
	(1, 1, 1),
	(2, 2, 1),
	(3, 1, 1), (3, 2, 2),
	(4, 1, 1), (4, 3, 2),
	(5, 3, 1), (5, 2, 2);
-- This is the following 2-part argument:
--
--     ModusPonens
-- BAR(2)------- FOO(1)
--          |
--          |
--          |        Constructive Syllogism
-- FOO therefore BAR (3)----------- FOO therefore BAZ (4)
--                          |
--                          |
--                          |
--                  BAZ therefore BAR (5)

INSERT INTO arguments (map_id, node_id, type_id) VALUES
	(1, 2, (SELECT type_id FROM connection_types WHERE conn_name="MPtherefore")),
	(1, 3, (SELECT type_id FROM connection_types WHERE conn_name="ConSyllogism"));

INSERT INTO connections (argument_id, node_id) VALUES
	(1,1), (1,3), (2, 4), (2,5);