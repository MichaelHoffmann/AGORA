<?php
/**
 * Adding as a test
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

/**
 * List of variables for insertion:
 * HTTP Query variables:
 * xml: The XML of map data to insert
 * uid: User ID of the user inserting the data
 * pass_hash: the hashed password of the user inserting the data
 * XML data:
 * MAP level:
 * id or ID: the ID of the map to be modified. 0 or nonexistent creates a new map and ignores everything else.
 * title: Title of the map (for new maps only)
 * desc: Description of the map (for new maps only)
 * lang: Language of the map (for new maps only)
 *
 * IN-MAP level:
 * textbox: insert or modify a textbox
 * text: The text the user typed into the box (or default text)
 * ID: ID of an existing textbox
 * TID: temporary (client) ID of a new textbox, will get an ID in the db and returned to the client
 * node: insert or modify a node
 * ID: ID of an existing node
 * TID: temporary (client) ID of a new node, will get an ID in the db and returned to the client
 * Type: Type of a node. See nodetypes table in database for a listing. Use the name.
 * x: x-coordinate of a node on the map
 * y: y-coordinate of a node on the map
 * typed: Whether the node has been typed or still contains default text
 * is_positive: Whether the argument is positive or not (logically speaking).
 * nodetext: link between a node and textbox. Due to hierarchy, it only needs one variable.
 * textboxID: ID of the textbox.
 * (NOTE: Position comes from ordering of the nodetexts. As a result, if ANY nodetext relationship is updated,
 * ALL nodetexts must be included- even without change.)
 * connection: insert or modify a connection (arguments, objections, etc.)
 * ID: ID of an existing connection
 * TID: temporary (client) ID of a new connection, will get an ID in the db and returned to the client
 * targetnodeID: ID of the node the argument is supporting. This is the SINGLE node that has an arrow pointing to it.
 * targetnodeTID: Temporary ID of the same (for when a new node and connection go in simultaneously)
 * x: x-coordinate of the argument's position on the map
 * y: y-coordinate of the argument's position on the map
 * sourcenode: link between supporting nodes and the argument. There can be as many of these as needed.
 * TID: Temporary (client) ID. No real ID is ever allowed, since modifying a relationship is nonsensical.
 * Delete the old one and add a new one instead, or modify the text in the node.
 * nodeID: ID of the node, if you're connecting an existing node to the argument (two-step process)
 * nodeTID: Temporary ID of the node, for when you're doing it all in one step.
 */
require 'configure.php';
require 'errorcodes.php';
require 'establish_link.php';
require 'utilfuncs.php';


/**
 * Convenience function.
 * Selects the last auto-generated ID (AUTO_INCREMENT) from the Database.
 * See the following for the function that this uses:
 * http://php.net/manual/en/function.mysql-insert-id.php
 */
function getLastInsert( $linkID ) {
	$query    = "SELECT LAST_INSERT_ID()";
	$resultID = mysqli_query( $linkID, $query );
	$row      = mysqli_fetch_assoc( $resultID );

	return $row['LAST_INSERT_ID()'];
}

/**
 *    Takes a textbox and gets the necessary information from XML into the DB.
 */
function textboxToDB( $tb, $mapID, $linkID, $userID, $output ) {
	global $tbTIDarray;
	$attr       = $tb->attributes();
	$text       = mysqli_real_escape_string( $linkID, $attr["text"] );
	$id         = $attr["ID"];
	$nodeID     = $attr["nodeID"];
	if ( $id ) {
		$query    = "SELECT * FROM textboxes WHERE textbox_id=$id";
		$resultID = mysqli_query( $linkID, $query );
		$row      = mysqli_fetch_assoc( $resultID );
		$dbUID    = $row["user_id"];
		// check for Map Link
		$queryM    = "SELECT * FROM nodes WHERE node_id=$nodeID";
		$resultIDM = mysqli_query( $linkID, $queryM );
		$rowM      = mysqli_fetch_assoc( $resultIDM );
		$nodeTypeM = $rowM['nodetype_id'];
		if ( $nodeTypeM == 11 && $text != "" ) {
			// check if text is a proper map name
			// long check -- mapid check
			// get name and convert text and save
			$pos = strpos( $text, "(" );
			if ( ( $pos !== false ) ) {
				$text = substr( $text, 0, $pos - 1 );
			}
			if ( is_numeric( $text ) ) {
				// check for Map Link
				$text = trim( $text );
				// check for map permissions first
				$queryP    = "SELECT maps.map_id,maps.proj_id, maps.title,maps.map_type,maps.created_date, category_map.category_id,projects.is_hostile,users.username,users.url FROM maps INNER JOIN users ON users.user_id = maps.user_id inner JOIN category_map on maps.map_id=category_map.map_id left join projects on projects.proj_id=category_map.category_id WHERE maps.is_deleted = 0 and maps.map_id=$text";
				$resultIDP = mysqli_query( $linkID, $queryP );
				if ( $resultIDP && mysqli_num_rows( $resultIDP ) != 0 ) {
					$row = mysqli_fetch_assoc( $resultIDP );
					if ( $row['proj_id'] ) {
						//Map is in a project.
						//Confirm that the project allows the user to open a map
						if ( ! isUserInMapProject( $userID, $text, $linkID ) ) {
							$text = "";
						}
					}
				} else {
					$text = "";
				}
				if ( $text != "" ) {
					$queryM    = "SELECT * FROM maps WHERE map_id=$text";
					$resultIDM = mysqli_query( $linkID, $queryM );
					if ( $resultIDM != null && mysqli_num_rows( $resultIDM ) > 0 ) {
						$rowM = mysqli_fetch_assoc( $resultIDM );
						$text = $text . " (" . $rowM['title'] . ")";
					} else {
						$text = "";
					}
				}
			} else {
				$text = "";
			}
			if ( $text == "" ) {
				$output->addAttribute( "mapLinkError", "true" );
			}
		}
		/*if ($is_project == 0)
		{
			if($userID == $dbUID){
			$uquery = "UPDATE textboxes SET text='$text', modified_date=NOW() WHERE textbox_id=$id";
			$status = mysqli_query( $linkID, $uquery );
			}
			else{
			modifyOther($output);
			return false;
			}
		}*/
		//if($is_project == 1){
		if ( $proj_type == 1 ) {
			if ( $userID == $dbUID ) {
				$uquery = "UPDATE textboxes SET text='$text', modified_date=NOW() WHERE textbox_id=$id";
				$status = mysqli_query( $linkID, $uquery );
			}
		} else if ( $proj_type == 0 ) {
			$uquery  = "UPDATE textboxes SET text='$text', modified_date=NOW() WHERE textbox_id=$id";
			$status  = mysqli_query( $linkID, $uquery );
			$uquery  = "UPDATE nodes SET user_id = $userID WHERE node_id=$nodeID";
			$success = mysqli_query( $linkID, $uquery );
		} else {
			notProjectMember( $output );
		}
		//}
	} else {
		$tid     = mysqli_real_escape_string( $linkID, $attr["TID"] );
		$iquery  = "INSERT INTO textboxes (user_id, map_id, text, created_date, modified_date) VALUES
										($userID, $mapID, '$text', NOW(), NOW())";
		$success = mysqli_query( $linkID, $iquery );
		if ( ! $success ) {
			insertFailed( $output, $iquery );

			return false;
		}
		$newID   = getLastInsert( $linkID );
		$textbox = $output->addChild( "textbox" );
		$textbox->addAttribute( "TID", $tid );
		$textbox->addAttribute( "ID", $newID );

		$tbTIDarray[ $tid ] = $newID; // Add the TID->ID mapping to the global lookup array
	}

	return true;
}

/**
 *    Takes a nodetext link and inserts it into the database.
 */
function nodeTextToDB( $nt, $nodeID, $linkID, $userID, $position, $output ) {
	global $tbTIDarray; //use the global variable
	$attr      = $nt->attributes();
	$textboxID = mysqli_real_escape_string( $linkID, $attr["textboxID"] );
	$tgtNodeID = mysqli_real_escape_string( $linkID, $attr["targetNodeID"] );

	$query    = "SELECT * FROM nodetext WHERE node_id=$nodeID AND position=$position";
	$resultID = mysqli_query( $linkID, $query );
	$row      = mysqli_fetch_assoc( $resultID );
	$ntID     = $row['nodetext_id'];
	if ( $ntID ) {
		//update should ALWAYS have a real textbox ID, or empty, so that we use target node ID
		//Note that an update allows us to switch from textbox to target node or vice versa - this is intentional
		if ( ! $textboxID && $tgtNodeID ) { // We use the target node ID
			$uquery = "UPDATE nodetext SET textbox_id=NULL, target_node_id=$tgtNodeID, modified_date=NOW() WHERE nodetext_id=$ntID";
		} else { // use the textbox ID
			$uquery = "UPDATE nodetext SET textbox_id=$textboxID, modified_date=NOW() WHERE nodetext_id=$ntID";
		}
		$success = mysqli_query( $linkID, $uquery );
		if ( ! $success ) {
			updateFailed( $output, $uquery );

			return false;
		}
	} else {
		//insert
		$tid = mysqli_real_escape_string( $linkID, $attr["TID"] );
		//insert with real textbox ID
		if ( $textboxID ) {
			//We are here given the real textbox ID to put into a new nodetext position (new node, or new position in an existing node)
			$iquery  = "INSERT INTO nodetext (node_id, textbox_id, target_node_id, position, created_date, modified_date) VALUES
							($nodeID, $textboxID, NULL, $position, NOW(), NOW())";
			$success = mysqli_query( $linkID, $iquery );
			if ( ! $success ) {
				insertFailed( $output, $iquery );

				return false;
			}
		} else if ( $tgtNodeID ) {
			//We are here given the real target node ID to put into a new nodetext position (new node, or new position in an existing node)
			$iquery  = "INSERT INTO nodetext (node_id, textbox_id, target_node_id, position, created_date, modified_date) VALUES
							($nodeID, NULL, $tgtNodeID, $position, NOW(), NOW())";
			$success = mysqli_query( $linkID, $iquery );
			if ( ! $success ) {
				insertFailed( $output, $iquery );

				return false;
			}
		} else if ( $tgtNodeID ) {
			//We have a target node TID, rather than an ID. Stubbing out space in case this is needed.

		} else { //insert with textbox TID
			$tTID   = mysqli_real_escape_string( $linkID, $attr["textboxTID"] );
			$textID = $tbTIDarray[ $tTID ];

			$iquery = "INSERT INTO nodetext (node_id, textbox_id, position, created_date, modified_date) VALUES
							($nodeID, $textID, $position, NOW(), NOW())";

			$success = mysqli_query( $linkID, $iquery );
			if ( ! $success ) {
				insertFailed( $output, $iquery );

				return false;
			}
		}
		//shared actions for ntTID logic
		$outID = getLastInsert( $linkID );
		$ntOut = $output->addChild( "nodetext" );
		$ntOut->addAttribute( "TID", $tid );
		$ntOut->addAttribute( "ID", $outID );
	}

	return true;
}


/**
 *    Takes a node from XML and puts it in the database.
 */
function nodeToDB( $node, $mapID, $linkID, $userID, $output ) {
	global $nodeTIDarray;
	$nodeOut    = null; // Done for later scoping
	$attr       = $node->attributes();
	$nodeID     = mysqli_real_escape_string( $linkID, $attr["ID"] );
	$type       = mysqli_real_escape_string( $linkID, $attr["Type"] );
	$x          = mysqli_real_escape_string( $linkID, $attr["x"] );
	$y          = mysqli_real_escape_string( $linkID, $attr["y"] );
	$typed      = mysqli_real_escape_string( $linkID, $attr["typed"] );
	$positivity = mysqli_real_escape_string( $linkID, $attr["is_positive"] );
	$cBy        = $attr['connected_by'];
	if ( ! $cBy ) {
		$cBy = 'implication';
	}
	$query    = "SELECT * FROM node_types WHERE type='$type'";
	$resultID = mysqli_query( $linkID, $query );
	$row      = mysqli_fetch_assoc( $resultID );
	$typeID   = $row['nodetype_id'];
	if ( $nodeID ) {
		//update
		$query    = "SELECT * FROM nodes WHERE node_id=$nodeID";
		$resultID = mysqli_query( $linkID, $query );
		$row      = mysqli_fetch_assoc( $resultID );
		$dbUID    = $row["user_id"];
		if ( $userID == $dbUID ) {
			$uquery  = "UPDATE nodes SET nodetype_id=$typeID, modified_date=NOW(), x_coord=$x, y_coord=$y, 
							typed=$typed, is_positive=$positivity, connected_by='$cBy'
							WHERE node_id=$nodeID";
			$success = mysqli_query( $linkID, $uquery );
			if ( ! $success ) {
				updateFailed( $output, $uquery );

				return false;
			} else {
				$nodeOut = $output->addChild( "node" );
				$nodeOut->addAttribute( "ID", $nodeID );
			}
		} else {
			//user is updating someone else's node. He is only allowed to change X and Y coordinates.
			$uquery  = "UPDATE nodes SET modified_date=NOW(), x_coord=$x, y_coord=$y WHERE node_id=$nodeID";
			$success = mysqli_query( $linkID, $uquery );
			if ( ! $success ) {
				updateFailed( $output, $uquery );

				return false;
			} else {
				$nodeOut = $output->addChild( "node" );
				$nodeOut->addAttribute( "ID", $nodeID );
			}
		}
	} else {
		//insert
		$tid     = mysqli_real_escape_string( $linkID, $attr["TID"] );
		$iquery  = "INSERT INTO nodes (user_id, map_id, nodetype_id, created_date, modified_date, x_coord, y_coord, typed, connected_by, is_positive) VALUES
										($userID, $mapID, $typeID, NOW(), NOW(), $x, $y, $typed, '$cBy', $positivity)";
		$success = mysqli_query( $linkID, $iquery );
		if ( ! $success ) {
			insertFailed( $output, $iquery );

			return false;
		} else {
			$nodeID  = getLastInsert( $linkID );
			$nodeOut = $output->addChild( "node" );
			$nodeOut->addAttribute( "TID", $tid );
			$nodeOut->addAttribute( "ID", $nodeID );
			$nodeTIDarray[ $tid ] = $nodeID; // Add the TID->ID mapping to the global lookup array
		}
	}
	$children = $node->children();
	$pos      = 0;
	foreach ( $children as $child ) {
		$pos++;
		//$nodeOut is still in scope here because PHP's scoping rules are relaxed.
		nodeTextToDB( $child, $nodeID, $linkID, $userID, $pos, $nodeOut );

		//Note that this won't be done if the owner check failed on an UPDATE
		//because the update will return false.
		//This behavior is correct:
		//if someone can't update a node they shouldn't be able to change its nodetext information.
		//(Also, they should fail the textbox owner check as well.)
	}

	return true;
}

/**
 *    Links between nodes and connections in the DB.
 */
function sourceNodeToDB( $source, $connID, $linkID, $output ) {
	global $nodeTIDarray;
	//Source Nodes don't have to worry about being updated.
	//They can only be DELETED or INSERTED.
	//They get DELETED automatically when the NODE they connect to is DELETED.
	$attr   = $source->attributes();
	$tid    = mysqli_real_escape_string( $linkID, $attr["TID"] );
	$nodeID = mysqli_real_escape_string( $linkID, $attr["nodeID"] );
	if ( ! $nodeID ) {
		$nodeTID = mysqli_real_escape_string( $linkID, $attr["nodeTID"] );
		$nodeID  = $nodeTIDarray[ $nodeTID ];
	}

	$iquery  = "INSERT INTO sourcenodes (connection_id, node_id, created_date, modified_date) VALUES
											($connID, $nodeID, NOW(), NOW())";
	$success = mysqli_query( $linkID, $iquery );
	if ( $success ) {
		$outID      = getLastInsert( $linkID );
		$sourcenode = $output->addChild( "sourcenode" );
		$sourcenode->addAttribute( "TID", $tid );
		$sourcenode->addAttribute( "ID", $outID );
	} else {
		insertFailed( $output, $iquery );

		return false;
	}

	return true;
}

/**
 *    Defines the "argument" part of a connection in the DB.
 */
function connectionToDB( $conn, $mapID, $linkID, $userID, $output ) {
	global $nodeTIDarray;
	$connection = $output->addChild( "connection" );
	$attr       = $conn->attributes();
	$id         = mysqli_real_escape_string( $linkID, $attr["ID"] );
	$tid        = mysqli_real_escape_string( $linkID, $attr["TID"] );
	$nodeID     = mysqli_real_escape_string( $linkID, $attr["targetnodeID"] );
	$x          = mysqli_real_escape_string( $linkID, $attr["x"] );
	$y          = mysqli_real_escape_string( $linkID, $attr["y"] );

	//get Type ID since that's what we need
	$type     = mysqli_real_escape_string( $linkID, $attr["type"] );
	$query1   = "SELECT * FROM connection_types WHERE conn_name = '$type'";
	$resultID = mysqli_query( $linkID, $query1 );
	$row      = mysqli_fetch_assoc( $resultID );
	$typeID   = $row["type_id"];

	if ( ! $nodeID ) {
		$tnodeTID = mysqli_real_escape_string( $linkID, $attr["targetnodeTID"] );
		$nodeID   = $nodeTIDarray[ $tnodeTID ];
	}

	if ( ! $id ) {
		//Insert the connection into the DB (target node and info)
		$iquery  = "INSERT INTO connections (user_id, map_id, node_id, type_id, x_coord, y_coord, created_date, modified_date) VALUES
											($userID, $mapID, $nodeID, $typeID, $x, $y, NOW(), NOW())";
		$success = mysqli_query( $linkID, $iquery );
		if ( ! $success ) {
			insertFailed( $output, $iquery );

			return false;
		} else {
			$id = getLastInsert( $linkID );
			$connection->addAttribute( "TID", $tid );
			$connection->addAttribute( "ID", $id );
		}
	} else {
		//Update TYPE of the connection
		//It's not legal to change what node the connection is targeting.
		$uquery  = "UPDATE connections SET type_id = $typeID, modified_date=NOW(), x_coord=$x, y_coord=$y WHERE connection_id=$id";
		$success = mysqli_query( $linkID, $uquery );
		if ( ! $success ) {
			updateFailed( $output, $uquery );

			return false;
		}
		$connection->addAttribute( "ID", $id );
		$connection->addAttribute( "new_type", $typeID );
	}
	//Get the source nodes
	$children = $conn->children();
	foreach ( $children as $child ) {
		sourceNodeToDB( $child, $id, $linkID, $connection );
	}

	return true;
}

/**
 *    Convenience function that iterates through the XML to find all the pieces.
 *    Separated out for clarity.
 *    Order doesn't matter, so long as there's nothing referencing things that don't exist yet.
 */
function xmlToDB( $xml, $mapID, $linkID, $userID, $output ) {
	$children = $xml->children();
	foreach ( $children as $child ) {
		switch ( $child->getName() ) {
			case "textbox":
				$success = textboxToDB( $child, $mapID, $linkID, $userID, $output );
				if ( ! $success ) {
					return false;
				}
				break;
			case "node":
				$success = nodeToDB( $child, $mapID, $linkID, $userID, $output );
				if ( ! $success ) {
					return false;
				}
				break;
			case "connection":
				$success = connectionToDB( $child, $mapID, $linkID, $userID, $output );
				if ( ! $success ) {
					return false;
				}
				break;
		}
	}

	return true;
}

/**
 *    Highest-level function, that does the top level logic.
 */
function insert( $xmlin, $userID, $pass_hash, $auto_open ) {
	global $version;
	header( "Content-type: text/xml" );
	$xmlstr = "<?xml version='1.0'?>\n<map version='$version'></map>";
	$output = new SimpleXMLElement( $xmlstr );
	$linkID = establishLink();
	if ( ! $linkID ) {
		badDBLink( $output );

		return $output;
	}

	if ( ! checkLogin( $userID, $pass_hash, $linkID ) || ! checkLoginOmitGuest( $userID ) ) {
		incorrectLogin( $output );

		return $output;
	}
	$userID = mysqli_real_escape_string( $linkID, $userID );

	//Dig the Map ID out of the XML
	try {
		$xml = new SimpleXMLElement( $xmlin );
	} catch ( Exception $e ) {
		poorXML( $output );

		return $output;
	}
	$mapID     = $xml['ID'];
	$mapClause = mysqli_real_escape_string( $linkID, "$mapID" );
	//A backwards-compatible fix to allow lowercase-id to continue working to avoid breaking client code:
	$mapID = $xml['id'];
	if ( $mapID && ! $mapClause ) {
		$mapClause = $mapID;
	}

	//Check to see if the map already exists
	if ( $mapClause == 0 ) {
		//If not, create it!
		$title = mysqli_real_escape_string( $linkID, $xml['title'] );
		if ( ! $title ) {
			$title = "Untitled Map";
		}
		$desc = mysqli_real_escape_string( $linkID, $xml['desc'] );
		if ( ! $desc ) {
			$desc = "No description";
		}

		$lang = mysqli_real_escape_string( $linkID, $xml['lang'] );
		if ( ! $lang ) {
			$lang = "EN-US";
		}


		$queryname   = "SELECT * FROM maps m where m.title = '$title' and m.is_deleted=0";
		$resultIDmap = mysqli_query( $linkID, $queryname );
		if ( $resultIDmap && mysqli_num_rows( $resultIDmap ) > 0 ) {
			mapNameTaked( $output );

			return $output;
		}

		$iquery = "INSERT INTO maps (user_id, title, description, lang, created_date, modified_date) VALUES
										($userID, '$title', '$desc', '$lang', NOW(), NOW())";


		mysqli_query( $linkID, $iquery );
		$mapClause = getLastInsert( $linkID );
		if ( ! $mapClause ) {
			insertFailed( $output, $iquery );

			return $output;
		}

		$output->addAttribute( "ID", $mapClause );
	}

	if ( $auto_open ) {
		$output->addAttribute( "autoopenarg", $auto_open );
	}

	$query    = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE map_id = $mapClause";
	$resultID = mysqli_query( $linkID, $query );
	if ( ! $resultID ) {
		dataNotFound( $output, $query );

		return $output;
	}
	$row = mysqli_fetch_assoc( $resultID );

	//Check to see if this is the map author
	//If so, $ownMap is set to true.

	$author = $row['user_id'];
	$ownMap = false;
	if ( $author == $userID ) {
		$ownMap = true;
		//TODO: Use this to determine if the INSERTIONS are legal
		//We need to establish a clear policy on what insertions *are* legal, though.
		//That will be done on the Node and Connection levels.
		//It hinges on the TYPES of nodes and connections, which haven't been fully established yet.

		//(Note that UPDATES are checked against ownership of that individual thing)
	}

	//This part neatly handles all possibilities of failure. All we have to do is chain back "false" returns.
	mysqli_query( $linkID, "START TRANSACTION" );

	$success = xmlToDB( $xml, $mapClause, $linkID, $userID, $output );
	//Update map last modified time

	if ( $success === true ) {
		$uquery = "UPDATE maps SET modified_date=NOW() WHERE map_id=$mapClause";
		$status = mysqli_query( $linkID, $uquery );
		if ( ! $status ) {
			updateFailed( $output, $uquery );
			mysqli_query( $linkID, "ROLLBACK" );
			rolledBack( $output );
		}
		mysqli_query( $linkID, "COMMIT" );
	} else {
		mysqli_query( $linkID, "ROLLBACK" );
		rolledBack( $output );
	}

	return $output;

}

$xmlparam  = to_utf8( $_GET['xml'] ); //TODO: Change this back to a GET when all testing is done.
$userID    = $_REQUEST['uid'];
$pass_hash = $_REQUEST['pass_hash'];
$proj_type = $_REQUEST['proj_type'];
$auto_open = $_REQUEST['autoopenarg'];
$output    = insert( $xmlparam, $userID, $pass_hash, $auto_open );
print( $output->asXML() );

