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

function getLastInsert( $linkID ) {
	$query    = "SELECT LAST_INSERT_ID()";
	$resultID = mysqli_query( $linkID, $query );
	$row      = mysqli_fetch_assoc( $resultID );

	return $row['LAST_INSERT_ID()'];
}


function saveMapAs( $userID, $pass_hash, $mapID, $newName ) {
	global $dbName, $version;
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

	$queryname   = "SELECT * FROM maps m where m.title = '$newName' and m.is_deleted=0";
	$resultIDmap = mysqli_query( $linkID, $queryname );
	if ( $resultIDmap && mysqli_num_rows( $resultIDmap ) > 0 ) {
		mapNameTaked( $output );

		return $output;
	}

	$query    = "SELECT maps.map_id,maps.proj_id,maps.lang, maps.description,maps.is_deleted,maps.title,maps.map_type,maps.user_id, category_map.category_id,projects.is_hostile,users.username FROM maps INNER JOIN users ON users.user_id = maps.user_id JOIN category_map on maps.map_id=category_map.map_id left join projects on projects.proj_id=category_map.category_id WHERE maps.is_deleted = 0 and maps.map_id=$mapID";
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

	$userID = mysqli_real_escape_string($linkID,$userID);
	$mapID = mysqli_real_escape_string($linkID,$mapID);
	$newName = mysqli_real_escape_string($linkID,$newName);

	// ADD AN ENTRY FOR NEW MAP
	$temptitle     = mysqli_real_escape_string( $linkID, $row['title'] );
	$tempdesc      = mysqli_real_escape_string( $linkID, $row['description'] );
	$tempisdeleted = $row['is_deleted'];
	$mapowner      = $row['user_id'];
	$templang      = $row['lang'];
	$tempmaptype   = $row['map_type'];
	$query         = "INSERT INTO maps (title, map_type,user_id,description,is_deleted,created_date,modified_date,lang) VALUES ('$newName','$tempmaptype',$userID,'$tempdesc',$tempisdeleted, NOW(), NOW() ,'$templang')";
	$success       = mysqli_query( $linkID, $query );
	if ( ! $success ) {
		saveAsMapFailed( $output, $query );

		return $output;
	}
	$newMapID = getLastInsert( $linkID );
	$query    = "INSERT INTO SavedComponents (CompId, OrgCompId,Type,OrgUserId) VALUES ($newMapID,$mapID,1,$mapowner)";
	$success  = mysqli_query( $linkID, $query );

	$query   = "INSERT INTO category_map (map_id, category_id) VALUES ($newMapID,(SELECT category_id FROM category WHERE category_name=(SELECT username FROM users WHERE user_id='$userID')))";
	$success = mysqli_query( $linkID, $query );
	if ( ! $success ) {
		saveAsMapFailed( $output, $query );

		return $output;
	}

	// global list 
	$globalNodes   = array();
	$globalTextBox = array();

	$query    = "SELECT * FROM textboxes WHERE map_id = $mapID ORDER BY textbox_id";
	$resultID = mysqli_query( $linkID, $query );
	if ( $resultID ) {
		for ( $x = 0; $x < mysqli_num_rows( $resultID ); $x++ ) {
			$row     = mysqli_fetch_assoc( $resultID );
			$textbox = $output->addChild( "textbox" );
			$textbox->addAttribute( "ID", $row['textbox_id'] );
			$textbox->addAttribute( "text", to_utf8( $row['text'] ) );
			$textbox->addAttribute( "deleted", $row['is_deleted'] );

			// Add new Text Boxes
			$temptext                            = mysqli_real_escape_string( $linkID, $row['text'] );
			$temppisdel                          = $row['is_deleted'];
			$query                               = "INSERT INTO textboxes (user_id, map_id,text,is_deleted,created_date,modified_date) VALUES ($userID,$newMapID,'$temptext',$temppisdel,NOW(),NOW())";
			$success                             = mysqli_query( $linkID, $query );
			$newtextboxid                        = getLastInsert( $linkID );
			$globalTextBox[ $row['textbox_id'] ] = $newtextboxid;

			if ( ! $success ) {
				saveAsMapFailed( $output, $query );

				return $output;
			}
		}
	}


	// Nodes take a bit more work.
	/*$query = "SELECT * FROM nodes INNER JOIN users ON nodes.user_id=users.user_id NATURAL JOIN node_types
	 WHERE map_id = $mapID AND modified_date>\"$timestamp\" ORDER BY node_id";
	*/
	$query    = "SELECT nodes.node_id,nodes.user_id, nodes.nodetype_id,users.firstname,users.lastname,users.url, users.username, nodes.x_coord, nodes.y_coord, nodes.typed, nodes.is_positive, nodes.connected_by, nodes.is_deleted, node_types.type
	FROM nodes INNER JOIN users ON nodes.user_id=users.user_id NATURAL JOIN node_types
	WHERE map_id = $mapID ORDER BY node_id";
	$resultID = mysqli_query( $linkID, $query );
	if ( $resultID ) {
		for ( $x = 0; $x < mysqli_num_rows( $resultID ); $x++ ) {
			$row     = mysqli_fetch_assoc( $resultID );
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

			// Add new nodes
			$temp1   = $row['nodetype_id'];
			$temp2   = $row['x_coord'];
			$temp3   = $row['y_coord'];
			$temp4   = $row['is_deleted'];
			$temp5   = $row['connected_by'];
			$temp6   = $row['typed'];
			$temp7   = $row['is_positive'];
			$query   = "INSERT INTO nodes (user_id,map_id,nodetype_id,created_date,modified_date,x_coord,y_coord,is_deleted,is_positive,connected_by,typed) VALUES ($userID,$newMapID,$temp1,NOW(),NOW(),$temp2,$temp3,$temp4,$temp7,'$temp5','$temp6')";
			$success = mysqli_query( $linkID, $query );
			if ( ! $success ) {
				saveAsMapFailed( $output, $query );

				return $output;
			}
			$newNodeID = getLastInsert( $linkID );
			$nodeowner = $row['user_id'];
			$query     = "INSERT INTO SavedComponents (CompId, OrgCompId,Type,OrgUserId) VALUES ($newNodeID,$node_id,2,$nodeowner)";
			$success   = mysqli_query( $linkID, $query );

			$globalNodes[ $node_id ] = $newNodeID;

			//Have to do this instead of a proper join for the simple reason that we don't want to have multiple instances of the same <node>
			$innerQuery = "SELECT * FROM nodetext WHERE node_id=$node_id ORDER BY position ASC";
			$resultID2  = mysqli_query( $linkID, $innerQuery );
			if ( ! $resultID2 ) {
				dataNotFound( $output, $innerQuery );

				return $output;
			}
			$newnodetexts = array();
			$newnoderef   = array();
			$newtextref   = array();
			for ( $y = 0; $y < mysqli_num_rows( $resultID2 ); $y++ ) {
				$cnt      = 0;
				$nodetext = $node->addChild( "nodetext" );
				$innerRow = mysqli_fetch_assoc( $resultID2 );
				$nodetext->addAttribute( "ID", $innerRow['nodetext_id'] );
				$nodetext->addAttribute( "textboxID", $innerRow['textbox_id'] );
				$nodetext->addAttribute( "targetNodeID", $innerRow['target_node_id'] );
				$nodetext->addAttribute( "deleted", $innerRow['is_deleted'] );

				// process afterwards ... ...
				if ( ( $innerRow['target_node_id'] != null && ! array_key_exists( $innerRow['target_node_id'], $globalNodes ) ) || ! array_key_exists( $innerRow['textbox_id'], $globalTextBox ) ) {
					$newnodetexts[ $cnt++ ]                    = $nodetext;
					$newnoderef[ $innerRow['textbox_id'] ]     = $innerRow['textbox_id'];
					$newtextref[ $innerRow['target_node_id'] ] = $innerRow['target_node_id'];
				} else {

					$tempp1  = $innerRow['target_node_id'] != null ? $globalNodes[ $innerRow['target_node_id'] ] : "NULL";
					$tempp2  = $globalTextBox[ $innerRow['textbox_id'] ];
					$tempp3  = $innerRow['position'];
					$tempp4  = $innerRow['is_deleted'];
					$query   = "INSERT INTO nodetext (node_id,textbox_id,target_node_id,position,created_date,modified_date,is_deleted) VALUES ($newNodeID,$tempp2,$tempp1,$tempp3,NOW(),NOW(),$tempp4)";
					$success = mysqli_query( $linkID, $query );
					if ( ! $success ) {
						saveAsMapFailed( $output, $query );

						return $output;
					}
				}
			}

		}

		for ( $newnodes = 0; $newnodes < count( $newnodetexts ); $newnodes++ ) {
			// Add new nodetext
			$nodetext       = $newnodetexts[ $newnodes ];
			$targetnodetemp = $nodetext->attributes()->target_node_id;
			$targettexttemp = $nodetext->attributes()->textbox_id;

			if ( ( $targetnodetemp == null || array_key_exists( $targetnodetemp, $globalNodes ) ) && array_key_exists( $targettexttemp, $globalTextBox ) ) {
				$query   = "INSERT INTO nodetext (node_id,textbox_id,target_node_id,position,created_date,modified_date,is_deleted) VALUES ($newNodeID,$globalTextBox[$targettexttemp],$globalNodes[$targetnodetemp],$nodetext->attributes()->position,NOW(),NOW(),$nodetext->attributes()->is_deleted)";
				$success = mysqli_query( $linkID, $query );
				if ( ! $success ) {
					saveAsMapFailed( $output, $query );

					return $output;
				}
			}

		}
	}

	$testing = array_keys( $newnodetexts );
	for ( $tcbt = 0; $tcbt < count( $testing ); $tcbt++ ) {
		error_log( $newnodetexts[ $testing[ $tcbt ] ] );
	}


	// sourcenodes will take a lot more work.
	$query    = "SELECT * FROM connections NATURAL JOIN connection_types WHERE map_id = $mapID";
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

			$mappednode = $globalNodes[ $row['node_id'] ];
			$temp1      = $row['type_id'];
			$temp2      = $row['x_coord'];
			$temp3      = $row['y_coord'];
			$temp4      = $row['is_deleted'];
			$query      = "INSERT INTO connections (user_id,map_id,node_id,type_id,x_coord,y_coord,created_date,modified_date,is_deleted) VALUES ($userID,$newMapID,$mappednode,$temp1,$temp2,$temp3,NOW(),NOW(),$temp4)";
			$success    = mysqli_query( $linkID, $query );
			if ( ! $success ) {
				saveAsMapFailed( $output, $query );

				return $output;
			}
			$newconnid = getLastInsert( $linkID );


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

				$temp1         = $innerRow['is_deleted'];
				$mappednodesrc = $globalNodes[ $innerRow['node_id'] ];

				$query   = "INSERT INTO sourcenodes (connection_id,node_id,created_date,modified_date,is_deleted) VALUES ($newconnid,$mappednodesrc,NOW(),NOW(),$temp1)";
				$success = mysqli_query( $linkID, $query );
				if ( ! $success ) {
					saveAsMapFailed( $output, $query );

					return $output;
				}
				//$newconnid = getLastInsert($linkID);
			}
		}
	}

	$query    = "SELECT maps.map_id,maps.title,maps.map_type,users.username,users.url,users.firstname,users.lastname FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE maps.is_deleted = 0 and maps.map_id=$newMapID";
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
	// form the output for the new map created 
	$output->addAttribute( "ID", $newMapID );
	$output->addAttribute( "title", $row['title'] );
	$output->addAttribute( "username", $row['username'] );
	$output->addAttribute( "url", $row['url'] );
	$output->addAttribute( "firstname", $row['firstname'] );
	$output->addAttribute( "lastname", $row['lastname'] );

	return $output;
}

$userID    = $_REQUEST['uid'];
$pass_hash = $_REQUEST['pass_hash'];
$mapID     = $_REQUEST['map_id'];
$newName   = $_REQUEST['newName'];
$output    = saveMapAs( $userID, $pass_hash, $mapID, $newName );
print $output->asXML();

