<?php
	$linkID = mysql_connect("localhost", "root", "s3s@me123") or die ("Could not connect to database!");
	mysql_select_db("agora", $linkID) or die ("Could not find database");
	$query = "SELECT * FROM maps NATURAL JOIN users";
	$resultID = mysql_query($query, $linkID) or die("Data not found."); 

	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0' ?>\n<list></list>";
	$xml = new SimpleXMLElement($xmlstr);
	for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
		$row = mysql_fetch_assoc($resultID);
		$map = $xml->addChild("map");
		$map->addAttribute("id", $row['map_id']);
		$map->addAttribute("title", $row['title']);
		$map->addAttribute("creator", $row['username']);
	}
	print($xml->asXML());
?>