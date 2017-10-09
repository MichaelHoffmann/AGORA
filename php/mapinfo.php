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
 * List of variables for insertion:
 * HTTP Query variables:
 * uid: User ID of the user inserting the data
 * pass_hash: the hashed password of the user inserting the data
 * mapID: ID of the map to be modified
 * title: New title for the map (any value PHP treats as false means no change)
 * desc: New description for the map (any value PHP treats as false means no change)
 * lang: New language for the map (any value PHP treats as false means no change)
 */

require 'configure.php';
require 'errorcodes.php';
require 'establish_link.php';
require 'utilfuncs.php';

function updateMapInfo( $userID, $pass_hash, $mapID, $title, $desc, $lang ) {
	global $version;
	header( "Content-type: text/xml" );
	$xmlstr = "<?xml version='1.0'?>\n<mapinfo version='$version'/>";
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

	$mapID  = mysqli_real_escape_string( $linkID, $mapID );
	$userID = mysqli_real_escape_string( $linkID, $userID );
	$title  = mysqli_real_escape_string( $linkID, $title );
	$desc   = mysqli_real_escape_string( $linkID, $desc );
	$lang   = mysqli_real_escape_string( $linkID, $lang );

	//Basic boilerplate is done. Query to see if the map exists
	$query    = "SELECT * FROM maps WHERE map_id = $mapID AND maps.is_deleted = 0";
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
	//Map exists. Let's look at its information.
	$mapOwner = $row['user_id'];
	if ( $mapOwner != $userID ) {
		if ( isUserInMapProject( $userID, $mapID, $linkID ) ) {
			//Okay, user's in a project, he can edit the map's info
		} else {
			//You can't modify someone else's map information!
			modifyOther( $output );

			return $output;
		}
	}

	// map names are unique ..
	$queryname   = "SELECT * FROM maps m where m.title = '$title' and m.is_deleted=0 and m.map_id!=$mapID";
	$resultIDmap = mysqli_query( $linkID, $queryname );
	if ( $resultIDmap && mysqli_num_rows( $resultIDmap ) > 0 ) {
		mapNameTakedonEdit( $output );

		return $output;
	}

	//User has permission to modify this map.
	//$title, $desc, $lang - any of these being false/0/null means "no change"
	if ( ! $title ) {
		$title = $row['title'];
	}
	if ( ! $desc ) {
		$desc = $row['description'];
	}
	if ( ! $lang ) {
		$lang = $row['lang'];
	}
	$uquery  = "UPDATE maps SET title='$title', description='$desc', lang='$lang', modified_date=NOW() WHERE map_id=$mapID";
	$success = mysqli_query( $linkID, $uquery );
	if ( ! $success ) {
		updateFailed( $output, $uquery );

		return false;
	} else {
		$map = $output->addChild( "map" );
		$map->addAttribute( "ID", $mapID );
		$map->addAttribute( "modified", true );
	}

	return $output;

}

$userID    = $_REQUEST['uid'];
$pass_hash = $_REQUEST['pass_hash'];
$mapID     = $_REQUEST['map_id'];
$title     = $_REQUEST['title'];
$desc      = $_REQUEST['desc'];
$lang      = $_REQUEST['lang'];

$output = updateMapInfo( $userID, $pass_hash, $mapID, $title, $desc, $lang );
print $output->asXML();

