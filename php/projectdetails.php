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
	*	Function for getting the project Details.
	*/
	function getProjectDetails($userID, $pass_hash,$projID,$projName){
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
		
		if($projID==-1){
			$projID = getCategoryIDfromName($projName,$linkID);
		}
				
		if($projID == null){
			projectNotFoundID($output);
			return $output;
		}
		//Basic boilerplate complete. Next step is to verify that the user is the owner of the project.
		$query = "SELECT * FROM projects INNER JOIN users ON users.user_id = projects.user_id WHERE proj_id = $projID";
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

		// Validations ..
		// user priv
		$UID = $row['user_id'];
		$title  = $row['title'];
		$ishostile = $row['is_hostile'];

		if($UID!=$userID){
			modifyOther($output);
			return $output;
		}

		$query = "SELECT projects.proj_id,projects.user_id,projusers.proj_id,projusers.user_level role,users.user_id,users.username FROM projects INNER JOIN projusers ON projects.proj_id = projusers.proj_id INNER JOIN users ON users.user_id = projusers.user_id where projects.user_id=$userID and projects.proj_id = $projID ORDER BY users.username";
		$resultID = mysql_query($query, $linkID);
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		$proj = $output->addChild("proj");
		$proj->addAttribute("ID", $projID);
		$proj->addAttribute("isHostile", $ishostile);
		$proj->addAttribute("title", $title);
		if(mysql_num_rows($resultID)==0){
			$proj->addAttribute("user_count", "0");
			return $output;
		}else{
			$users = $proj->addChild("users");
			$count = 0 ;
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){
				$row = mysql_fetch_assoc($resultID);
				if($row['role']==9){
				$userDtl = $proj->addChild("admin");
				$userDtl->addAttribute("name", $row['username']);
				$userDtl->addAttribute("userid", $row['user_id']);				
				$userDtl->addAttribute("role", $row['role']);
				}else{ 
				$userDtl = $users->addChild("userDetail");
				$userDtl->addAttribute("name", $row['username']);
				$userDtl->addAttribute("userid", $row['user_id']);				
				$userDtl->addAttribute("role", $row['role']);
				$count++;
				}
			}
			$proj->addAttribute("user_count", $count);
		}
		return $output;
	}

	$userID = mysql_real_escape_string($_REQUEST['uid']);
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);
	$projID = mysql_real_escape_string($_REQUEST['projID']);
	$projname = "";
	if($projID == -1){
		$projname = mysql_real_escape_string($_REQUEST['projName']);
	}
	$output=getProjectDetails($userID, $pass_hash,$projID,$projname);
	error_log($output->asXML(),0);
	print($output->asXML());
?>