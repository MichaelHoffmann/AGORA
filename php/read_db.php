<?php
	$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
	mysql_select_db("agora", $linkID) or die ("Could not find database");
	$query = "SELECT * FROM nodes NATURAL JOIN nodetext NATURAL JOIN textboxes NATURAL JOIN node_types";
	$resultID = mysql_query($query, $linkID) or die("Data not found."); 

	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0' ?>\n<map></map>";
	$xml = new SimpleXMLElement($xmlstr);
	for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
		$row = mysql_fetch_assoc($resultID);
		$node = $xml->addChild("node");
		$node->addAttribute("ID", $row['node_id']);
		$node->addAttribute("type", $row['type']);
		$node->addAttribute("text", $row['text']);
	}
	print($xml->asXML());
?>