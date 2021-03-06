<?php
/**
 * AGORA - an interactive and web-based argument mapping tool that stimulates reasoning,
 * reflection, critique, deliberation, and creativity in individual argument construction
 * and in collaborative or adversarial settings.
 * Copyright (C) 2011 Georgia Institute of Technology
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
require 'configure.php';
require 'errorcodes.php';
require 'establish_link.php';
require 'utilfuncs.php';
/**
 *    Function that loads a map from the database.
 *    Might be worth refactoring this somewhat.
 */
function get_map( $userID, $pass_hash, $mapID, $timestamp ) {
	global $version;
	//Set up the basics of the XML.
	header( "Content-type: text/xml" );
	$outputstr = "<?xml version='1.0' encoding='UTF-8'?>\n<map version='$version'></map>";
	$output    = new SimpleXMLElement( $outputstr );
	//Standard SQL connection stuff
	$linkID = establishLink();
	if ( ! $linkID ) {
		badDBLink( $output );

		return $output;
	}
	if ( ! $userID ) {
		//Don't have to check login info here
	} else if ( ! checkLogin( $userID, $pass_hash, $linkID ) ) {
		incorrectLogin( $output );

		return $output;
	}

	$mapID     = mysqli_real_escape_string( $linkID, $mapID );
	$timestamp = mysqli_real_escape_string( $linkID, $timestamp );

	$query    = "SELECT maps.map_id,maps.proj_id, maps.title,maps.map_type,maps.created_date, category_map.category_id,projects.is_hostile,users.username,users.url FROM maps INNER JOIN users ON users.user_id = maps.user_id inner JOIN category_map on maps.map_id=category_map.map_id left join projects on projects.proj_id=category_map.category_id WHERE maps.is_deleted = 0 and maps.map_id=$mapID";
	$resultID = mysqli_query( $linkID, $query );
	if ( ! $resultID ) {
		dataNotFound( $output, $query );

		return $output;
	}
	if ( mysqli_num_rows( $resultID ) == 0 ) {
		nonexistent( $output, $query );

		return $output;
	}
	$row = mysqli_fetch_assoc( $resultID );

	if ( $row['proj_id'] ) {
		//Map is in a project.
		//Confirm that the project allows the user to open a map
		if ( isUserInMapProject( $userID, $mapID, $linkID ) ) {
			//Nothing needs to be done, the logic will continue as normal
		} else {
			//Bail!
			notInProject( $output, "User ID: $userID and Map ID: $mapID" );

			return $output;
		}
	}
	//If map isn't in a project, continue as normal.

	$output->addAttribute( "ID", $row['map_id'] );
	$output->addAttribute( "title", $row['title'] );
	$output->addAttribute( "username", $row['username'] );
	$output->addAttribute( "url", $row['url'] );
	$output->addAttribute( "project", $row['category_id'] );
	$output->addAttribute( "map_type", $row['map_type'] );
	$output->addAttribute( "is_hostile", $row['is_hostile'] );
	$output->addAttribute( "created_date", $row['created_date'] );
	if ( $timestamp == 0 ) {
		$output->addAttribute( "reloadRPANEL", "1" );
	} else {
		$output->addAttribute( "reloadRPANEL", "0" );
	}


	$mapHistory = false;
	// check for the history of the map and get the same ..
	$query    = "SELECT * FROM maps inner join SavedComponents on map_id=CompId inner join users on OrgUserId=users.user_id where type=1 and map_id = $mapID";
	$resultID = mysqli_query( $linkID, $query );
	if ( $resultID && mysqli_num_rows( $resultID ) > 0 ) {
		$detailTree = $output->addChild( "mapHistory" );
		fetchHistoryTreeForMap( $mapID, 0, $detailTree, $linkID );
		$mapHistory = true;
	}


	$timeID = mysqli_query( $linkID, "SELECT NOW()" );
	if ( ! $timeID ) {
		noTime( $output );

		return $output;
	}
	$timerow = mysqli_fetch_assoc( $timeID );
	$now     = $timerow['NOW()'];
	$output->addAttribute( "timestamp", $now );

	// Textboxes are easy!
	$query    = "SELECT * FROM textboxes WHERE map_id = $mapID AND modified_date>'$timestamp' ORDER BY textbox_id";
	$resultID = mysqli_query( $linkID, $query );
	if ( $resultID ) {
		for ( $x = 0; $x < mysqli_num_rows( $resultID ); $x++ ) {
			$row     = mysqli_fetch_assoc( $resultID );
			$textbox = $output->addChild( "textbox" );
			$textbox->addAttribute( "ID", $row['textbox_id'] );
			$textbox->addAttribute( "text", to_utf8( $row['text'] ) );
			$textbox->addAttribute( "deleted", $row['is_deleted'] );
		}
	}


	// Nodes take a bit more work.
	/*$query = "SELECT * FROM nodes INNER JOIN users ON nodes.user_id=users.user_id NATURAL JOIN node_types
		WHERE map_id = $mapID AND modified_date>\"$timestamp\" ORDER BY node_id";
	*/
	$query = "SELECT nodes.node_id, nodes.nodetype_id,users.firstname,users.lastname,users.url, users.username, nodes.x_coord, nodes.y_coord, nodes.typed, nodes.is_positive, nodes.connected_by, nodes.is_deleted, node_types.type
			FROM nodes INNER JOIN users ON nodes.user_id=users.user_id NATURAL JOIN node_types 
			WHERE map_id = $mapID AND modified_date>\"$timestamp\" ORDER BY node_id";
	if ( $mapHistory ) {
		$query = "SELECT nodes.node_id,nodes.nodetype_id, users.firstname,users.lastname,users.url, users.username, nodes.x_coord, nodes.y_coord, nodes.typed, nodes.is_positive, nodes.connected_by, nodes.is_deleted, node_types.type,usersparent.user_id AS prevauthoruid,usersparent.username AS prevauthor,usersparent.url AS prevauthorurl FROM nodes INNER JOIN users ON nodes.user_id=users.user_id left join SavedComponents ON nodes.node_id = CompId left join nodes as nodesparent on OrgCompId = nodesparent.node_id left join users as usersparent on nodesparent.user_id = usersparent.user_id left JOIN node_types on nodes.nodetype_id = node_types.nodetype_id
			WHERE nodes.map_id = $mapID AND nodes.modified_date>\"$timestamp\" ORDER BY nodes.node_id";
	}
	$resultID = mysqli_query( $linkID, $query );
	if ( $resultID ) {
		for ( $x = 0; $x < mysqli_num_rows( $resultID ); $x++ ) {
			$row = mysqli_fetch_assoc( $resultID );
			error_log( $query, 0 );
			$node_id = $row['node_id'];
			$node    = $output->addChild( "node" );
			$node->addAttribute( "ID", $node_id );
			$node->addAttribute( "Type", $row['type'] );
			$node->addAttribute( "Author", $row['username'] );
			$node->addAttribute( "FirstName", $row['firstname'] );
			$node->addAttribute( "LastName", $row['lastname'] );
			$node->addAttribute( "URL", $row['url'] );
			$node->addAttribute( "x", $row['x_coord'] );
			$node->addAttribute( "y", $row['y_coord'] );
			$node->addAttribute( "typed", $row['typed'] );
			$node->addAttribute( "positive", $row['is_positive'] );
			$node->addAttribute( "connected_by", $row['connected_by'] );
			$node->addAttribute( "deleted", $row['is_deleted'] );
			if ( $mapHistory ) {
				$node->addAttribute( "PA", $row['prevauthor'] );
				$node->addAttribute( "PAUrl", $row['prevauthorurl'] );
			}
			//Have to do this instead of a proper join for the simple reason that we don't want to have multiple instances of the same <node>
			$innerQuery = "SELECT * FROM nodetext WHERE node_id=$node_id ORDER BY position ASC";
			$resultID2  = mysqli_query( $linkID, $innerQuery );
			if ( ! $resultID2 ) {
				dataNotFound( $output, $innerQuery );

				return $output;
			}
			for ( $y = 0; $y < mysqli_num_rows( $resultID2 ); $y++ ) {
				$nodetext = $node->addChild( "nodetext" );
				$innerRow = mysqli_fetch_assoc( $resultID2 );
				$nodetext->addAttribute( "ID", $innerRow['nodetext_id'] );
				$nodetext->addAttribute( "textboxID", $innerRow['textbox_id'] );
				$nodetext->addAttribute( "targetNodeID", $innerRow['target_node_id'] );
				$nodetext->addAttribute( "deleted", $innerRow['is_deleted'] );
			}
		}
	}

	// sourcenodes will take a lot more work.
	$query    = "SELECT * FROM connections NATURAL JOIN connection_types WHERE map_id = $mapID AND modified_date>\"$timestamp\"";
	$resultID = mysqli_query( $linkID, $query );
	if ( $resultID ) {
		for ( $x = 0; $x < mysqli_num_rows( $resultID ); $x++ ) {
			$row        = mysqli_fetch_assoc( $resultID );
			$conn_id    = $row['connection_id'];
			$connection = $output->addChild( "connection" );
			$connection->addAttribute( "connID", $conn_id );
			$connection->addAttribute( "type", $row['conn_name'] );
			$connection->addAttribute( "targetnode", $row['node_id'] );
			$connection->addAttribute( "x", $row['x_coord'] );
			$connection->addAttribute( "y", $row['y_coord'] );
			$connection->addAttribute( "deleted", $row['is_deleted'] );
			//Set up the inner query to find the source nodes
			$innerQuery = "SELECT * FROM sourcenodes WHERE connection_id=$conn_id";
			$resultID2  = mysqli_query( $linkID, $innerQuery );
			if ( ! $resultID2 ) {
				dataNotFound( $output, $innerQuery );

				return $output;
			}
			for ( $y = 0; $y < mysqli_num_rows( $resultID2 ); $y++ ) {
				$sourcenode = $connection->addChild( "sourcenode" );
				$innerRow   = mysqli_fetch_assoc( $resultID2 );
				$sourcenode->addAttribute( "ID", $innerRow['sn_id'] );
				$sourcenode->addAttribute( "nodeID", $innerRow['node_id'] );
				$sourcenode->addAttribute( "deleted", $innerRow['is_deleted'] );
			}
		}
	}

	return $output;
}

$userID    = $_REQUEST['uid'];
$pass_hash = $_REQUEST['pass_hash'];
$mapID     = $_REQUEST['map_id'];
$timestamp = $_REQUEST['timestamp'];
$output    = get_map( $userID, $pass_hash, $mapID, $timestamp );
print $output->asXML();

