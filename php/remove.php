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
	xml: The XML of map data to remove (or remove things from)
	uid: User ID of the user removing the data
	pass_hash: the hashed password of the user removing the data
	
	* XML data:
		MAP level:
			id or ID: the ID of the map to be modified. 0 or nonexistent creates a new map and ignores everything else.
			remove: If this is a string PHP recognizes as true ("1", "true", etc), delete the map.
		
		IN-MAP level:
			node: remove a node
				ID: ID of an existing node
			
			Other things do not need to be deleted explicitly because the database code contains logic for "chaining" deletes.
			Since we are not TRULY deleting it, but setting a flag, this does not use ON DELETE CASCADE.
			For details, look at agora.sql and examine the ON UPDATE triggers.

*/
	require 'configure.php';
	require 'checklogin.php';
	require 'establish_link.php';
	/**
	*	Function for removing a node from the database.
	*/
	function removeNode($node, $mapID, $linkID, $userID)
	{
		print "<BR>----Node found in XML";
		$attr = $node->attributes();
		$nID = mysql_real_escape_string($attr["ID"]);
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
		global $dbName;
		//Standard SQL connection stuff
		$linkID= establishLink();
		mysql_select_db($dbName, $linkID) or die ("Could not find database");

		if(!checkLogin($userID, $pass_hash, $linkID)){
			print "Incorrect login!";
			return;
		}
		
		//Dig the Map ID out of the XML
		$xml = new SimpleXMLElement($xmlin);
		$mapID = $xml['ID'];
		$mapClause = mysql_real_escape_string("$mapID");
		//A backwards-compatible fix to allow lowercase-id to continue working to avoid breaking client code:
		$mapID = $xml['id'];
		if($mapID && !$mapClause){
			$mapClause=$mapID;
		}
		$delMap = mysql_real_escape_string($xml['remove']);
		//Check to see if the map already exists
		$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE map_id = $mapClause";
		$resultID = mysql_query($query, $linkID) or die ("Cannot get map! Query was: $query"); 
		$row = mysql_fetch_assoc($resultID);
		$UID = $row['user_id'];
		if($delMap && $mapClause!=0){
			if($UID!=$userID){
				print "You cannot delete someone else's map!";
				return;
			}		
			$query = "UPDATE maps SET is_deleted=1, modified_date=NOW() WHERE map_id=$mapClause";
			$success = mysql_query($query, $linkID);
			if($success){
				print "Successfully deleted the map!";
			}else{
				print "Could not delete the map!";
			}
		}else if($mapClause==0 or mysql_num_rows($resultID)==0){
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