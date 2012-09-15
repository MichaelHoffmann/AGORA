<?php
	/**
	AGORA - an interactive and web-based argument mapping tool that stimulates reasoning,
			reflection, critique, deliberation, and creativity in individual argument construction
			and in collaborative or adversarial settings.
    Copyright (C) 2011 Georgia Institute of Technology

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

	*/
	require 'configure.php';
	require 'errorcodes.php';
	require 'establish_link.php';
	require 'utilfuncs.php';
	/**
	*	Function for getting the project list.
	*/
	function list_projects($userID, $pass_hash){
		global $dbName, $version;
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<list version='$version'></list>";
		$output = new SimpleXMLElement($xmlstr);

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
		
		// This is My private Project Space - username is userid	
		$username = getUserNameFromUserId($userID,$linkID);
		$query="SELECT category_id,category_name FROM category WHERE category_name='$username'";
		$found_category_id=mysql_query($query, $linkID);
		if( mysql_num_rows($found_category_id) < 1){
			$create_private_proj="INSERT INTO category (category_name, is_project) VALUES ((SELECT username FROM users WHERE user_id='$userID'), 1)";
			$create_parent_link="INSERT INTO parent_categories (category_id, parent_category_name,parent_categoryid) 
								VALUES ((SELECT category_id FROM category WHERE category_name=(SELECT username FROM users WHERE user_id='$userID')),'Private, for individual users',38)";
			$make_user_admin = "INSERT INTO projusers (proj_id, user_id, user_level) VALUES 
									((SELECT category_id FROM category WHERE category_name=(SELECT username FROM users WHERE user_id='$userID')), '$userID', 9)";
			mysql_query($create_private_proj, $linkID);
			mysql_query($create_parent_link, $linkID);
			mysql_query($make_user_admin, $linkID);
			$query="SELECT category_id,category_name FROM category WHERE category_name='$username'";
			$found_category_id=mysql_query($query, $linkID);
		}
		$row = mysql_fetch_assoc($found_category_id);
		$output->addAttribute("privateCategoryName",  $row['category_name']);
		$output->addAttribute("privateCategoryID",  $row['category_id']);

		$query = "SELECT * FROM projects INNER JOIN users ON users.user_id = projects.user_id INNER JOIN projusers ON projects.proj_id = projusers.proj_id where projects.user_id=$userID and projusers.user_level=9 ORDER BY projects.title";
		$resultID = mysql_query($query, $linkID);
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		if(mysql_num_rows($resultID)==0){
			$output->addAttribute("proj_count", "0");
			//This is a better alternative than reporting an error.
			return $output;
		}else{
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){
				$row = mysql_fetch_assoc($resultID);
				$proj = $output->addChild("proj");
				error_log("proj",0);
				$proj->addAttribute("ID", $row['proj_id']);
				$proj->addAttribute("title", $row['title']);
				$proj->addAttribute("creator", $row['username']);
				$proj->addAttribute("role", $row['user_level']);
				$proj->addAttribute("type", $row['is_hostile']);
			}
		}
		return $output;
	}

	$userID = mysql_real_escape_string($_REQUEST['uid']);
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);
	$output=list_projects($userID, $pass_hash);
	error_log($output->asXML(),0);
	print($output->asXML());
?>