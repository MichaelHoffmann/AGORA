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
 * projID: If any value PHP treats as false (use 0 for neatness), we are creating a new project. Otherwise, we're updating a project.
 * newpass: The hash of the project's password. Only needed for creating a project with one, or updating a project's password. When left blank, it means that the project's password is set to NULL, which makes it so that the only way in is for the administrator to explicitly add users in the project/user management system (rather than e-mailing everyone the password so they can add themselves). -- not used
 * title: Title of the project. Only needed for creating a project or changing the project's title.
 * is_hostile: If 1, then the project is a "debate" project - maps behave the same as a normal map; the project is effectively an access-limiting tool. If the project is a "collabortive" project, then anyone can edit anything.
 * proj_users: list of users who are given access to this project.
 **/
require 'configure.php';
require 'errorcodes.php';
require 'establish_link.php';
require 'utilfuncs.php';

function getLastInsert( $linkID ) {
	$query    = "SELECT LAST_INSERT_ID()";
	$resultID = mysqli_query( $linkID, $query );
	$row      = mysqli_fetch_assoc( $resultID );

	return $row['LAST_INSERT_ID()'];
}

function createProject( $userID, $pass_hash, $title, $is_hostile, $proj_users, $parent_cat ) {
	global $version;
	header( "Content-type: text/xml" );
	$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
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

	// special checking for guest login ...


	//Basic boilerplate is done. Next step is to create a new project with the various attributes.

	// Validations ..

	// 1. check if project name is unique ..
	// 2. check if users - project mapping in proj users is 1:1
	if ( isProjectNameTaken( $title, $linkID ) ) {
		$proj = $output->addChild( "proj" );
		projectNameUsed( $proj );
		error_log( "project name already used", 0 );

		return $output;
	}

	$userID     = mysqli_real_escape_string( $linkID, $userID );
	$parent_cat = mysqli_real_escape_string( $linkID, $parent_cat );
	$is_hostile = mysqli_real_escape_string( $linkID, $is_hostile );

	// check for valid parent cat .... else create a new private project .. ..
	if ( $parent_cat == 0 || ! $parent_cat ) {
		$username = getUserNameFromUserId( $userID, $linkID );
		$username = mysqli_real_escape_string( $linkID, $username );

		$query             = "SELECT category_id FROM category WHERE category_name='$username'";
		$found_category_id = mysqli_query( $linkID, $query );
		if ( ! $found_category_id || mysqli_num_rows( $found_category_id ) < 1 ) {
			$create_private_proj = "INSERT INTO category (category_name, is_project) VALUES ((SELECT username FROM users WHERE user_id='$userID'), 1)";
			$create_parent_link  = "INSERT INTO parent_categories (category_id, parent_category_name) 
											VALUES ((SELECT category_id FROM category WHERE category_name=(SELECT username FROM users WHERE user_id='$userID')),'Private, for individual users')";
			$make_user_admin     = "INSERT INTO projusers (proj_id, user_id, user_level) VALUES 
												((SELECT category_id FROM category WHERE category_name=(SELECT username FROM users WHERE user_id='$userID')), '$userID', 9)";
			mysqli_query( $linkID, $create_private_proj );
			$parent_cat = getLastInsert( $linkID );
			mysqli_query( $linkID, $create_parent_link );
			mysqli_query( $linkID, $make_user_admin );
		} else {
			$row        = mysqli_fetch_assoc( $found_category_id );
			$parent_cat = $row['category_id'];
		}
	} else {
		// check before getting in ....		
		$checkIfProj   = "SELECT * FROM category WHERE category_id=$parent_cat AND is_project=1";
		$result_IsProj = mysqli_query( $linkID, $checkIfProj );
		if ( $result_IsProj && mysqli_num_rows( $result_IsProj ) > 0 ) {
			$verifyProjMember = "SELECT proj_id FROM projusers 
			                    		WHERE proj_id=$parent_cat AND user_id = $userID";
			$result_VerifyMem = mysqli_query( $linkID, $verifyProjMember );
			if ( ! $result_VerifyMem || mysqli_num_rows( $result_VerifyMem ) <= 0 ) {
				$errorchild = $output->addChild( "error" );
				$errorchild->addAttribute( "Verified", "No" );
				notInProject( $errorchild, $linkID );

				return $output;
			}
		}
	}


	$query = "INSERT INTO category (category_name,is_project) VALUES ('$title', 1)";
	mysqli_query( $linkID, $query );
	$proj_catID = getLastInsert( $linkID );

	$query = "INSERT INTO projects (proj_id,user_id, title, is_hostile) VALUES
											($proj_catID,$userID, '$title', $is_hostile)";
	mysqli_query( $linkID, $query );
	$projID = getLastInsert( $linkID );
	if ( ! $projID ) {
		insertFailed( $output, $query );

		return $output;
	}
	$query = "INSERT INTO projusers (proj_id, user_id, user_level) VALUES ($projID, $userID, 9)";
	mysqli_query( $linkID, $query );

	// Add an entry into the Parent - Cat table
	$parent_category_name = getCategoryNamefromID( $parent_cat, $linkID );
	if ( $parent_category_name != null && $parent_category_name != "" ) {
		$parent_category_name = mysqli_real_escape_string( $linkID, $parent_category_name );
		$query                = "INSERT INTO parent_categories (category_id,parent_category_name,parent_categoryid) VALUES ($proj_catID,'$parent_category_name',$parent_cat)";
		mysqli_query( $linkID, $query );
	}

	$usersNotFound     = "";
	$userNotFoundCount = 0;

	// assign other users to project *** check if they are not already assigned and change ****
	// here the proj_id is actually the cat id .......
	foreach ( $proj_users as $user ) {
		$newuser_id = getUserIdFromUserName( $user, $linkID );
		if ( $newuser_id != -1 && ! isUserInProjectSpace( $newuser_id, $projID, $linkID ) ) {
			$query = "INSERT INTO projusers (proj_id, user_id, user_level) VALUES ($proj_catID, $newuser_id, 1)";
			mysqli_query( $linkID, $query );
		} else {
			$userNotFoundCount++;
			$usersNotFound .= " " . $user;
		}
	}

	//This is a lame hack that shouldn't be needed, but it'll work.
	$proj = $output->addChild( "project" );
	$proj->addAttribute( "ID", $projID );

	if ( $userNotFoundCount > 0 ) {
		$otheruser = $output->addChild( "userError" );
		$otheruser->addAttribute( "message", $usersNotFound );
	}

	return $output;
}

function editProject( $userID, $pass_hash, $projID, $title, $is_hostile, $typechange ) {
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
	//Basic boilerplate complete. Next step is to verify that the user is the owner of the project.

	$query    = "SELECT * FROM projects INNER JOIN users ON
				users.user_id = projects.user_id WHERE proj_id = $projID";
	$resultID = mysqli_query( $linkID, $query );
	if ( ! $resultID ) {
		dataNotFound( $output, $query );

		return $output;
	}
	$row = mysqli_fetch_assoc( $resultID );
	if ( ! $row['proj_id'] ) {
		nonexistent( $output, $query );

		return $output;
	}

	// Validations ..
	// user priv
	$UID = $row['user_id'];
	if ( $UID != $userID ) {
		modifyOther( $output );

		return $output;
	}
	$output->addAttribute( "temp", $typechange );
	if ( ! $typechange ) {
		$proj_name = $row['title'];
		$output->addAttribute( "temp1", $typechange );
		// No change in title - so we can prevent 2 queries here !!
		if ( strcasecmp( $proj_name, $title ) != 0 ) {
			// 1. check if project name is unique ..
			// 2. check if users - project mapping in proj users is 1:1
			if ( isProjectNameTakenEdit( $title, $linkID, $projID ) ) {
				$proj = $output->addChild( "proj" );
				projectNameUsed( $proj );
				error_log( "project name already used", 0 );

				return $output;
			}
		}

		error_log( "updated project name", 0 );
		$query   = "UPDATE category SET category_name='$title' WHERE category_id=$projID";
		$success = mysqli_query( $linkID, $query );
		$query   = "UPDATE parent_categories SET parent_category_name='$title' WHERE parent_categoryid=$projID";
		$success = mysqli_query( $linkID, $query );
		$query   = "UPDATE projects SET title='$title', is_hostile=$is_hostile WHERE proj_id=$projID";
		$success = mysqli_query( $linkID, $query );

	} else {
		$output->addAttribute( "temp1", $typechange );
		$query   = "UPDATE projects SET is_hostile=$is_hostile WHERE proj_id=$projID";
		$success = mysqli_query( $linkID, $query );
	}

	if ( $success ) {
		$proj = $output->addChild( "project" );
		$proj->addAttribute( "ID", $projID );
		$proj->addAttribute( "updated", true );

		return $output;
	} else {
		$proj = $output->addChild( "project" );
		$proj->addAttribute( "ID", $projID );
		$proj->addAttribute( "updated", false );
		updateFailed( $output, $query );

		return $output;
	}
}

$userID     = $_REQUEST['uid'];
$pass_hash  = $_REQUEST['pass_hash'];
$projID     = $_REQUEST['projID'];
$title      = $_REQUEST['title'];
$is_hostile = $_REQUEST['is_hostile'];

if ( ! $projID ) {
	$parent_cat = $_REQUEST['parent_category'];
	$num_users  = $_REQUEST["user_count"];
	error_log( $num_users );
	if ( $num_users > 0 ) {
		$proj_users = $_REQUEST["proj_users"];
	} else {
		$proj_users = array();
	}

	$output = createProject( $userID, $pass_hash, $title, $is_hostile, $proj_users, $parent_cat );
} else {
	$typechange = false;
	if ( array_key_exists( "changeType", $_REQUEST ) ) {
		$typechange = ( $_REQUEST['changeType'] );
	}
	$output = editProject( $userID, $pass_hash, $projID, $title, $is_hostile, $typechange );
}
print ( $output->asXML() );
