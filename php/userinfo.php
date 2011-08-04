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
	require 'establish_link.php';
	/**
	*	Function for getting a particular user's information
	*/
	function user_info($username){
		global $dbName, $version;
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<user version='$version'></user>";
		$output = new SimpleXMLElement($xmlstr);
		
		$linkID= establishLink();
		if(!$linkID){
			$fail=$output->addChild("error");
			$fail->addAttribute("text", "Could not establish link to the database server");
			return $output;
		}
		mysql_select_db($dbName, $linkID) or die ("Could not find database");
		$query = "SELECT * FROM users WHERE username=$username";
		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			$fail=$output->addChild("error");
			$fail->addAttribute("text", "Database query not found.");
			return $output;
		}
		if(mysql_num_rows($resultID)==0){
			$fail=$output->addChild("error");
			$fail->addAttribute("text", "There is no user with this name! Query was: $query");
			//Calling this an error is perhaps a bit strong, but an empty list seems uninformative ...
			return $output;
		}else{
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
				$row = mysql_fetch_assoc($resultID);
				if($row['is_deleted']){
					$fail = $output->addChild("error");
					$fail->addAttribute("text", "User's account has been deleted. For protection");
				}
				$map = $output->addChild("map");
				$map->addAttribute("ID", $row['map_id']);
				$map->addAttribute("title", $row['title']);
				$map->addAttribute("creator", $row['username']);
			}
		}
		return $output;
	}
	$userID = mysql_real_escape_string($_REQUEST['username']);  //TODO: Change this back to a GET when all testing is done.
	$output=user_info($username);
	print($output->asXML());
?>