<?php

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
				$uquery = "UPDATE textboxes SET text=\"$text\", modified_date=NOW() WHERE textbox_id=$id";
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
										($userID, $mapID, \"$text\", NOW(), NOW())";
			//print "<BR>Query: $iquery";
			mysql_query($iquery, $linkID);
			$newID = getLastInsert($linkID);
			$textbox=$output->addChild("textbox");
			$textbox->addAttribute("TID", $tid);
			$textbox->addAttribute("ID", $newID);
			
			$tbTIDarray[$tid]=$newID; // Add the TID->ID mapping to the global lookup array
		}
	}

	/**
	*	Takes a nodetext link and inserts it into the database.
	*/
	function nodeTextToDB($nt, $nodeID, $linkID, $userID, $position, $output)
	{
		global $tbTIDarray; //use the global variable
		
		//print "<BR>NodeText found";
		$attr = $nt->attributes();
		$textboxID = mysql_real_escape_string($attr["textboxID"]);
		
		$query = "SELECT * FROM nodetext WHERE node_id=$nodeID AND position=$position";
		$resultID = mysql_query($query, $linkID);
		$row = mysql_fetch_assoc($resultID);
		$ntID = $row['nodetext_id'];
		
		if($ntID){
			//update should ALWAYS have a real textbox ID.
			$uquery = "UPDATE nodetext SET textbox_id=$textboxID, modified_date=NOW() WHERE nodetext_id=$ntID";
			//print "<BR>Update query is: $uquery";
			mysql_query($uquery, $linkID);
		}else{
			//insert
			if($textboxID){
				//We are here given the real textbox ID to put into a new nodetext position (new node, or new position in an existing node)
				$iquery = "INSERT INTO nodetext (node_id, textbox_id, position, created_date, modified_date) VALUES
							($nodeID, $textboxID, $position, NOW(), NOW())";
				//print "<BR>Insert Query is: $iquery";
				mysql_query($iquery, $linkID);
				
			}else{
				$tid = mysql_real_escape_string($attr["TID"]);
				$tTID = mysql_real_escape_string($attr["textboxTID"]);
				$textID=$tbTIDarray[$tTID];
				
				$iquery = "INSERT INTO nodetext (node_id, textbox_id, position, created_date, modified_date) VALUES 
							($nodeID, $textID, $position, NOW(), NOW())";
				
				mysql_query($iquery, $linkID);
				
				$outID = getLastInsert($linkID);
				$ntOut=$output->addChild("nodetext");
				$ntOut->addAttribute("TID", $tid);
				$ntOut->addAttribute("ID", $outID);
			}
		}
	}
	/**
	*	Takes a node from XML and puts it in the database.
	*/
	function nodeToDB($node, $mapID, $linkID, $userID, $output)
	{
		global $nodeTIDarray;
		
		//print "<BR>----Node found";
		$attr = $node->attributes();
		$nodeID = mysql_real_escape_string($attr["ID"]);
		$type = mysql_real_escape_string($attr["Type"]);
		$x = mysql_real_escape_string($attr["x"]);
		$y = mysql_real_escape_string($attr["y"]);
		$query = "SELECT * FROM node_types WHERE type=\"$type\"";
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
				$uquery = "UPDATE nodes SET nodetype_id=$typeID, modified_date=NOW(), x_coord=$x, y_coord=$y WHERE node_id=$nodeID";
				//print "<BR>Update Query is: $uquery";							
				$status=mysql_query($uquery, $linkID);
				//print "<BR>Query executed! Status: $status";
			}else{
				//print "<BR>You are attempting to modify someone else's work or a nonexistent textbox. This is not permissible.";
				return false;
			}
		
		
			$uquery = "UPDATE nodes SET nodetype_id=$typeID, modified_date=NOW(), x_coord=$x, y_coord=$y WHERE node_id=$nodeID";
			//print "<BR>Update Query is: $uquery";							
			mysql_query($uquery, $linkID);
		}else{
			//insert
			$tid = mysql_real_escape_string($attr["TID"]);		
			$iquery = "INSERT INTO nodes (user_id, map_id, nodetype_id, created_date, modified_date, x_coord, y_coord) VALUES
										($userID, $mapID, $typeID, NOW(), NOW(), $x, $y)";
			//print "<BR>Insert Query is: $iquery";							
			mysql_query($iquery, $linkID);
			$nodeID = getLastInsert($linkID);
			$nodeOut=$output->addChild("node");
			$nodeOut->addAttribute("TID", $tid);
			$nodeOut->addAttribute("ID", $nodeID);
			
			$nodeTIDarray[$tid]=$nodeID; // Add the TID->ID mapping to the global lookup array
			
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
		}
	}
	
	/**
	*	Defines the "argument" part of a connection in the DB.
	*/
	function connectionToDB($conn, $mapID, $linkID, $userID, $output)
	{
		global $nodeTIDarray;
		//print "<BR>---Connection found";
		$attr = $conn->attributes();
		$id = mysql_real_escape_string($attr["ID"]);
		$nodeID = mysql_real_escape_string($attr["targetnodeID"]);
		$x = mysql_real_escape_string($attr["x"]);
		$y = mysql_real_escape_string($attr["y"]);
		
		//get Type ID since that's what we need
		$type = mysql_real_escape_string($attr["type"]);
		$query1 = "SELECT * FROM connection_types WHERE conn_name = \"$type\"";
		$resultID = mysql_query($query1, $linkID);
		$row = mysql_fetch_assoc($resultID);
		$typeID = $row["type_id"];
		
		$tid = mysql_real_escape_string($attr["TID"]);
		
		if(!$nodeID){
			$tnodeTID = mysql_real_escape_string($attr["targetnodeTID"]);
			$nodeID=$nodeTIDarray[$tnodeTID];
		}
		
		if(!$id){
			//Insert the connection into the DB (target node and info)
			$iquery = "INSERT INTO connections (user_id, map_id, node_id, type_id, x_coord, y_coord, created_date, modified_date) VALUES
											($userID, $mapID, $nodeID, $typeID, $x, $y, NOW(), NOW())";
			//print "<BR>Insert Query is: $iquery";
			mysql_query($iquery, $linkID);
			$id = getLastInsert($linkID);
			$connection = $output->addChild("connection");
			$connection->addAttribute("TID", $tid);
			$connection->addAttribute("ID", $id);
			
		}else{
			//Update TYPE of the connection
			//It's not legal to change what node the connection is targeting.
			$uquery = "UPDATE connections SET type_id = $typeID, modified_date=NOW(), x_coord=$x, y_coord=$y WHERE connection_id=$id";
			//print "<BR>Update query: $uquery";
			mysql_query($uquery, $linkID);
		
		}
		//Get the source nodes
		$children = $conn->children();
		foreach ($children as $child)
		{
			sourceNodeToDB($child, $id, $linkID, $connection);
		}
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
					textboxToDB($child, $mapID, $linkID, $userID, $output);
					break;
				case "node":
					nodeToDB($child, $mapID, $linkID, $userID, $output);
					break;
				case "connection":
					connectionToDB($child, $mapID, $linkID, $userID, $output);
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
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<map></map>";
		$output = new SimpleXMLElement($xmlstr);
		
		$linkID= establishLink();
		mysql_select_db("agora", $linkID) or die ("Could not find database");

		if(!checkLogin($userID, $pass_hash, $linkID)){
			//print "Incorrect login!";
			return;
		}
	
	
		//Dig the Map ID out of the XML
		$xml = new SimpleXMLElement($xmlin);
		$mapID = $xml['id'];
		$mapClause = mysql_real_escape_string("$mapID");
		
		$lang = mysql_real_escape_string($xml['lang']);
		if(!$lang){
			$lang="EN-US";
		}

		//Check to see if the map already exists
		if($mapClause==0){
			//If not, create it!
			$iquery = "INSERT INTO maps (user_id, title, description, lang, created_date, modified_date) VALUES
										($userID, 'Example', 'Description', \"$lang\", NOW(), NOW())";
			mysql_query($iquery, $linkID);						
			$mapClause = getLastInsert($linkID);
			if(!$mapClause){
				$fail=$output->addChild("error");
				$fail->addAttribute("text", "The map was not added properly. Query: $iquery");
			}
			
			$output->addAttribute("ID", $mapClause);
		}

		$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE map_id = $mapClause";
		$resultID = mysql_query($query, $linkID) or die ("Cannot get map!"); 
		$row = mysql_fetch_assoc($resultID);
		
		//Check to see if this is the map author
		//If so, $ownMap is set to true.
		
		$author = $row['user_id'];
		//print "Author: $author  Map: $mapClause <BR>";
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
			//print "<BR>Query committed!<BR>";
		}else{
			mysql_query("ROLLBACK");
			//print "<BR>Query rolled back!<BR>";
		}
		return $output;
		
	}
	$xmlparam = $_REQUEST['xml']; //TODO: Change this back to a GET when all testing is done.
	$userID = $_REQUEST['uid'];
	$pass_hash = $_REQUEST['pass_hash'];
	$output = insert($xmlparam, $userID, $pass_hash); 
	print($output->asXML());
?>
