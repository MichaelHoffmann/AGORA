<?php
	$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
	mysql_select_db("agora", $linkID) or die ("Could not find database");
	$mapID = 1; //TODO: read this from input somehow.
	$whereclause = mysql_real_escape_string("WHERE map_id = $mapID");
	$query = "SELECT * FROM maps " . $whereclause ; //WHERE mapID == something passed in....	
	$resultID = mysql_query($query, $linkID) or die("Data not found."); 
	
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0' ?>\n<map></map>";
	$xml = new SimpleXMLElement($xmlstr);
	$row = mysql_fetch_assoc($resultID);
	$xml->addAttribute("id", $row['map_id']);
	$xml->addAttribute("creator", $row['user_id']);
	
	print($xml->asXML());
?>