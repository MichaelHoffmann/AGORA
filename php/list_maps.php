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
	require 'establish_link.php';
	/**
	*	File for getting the map list.
	*/
	$linkID= establishLink();
	mysql_select_db("agora", $linkID) or die ("Could not find database");
	$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id  AND maps.is_deleted=0";
	$resultID = mysql_query($query, $linkID) or die("Data not found."); 

	if(mysql_num_rows($resultID)==0){
		print "There are no maps in the list! Query was: $query";
		return false;
	}
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0' ?>\n<list></list>";
	$xml = new SimpleXMLElement($xmlstr);
	for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
		$row = mysql_fetch_assoc($resultID);
		if($row['is_deleted']){
			$fail = $xml->addChild("error");
			$fail->addAttribute("Map has been deleted.");
		}
		$map = $xml->addChild("map");
		$map->addAttribute("ID", $row['map_id']);
		$map->addAttribute("title", $row['title']);
		$map->addAttribute("creator", $row['username']);
	}
	print($xml->asXML());
?>