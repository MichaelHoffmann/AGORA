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
	List of variables for project creation:
	uid: ID number for the user
	pass_hash: The hash of the user's password
	projID: The ID of the project.
	userID: The ID of the user to be added or removed.
	action: "add" or "remove". Pretty self-explanatory, really.

	THIS IS NOT THE CODE FOR A USER JOINING THE PROJECT WITH THE PASSWORD!
**/
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
function getLastInsert($linkID) {
	$query    = "SELECT LAST_INSERT_ID()";
	$resultID = mysqli_query( $linkID, $query );
	$row      = mysqli_fetch_assoc( $resultID );
	return $row['LAST_INSERT_ID()'];
}

function deleteProject($projID, $userID, $pass_hash) {
	global $version;
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
	$output = new SimpleXMLElement($xmlstr);
	$output->addAttribute("ID", $projID);
	$proj=$output->addChild("proj");	
	
	$linkID = establishLink();
	if (!$linkID) {
		badDBLink($output);
		return $output;
	}
	if (!checkLogin($userID, $pass_hash, $linkID)) {
		incorrectLogin($output);
		return $output;
	}
	//Basic boilerplate is done.
	if (!checkForAdmin($projID, $userID, $linkID)) {
		error_log("na", 0);
		notProjectAdmin($output);
		return $output;
	}

	$userID    = mysqli_real_escape_string( $linkID, $userID );
	$projID    = mysqli_real_escape_string( $linkID, $projID );
	$pass_hash = mysqli_real_escape_string( $linkID, $pass_hash );

	// check if any child projects exist ...
	$query    = "SELECT * FROM parent_categories c inner join category p on c.parent_categoryid = p.category_id and p.category_id = $projID";
	$resultID = mysqli_query( $linkID, $query );

	if (!$resultID) {
		dataNotFound($output, $query);
		return $output;
	}

	if ( mysqli_num_rows( $resultID ) != 0 ) {
		deleteParentCatrgory($output);
		return $output;
	}

	/// 1 .
	// Check if no maps are present .. Then delete both project and Category .. ... ....	
	// move to private project / delete project category mapping all table entries !!!!!
	$query    = "SELECT * FROM `category_map` c inner join projects p on c.category_id = p.proj_id and c.category_id = $projID";
	$resultID = mysqli_query( $linkID, $query );
	if (!$resultID) {
		dataNotFound($output, $query);
		return $output;
	}

	if ( mysqli_num_rows( $resultID ) == 0 ) {
		$complete = true;
		mysqli_query( $linkID, "START TRANSACTION" );
		$query   = "DELETE FROM category WHERE category_id=$projID AND is_project=1";
		$success = mysqli_query( $linkID, $query );
		if ($success) {
			$query   = "DELETE FROM parent_categories WHERE category_id=$projID";
			$success = mysqli_query( $linkID, $query );
			$query   = "DELETE FROM projects WHERE proj_id=$projID";
			$success = mysqli_query( $linkID, $query );
			if (!$success) {
				$complete = false;
			} else {
				$query   = "DELETE FROM projusers WHERE proj_id=$projID";
				$success = mysqli_query( $linkID, $query );
			}
		} else {
			$complete = false;
		}
		$proj->addAttribute("map_count", "0");
		if (!$complete) {
			error_log("Rolled back", 0);
			mysqli_query( $linkID, "ROLLBACK" );
			$proj->addAttribute("deleted", "0");
		} else {
			$proj->addAttribute("deleted", "1");
		}
		mysqli_query( $linkID, "COMMIT" );
		return $output;
	}

	/// 2.
	// Check if maps are present - from users other than admins ... ... ...

	// check if maps are present - all of which are mine ... ... ...
	// move to private project / delete project category mapping all table entries !!!!!

	$query    = "SELECT * FROM category_map c inner join maps p on c.map_id = p.map_id and c.category_id = $projID and p.user_id != $userID and is_deleted=0";
	$resultID = mysqli_query( $linkID, $query );
	if (!$resultID) {
		dataNotFound($output, $query);
		return $output;
	}

	if ( mysqli_num_rows( $resultID ) == 0 ) {
		$complete = true;
		mysqli_query( $linkID, "START TRANSACTION" );
		$query   = "DELETE FROM category WHERE category_id=$projID AND is_project=1";
		$success = mysqli_query( $linkID, $query );
		if ($success) {
			$query    = "DELETE FROM parent_categories WHERE category_id=$projID";
			$success  = mysqli_query( $linkID, $query );
			$query    = "SELECT * FROM maps INNER JOIN category_map ON maps.map_id = category_map.map_id where category_map.category_id = $projID ";
			$resultID = mysqli_query( $linkID, $query );
			if ( $resultID && ( mysqli_num_rows( $resultID ) > 0 ) ) {
				$getAutoProjName = generateAutoProjName($userID, $linkID);
				$privProjectID = $getAutoProjName['Id'];
				for ( $x = 0; $x < mysqli_num_rows( $resultID ); $x++ ) {
					$row     = mysqli_fetch_assoc( $resultID );
					$mapID   = $row['map_id'];
					$query   = "UPDATE maps SET proj_id=$privProjectID where map_id=$mapID";
					$success = mysqli_query( $linkID, $query );
					$query   = "UPDATE category_map SET category_id=$privProjectID where map_id=$mapID";
					$success = mysqli_query( $linkID, $query );
					if ( ! $success ) {
						mysqli_query( $linkID, "ROLLBACK" );
						rolledBack($output);
						return $output;
					}
				}
			}
			$query   = "DELETE FROM projects WHERE proj_id=$projID";
			$success = mysqli_query( $linkID, $query );
			if (!$success) {
				$complete = false;
			} else {
				$query   = "DELETE FROM projusers WHERE proj_id=$projID";
				$success = mysqli_query( $linkID, $query );
			}
		} else {
			$complete = false;
		}
		if (!$complete) {
			error_log("Rolled back", 0);
			$proj->addAttribute("deleted", "0");
			mysqli_query( $linkID, "ROLLBACK" );
		} else {
			$proj->addAttribute("deleted", "1");
			mysqli_query( $linkID, "COMMIT" );
								error_log("changing commit",0);
					
		}
	} else {
		deleteProjectWithMaps($output);
		return $output;
	}

	return $output;
}

$userID    = $_REQUEST['uid'];
$pass_hash = $_REQUEST['pass_hash'];
$projID    = $_REQUEST['projID'];

header("Content-type: text/xml");
$output = deleteProject($projID, $userID, $pass_hash);
error_log($output->asXML(), 0);
print $output->asXML();
