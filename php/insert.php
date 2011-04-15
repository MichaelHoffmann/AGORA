<?php

	function checkLogin($userID, $pass_hash)
	{
		//$linkID = mysql_connect("localhost", "root", "s3s@me123") or die ("Could not connect to database!");
		$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
		mysql_select_db("agora", $linkID) or die ("Could not find database");
		$userclause = mysql_real_escape_string("$userID");
		$passclause = mysql_real_escape_string("$pass_hash");
		$query = "SELECT * FROM users WHERE user_ID='$userID' AND password='$passclause'";
		$resultID = mysql_query($query, $linkID) or die("Data not found."); 
		//$row = mysql_fetch_assoc($resultID);
		if(mysql_num_rows($resultID)>0){
			return true;
		}else{
			return false;
		}
	}

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
		print "<BR>Textbox found";
		$attr = $tb->attributes();
		$tid = $attr["TID"];
		$text = $attr["text"];
		
		$iquery = "INSERT INTO textboxes (textbox_tid, user_id, map_id, text, created_date, modified_date) VALUES
									($tid, $userID, $mapID, \"$text\", NOW(), NOW())";
		print "<BR>Query: $iquery";
		mysql_query($iquery, $linkID);
		$newID = getLastInsert($linkID);
		print "<BR>New textbox ID: $newID";
	}
	function nodeToDB($node, $mapID, $linkID, $userID)
	{
		print "<BR>Node found";
		$attr = $node->attributes();
		$tid = $attr["TID"];
		$type = $attr["Type"];
		//$iquery = "INSERT INTO nodes (node_tid, user_id, map_id, nodetype_id, created_date, modified_date, x_coord, y_coord)";
		
	}
	function connectionToDB($conn, $mapID, $linkID, $userID)
	{
		print "<BR>Connection found";
	}
	
	function xmlToDB($xml, $mapID, $linkID, $userID)
	{
		print "Now in xml-to-DB function<BR>";
		$children = $xml->children();
		print count($children);
		foreach ($children as $child){
			switch($child->getName()){
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
		if(!checkLogin($userID, $pass_hash)){
			print "Incorrect login!";
			return;
		}
	
		//Standard SQL connection stuff
		//$linkID = mysql_connect("localhost", "root", "s3s@me123") or die ("Could not connect to database!");
		$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
		mysql_select_db("agora", $linkID) or die ("Could not find database");
		
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

		//$query = "SELECT * FROM maps NATURAL JOIN users WHERE map_id = $mapClause";

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

		
		//Set up the basics of the output XML.
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