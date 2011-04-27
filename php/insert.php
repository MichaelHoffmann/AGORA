<?php

	require 'checklogin.php';

	function getLastInsert($linkID)
	{
		$query = "SELECT LAST_INSERT_ID()";
		$resultID = mysql_query($query, $linkID);
		$row = mysql_fetch_assoc($resultID);
		return $row['LAST_INSERT_ID()'];
		print "New Textbox ID: $mapClause <BR>";
	}

	function textboxToDB($tb, $mapID, $linkID, $userID)
	{
		print "<BR>---Textbox found";
		$attr = $tb->attributes();
		$text = mysql_real_escape_string($attr["text"]);
		$id = $attr["ID"];
		if($id){
			//TODO: add author check
			print "<BR>Textbox ID is $id";
			$uquery = "UPDATE textboxes SET text=\"$text\", modified_date=NOW() WHERE textbox_id=$id";
			print "<BR>Update query: $uquery";
			$status = mysql_query($uquery, $linkID);
			print "<BR>Query executed! Status: $status";
		}else{	
			$tid = mysql_real_escape_string($attr["TID"]);
			$iquery = "INSERT INTO textboxes (textbox_tid, user_id, map_id, text, created_date, modified_date) VALUES
										($tid, $userID, $mapID, \"$text\", NOW(), NOW())";
			print "<BR>Query: $iquery";
			mysql_query($iquery, $linkID);
			$newID = getLastInsert($linkID);
			print "<BR>New textbox ID: $newID";
		}
	}

	function nodeTextToDB($nt, $nodeID, $linkID, $userID, $position)
	{
		print "<BR>NodeText found";
		$attr = $nt->attributes();
		$textboxID = mysql_real_escape_string($attr["textboxID"]);
		
		$query = "SELECT * FROM nodetext WHERE node_id=$nodeID AND position=$position";
		$resultID = mysql_query($query, $linkID);
		$row = mysql_fetch_assoc($resultID);
		$ntID = $row['nodetext_id'];
		
		if($ntID){
			//update should ALWAYS have a real textbox ID.
			$uquery = "UPDATE nodetext SET textbox_id=$textboxID, modified_date=NOW() WHERE nodetext_id=$ntID";
			print "<BR>Update query is: $uquery";
			mysql_query($uquery, $linkID);
		}else{
			//insert
				if($textboxID){
				//We are here given the real textbox ID to put into a new nodetext position (new node, or new position in an existing node)
				$iquery = "INSERT INTO nodetext (node_id, textbox_id, position, created_date, modified_date) VALUES
							($nodeID, $textboxID, $position, NOW(), NOW())";
				print "<BR>Insert Query is: $iquery";
				mysql_query($iquery, $linkID);
				
			}else{
				$tTID = mysql_real_escape_string($attr["textboxTID"]);
				$query = "SELECT * from textboxes WHERE textbox_tid = $tTID";
				$resultID = mysql_query($query, $linkID);
				$row = mysql_fetch_assoc($resultID);
				$textID = $row['textbox_id'];
				print "<BR>Textbox $textID found";
				$iquery = "INSERT INTO nodetext (node_id, textbox_id, position, created_date, modified_date) VALUES
							($nodeID, $textID, $position, NOW(), NOW())";
				print "<BR>Insert Query is: $iquery";
				mysql_query($iquery, $linkID);
			}
		}
	}
	
	function nodeToDB($node, $mapID, $linkID, $userID)
	{
		print "<BR>----Node found";
		$attr = $node->attributes();
		$nodeID = mysql_real_escape_string($attr["ID"]);
		$type = mysql_real_escape_string($attr["Type"]);
		$x = mysql_real_escape_string($attr["x"]);
		$y = mysql_real_escape_string($attr["y"]);
		$query = "SELECT * FROM node_types WHERE type=\"$type\"";
		print "<BR>Query is: $query";
		$resultID = mysql_query($query, $linkID);
		$row = mysql_fetch_assoc($resultID);
		$typeID = $row['nodetype_id'];
		print "<BR>Type ID is $typeID";
		if($nodeID){
			$iquery = "INSERT INTO nodes (node_id, user_id, map_id, nodetype_id, created_date, modified_date, x_coord, y_coord) VALUES
										($nodeID, $userID, $mapID, $typeID, NOW(), NOW(), $x, $y)";
		}else{
			$tid = mysql_real_escape_string($attr["TID"]);		
			$iquery = "INSERT INTO nodes (node_tid, user_id, map_id, nodetype_id, created_date, modified_date, x_coord, y_coord) VALUES
										($tid, $userID, $mapID, $typeID, NOW(), NOW(), $x, $y)";
			print "<BR>Insert Query is: $iquery";							
			mysql_query($iquery, $linkID);
			$nodeID = getLastInsert($linkID);
			print "<BR>New node ID: $nodeID";
		}
		$children = $node->children();
		$pos = 0;
		foreach ($children as $child)
		{
			$pos++;
			nodeTextToDB($child, $nodeID, $linkID, $userID, $pos);
		}
	}
	function sourceNodeToDB($source, $argID, $linkID)
	{
		print "<BR>SourceNode found";
		$attr = $source->attributes();
		$nodeTID = mysql_real_escape_string($attr["nodeTID"]);
		$query = "SELECT * from nodes WHERE node_tid = $nodeTID";
		$resultID = mysql_query($query, $linkID);
		$row = mysql_fetch_assoc($resultID);
		$nodeID = $row['node_id'];
		
		$iquery = "INSERT INTO connections (argument_id, node_id, created_date, modified_date) VALUES
											($argID, $nodeID, NOW(), NOW())";
		print "<BR>Insert Query is: $iquery";
		mysql_query($iquery, $linkID);
		
	}
	function connectionToDB($conn, $mapID, $linkID, $userID)
	{
		print "<BR>---Connection found";
		$attr = $conn->attributes();
		$tid = mysql_real_escape_string($attr["argTID"]);
		$type = mysql_real_escape_string($attr["type"]);
		$tnodeTID = mysql_real_escape_string($attr["targetnodeTID"]);
		//Get the real data for the DB
		$query1 = "SELECT * FROM connection_types WHERE conn_name = \"$type\"";
		$query2 = "SELECT * FROM nodes WHERE node_tid=$tnodeTID";
		$resultID = mysql_query($query1, $linkID);
		$row = mysql_fetch_assoc($resultID);
		$typeID = $row["type_id"];
		$resultID = mysql_query($query2, $linkID);
		$row = mysql_fetch_assoc($resultID);
		$nodeID = $row["node_id"];
		//Insert the argument part into the DB (target node and info)
		$iquery = "INSERT INTO arguments (arg_tid, user_id, map_id, node_id, type_id, created_date, modified_date) VALUES
										($tid, $userID, $mapID, $nodeID, $typeID, NOW(), NOW())";
		print "<BR>Insert Query is: $iquery";
		mysql_query($iquery, $linkID);
		$newID = getLastInsert($linkID);
		print "<BR>New connection ID: $newID";
		//Get the argument part (source nodes)
		$children = $conn->children();
		foreach ($children as $child)
		{
			sourceNodeToDB($child, $newID, $linkID);
		}
		
		
		
	}
	
	function xmlToDB($xml, $mapID, $linkID, $userID)
	{
		print "Now in xml-to-DB function<BR>";
		$children = $xml->children();
		print count($children);

		foreach ($children as $child)
		{
			switch($child->getName())
			{
				case "textbox":
					textboxToDB($child, $mapID, $linkID, $userID);
					break;
				case "node":
					nodeToDB($child, $mapID, $linkID, $userID);
					break;
				case "connection":
					connectionToDB($child, $mapID, $linkID, $userID);
					break;
			}
		}
		
		//Validate and insert/update nodes
		//Validate and insert/update textboxes
		//Validate and insert/update nodetext
		//Validate and insert/update arguments
		//Validate and insert/update connections
		
		//If ANY of the above failed, we return false and let the rollback solve our problems for us.
		
		
		
		return true;
	}
	
	
	function insert($xmlin, $userID, $pass_hash)
	{
		//Standard SQL connection stuff
		//$linkID = mysql_connect("localhost", "root", "s3s@me123") or die ("Could not connect to database!");
		$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
		mysql_select_db("agora", $linkID) or die ("Could not find database");

		if(!checkLogin($userID, $pass_hash, $linkID)){
			print "Incorrect login!";
			return;
		}
	
	
		//Dig the Map ID out of the XML
		$xml = new SimpleXMLElement($xmlin);
		$mapID = $xml['id'];
		$mapClause = mysql_real_escape_string("$mapID");
		//Check to see if the map already exists
		if($mapClause==0){
			//If not, create it!
			$iquery = "INSERT INTO MAPS (user_id, title, description, created_date, modified_date) VALUES
										($userID, 'Example', 'Description', NOW(), NOW())";
			mysql_query($iquery, $linkID);						
			
			$mapClause = getLastInsert($linkID);
			print "New map ID: $mapClause <BR>";
		}

		$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE map_id = $mapClause";
		$resultID = mysql_query($query, $linkID) or die ("Cannot get map!"); 
		$row = mysql_fetch_assoc($resultID);
		
		//Check to see if this is the map author
		//If so, $ownMap is set to true.
		
		$author = $row['user_id'];
		print "Author: $author  Map: $mapClause <BR>";
		$ownMap = false;
		if($author == $userID){
			$ownMap=true;
			//TODO: Use this to determine if the INSERTIONS (or UPDATES) are legal
		}
		
		mysql_query("START TRANSACTION");

		$success = xmlToDB($xml, $mapClause, $linkID, $userID);
		if($success===true){
			mysql_query("COMMIT");
			print "<BR>Query committed!<BR>";
		}else{
			mysql_query("ROLLBACK");
			print "<BR>Query rolled back!<BR>";
		}

		
		//TODO: output XML here
		/*
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<map></map>";
		$output = new SimpleXMLElement($xmlstr);
		return $output;
		*/
	}
	$xmlparam = $_REQUEST['xml']; //TODO: Change this back to a GET when all testing is done.
	$userID = $_REQUEST['uid'];
	$pass_hash = $_REQUEST['pass_hash'];
	$output = insert($xmlparam, $userID, $pass_hash); 
	//print($output->asXML()); //TODO: turn this back on
?>