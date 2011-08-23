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
	require 'checklogin.php';
	require 'errorcodes.php';
	require 'establish_link.php';
	
	/**
	*	File for getting the list of maps a specific user has made.
	*/
	
	function my_maps($userID, $pass_hash){
		global $dbName, $version;
		header("Content-type: text/xml");	
		$outputstr = "<?xml version='1.0' ?>\n<list version='$version'></list>";
		$output = new SimpleXMLElement($outputstr);
		
		$linkID= establishLink();
		if(!$linkID){
			badDBLink($output);
			return $output;
		}
		$status = mysql_select_db($dbName, $linkID);
		if(!$status){
			databaseNotFound($output);
			return $output;
		}
		if(!checkLogin($userID, $pass_hash, $linkID)){
			incorrectLogin($output);
			return $output;
		}
		
		/*
			Let's break this down.
			SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE map_id IN (query) ORDER BY title
			We want to get all the columns in `maps` JOINED with `users`, with user_id as the join column.
			What's that mean? Basically, we get the maps, but we get full user info on the creator.
			What are we getting that from? WHERE the map_id is IN the list of stuff from the other query.
			Okay, so what's that query?
			SELECT something UNION something else - in other words, two separate sets of maps.
			The first one... SELECT DISTINCT map_id FROM `nodes` WHERE user_id=$userID
			That gets us the list of unique maps where a user owns a node in it
			The second one... SELECT DISTINCT map_id FROM `maps` WHERE user_id=$userID
			That's the list of unique maps a person is considered to own.
			
			So, combine the list of maps a person's contributed to (owns a node) with a list of his own maps...
			Then select all those maps from the maps table and get the full user info as well and order them by title.
		*/
		$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE map_id IN (SELECT DISTINCT map_id FROM nodes WHERE user_id=$userID UNION SELECT DISTINCT map_id FROM maps WHERE user_id=$userID) AND maps.is_deleted=0 ORDER BY title, map_id";
				
		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		if(mysql_num_rows($resultID)==0){
			$empty = $output->addChild("empty");
			$empty->addAttribute("text", "This user has not created or contributed to any maps");
			//Idea for the client: put an additional "create map" button in the "my maps" list, perhaps?
		}
		
		for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
			$row = mysql_fetch_assoc($resultID);
			$map = $output->addChild("map");
			$map->addAttribute("ID", $row['map_id']);
			$map->addAttribute("title", $row['title']);
			$map->addAttribute("creator", $row['username']);
		}
		return $output;
	}
	
	
	$userID = mysql_real_escape_string($_REQUEST['uid']);  //TODO: Change this back to a GET when all testing is done.
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']); //TODO: Change this back to a GET when all testing is done.
	$output = my_maps($userID, $pass_hash);
	print($output->asXML());
?>