<?php
	require 'establish_link.php';
	/**
	*	Function that loads a map from the database.
	*	Might be worth refactoring this somewhat.
	*/
	function get_map($mapID, $timestamp){
		//Standard SQL connection stuff
		$linkID= establishLink();
		mysql_select_db("agora", $linkID) or die ("Could not find database");
		$whereclause = mysql_real_escape_string("$mapID");
		$timeclause = mysql_real_escape_string("$timestamp");
		$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE map_id = $whereclause AND maps.is_deleted = 0";
		$resultID = mysql_query($query, $linkID) or die("Data not found."); 
		if(mysql_num_rows($resultID)==0){
			print "The map either does not exist or has been deleted. Query was: $query";
			return false;
		}
		
		//Set up the basics of the XML.
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<map></map>";
		$xml = new SimpleXMLElement($xmlstr);
		$row = mysql_fetch_assoc($resultID);
		$xml->addAttribute("ID", $row['map_id']);
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
		$query = "SELECT * FROM nodes INNER JOIN users ON nodes.user_id=users.user_id NATURAL JOIN node_types 
			WHERE map_id = $whereclause AND modified_date>\"$timeclause\" ORDER BY node_id";
		$resultID = mysql_query($query, $linkID); 
		if($resultID){
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
				$row = mysql_fetch_assoc($resultID);
				$node_id = $row['node_id'];
				$node = $xml->addChild("node");
				$node->addAttribute("ID", $node_id);
				$node->addAttribute("Type", $row['type']);
				$node->addAttribute("Author", $row['username']);
				$node->addAttribute("x", $row['x_coord']);
				$node->addAttribute("y", $row['y_coord']);
				$node->addAttribute("typed", $row['typed']);
				$node->addAttribute("positive", $row['is_positive']);				
				$node->addAttribute("deleted", $row['is_deleted']);
				//Have to do this instead of a proper join for the simple reason that we don't want to have multiple instances of the same <node>
				$innerQuery="SELECT * FROM nodetext WHERE node_id=$node_id ORDER BY position ASC";
				$resultID2 = mysql_query($innerQuery, $linkID) or die("Data not found in nodetext lookup."); 
				for($y=0; $y<mysql_num_rows($resultID2); $y++){
					$nodetext = $node->addChild("nodetext");
					$innerRow=mysql_fetch_assoc($resultID2);
					$nodetext->addAttribute("ID", $innerRow['nodetext_id']);
					$nodetext->addAttribute("textboxID", $innerRow['textbox_id']);
					$nodetext->addAttribute("deleted", $innerRow['is_deleted']);
				}			
			}
		}

		// sourcenodes will take a lot more work.
		$query = "SELECT * FROM connections NATURAL JOIN connection_types WHERE map_id = $whereclause AND modified_date>\"$timeclause\"";
		$resultID = mysql_query($query, $linkID);
		if($resultID){
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
				$row = mysql_fetch_assoc($resultID);
				$conn_id=$row['connection_id'];
				$connection = $xml->addChild("connection");
				$connection->addAttribute("connID", $conn_id);
				$connection->addAttribute("type", $row['conn_name']);
				$connection->addAttribute("targetnode", $row['node_id']);
				$connection->addAttribute("x", $row['x_coord']);
				$connection->addAttribute("y", $row['y_coord']);
				$connection->addAttribute("deleted", $row['is_deleted']);
				//Set up the inner query to find the source nodes
				$innerQuery="SELECT * FROM sourcenodes WHERE connection_id=$conn_id";
				$resultID2 = mysql_query($innerQuery, $linkID) or die("Data not found in connection lookup");
				for($y=0; $y<mysql_num_rows($resultID2); $y++){
					$sourcenode = $connection->addChild("sourcenode");
					$innerRow=mysql_fetch_assoc($resultID2);
					$sourcenode->addAttribute("ID", $innerRow['sn_id']);
					$sourcenode->addAttribute("nodeID", $innerRow['node_id']);
					$sourcenode->addAttribute("deleted", $innerRow['is_deleted']);
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
