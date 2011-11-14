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
	
	/**
		List of variables for project creation:
		uid: ID number for the user
		pass_hash: The hash of the user's password
		(These are used to verify that the user has permission to load the project.)
		projID: The ID of the project.
	*/
	require 'configure.php';
	require 'errorcodes.php';
	require 'establish_link.php';
	require 'utilfuncs.php';
	/**
	*	Function that loads a project from the database.
	*/
	function load_prj($userID, $pass_hash, $projID){
	global $dbName, $version;
		//Usual boilerplate follows
		header("Content-type: text/xml");
		$outputstr = "<?xml version='1.0' encoding='UTF-8'?>\n<list version='$version'></list>";
		$output = new SimpleXMLElement($outputstr);
		//Standard SQL connection stuff
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
		//checking login for accuracy
		if(!checkLogin($userID, $pass_hash, $linkID)){
			incorrectLogin($output);
			return $output;
		}
		//End of boilerplate
		
		
		//First step: find out if user has access to the project at all
		$squery = "SELECT * FROM projusers WHERE 
			proj_id = $projID AND projusers.user_id = $userID";
		$resultID = mysql_query($squery, $linkID);		
		if(!$resultID){
			dataNotFound($output, $squery);
			return $output;
		}
		if(mysql_num_rows($resultID)==0){
			notInProject($output, $squery);
			return $output;
		}
		//If we make it this far, the project contains the user.
		
		//Second step: get the maps in that project
		$query = "SELECT
				maps.map_id, maps.title, projects.user_id, maps.modified_date, users.username
				FROM projects 
					INNER JOIN projmaps ON projects.proj_id = projmaps.proj_id
					INNER JOIN maps ON projmaps.map_id = maps.map_id
					INNER JOIN users ON projects.user_id = users.user_id
				WHERE 
					projects.proj_id = $projID AND maps.is_deleted=0
				ORDER BY maps.title";
		$resultID = mysql_query($query, $linkID);						
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		if(mysql_num_rows($resultID)==0){
			//This is not an error. This simply means there are no maps in the project.
			$output->addAttribute("map_count", "0");
			return $output;
		}else{
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
				$row = mysql_fetch_assoc($resultID);
				$map = $output->addChild("map");
				$map->addAttribute("ID", $row['map_id']);
				$map->addAttribute("title", $row['title']);
				$map->addAttribute("creator", $row['username']);
				$map->addAttribute("last_modified", $row['modified_date']);
			}
		}
		//third step: get all the users from the project
		$uquery = "SELECT
				users.user_id, users.username, projusers.user_level
				FROM projects 
					INNER JOIN projusers ON projects.proj_id = projusers.proj_id
					INNER JOIN users ON projusers.user_id = users.user_id
				WHERE 
					projects.proj_id = $projID";
		$resultID = mysql_query($uquery, $linkID);						
		if(!$resultID){
			dataNotFound($output, $uquery);
			return $output;
		}
		if(mysql_num_rows($resultID)==0){
			//This is not an error. This simply means there are no users in the project.
			//(Remember that the project creator doesn't have to be in the user list)
			$output->addAttribute("user_count", "0");
			return $output;
		}else{
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
				$row = mysql_fetch_assoc($resultID);
				$user = $output->addChild("user");
				$user->addAttribute("ID", $row['user_id']);
				$user->addAttribute("username", $row['username']);
				//Following piece of data could be made more presentable
				//However, doing so now robs us of flexibility later on.
				$user->addAttribute("level", $row['user_level']);
			}
		}
		return $output;
	}
	
	$userID = mysql_real_escape_string($_REQUEST['uid']);
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);
	$projID = mysql_real_escape_string($_REQUEST['projID']);
	
	$output = load_prj($userID, $pass_hash, $projID); 
	print $output->asXML();
?>
