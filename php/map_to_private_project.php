<?php
	/**
	*	Moves the map created into the user's private project
	*/
	require 'configure.php';
	require 'errorcodes.php';
	require 'establish_link.php';
	require 'utilfuncs.php';

	function mapToPrivateProject($userID, $pass_hash, $mapID){
		global $dbName, $version;
		header("Content-type: text/xml");
		$outputstr = "<?xml version='1.0' ?>\n<publish version='$version'></publish>";
		$output = new SimpleXMLElement($outputstr);
		$linkID= establishLink();
		if(!$linkID){
			badDBLink($output);
			return $output;
		}
		$status=mysql_select_db($dbName, $linkID);
		if(!$status){
			databaseNotFound($output);
			return $output;
		}
		if(!checkLogin($userID, $pass_hash, $linkID)){
			incorrectLogin($output);
			return $output;
		}
		$query="SELECT category_id FROM category WHERE category_name='$userID'";
		$found_category_id=mysql_query($query, $linkID);
		if( mysql_num_rows(found_category_id) < 1){
			$create_private_proj="INSERT INTO category (category_name, is_project) VALUES ((SELECT username FROM users WHERE user_id='$userID'), 1)";
			$create_parent_link="INSERT INTO parent_categories (category_id, parent_category_name,parent_categoryid) 
								VALUES ((SELECT category_id FROM category WHERE category_name=(SELECT username FROM users WHERE user_id='$userID')),'Private, for individual users',38)";
			$make_user_admin = "INSERT INTO projusers (proj_id, user_id, user_level) VALUES 
									((SELECT category_id FROM category WHERE category_name=(SELECT username FROM users WHERE user_id='$userID')), '$userID', 9)";
			mysql_query($create_private_proj, $linkID);
			mysql_query($create_parent_link, $linkID);
			if(mysql_query($make_user_admin, $linkID)){
				$output->addAttribute("MadeAdmin", 1);
			} else {
				$output->addAttribute("MadeAdmin", mysql_error());
			}

			$output->addAttribute("NewCat", "True");
		}
		$create_map_link="INSERT INTO category_map (map_id, category_id) VALUES ('$mapID',(SELECT category_id FROM category WHERE category_name=(SELECT username FROM users WHERE user_id='$userID')))";
		mysql_query($create_map_link, $linkID);
		$output->addAttribute("Category", $userID);
		return $output;
	}

	$userID = mysql_real_escape_string($_REQUEST['user_id']); //TODO: Change this back to a GET when all testing is done.
	$mapID = mysql_real_escape_string($_REQUEST['map_id']);
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);
	$output = mapToPrivateProject($userID, $pass_hash, $mapID); 
	print($output->asXML());
?>
