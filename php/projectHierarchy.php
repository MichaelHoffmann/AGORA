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
 *    Function for getting the project list.
 */
function getProjectPath( $userID, $pass_hash, $id ) {
	global $version;
	header( "Content-type: text/xml" );
	$xmlstr = "<?xml version='1.0' ?>\n<list version='$version'></list>";
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

	// Form the hierarchy for the projects ...			
	$query      = "SELECT c.category_id catid,c.category_name catname,child.category_id pcCatId,child.parent_categoryid,c.is_project FROM category AS c LEFT JOIN `parent_categories` AS child ON c.category_id = child.category_id";
	$resultID   = mysqli_query( $linkID, $query );
	$catMap     = Array();
	$catNameMap = Array();
	if ( $resultID && mysqli_num_rows( $resultID ) > 0 ) {
		for ( $x = 0; $x < mysqli_num_rows( $resultID ); $x++ ) {
			$row        = mysqli_fetch_assoc( $resultID );
			$detailsMap = Array();
			$catIdVal   = $row['catid'];
			// details ...
			$catName                 = $row['catname'];
			$catParent               = $row['parent_categoryid'];
			$catType                 = $row['is_project'];
			$detailsMap['name']      = $catName;
			$detailsMap['isproject'] = $catType;
			if ( $catParent != null ) {
				$catMap[ $catIdVal ] = $catParent;
			}
			$catNameMap[ $catIdVal ] = $detailsMap;
		}
	}

	$vistedNodes = Array();
	$path        = $output->addChild( "path" );
	$path        = fetchTreeXmlForProj( $id, $catMap, $catNameMap, $path, $vistedNodes );

	return $output;
}

function getMapPath( $userID, $pass_hash, $id ) {
	global $version;
	header( "Content-type: text/xml" );
	$xmlstr = "<?xml version='1.0' ?>\n<list version='$version'></list>";
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

	$id           = mysqli_real_escape_string( $linkID, $id );
	$queryForCats = "(SELECT category_id FROM category_map WHERE map_id = $id)";
	$resultID     = mysqli_query( $linkID, $queryForCats );
	$row          = mysqli_fetch_assoc( $resultID );
	$catmapid     = $row['category_id'];

	error_log( $catmapid . "jakl" );
	// Form the hierarchy for the projects ...			
	$query      = "SELECT c.category_id catid,c.category_name catname,child.category_id pcCatId,child.parent_categoryid,c.is_project FROM category AS c LEFT JOIN `parent_categories` AS child ON c.category_id = child.category_id";
	$resultID   = mysqli_query( $linkID, $query );
	$catMap     = Array();
	$catNameMap = Array();
	if ( $resultID && mysqli_num_rows( $resultID ) > 0 ) {
		for ( $x = 0; $x < mysqli_num_rows( $resultID ); $x++ ) {
			$row        = mysqli_fetch_assoc( $resultID );
			$detailsMap = Array();
			$catIdVal   = $row['catid'];
			// details ...
			$catName                 = $row['catname'];
			$catParent               = $row['parent_categoryid'];
			$catType                 = $row['is_project'];
			$detailsMap['name']      = $catName;
			$detailsMap['isproject'] = $catType;
			if ( $catParent != null ) {
				$catMap[ $catIdVal ] = $catParent;
			}
			$catNameMap[ $catIdVal ] = $detailsMap;
		}
	}

	$vistedNodes = Array();
	$path        = $output->addChild( "path" );
	$path        = fetchTreeXmlForProj( $catmapid, $catMap, $catNameMap, $path, $vistedNodes );

	return $output;

}

$userID    = $_REQUEST['uid'];
$pass_hash = $_REQUEST['pass_hash'];
$id        = $_REQUEST['id'];
$type      = $_REQUEST['type'];

if ( $type == "maps" ) {
	$output = getMapPath( $userID, $pass_hash, $id );
} else {
	$output = getProjectPath( $userID, $pass_hash, $id );
}
error_log( $output->asXML(), 0 );
print ( $output->asXML() );
