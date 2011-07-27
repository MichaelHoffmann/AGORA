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
		REMOVE level: the top level tag
			MAP level:
				id: the ID of the map to be modified. 0 or nonexistent creates a new map and ignores everything else.
*/

	require 'configure.php';
	require 'checklogin.php';
	require 'establish_link.php';

	function removeMap($map, $output, $linkID, $userID){
		$mapID = $map['id'];
		$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE map_id = $mapID";
		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			$fail=$output->addChild("error");
			$fail->addAttribute("text", "Cannot get map! Query was: $query");
			return false;
		}
		$row = mysql_fetch_assoc($resultID);
		if(!$row['map_id']){
			$fail=$output->addChild("error");
			$fail->addAttribute("text", "Map $mapID does not exist!");
			return false;
		}
		$UID = $row['user_id'];
		if($UID!=$userID){
			$fail=$output->addChild("error");
			$fail->addAttribute("text", "You cannot delete someone else's map!");
			return false;
		}
		$query = "UPDATE maps SET is_deleted=1, modified_date=NOW() WHERE map_id=$mapID";
		$success = mysql_query($query, $linkID);
		if($success){
			$rmap=$output->addChild("map");
			$rmap->addAttribute("ID", $mapID);
			$rmap->addAttribute("removed", true);
			return true;
		}else{
			$rmap=$output->addChild("map");
			$rmap->addAttribute("ID", $mapID);
			$rmap->addAttribute("removed", false);		
			$fail=$output->addChild("error");
			$fail->addAttribute("text", "Could not delete the map!");
			return false;
		}
	}
	
	function xmlToDB($xml, $output, $linkID, $userID)	
	{
		$children = $xml->children();
		$retval = true;
		foreach ($children as $child)
		{
			switch($child->getName())
			{
				case "map":
					$retval = removeMap($child, $output, $linkID, $userID);
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
		global $dbName, $version;
		//Standard SQL connection stuff
		$linkID= establishLink();
		if(!$linkID){
			$fail=$output->addChild("error");
			$fail->addAttribute("text", "Could not establish link to the database server");
			return $output;
		}
		$status=mysql_select_db($dbName, $linkID);
		if(!$status){
			$fail=$output->addChild("error");
			$fail->addAttribute("text", "Could not find database");
			return $output;
		}
		//basic XML output initialization
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<AGORA version='$version'/>";
		$output = new SimpleXMLElement($xmlstr);
		
		if(!checkLogin($userID, $pass_hash, $linkID)){
			$fail=$output->addChild("error");
			$fail->addAttribute("text", "Incorrect login");
			return $output;
		}
		
		//Read the input XML
		try{
			$xml = new SimpleXMLElement($xmlin);
		}catch(Exception $e){
			$fail=$output->addChild("error");
			$fail->addAttribute("text", "Improperly formatted input XML!");
			return $output;
		}
		//Transactions used for protecting maps from mass deletes that are partially illegal.
		mysql_query("START TRANSACTION");
		$success = xmlToDB($xml, $output, $linkID, $userID);
		if($success===true){
			mysql_query("COMMIT");
		}else{
			mysql_query("ROLLBACK");
		}
		return $output;
	}

	$xmlparam = $_REQUEST['xml']; //TODO: Change this back to a GET when all testing is done.
	$userID = $_REQUEST['uid'];
	$pass_hash = $_REQUEST['pass_hash'];
	$output = remove($xmlparam, $userID, $pass_hash); 
	print $output->asXML();
?>