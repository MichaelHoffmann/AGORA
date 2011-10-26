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
	
	function addMap($mapID, $projID, $userID, $pass_hash){
	
	}
	
	function removeMap($mapID, $projID, $userID, $pass_hash){
	}

	$userID = mysql_real_escape_string($_REQUEST['uid']);
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);
	$projID = mysql_real_escape_string($_REQUEST['projID']);
	$mapID =  mysql_real_escape_string($_REQUEST['mapID']);
	$action = $_REQUEST['action'];
	
	$xmlstr = "<?xml version='1.0' ?>\n<AGORA version='$version'/>";
	$output = new SimpleXMLElement($xmlstr);
		
	if($action=="add"){
		addMap($mapID, $projID, $userID, $pass_hash);
	}else if($action=="remove"){
		removeMap($mapID, $projID, $userID, $pass_hash);
	}else{
		meaninglessQueryVariables($output, "The 'action' variable must be set to either add or remove.")
	}
	
?>