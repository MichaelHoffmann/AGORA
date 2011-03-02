<?php

	function get_map($mapID){

		$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
		mysql_select_db("agora", $linkID) or die ("Could not find database");
		$whereclause = mysql_real_escape_string("WHERE map_id = $mapID");
		$query = "SELECT * FROM maps " . $whereclause ; //WHERE mapID == something passed in....	
		$resultID = mysql_query($query, $linkID) or die("Data not found."); 
		
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<map></map>";
		$xml = new SimpleXMLElement($xmlstr);
		$row = mysql_fetch_assoc($resultID);
		$xml->addAttribute("id", $row['map_id']);
		$xml->addAttribute("creator", $row['user_id']);
		
		$query = "SELECT * FROM textboxes " . $whereclause ; //WHERE mapID == something passed in....	
		$resultID = mysql_query($query, $linkID) or die("Data not found."); 
		for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
			$row = mysql_fetch_assoc($resultID);
			$node = $xml->addChild("textbox");
			$node->addAttribute("ID", $row['textbox_id']);
			$node->addAttribute("text", $row['text']);
		}
		
		return $xml;
	}
	$xml = get_map(1); // TODO: read this number from somewhere else.
	print($xml->asXML());
?>