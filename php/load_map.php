<?php

	/**
	*	Function that loads a map from the database.
	*	Might be worth refactoring this somewhat.
	*/
	function get_map($mapID, $timestamp){
		//Standard SQL connection stuff
		//$linkID = mysql_connect("localhost", "root", "s3s@me123") or die ("Could not connect to database!");
		//$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
		$linkID = mysql_connect("localhost", "root", "root") or die ("Could not connect to database!");
		mysql_select_db("agora", $linkID) or die ("Could not find database");
		$whereclause = mysql_real_escape_string("$mapID");
		$timeclause = mysql_real_escape_string("$timestamp");
		$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE map_id = $whereclause";
		$resultID = mysql_query($query, $linkID) or die("Data not found."); 
		//Set up the basics of the XML.
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<map></map>";
		$xml = new SimpleXMLElement($xmlstr);
		$row = mysql_fetch_assoc($resultID);
		$xml->addAttribute("id", $row['map_id']);
		$xml->addAttribute("username", $row['username']);
		
		$timeID = mysql_query("SELECT NOW()", $linkID) or die ("Could not get timestamp from server.");
		$timerow = mysql_fetch_assoc($timeID);
		$now = $timerow['NOW()'];
		$xml->addAttribute("timestamp", "$now");
		
		// Textboxes are easy!
		$query = "SELECT * FROM textboxes WHERE map_id = $whereclause AND modified_date>\"$timeclause\" ORDER BY textbox_id";
		$resultID = mysql_query($query, $linkID); 
		if($resultID){
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
				$row = mysql_fetch_assoc($resultID);
				$textbox = $xml->addChild("textbox");
				$textbox->addAttribute("ID", $row['textbox_id']);
				$textbox->addAttribute("text", $row['text']);
				$textbox->addAttribute("deleted", $row['is_deleted']);
			}
		}


		// Nodes take a bit more work.
		$query = "SELECT * FROM nodes NATURAL JOIN node_types WHERE map_id = $whereclause AND modified_date>\"$timeclause\" ORDER BY node_id";
		$resultID = mysql_query($query, $linkID); 
		if($resultID){
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
				$row = mysql_fetch_assoc($resultID);
				$node_id = $row['node_id'];
				$node = $xml->addChild("node");
				$node->addAttribute("ID", $node_id);
				$node->addAttribute("Type", $row['type']);
				$node->addAttribute("Author", $row['user_id']);
				$node->addAttribute("deleted", $row['is_deleted']);
				$node->addAttribute("gridX", $row['x_coord']);
				$node->addAttribute("gridY", $row['y_coord']);
				//Have to do this instead of a proper join for the simple reason that we don't want to have multiple instances of the same <node>
				$innerQuery="SELECT * FROM nodetext WHERE node_id=$node_id ORDER BY position ASC";
				$resultID2 = mysql_query($innerQuery, $linkID) or die("Data not found in nodetext lookup."); 
				for($y=0; $y<mysql_num_rows($resultID2); $y++){
					$nodetext = $node->addChild("nodetext");
					$innerRow=mysql_fetch_assoc($resultID2);
					$nodetext->addAttribute("ID", $innerRow['textbox_id']);
				}			
			}
		}

		// sourcenodes will take a lot more work.
		$query = "SELECT * FROM connections NATURAL JOIN connection_types WHERE map_id = $whereclause AND modified_date>\"$timeclause\"";
		$resultID = mysql_query($query, $linkID);
		if($resultID){
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
				$row = mysql_fetch_assoc($resultID);
				$arg_id=$row['connection_id'];
				$connection = $xml->addChild("connection");
				$connection->addAttribute("argID", $arg_id);
				$connection->addAttribute("type", $row['conn_name']);
				$connection->addAttribute("targetnode", $row['node_id']);
				$connection->addAttribute("deleted", $row['is_deleted']);
				$connection->addAttribute("gridX", $row['x_coord']);
				$connection->addAttribute("gridY", $row['y_coord']);
				//Set up the inner query to find the source nodes
				$innerQuery="SELECT * FROM sourcenodes WHERE connection_id=$arg_id";
				$resultID2 = mysql_query($innerQuery, $linkID) or die("Data not found in connection lookup");
				for($y=0; $y<mysql_num_rows($resultID2); $y++){
					$sourcenode = $connection->addChild("sourcenode");
					$innerRow=mysql_fetch_assoc($resultID2);
					$sourcenode->addAttribute("nodeID", $innerRow['node_id']);
				}	
			}
		}
		return $xml;
	}
	$map_id = $_REQUEST['map_id'];  //TODO: Change this back to a GET when all testing is done.
	$timestamp = $_REQUEST['timestamp'];  //TODO: Change this back to a GET when all testing is done.
	$xml = get_map($map_id, $timestamp); 
	print($xml->asXML());
?>