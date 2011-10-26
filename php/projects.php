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
		projID: If any value PHP treats as false (use 0 for neatness), we are creating a new project. Otherwise, we're updating a project.
		newpass: The hash of the project's password. Only needed for creating a project with one, or updating a project's password. When left blank, it means that the project's password is set to NULL, which makes it so that the only way in is for the administrator to explicitly add users in the project/user management system (rather than e-mailing everyone the password so they can add themselves).
		title: Title of the project. Only needed for creating a project or changing the project's title.
		is_hostile: If 1, then the project is a "debate" project - maps behave the same as a normal map; the project is effectively an access-limiting tool. If the project is a "collabortive" project, then anyone can edit anything.
		
	**/
	require 'configure.php';
	require 'errorcodes.php';
	require 'establish_link.php';
	require 'utilfuncs.php';
	
	function getLastInsert($linkID)
	{
		$query = "SELECT LAST_INSERT_ID()";
		$resultID = mysql_query($query, $linkID);
		$row = mysql_fetch_assoc($resultID);
		return $row['LAST_INSERT_ID()'];
	}
	
	function createProject($userID, $pass_hash, $newpass, $title, $is_hostile){
		global $dbName, $version;
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
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
		//Basic boilerplate is done. Next step is to create a new project with the various attributes.
		
		//Make sure the password is set to be NULL if it's nonexistent.
		if(!$newpass){
			$newpass="NULL";
		}
		$query = "INSERT INTO projects (user_id, title, password, is_hostile) VALUES
										($userID, '$title', $newpass, $is_hostile)";
		mysql_query($query, $linkID);
		$projID = getLastInsert($linkID);
		if(!$projID){
			insertFailed($output, $query);
			return $output;
		}
		$proj = $output->addChild("project");
		$proj->addAttribute("ID", $projID);
		return $output;
	}
	
	function editProject($userID, $pass_hash, $projID, $newpass, $title, $is_hostile){
		global $dbName, $version;
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
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
		//Basic boilerplate complete. Next step is to verify that the user is the owner of the project.
		
		$query = "SELECT * FROM projects INNER JOIN users ON 
			users.user_id = projects.user_id WHERE proj_id = $projID";
		$resultID = mysql_query($query, $linkID);
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		$row = mysql_fetch_assoc($resultID);
		if(!$row['proj_id']){
			nonexistent($output, $query);
			return $output;
		}
		$UID = $row['user_id'];
		if($UID!=$userID){
			modifyOther($output);
			return $output;
		}
		
		//If we get here, we know that the user is the owner of the project.
		
		$query = "UPDATE projects SET title='$title', password=$newpass, is_hostile=$is_hostile WHERE proj_id=$projID";
		$success = mysql_query($query, $linkID);
		if($success){
			$proj=$output->addChild("project");
			$proj->addAttribute("ID", $projID);
			$proj->addAttribute("updated", true);
			return $output;
		}else{
			$proj=$output->addChild("project");
			$proj->addAttribute("ID", $projID);
			$proj->addAttribute("updated", false);
			updateFailed($output, $query);
			return $output;
		}
	}
	
	$userID = mysql_real_escape_string($_REQUEST['uid']);
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);
	$projID = mysql_real_escape_string($_REQUEST['projID']);
	$newpass = mysql_real_escape_string($_REQUEST['newpass']);
	$newpass = mysql_real_escape_string($_REQUEST['newpass']);
	$title = mysql_real_escape_string($_REQUEST['title']);
	$is_hostile = mysql_real_escape_string($_REQUEST['is_hostile']);
	if(!$projID){
		$output = createProject($userID, $pass_hash, $newpass, $title, $is_hostile);
	}else{
		$output = editProject($userID, $pass_hash, $projID, $newpass, $title, $is_hostile);
	}
	print($output->asXML());
?>