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
	/**
	*	Function for allowing users to confirm their login information.
	*	Returns XML containing the UID once the username and password hash are given.
	*/
	function pull_chat($username, $time, $map_type)
	{
		global $dbname, $version;
		header("Content-type: text/xml");
		$outputstr = "<?xml version='1.0' ?>\n<login version='$version'></login>";
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
		$query = "SELECT * FROM chat WHERE time >='$time' AND map_type='$map_type'";

		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		$row = mysql_fetch_assoc($resultID);
		if($row['text']){
			$output->addAttribute("username", $row['username']);
			$output->addAttribute("text", $row['text']);
		}else{
			return $output;
		}
		return $output;
	}
	
	$username = mysql_real_escape_string($_REQUEST['username']);
	$time = mysql_real_escape_string($_REQUEST['time']);
	$map_type = mysql_real_escape_string($_REQUEST['map_type']);
	$output = login($username, $pass_hash);
	print($output->asXML());
?>