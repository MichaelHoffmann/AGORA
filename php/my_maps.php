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
 *    File for getting the list of maps a specific user has made.
 */

function my_maps( $userID, $pass_hash ) {
	global $version;
	header( "Content-type: text/xml" );
	$outputstr = "<?xml version='1.0' ?>\n<list version='$version'></list>";
	$output    = new SimpleXMLElement( $outputstr );

	$linkID = establishLink();
	if ( ! $linkID ) {
		badDBLink( $output );

		return $output;
	}
	if ( ! checkLogin( $userID, $pass_hash, $linkID ) ) {
		incorrectLogin( $output );

		return $output;
	}

	$userID = mysqli_real_escape_string( $linkID, $userID );

	$query = "SELECT maps.map_id, maps.title, users.username, users.firstname, users.lastname, users.url, maps.modified_date, lastviewed.lv_date 
		FROM maps LEFT JOIN lastviewed ON lastviewed.map_id=maps.map_id LEFT JOIN users ON maps.user_id=users.user_id 
		WHERE users.user_id=$userID AND maps.is_deleted=0 ORDER BY title, maps.map_id";

	$resultID = mysqli_query( $linkID, $query );
	if ( ! $resultID ) {
		dataNotFound( $output, $query );

		return $output;
	}
	if ( mysqli_num_rows( $resultID ) == 0 ) {
		$empty = $output->addChild( "empty" );
		$empty->addAttribute( "text", "This user has not created or contributed to any maps" );
		//Idea for the client: put an additional "create map" button in the "my maps" list, perhaps?
	}

	for ( $x = 0; $x < mysqli_num_rows( $resultID ); $x++ ) {
		$row       = mysqli_fetch_assoc( $resultID );
		$currMapID = $row['map_id'];
		$map       = $output->addChild( "map" );
		$map->addAttribute( "currMapID", $currMapID );
		$queryForCats = "SELECT category_name FROM category WHERE category_id = 
						(SELECT category_id FROM category_map WHERE map_id = $currMapID)";
		$resultingCat = mysqli_query( $linkID, $queryForCats );
		$mapCategory  = mysqli_fetch_array( $resultingCat );
		$map->addAttribute( "ID", $row['map_id'] );
		$map->addAttribute( "category", $mapCategory[0] );
		$map->addAttribute( "title", $row['title'] );
		$map->addAttribute( "creator", $row['username'] );
		$map->addAttribute( "last_modified", $row['modified_date'] );
		$map->addAttribute( "last_viewed", $row['lv_date'] );
		$map->addAttribute( "firstname", $row['firstname'] );
		$map->addAttribute( "lastname", $row['lastname'] );
		$map->addAttribute( "url", $row['url'] );
	}

	return $output;
}


$userID    = $_REQUEST['uid'];  //TODO: Change this back to a GET when all testing is done.
$pass_hash = $_REQUEST['pass_hash']; //TODO: Change this back to a GET when all testing is done.
$output    = my_maps( $userID, $pass_hash );
print( $output->asXML() );
