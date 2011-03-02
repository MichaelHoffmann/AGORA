<?php

	function get_map($mapID){

		$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
		mysql_select_db("agora", $linkID) or die ("Could not find database");
		$whereclause = mysql_real_escape_string("WHERE map_id = $mapID");
		$query = "SELECT * FROM maps " . $whereclause ;
		$resultID = mysql_query($query, $linkID) or die("Data not found."); 
		
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<map></map>";
		$xml = new SimpleXMLElement($xmlstr);
		$row = mysql_fetch_assoc($resultID);
		$xml->addAttribute("id", $row['map_id']);
		$xml->addAttribute("creator", $row['user_id']);
		
		$query = "SELECT * FROM textboxes " . $whereclause ; 
		$resultID = mysql_query($query, $linkID) or die("Data not found in textbox lookup."); 
		for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
			$row = mysql_fetch_assoc($resultID);
			$textbox = $xml->addChild("textbox");
			$textbox->addAttribute("ID", $row['textbox_id']);
			$textbox->addAttribute("text", $row['text']);
		}
		
		$query = "SELECT * FROM nodes " . $whereclause;
		
		$resultID = mysql_query($query, $linkID) or die("Data not found in node lookup."); 
		for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
			$row = mysql_fetch_assoc($resultID);
			$node_id = $row['node_id'];
			$node = $xml->addChild("node");
			$node->addAttribute("ID", $row['node_id']);
			$node->addAttribute("Author", $row['user_id']);
			$innerQuery="SELECT * from nodetext WHERE node_id=$node_id ORDER BY position ASC";
			$resultID2 = mysql_query($innerQuery, $linkID) or die("Data not found in nodetext lookup."); 
			for($y=0; $y<mysql_num_rows($resultID2); $y++){
				$nodetext = $node->addChild("nodetext");
				$innerRow=mysql_fetch_assoc($resultID2);
				$nodetext->addAttribute("ID", $innerRow['textbox_id']);
			}			
		}
		
		return $xml;
	}
	$xml = get_map(1); // TODO: read this number from somewhere else.
	print($xml->asXML());
?>