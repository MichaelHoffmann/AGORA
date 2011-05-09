<?php
	require 'checklogin.php';
	
	/**
	*	Function for removing a node from the database.
	*/
	function removeNode($node, $mapID, $linkID, $userID)
	{
		print "<BR>----Node found in XML";
		$attr = $node->attributes();
		$nID = mysql_real_escape_string($attr["id"]);
		$query = "SELECT * FROM nodes WHERE node_id=$nID";
		$resultID = mysql_query($query, $linkID);
		$row = mysql_fetch_assoc($resultID);
		if($userID == $row["user_id"]){
			print "<BR>Now deleting....<BR>";
			$uquery = "UPDATE nodes SET modified_date=NOW(), is_deleted=1 WHERE node_id=$nID";
			print $uquery;
			$retval = mysql_query($uquery, $linkID);
			if(!$retval){
				return $retval;
			}
			//TODO: manually cascade this stuff over
			
			//Nodes can be NODES in Node-Text relationship
			print "<BR>Now cascading over to Nodetext....<BR>"
			$uquery = "UPDATE nodetext SET modified_date=NOW(), is_deleted=1 WHERE node_id=$nID"
			print $uquery;
			$retval = mysql_query($uquery, $linkID);
			if(!retval){
				return $retval;
			}
			//cascading over to TEXTBOXES will be troublesome since I have to stash all the nodetexts that are deleted...
			
			
			//Nodes can be SOURCENODES of connections
			print "<BR>Now cascading over to Connections....<BR>"
			$uquery = "UPDATE connections SET modified_date=NOW(), is_deleted=1 WHERE node_id=$nID"
			print $uquery;
			$retval = mysql_query($uquery, $linkID);
			if(!retval){
				return $retval;
			}
			//Nodes can be TARGETNODES of arguments
			print "<BR>Now cascading over to Arguments....<BR>"
			$uquery = "UPDATE arguments SET modified_date=NOW(), is_deleted=1 WHERE node_id=$nID"
			print $uquery;
			$retval = mysql_query($uquery, $linkID);
			if(!retval){
				return $retval;
			}
			
			return $retval;
		}else{
			print "<BR>You are attempting to delete someone else's work or a nonexistent node. This is not permissible.";
			return false;
		}
	}
	/**
	*	Convenience function. Iterates throughout the database. Separated from main logic for clarity.
	*	http://dev.mysql.com/doc/refman/5.5/en/innodb-foreign-key-constraints.html
	*/
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
	
	/**
	*	Highest level function. Handles SQL connection logic.
	*/
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
						
			//Transactions used for protecting maps from mass deletes that are partially illegal.
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
	//print($output->asXML()); //TODO: turn this back on when output XML is set up
?>