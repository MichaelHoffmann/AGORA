<?php

	function get_map($mapID){

		//Standard SQL connection stuff
		$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
		mysql_select_db("agora", $linkID) or die ("Could not find database");
		$whereclause = mysql_real_escape_string("WHERE map_id = $mapID");
		$query = "SELECT * FROM maps NATURAL JOIN users " . $whereclause ;
		$resultID = mysql_query($query, $linkID) or die("Data not found."); 
		//Set up the basics of the XML.
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<map></map>";
		$xml = new SimpleXMLElement($xmlstr);
		$row = mysql_fetch_assoc($resultID);
		$xml->addAttribute("id", $row['map_id']);
		$xml->addAttribute("username", $row['username']);
		
		
		// Textboxes are easy!
		$query = "SELECT * FROM textboxes " . $whereclause ; 
		$resultID = mysql_query($query, $linkID) or die("Data not found in textbox lookup."); 
		for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
			$row = mysql_fetch_assoc($resultID);
			$textbox = $xml->addChild("textbox");
			$textbox->addAttribute("ID", $row['textbox_id']);
			$textbox->addAttribute("text", $row['text']);
		}


		// Nodes take a bit more work.
		$query = "SELECT * FROM nodes " . $whereclause;
		$resultID = mysql_query($query, $linkID) or die("Data not found in node lookup."); 
		for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
			$row = mysql_fetch_assoc($resultID);
			$node_id = $row['node_id'];
			$node = $xml->addChild("node");
			$node->addAttribute("ID", $node_id);
			$node->addAttribute("Author", $row['user_id']);
			//Have to do this instead of a proper join for the simple reason that we don't want to have multiple instances of the same <node>
			$innerQuery="SELECT * FROM nodetext WHERE node_id=$node_id ORDER BY position ASC";
			$resultID2 = mysql_query($innerQuery, $linkID) or die("Data not found in nodetext lookup."); 
			for($y=0; $y<mysql_num_rows($resultID2); $y++){
				$nodetext = $node->addChild("nodetext");
				$innerRow=mysql_fetch_assoc($resultID2);
				$nodetext->addAttribute("ID", $innerRow['textbox_id']);
			}			
		}

		// Connections will take a lot more work.
		$query = "SELECT * FROM arguments NATURAL JOIN connection_types " . $whereclause;
		$resultID = mysql_query($query, $linkID) or die("Data not found in arg lookup.");
		for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
			$row = mysql_fetch_assoc($resultID);
			$arg_id=$row['argument_id'];
			$connection = $xml->addChild("connection");
			$connection->addAttribute("argID", $arg_id);
			$connection->addAttribute("type", $row['conn_name']);
			$connection->addAttribute("targetnode", $row['node_id']);
			//Set up the inner query to find the source nodes
			$innerQuery="SELECT * FROM connections WHERE argument_id=$arg_id";
			$resultID2 = mysql_query($innerQuery, $linkID) or die("Data not found in connection lookup");
			for($y=0; $y<mysql_num_rows($resultID2); $y++){
				$sourcenode = $connection->addChild("sourcenode");
				$innerRow=mysql_fetch_assoc($resultID2);
				$sourcenode->addAttribute("nodeID", $innerRow['node_id']);
			}	
		}
		
		
		return $xml;
	}
	$map_id = $_POST['map_id'];
	$xml = get_map($map_id); // TODO: read this number from somewhere else.
	print($xml->asXML());
?>