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
		$outputstr = "<?xml version='1.0' encoding='UTF-8'?>\n<map version='$version'></map>";
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
		//End of boilerplate
		
		
		
		return $output;
	}
	
	$userID = mysql_real_escape_string($_REQUEST['uid']);
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);
	$projID = mysql_real_escape_string($_REQUEST['projID']);
	
	$output = load_prj($userID, $pass_hash, $projID); 
	print $output->asXML();
?>
