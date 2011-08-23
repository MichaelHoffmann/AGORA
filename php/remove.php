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
	require 'errorcodes.php';
	require 'establish_link.php';
	require 'utilfuncs.php';
	/**
	*	Function for removing a node from the database.
	*/
	function removeNode($node, $mapID, $output, $linkID, $userID)
	{
		$attr = $node->attributes();
		$nID = mysql_real_escape_string($attr["ID"]);
		$query = "SELECT * FROM nodes WHERE node_id=$nID AND map_id=$mapID";
		$resultID = mysql_query($query, $linkID);
		if(!$resultID){
			dataNotFound($output, $query);
			return false;
		}
		$row = mysql_fetch_assoc($resultID);
		if($userID == $row["user_id"]){
			$uquery = "UPDATE nodes SET modified_date=NOW(), is_deleted=1 WHERE node_id=$nID";
			$retval = mysql_query($uquery, $linkID);
			if(!$retval){
				$status=$output->addChild("node");
				$status->addAttribute("ID", $nID);
				updateFailed($output, $uquery);
				return $retval;
			}else{
				$status=$output->addChild("node");
				$status->addAttribute("ID", $nID);
				$status->addAttribute("removed", true);
			}
			return $retval;
		}else{
			modifyOther($output);
			return false;
		}
	}
	/**
	*	Convenience function. Iterates throughout the database. Separated from main logic for clarity.
	*	http://dev.mysql.com/doc/refman/5.5/en/innodb-foreign-key-constraints.html
	*/
	function xmlToDB($xml, $mapID, $output, $linkID, $userID)	
	{
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
					$retval = removeNode($child, $mapID, $output, $linkID, $userID);
					break;
				case "connection":
					//connectionToDB($child, $mapID, $linkID, $userID);
					break;
			}
			if($retval == false){  // We've already had one failure, no reason to continue
				metaError($output);
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
		global $dbName, $version;
		
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<AGORA version='$version'></AGORA>";
		$output = new SimpleXMLElement($xmlstr);
		
		//Standard SQL connection stuff
		$linkID= establishLink();
		if(!$linkID){
			badDBLink($output);
			return $output;
		}
		$status=mysql_select_db($dbName, $linkID);
		if(!$status){
			databaseNotFound($output);
			return $output;
		}

		if(!checkLogin($userID, $pass_hash, $linkID)){
			incorrectLogin($output);
			return $output;
		}
		
		//Dig the Map ID out of the XML
		//Dig the Map ID out of the XML
		try{
			$xml = new SimpleXMLElement($xmlin);
		}catch(Exception $e){
			poorXML($output);
			return $output;
		}
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
		$resultID = mysql_query($query, $linkID);
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		
		$row = mysql_fetch_assoc($resultID);		
		if(!$row['map_id']){
			nonexistent($output, $query);
			return $output;
		}
		
		$UID = $row['user_id'];
		if($delMap && $mapClause!=0){
			if($UID!=$userID){
				modifyOther($output);
				return $output;
			}		
			$query = "UPDATE maps SET is_deleted=1, modified_date=NOW() WHERE map_id=$mapClause";
			$success = mysql_query($query, $linkID);
			if($success){
				$status=$output->addChild("status");
				$status->addAttribute("value", "1");
				$status->addAttribute("text", "Successfully deleted the map!");
				return $output;
			}else{
				$status=$output->addChild("status");
				$status->addAttribute("value", "0");
				$status->addAttribute("text", "Could not delete the map!");
				return $output;
			}
		}else if($mapClause==0 or mysql_num_rows($resultID)==0){
			cannotDeleteFromNonexistent($output);
			return $output;
		}else{
			//the map exists, and now we operate on it
						
			//Transactions used for protecting maps from mass deletes that are partially illegal.
			mysql_query("START TRANSACTION");
			$success = xmlToDB($xml, $mapClause, $output, $linkID, $userID);
			if($success===true){
				mysql_query("COMMIT");
			}else{
				mysql_query("ROLLBACK");
			}
		}
		return $output;
	}

	$xmlparam = $_REQUEST['xml']; //TODO: Change this back to a GET when all testing is done.
	$userID = $_REQUEST['uid'];
	$pass_hash = $_REQUEST['pass_hash'];
	$output = remove($xmlparam, $userID, $pass_hash); 
	print($output->asXML()); //TODO: turn this back on when output XML is set up
?>