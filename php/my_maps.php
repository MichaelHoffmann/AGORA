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
	require 'establish_link.php';
	
	/**
	*	File for getting the list of maps a specific user has made.
	*/
	
	$userID = mysql_real_escape_string($_REQUEST['uid']);
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);
	
	header("Content-type: text/xml");	
	$xmlstr = "<?xml version='1.0' ?>\n<list></list>";
	$xml = new SimpleXMLElement($xmlstr);
	
	$linkID= establishLink();
	$status = mysql_select_db($dbName, $linkID);
	if(!$status){
		$fail=$xml->addChild("error");
		$fail->addAttribute("text", "Could not connect to database");
		print ($xml->asXML());
		return false;
	}
	if(!checkLogin($userID, $pass_hash, $linkID)){
		$fail=$xml->addChild("error");
		$fail->addAttribute("text", "Login failed!");
		print ($xml->asXML());
		return false;
	}
	
	$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE maps.user_id=$userID AND maps.is_deleted=0 ORDER BY maps.title";
	$resultID = mysql_query($query, $linkID); 
	if(!$resultID or mysql_num_rows($resultID)==0){
		$fail=$xml->addChild("error");
		$fail->addAttribute("text", "The query failed! Query was: $query");
		print ($xml->asXML());
		return false;
	}
	if(mysql_num_rows($resultID)==0){
		$empty = $xml->addChild("empty");
		$empty->addAttribute("text", "This user has not created any maps");
		//Idea for the client: put an additional "create map" button in the "my maps" list, perhaps?
	}

	for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
		$row = mysql_fetch_assoc($resultID);
		$map = $xml->addChild("map");
		$map->addAttribute("ID", $row['map_id']);
		$map->addAttribute("title", $row['title']);
		$map->addAttribute("creator", $row['username']);
	}
	print($xml->asXML());
?>