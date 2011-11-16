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
		projID: The ID of the project.
		mapID: The ID of the map.
		action: "add" or "remove". Pretty self-explanatory, really. Right now, there's no "create a new map as part of a project" function on the server, and doesn't actually need to be: the client can have a button which automatically calls insert.php followed by projmaps.php?action=add when it gets a successful result from insert.php.		
	**/
	require 'configure.php';
	require 'errorcodes.php';
	require 'establish_link.php';
	require 'utilfuncs.php';
	
	function addMap($mapID, $projID, $userID, $pass_hash, $output){
		$output->addAttribute("ID", $projID);
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
		//Basic boilerplate is done. Next step is to add the map to the project.
		
		//First, we check whether the user has authority to move the map into the project. To prevent abuse, only the map's creator can move the map into the project, and then only if he is a user of the project.
		
		//check currently omitted for testing purposes: can't be done until projusers exists
		//TODO: add check once projusers is working properly
		//TODO: add check for checking that project/map relationship doesn't already exist. If it does, nothing to do here.
		
		$query = "UPDATE maps SET proj_id=$projID WHERE map_id=$mapID";
		$success = mysql_query($query, $linkID);
		if($success){
			$map=$output->addChild("map");
			$map->addAttribute("ID", $mapID);
			$map->addAttribute("added", true);
			return $output;
		}else{
			$map=$output->addChild("map");
			$map->addAttribute("ID", $mapID);
			$map->addAttribute("added", false);
			updateFailed($output, $query);
			return $output;
		}
		
		return $output;
	}
	
	function removeMap($mapID, $projID, $userID, $pass_hash, $output){
		$output->addAttribute("ID", $projID);
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
		//Basic boilerplate is done. Next step is to remove the map from the project.
		//First, we check whether the user has authority to move the map out of the project. To prevent abuse, only the map's creator or a project administrator can move the map out of the project. The owner can do this even if he is no longer a user of the project. (Thinking: you can't kick me out of a project to take away my ability to work on my map.)
		
		//check currently omitted for testing purposes: can't be done until projusers exists
		//TODO: add check once projusers is working properly
		
		$query = "UPDATE maps SET proj_id=NULL WHERE map_id=$mapID";
		
		$success = mysql_query($query, $linkID);
		if($success){
			$map=$output->addChild("map");
			$map->addAttribute("ID", $mapID);
			$map->addAttribute("deleted", true);
			return $output;
		}else{
			$map=$output->addChild("map");
			$map->addAttribute("ID", $mapID);
			$map->addAttribute("deleted", false);
			updateFailed($output, $query);
			return $output;
		}
		
		return $output;
		
		
		
		
		return $output;
	}

	$userID = mysql_real_escape_string($_REQUEST['uid']);
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);
	$projID = mysql_real_escape_string($_REQUEST['projID']);
	$mapID =  mysql_real_escape_string($_REQUEST['mapID']);
	$action = $_REQUEST['action'];
	
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
	$output = new SimpleXMLElement($xmlstr);

	if($action=="add"){
		$output=addMap($mapID, $projID, $userID, $pass_hash, $output);
	}else if($action=="remove"){
		$output=removeMap($mapID, $projID, $userID, $pass_hash, $output);
	}else{
		meaninglessQueryVariables($output, "The 'action' variable must be set to either add or remove.");
	}
	print $output->asXML();
	
?>