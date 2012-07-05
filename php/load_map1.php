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
	require 'configure.php';
	require 'errorcodes.php';
	require 'establish_link.php';
	require 'utilfuncs.php';
	/**
	*	Function that loads a map from the database.
	*	Might be worth refactoring this somewhat.
	*/
	function get_map($userID, $pass_hash, $mapID, $timestamp){
		global $dbName, $version;
		//Set up the basics of the XML.
		header("Content-type: text/xml");
		$outputstr = "<?xml version='1.0' encoding='UTF-8'?>\n<map version='$version'></map>";
		$output = new SimpleXMLElement($outputstr);
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
		if(!$userID){
			//Don't have to check login info here
		}else if(!checkLogin($userID, $pass_hash, $linkID)){
				incorrectLogin($output);
				return $output;
		}			
		
		$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE map_id = $mapID AND maps.is_deleted = 0";
		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		if(mysql_num_rows($resultID)==0){
			nonexistent($output, $query);
			return $output;
		}
		$row = mysql_fetch_assoc($resultID);
		
		if($row['proj_id']){
			//Map is in a project.
			//Confirm that the project allows the user to open a map
			if(isUserInMapProject($userID, $mapID, $linkID)){
				//Nothing needs to be done, the logic will continue as normal
			}else{
				//Bail!
				notInProject($output, "User ID: $userID and Map ID: $mapID");
				return $output;
			}
		}
		//If map isn't in a project, continue as normal.
		
		$output->addAttribute("ID", $row['map_id']);
		$output->addAttribute("title", $row['title']);
		$output->addAttribute("username", $row['username']);
		$output->addAttribute("project", $row['proj_id']);
		
		$timeID = mysql_query("SELECT NOW()", $linkID);
		if(!$timeID){
			noTime($output);
			return $output;
		}
		$timerow = mysql_fetch_assoc($timeID);
		$now = $timerow['NOW()'];
		$output->addAttribute("timestamp", "$now");
		
		// Textboxes are easy!
		$query = "SELECT * FROM textboxes WHERE map_id = $mapID AND modified_date>'$timestamp' ORDER BY textbox_id";
		$resultID = mysql_query($query, $linkID); 
		if($resultID){
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
				$row = mysql_fetch_assoc($resultID);
				$textbox = $output->addChild("textbox");
				$textbox->addAttribute("ID", $row['textbox_id']);
				$textbox->addAttribute("text", to_utf8($row['text']));
				$textbox->addAttribute("deleted", $row['is_deleted']);
			}
		}


		// Nodes take a bit more work.
		/*$query = "SELECT * FROM nodes INNER JOIN users ON nodes.user_id=users.user_id NATURAL JOIN node_types 
			WHERE map_id = $mapID AND modified_date>\"$timestamp\" ORDER BY node_id";
		*/
		$query = "SELECT nodes.node_id, nodes.nodetype_id, users.username, nodes.x_coord, nodes.y_coord, nodes.typed, nodes.is_positive, nodes.connected_by, nodes.is_deleted, node_types.type
			FROM nodes INNER JOIN users ON nodes.user_id=users.user_id NATURAL JOIN node_types 
			WHERE map_id = $mapID AND modified_date>\"$timestamp\" ORDER BY node_id";
		$resultID = mysql_query($query, $linkID); 
		if($resultID){
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
				$row = mysql_fetch_assoc($resultID);
				$node_id = $row['node_id'];
				$node = $output->addChild("node");
				$node->addAttribute("ID", $node_id);
				$node->addAttribute("Type", $row['type']);
				$node->addAttribute("Author", $row['username']);
				$node->addAttribute("FirstName", $row['firstname']);
				$node->addAttribute("LastNameName", $row['lastname']);
				$node->addAttribute("URL", $row['url']);
				$node->addAttribute("x", $row['x_coord']);
				$node->addAttribute("y", $row['y_coord']);
				$node->addAttribute("typed", $row['typed']);
				$node->addAttribute("positive", $row['is_positive']);
				$node->addAttribute("connected_by", $row['connected_by']);
				$node->addAttribute("deleted", $row['is_deleted']);
				//Have to do this instead of a proper join for the simple reason that we don't want to have multiple instances of the same <node>
				$innerQuery="SELECT * FROM nodetext WHERE node_id=$node_id ORDER BY position ASC";
				$resultID2 = mysql_query($innerQuery, $linkID);
				if(!$resultID2){
					dataNotFound($output, $innerQuery);
					return $output;
				}
				for($y=0; $y<mysql_num_rows($resultID2); $y++){
					$nodetext = $node->addChild("nodetext");
					$innerRow=mysql_fetch_assoc($resultID2);
					$nodetext->addAttribute("ID", $innerRow['nodetext_id']);
					$nodetext->addAttribute("textboxID", $innerRow['textbox_id']);
					$nodetext->addAttribute("targetNodeID", $innerRow['target_node_id']);
					$nodetext->addAttribute("deleted", $innerRow['is_deleted']);
				}			
			}
		}

		// sourcenodes will take a lot more work.
		$query = "SELECT * FROM connections NATURAL JOIN connection_types WHERE map_id = $mapID AND modified_date>\"$timestamp\"";
		$resultID = mysql_query($query, $linkID);
		if($resultID){
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
				$row = mysql_fetch_assoc($resultID);
				$conn_id=$row['connection_id'];
				$connection = $output->addChild("connection");
				$connection->addAttribute("connID", $conn_id);
				$connection->addAttribute("type", $row['conn_name']);
				$connection->addAttribute("targetnode", $row['node_id']);
				$connection->addAttribute("x", $row['x_coord']);
				$connection->addAttribute("y", $row['y_coord']);
				$connection->addAttribute("deleted", $row['is_deleted']);
				//Set up the inner query to find the source nodes
				$innerQuery="SELECT * FROM sourcenodes WHERE connection_id=$conn_id";
				$resultID2 = mysql_query($innerQuery, $linkID);
				if(!$resultID2){
					dataNotFound($output, $innerQuery);
					return $output;
				}
				for($y=0; $y<mysql_num_rows($resultID2); $y++){
					$sourcenode = $connection->addChild("sourcenode");
					$innerRow=mysql_fetch_assoc($resultID2);
					$sourcenode->addAttribute("ID", $innerRow['sn_id']);
					$sourcenode->addAttribute("nodeID", $innerRow['node_id']);
					$sourcenode->addAttribute("deleted", $innerRow['is_deleted']);
				}	
			}
		}
		return $output;
	}
	$userID = mysql_real_escape_string($_REQUEST['uid']);
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);
	$mapID = mysql_real_escape_string($_REQUEST['map_id']);
	$timestamp = mysql_real_escape_string($_REQUEST['timestamp']);
	$output = get_map($userID, $pass_hash, $mapID, $timestamp); 
	print $output->asXML();
?>
