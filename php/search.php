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
	*	File for searching maps.
	*/
	
	function search_by_title($text){
		global $dbName, $version;
		//basic XML output initialization
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<AGORA version='$version'/>";
		$output = new SimpleXMLElement($xmlstr);
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
		
		$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE title LIKE '%$text%' AND maps.is_deleted=0";
		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		$row = mysql_fetch_assoc($resultID);
		if(mysql_num_rows($resultID)==0){
			$output->addAttribute("map_count", "0");
			//This is a better alternative than reporting an error.
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
		return $output;
	}
	
	function search_by_text($text){
		global $dbName, $version;
		//basic XML output initialization
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<AGORA version='$version'/>";
		$output = new SimpleXMLElement($xmlstr);
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
		
		$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE map_id IN (SELECT DISTINCT map_id FROM `textboxes` WHERE text LIKE '%$text%')";

		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		$row = mysql_fetch_assoc($resultID);
		if(mysql_num_rows($resultID)==0){
			$output->addAttribute("map_count", "0");
			//This is a better alternative than reporting an error.
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
		return $output;
	}
	
	function search_by_user($text){
		global $dbName, $version;
		//basic XML output initialization
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<AGORA version='$version'/>";
		$output = new SimpleXMLElement($xmlstr);
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
		
		$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE title LIKE '%$text%' AND maps.is_deleted=0"; //TODO: Replace this query with a query on usernames
		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		$row = mysql_fetch_assoc($resultID);
		if(mysql_num_rows($resultID)==0){
			$output->addAttribute("map_count", "0");
			//This is a better alternative than reporting an error.
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
		return $output;
	}
	
	function search($sType, $sQuery){
		switch($sType){
			//This makes it simple enough to add more types later on.
			case "title":
				return search_by_title($sQuery);
				break;
				
			case "text":
				return search_by_text($sQuery);
				break;
			
			case "user":
				return search_by_user($sQuery);
				break;
		}	
	}
	
	$sType = mysql_real_escape_string($_REQUEST['type']);  //TODO: Change this back to a GET when all testing is done.
	$sQuery = mysql_real_escape_string($_REQUEST['query']);  //TODO: Change this back to a GET when all testing is done.
	$output = search($sType, $sQuery);
	print $output->asXML();
	
	
	
?>