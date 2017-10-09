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

/**
 * List of variables for project creation:
 * uid: ID number for the user
 * pass_hash: The hash of the user's password
 * projID: The ID of the project.
 * mapID: The ID of the map.
 * type: whether the map is a "debate" or "cooperate" map.
 * All maps are "debate"...UNLESS they're in a project, where they can be either.
 * action: "add" or "remove". Pretty self-explanatory, really.
 * Right now, there's no "create a new map as part of a project" function on the server, and doesn't actually need to be: the client can have a button which automatically calls insert.php followed by projmaps.php?action=add when it gets a successful result from insert.php.
 * "modify" exists, but does the same thing as "add" (in fact, it just calls addMap).
 **/
require 'configure.php';
require 'errorcodes.php';
require 'establish_link.php';
require 'utilfuncs.php';

function modifyMap( $mapID, $projID, $userID, $pass_hash, $type, $output ) {
	return addMap( $mapID, $projID, $userID, $pass_hash, $type, $output );
}

function addMap( $mapID, $projID, $userID, $pass_hash, $type, $output ) {
	$output->addAttribute( "ID", $projID );
	global $version;
	header( "Content-type: text/xml" );
	$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
	$output = new SimpleXMLElement( $xmlstr );
	$linkID = establishLink();
	if ( ! $linkID ) {
		badDBLink( $output );

		return $output;
	}
	if ( ! checkLogin( $userID, $pass_hash, $linkID ) ) {
		incorrectLogin( $output );

		return $output;
	}
	//Basic boilerplate is done. Next step is to add the map to the project.

	$mapID = mysqli_real_escape_string( $linkID, $mapID );
	$userID = mysqli_real_escape_string( $linkID, $userID );
	$projID = mysqli_real_escape_string( $linkID, $projID );

	//First, we check whether the user has authority to move the map into the project. To prevent abuse, only the map's creator can move the map into the project...
	$checkQuery = "SELECT user_id FROM maps WHERE map_id=$mapID";
	$resultID   = mysqli_query( $linkID, $checkQuery );
	$row        = mysqli_fetch_assoc( $resultID );
	$uid        = $row['user_id'];
	if ( $userID != $uid ) {
		//User is attempting to move someone else's map.
		modifyOther( $output );

		return $output;
	}
	//...and then only if he is a user of the project.
	$puQuery  = "SELECT user_id FROM projusers WHERE proj_id=$projID AND user_id=$userID";
	$resultID = mysqli_query( $linkID, $puQuery );
	if ( mysqli_num_rows( $resultID ) == 0 ) {
		//User is attempting to move map into a project he is not a member of
		notInProject( $output, $puQuery );

		return $output;
	}
	//Sanity check here
	if ( $type != "debate" && $type != "cooperate" ) {
		$type = "debate";
	}

	$query   = "UPDATE maps SET proj_id=$projID, map_type='$type' WHERE map_id=$mapID";
	$success = mysqli_query( $linkID, $query );
	if ( $success ) {
		$map = $output->addChild( "map" );
		$map->addAttribute( "ID", $mapID );
		$map->addAttribute( "added", true );
		$map->addAttribute( "type", $type );

		return $output;
	} else {
		$map = $output->addChild( "map" );
		$map->addAttribute( "ID", $mapID );
		$map->addAttribute( "added", false );
		updateFailed( $output, $query );

		return $output;
	}

	return $output;
}

function removeMap( $mapID, $projID, $userID, $pass_hash, $output ) {
	$output->addAttribute( "ID", $projID );
	global $version;
	header( "Content-type: text/xml" );
	$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
	$output = new SimpleXMLElement( $xmlstr );
	$linkID = establishLink();
	if ( ! $linkID ) {
		badDBLink( $output );

		return $output;
	}
	if ( ! checkLogin( $userID, $pass_hash, $linkID ) ) {
		incorrectLogin( $output );

		return $output;
	}
	//Basic boilerplate is done. Next step is to remove the map from the project.
	/*First, we check whether the user has authority to move the map out of the project.
	To prevent abuse, only the map's creator or a project administrator can move the map out of the project.
	The owner can do this even if he is no longer a user of the project.
	This does NOT delete the map.
	(Thinking: you can't kick me out of a project to take away my ability to work on my map.)
	*/

	$mapID = mysqli_real_escape_string( $linkID, $mapID );

	//If he's the map's owner, or an admin of the project, he can move the map out of the project.
	$query    = "SELECT user_id FROM maps WHERE map_id=$mapID";
	$resultID = mysqli_query( $linkID, $query );
	$row      = mysqli_fetch_assoc( $resultID );
	$uid      = $row['user_id'];
	if ( $userID != $uid && ! checkForAdmin( $projID, $userID, $linkID ) ) {
		notProjectAdmin( $output );

		return $output;
	}

	$query   = "UPDATE maps SET proj_id=NULL, map_type='debate' WHERE map_id=$mapID";
	$success = mysqli_query( $linkID, $query );
	if ( $success ) {
		$map = $output->addChild( "map" );
		$map->addAttribute( "ID", $mapID );
		$map->addAttribute( "removed", true );

		return $output;
	} else {
		$map = $output->addChild( "map" );
		$map->addAttribute( "ID", $mapID );
		$map->addAttribute( "removed", false );
		updateFailed( $output, $query );

		return $output;
	}

	return $output;
}

$userID    = $_REQUEST['uid'];
$pass_hash = $_REQUEST['pass_hash'];
$projID    = $_REQUEST['projID'];
$mapID     = $_REQUEST['mapID'];
$type      = $_REQUEST['type'];
//Type must be one of "debate" or "cooperate". If calling remove, this is ignored.
$action = $_REQUEST['action'];

header( "Content-type: text/xml" );
$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
$output = new SimpleXMLElement( $xmlstr );

if ( $action == "add" ) {
	$output = addMap( $mapID, $projID, $userID, $pass_hash, $type, $output );
} else if ( $action == "remove" ) {
	$output = removeMap( $mapID, $projID, $userID, $pass_hash, $output );
} else if ( $action == "modify" ) {
	$output = modifyMap( $mapID, $projID, $userID, $pass_hash, $type, $output );
} else {
	meaninglessQueryVariables( $output, "The 'action' variable must be set to either add or remove." );
}
print $output->asXML();

