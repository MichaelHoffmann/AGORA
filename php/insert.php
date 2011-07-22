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

/**
List of variables for insertion:
	* HTTP Query variables:
	xml: The XML of map data to insert
	uid: User ID of the user inserting the data
	pass_hash: the hashed password of the user inserting the data
	
	* XML data:
		MAP level:
			id or ID: the ID of the map to be modified. 0 or nonexistent creates a new map and ignores everything else.
			title: Title of the map (for new maps only)
			desc: Description of the map (for new maps only)
			lang: Language of the map (for new maps only)
		
		IN-MAP level:
			textbox: insert or modify a textbox
				text: The text the user typed into the box (or default text)
				ID: ID of an existing textbox
				TID: temporary (client) ID of a new textbox, will get an ID in the db and returned to the client
			node: insert or modify a node
				ID: ID of an existing node
				TID: temporary (client) ID of a new node, will get an ID in the db and returned to the client
				Type: Type of a node. See nodetypes table in database for a listing. Use the name.
				x: x-coordinate of a node on the map
				y: y-coordinate of a node on the map
				typed: Whether the node has been typed or still contains default text
				is_positive: Whether the argument is positive or not (logically speaking).
				
				* nodetext: link between a node and textbox. Due to hierarchy, it only needs one variable.
					textboxID: ID of the textbox.
					(NOTE: Position comes from ordering of the nodetexts. As a result, if ANY nodetext relationship is updated, 
							ALL nodetexts must be included- even without change.)
			connection: insert or modify a connection (arguments, objections, etc.)
				ID: ID of an existing connection
				TID: temporary (client) ID of a new connection, will get an ID in the db and returned to the client
				targetnodeID: ID of the node the argument is supporting. This is the SINGLE node that has an arrow pointing to it.
				targetnodeTID: Temporary ID of the same (for when a new node and connection go in simultaneously)
				x: x-coordinate of the argument's position on the map
				y: y-coordinate of the argument's position on the map

				* sourcenode: link between supporting nodes and the argument. There can be as many of these as needed.
					TID: Temporary (client) ID. No real ID is ever allowed, since modifying a relationship is nonsensical.
							Delete the old one and add a new one instead, or modify the text in the node.
					nodeID: ID of the node, if you're connecting an existing node to the argument (two-step process)
					nodeTID: Temporary ID of the node, for when you're doing it all in one step.

*/
	require 'configure.php';
	require 'checklogin.php';
	require 'establish_link.php';
	
	
	$tbTIDarray;
	$nodeTIDarray;
	/**
	* Convenience function.
	* Selects the last auto-generated ID (AUTO_INCREMENT) from the Database.
	* See the following for the function that this uses:
	* http://php.net/manual/en/function.mysql-insert-id.php
	*/
	function getLastInsert($linkID)
	{
		$query = "SELECT LAST_INSERT_ID()";
		$resultID = mysql_query($query, $linkID);
		$row = mysql_fetch_assoc($resultID);
		return $row['LAST_INSERT_ID()'];
	}

	/**
	*	Takes a textbox and gets the necessary information from XML into the DB.
	*/
	function textboxToDB($tb, $mapID, $linkID, $userID, $output)
	{
		global $tbTIDarray;
		//print "<BR>---Textbox found";
		$attr = $tb->attributes();
		$text = mysql_real_escape_string($attr["text"]);
		$id = $attr["ID"];
		if($id){
			//print "<BR>Textbox ID is $id";
			$query = "SELECT * FROM textboxes WHERE textbox_id=$id";
			//print "<BR>author check query: $query";
			$resultID = mysql_query($query, $linkID);
			$row = mysql_fetch_assoc($resultID);
			$dbUID = $row["user_id"];
			//print "<BR>UID out of the database: $dbUID";
			if($userID == $dbUID){
				$uquery = "UPDATE textboxes SET text='$text', modified_date=NOW() WHERE textbox_id=$id";
				//print "<BR>Update query: $uquery";
				$status = mysql_query($uquery, $linkID);
				//print "<BR>Query executed! Status: $status";
			}else{
				$fail=$output->addChild("error");
				$fail->addAttribute("text", "You are attempting to modify someone else's work or a nonexistent textbox. This is not permissible.");
				return false;
			}
			

		}else{	
			$tid = mysql_real_escape_string($attr["TID"]);
			$iquery = "INSERT INTO textboxes (user_id, map_id, text, created_date, modified_date) VALUES
										($userID, $mapID, '$text', NOW(), NOW())";
			//print "<BR>Query: $iquery";
			$success = mysql_query($iquery, $linkID);
			if(!$success){
				$fail=$output->addChild("error");
				$fail->addAttribute("text", "The textbox insert failed: $iquery");
				return false;
			}
			$newID = getLastInsert($linkID);
			$textbox=$output->addChild("textbox");
			$textbox->addAttribute("TID", $tid);
			$textbox->addAttribute("ID", $newID);
			
			$tbTIDarray[$tid]=$newID; // Add the TID->ID mapping to the global lookup array
		}
		return true;
	}

	/**
	*	Takes a nodetext link and inserts it into the database.
	*/
	function nodeTextToDB($nt, $nodeID, $linkID, $userID, $position, $output)
	{
		global $tbTIDarray; //use the global variable
		
		//print "<BR>NodeText found";
		$attr = $nt->attributes();
		$cBy = $attr['connected_by'];
		if(!$cBy){
			$cBy='implication';
		}
		$textboxID = mysql_real_escape_string($attr["textboxID"]);
		
		$query = "SELECT * FROM nodetext WHERE node_id=$nodeID AND position=$position";
		$resultID = mysql_query($query, $linkID);
		$row = mysql_fetch_assoc($resultID);
		$ntID = $row['nodetext_id'];
		if($ntID){
			//update should ALWAYS have a real textbox ID.
			$uquery = "UPDATE nodetext SET textbox_id=$textboxID, connected_by=$cBy, modified_date=NOW() WHERE nodetext_id=$ntID";
			//print "<BR>Update query is: $uquery";
			$success = mysql_query($uquery, $linkID);
			if(!$success){
				$fail=$output->addChild("error");
				$fail->addAttribute("text", "Unable to update the NODETEXT link. Query was: $uquery");
				return false;
			}
		}else{
			//insert
			$tid = mysql_real_escape_string($attr["TID"]);
			//insert with real textbox ID
			if($textboxID){
				//We are here given the real textbox ID to put into a new nodetext position (new node, or new position in an existing node)
				$iquery = "INSERT INTO nodetext (node_id, textbox_id, position, connected_by, created_date, modified_date) VALUES
							($nodeID, $textboxID, $position, $cBy, NOW(), NOW())";
				$success=mysql_query($iquery, $linkID);
				if(!$success){
					$fail=$output->addChild("error");
					$fail->addAttribute("text", "Unable to insert the NODETEXT. Query was: $iquery");
					return false;
				}
			//insert with textbox TID
			}else{
				$tTID = mysql_real_escape_string($attr["textboxTID"]);
				$textID=$tbTIDarray[$tTID];
				
				$iquery = "INSERT INTO nodetext (node_id, textbox_id, position, connected_by, created_date, modified_date) VALUES 
							($nodeID, $textID, $position, '$cBy', NOW(), NOW())";
				
				$success = mysql_query($iquery, $linkID);
				if(!$success){
					$fail=$output->addChild("error");
					$fail->addAttribute("text", "Unable to insert the NODETEXT. Query was: $iquery");
					return false;
				}
			}
			//shared actions for ntTID logic
			$outID = getLastInsert($linkID);
			$ntOut=$output->addChild("nodetext");
			$ntOut->addAttribute("TID", $tid);
			$ntOut->addAttribute("ID", $outID);
		}
		return true;
	}
	/**
	*	Takes a node from XML and puts it in the database.
	*/
	function nodeToDB($node, $mapID, $linkID, $userID, $output)
	{
		global $nodeTIDarray;
		
		//print "<BR>----Node found";
		$nodeOut = null; // Done for later scoping
		$attr = $node->attributes();
		$nodeID = mysql_real_escape_string($attr["ID"]);
		$type = mysql_real_escape_string($attr["Type"]);
		$x = mysql_real_escape_string($attr["x"]);
		$y = mysql_real_escape_string($attr["y"]);
		$typed = mysql_real_escape_string($attr["typed"]);
		$positivity = mysql_real_escape_string($attr["is_positive"]);
		$query = "SELECT * FROM node_types WHERE type='$type'";
		//print "<BR>Query is: $query";
		$resultID = mysql_query($query, $linkID);
		$row = mysql_fetch_assoc($resultID);
		$typeID = $row['nodetype_id'];
		//print "<BR>Type ID is $typeID";
		if($nodeID){		
			//update
			//print "<BR>Node ID is $nodeID";
			$query = "SELECT * FROM nodes WHERE node_id=$nodeID";
			//print "<BR>author check query: $query";
			$resultID = mysql_query($query, $linkID);
			$row = mysql_fetch_assoc($resultID);
			$dbUID = $row["user_id"];
			
			//print "<BR>UID out of the database: $dbUID";
			if($userID == $dbUID){
				$uquery = "UPDATE nodes SET nodetype_id=$typeID, modified_date=NOW(), x_coord=$x, y_coord=$y, typed=$typed, is_positive=$positivity
							WHERE node_id=$nodeID";
				$success=mysql_query($uquery, $linkID);
				if(!$success){
					$fail=$output->addChild("error");
					$fail->addAttribute("text", "Unable to update the NODE. Query was: $uquery");
					return false;
				}else{
					$nodeOut=$output->addChild("node");
					$nodeOut->addAttribute("ID", $nodeID);
				}
			}else{
				$fail=$output->addChild("error");
				$fail->addAttribute("text", "You are attempting to modify someone else's work or a nonexistent node. This is not permissible.");
				return false;
			}
		}else{
			//insert
			$tid = mysql_real_escape_string($attr["TID"]);		
			$iquery = "INSERT INTO nodes (user_id, map_id, nodetype_id, created_date, modified_date, x_coord, y_coord, typed, is_positive) VALUES
										($userID, $mapID, $typeID, NOW(), NOW(), $x, $y, $typed, $positivity)";
			$success=mysql_query($iquery, $linkID);
			if(!$success){
				$fail=$output->addChild("error");
				$fail->addAttribute("text", "Unable to add the NODE. Query was: $iquery");
				return false;
			}else{
				$nodeID = getLastInsert($linkID);
				$nodeOut=$output->addChild("node");
				$nodeOut->addAttribute("TID", $tid);
				$nodeOut->addAttribute("ID", $nodeID);
				$nodeTIDarray[$tid]=$nodeID; // Add the TID->ID mapping to the global lookup array
			}
		}
		$children = $node->children();
		$pos = 0;
		foreach ($children as $child)
		{
			$pos++;
			//$nodeOut is still in scope here because PHP's scoping rules are relaxed.
			nodeTextToDB($child, $nodeID, $linkID, $userID, $pos, $nodeOut);
			
			//Note that this won't be done if the owner check failed on an UPDATE
			//because the update will return false.
			//This behavior is correct:
			//if someone can't update a node they shouldn't be able to change its nodetext information.
			//(Also, they should fail the textbox owner check as well.)
		}
		return true;
	}
	
	/**
	*	Links between nodes and connections in the DB.
	*/
	function sourceNodeToDB($source, $connID, $linkID, $output)
	{	
		global $nodeTIDarray;
		//Source Nodes don't have to worry about being updated.
		//They can only be DELETED or INSERTED.
		//They get DELETED automatically when the NODE they connect to is DELETED.
		//print "<BR>SourceNode found";
		$attr = $source->attributes();
		$tid =  mysql_real_escape_string($attr["TID"]);
		$nodeID = mysql_real_escape_string($attr["nodeID"]);
		if(!$nodeID){
			$nodeTID = mysql_real_escape_string($attr["nodeTID"]);
			$nodeID = $nodeTIDarray[$nodeTID];
		}
		
		$iquery = "INSERT INTO sourcenodes (connection_id, node_id, created_date, modified_date) VALUES
											($connID, $nodeID, NOW(), NOW())";
		//print "<BR>Insert Query is: $iquery";
		$success = mysql_query($iquery, $linkID);
		if($success){
			$outID = getLastInsert($linkID);
			$sourcenode = $output->addChild("sourcenode");
			$sourcenode->addAttribute("TID", $tid);
			$sourcenode->addAttribute("ID", $outID);
		}else{
			$fail=$output->addChild("error");
			$fail->addAttribute("text", "The source node is not being added properly. Query was: $iquery");
			return false;
		}
		return true;
	}
	
	/**
	*	Defines the "argument" part of a connection in the DB.
	*/
	function connectionToDB($conn, $mapID, $linkID, $userID, $output)
	{
		global $nodeTIDarray;
		//print "<BR>---Connection found";
		$connection = $output->addChild("connection");
		$attr = $conn->attributes();
		$id = mysql_real_escape_string($attr["ID"]);
		$tid = mysql_real_escape_string($attr["TID"]);
		$nodeID = mysql_real_escape_string($attr["targetnodeID"]);
		$x = mysql_real_escape_string($attr["x"]);
		$y = mysql_real_escape_string($attr["y"]);
		
		//get Type ID since that's what we need
		$type = mysql_real_escape_string($attr["type"]);
		$query1 = "SELECT * FROM connection_types WHERE conn_name = '$type'";
		$resultID = mysql_query($query1, $linkID);
		$row = mysql_fetch_assoc($resultID);
		$typeID = $row["type_id"];
		
		if(!$nodeID){
			$tnodeTID = mysql_real_escape_string($attr["targetnodeTID"]);
			$nodeID=$nodeTIDarray[$tnodeTID];
		}
		
		if(!$id){
			//Insert the connection into the DB (target node and info)
			$iquery = "INSERT INTO connections (user_id, map_id, node_id, type_id, x_coord, y_coord, created_date, modified_date) VALUES
											($userID, $mapID, $nodeID, $typeID, $x, $y, NOW(), NOW())";
			//print "<BR>Insert Query is: $iquery";
			$success = mysql_query($iquery, $linkID);
			if(!$success){
				$fail=$output->addChild("error");
				$fail->addAttribute("text", "Unable to add the CONNECTION. Query was: $iquery");
				return false;
			}else{
				$id = getLastInsert($linkID);
				$connection->addAttribute("TID", $tid);
				$connection->addAttribute("ID", $id);
			}
		}else{
			//Update TYPE of the connection
			//It's not legal to change what node the connection is targeting.
			$uquery = "UPDATE connections SET type_id = $typeID, modified_date=NOW(), x_coord=$x, y_coord=$y WHERE connection_id=$id";
			//print "<BR>Update query: $uquery";
			$success=mysql_query($uquery, $linkID);
			if(!$success){
				$fail=$output->addChild("error");
				$fail->addAttribute("text", "Unable to update the CONNECTION. Query was: $uquery");
				return false;
			}
			$connection->addAttribute("ID", $id);
		}
		//Get the source nodes
		$children = $conn->children();
		foreach ($children as $child)
		{
			sourceNodeToDB($child, $id, $linkID, $connection);
		}
		return true;
	}
	
	/**
	*	Convenience function that iterates through the XML to find all the pieces.
	*	Separated out for clarity.
	*	Order doesn't matter, so long as there's nothing referencing things that don't exist yet.
	*/
	function xmlToDB($xml, $mapID, $linkID, $userID, $output)
	{
		//print "Now in xml-to-DB function<BR>";
		$children = $xml->children();
		//print count($children);

		foreach ($children as $child)
		{
			switch($child->getName())
			{
				case "textbox":
					//print "textbox";
					$success = textboxToDB($child, $mapID, $linkID, $userID, $output);
					if(!$success){
						return false;
					}
					break;
				case "node":
					//print "node";
					$success = nodeToDB($child, $mapID, $linkID, $userID, $output);
					if(!$success){
						return false;
					}
					break;
				case "connection":
					//print "conn";
					$success = connectionToDB($child, $mapID, $linkID, $userID, $output);
					if(!$success){
						return false;
					}
					break;
			}
		}		
		return true;
	}
	
	/**
	*	Highest-level function, that does the top level logic.
	*/
	function insert($xmlin, $userID, $pass_hash)
	{
		global $dbName, $version;
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<map version='$version'></map>";
		$output = new SimpleXMLElement($xmlstr);
		$linkID= establishLink();
		mysql_select_db($dbName, $linkID) or die ("error: Could not find database");

		if(!checkLogin($userID, $pass_hash, $linkID)){
			$fail=$output->addChild("error");
			$fail->addAttribute("text", "Incorrect Login!");
			return $output;
		}
	
		//Dig the Map ID out of the XML
		try{
			$xml = new SimpleXMLElement($xmlin);
		}catch(Exception $e){
			$fail=$output->addChild("error");
			$fail->addAttribute("text", "Improperly formatted input XML!");
		}
		$mapID = $xml['ID']; 
		$mapClause = mysql_real_escape_string("$mapID");
		//A backwards-compatible fix to allow lowercase-id to continue working to avoid breaking client code:
		$mapID = $xml['id'];
		if($mapID && !$mapClause){
			$mapClause=$mapID;
		}

		//Check to see if the map already exists
		if($mapClause==0){
			//If not, create it!
			$title = mysql_real_escape_string($xml['title']);
			if(!$title){
				$title = "Untitled Map";
			}
			$desc = mysql_real_escape_string($xml['desc']);
			if(!$desc){
				$desc = "No description";
			}
			
			$lang = mysql_real_escape_string($xml['lang']);
			if(!$lang){
				$lang="EN-US";
			}
			$iquery = "INSERT INTO maps (user_id, title, description, lang, created_date, modified_date) VALUES
										($userID, '$title', '$desc', '$lang', NOW(), NOW())";
			mysql_query($iquery, $linkID);						
			$mapClause = getLastInsert($linkID);
			if(!$mapClause){
				$fail=$output->addChild("error");
				$fail->addAttribute("text", "The map was not added properly. Query: $iquery");
			}
			
			$output->addAttribute("ID", $mapClause);
		}

		$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE map_id = $mapClause";
		$resultID = mysql_query($query, $linkID) or die ("error: Cannot get map!"); 
		$row = mysql_fetch_assoc($resultID);
		
		//Check to see if this is the map author
		//If so, $ownMap is set to true.
		
		$author = $row['user_id'];
		$ownMap = false;
		if($author == $userID){
			$ownMap=true;
			//TODO: Use this to determine if the INSERTIONS are legal
			//We need to establish a clear policy on what insertions *are* legal, though.
			//That will be done on the Node and Connection levels.
			//It hinges on the TYPES of nodes and connections, which haven't been fully established yet.
			
			//(Note that UPDATES are checked against ownership of that individual thing)
		}
		
		//This part neatly handles all possibilities of failure. All we have to do is chain back "false" returns.
		mysql_query("START TRANSACTION");
		
		$success = xmlToDB($xml, $mapClause, $linkID, $userID, $output);
		if($success===true){
			mysql_query("COMMIT");
		}else{
			mysql_query("ROLLBACK");
			$fail=$output->addChild("error");
			$fail->addAttribute("text", "The queries have been rolled back!");
		}
		return $output;
		
	}
	$xmlparam = $_REQUEST['xml']; //TODO: Change this back to a GET when all testing is done.
	$userID = $_REQUEST['uid'];
	$pass_hash = $_REQUEST['pass_hash'];
	$output = insert($xmlparam, $userID, $pass_hash); 
	print($output->asXML());
?>
