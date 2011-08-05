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
		
		$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE maps.user_id=$userID AND maps.is_deleted=0 ORDER BY maps.title";
		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		if(mysql_num_rows($resultID)==0){
			$empty = $output->addChild("empty");
			$empty->addAttribute("text", "This user has not created any maps");
			//Idea for the client: put an additional "create map" button in the "my maps" list, perhaps?
		}

		for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
			$row = mysql_fetch_assoc($resultID);
			$map = $output->addChild("map");
			$map->addAttribute("ID", $row['map_id']);
			$map->addAttribute("title", $row['title']);
			$map->addAttribute("creator", $row['username']);
		}
	}
	
	
	$userID = mysql_real_escape_string($_REQUEST['uid']);  //TODO: Change this back to a GET when all testing is done.
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']); //TODO: Change this back to a GET when all testing is done.
	my_maps($userID, $pass_hash);
	print($output->asXML());
?>