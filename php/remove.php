<?php
	require 'checklogin.php';
	
	function removeNode($node, $mapID, $linkID, $userID)
	{
		print "<BR>----Node found";
		$attr = $node->attributes();
		$nID = mysql_real_escape_string($attr["id"]);
		$query = "SELECT * FROM nodes WHERE node_id=$nID";
		$resultID = mysql_query($query, $linkID);
		$row = mysql_fetch_assoc($resultID);
		if($userID == $row["user_id"]){
			print "<BR>Now deleting....<BR>";
			$dquery = "DELETE FROM nodes WHERE node_id=$nID";
			print $dquery;
			return mysql_query($query, $linkID);
		}else{
			print "<BR>You are attempting to delete someone else's work. This is not permissible.";
			return false;
		}
	}
	
	function xmlToDB($xml, $mapID, $linkID, $userID)	
	{
		print "<BR>Now taking the XML and deleting things with it...";
		$children = $xml->children();
		$retval = true;
		foreach ($children as $child)
		{
			switch($child->getName())
			{
				case "textbox":
					//textboxToDB($child, $mapID, $linkID, $userID);
					break;
				case "node":
					$retval = removeNode($child, $mapID, $linkID, $userID);
					break;
				case "connection":
					//connectionToDB($child, $mapID, $linkID, $userID);
					break;
			}
			if($retval == false){  // We've already had one failure, no reason to continue
				return false;
			}
		}
		return true;
	}
	
	function remove($xmlin, $userID, $pass_hash)
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
		$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE map_id = $mapClause";
		$resultID = mysql_query($query, $linkID) or die ("Cannot get map!"); 
		$row = mysql_fetch_assoc($resultID);
		if($mapClause==0 or mysql_num_rows($resultID)==0){
			print "This map does not exist, therefore you cannot remove things from this map.";
		}else{
			//the map exists, and now we operate on it
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
			
			//TODO: set up output XML here
			
		}		
	}

	$xmlparam = $_REQUEST['xml']; //TODO: Change this back to a GET when all testing is done.
	$userID = $_REQUEST['uid'];
	$pass_hash = $_REQUEST['pass_hash'];
	$output = remove($xmlparam, $userID, $pass_hash); 
	//print($output->asXML()); //TODO: turn this back on
?>