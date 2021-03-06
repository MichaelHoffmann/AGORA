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
 * List of variables for project joining:
 * uid: ID number for the user
 * pass_hash: The hash of the user's password
 * projID: Number of project to join
 * projPass: password of the project
 */
require 'configure.php';
require 'errorcodes.php';
require 'establish_link.php';
require 'utilfuncs.php';

function joinProject( $userID, $pass_hash, $projID, $projPass ) {
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

	$userID = mysqli_real_escape_string( $linkID, $userID );
	$projID = mysqli_real_escape_string( $linkID, $projID );

	//Basic boilerplate complete. Next step is to verify that the password is correct
	$query    = "SELECT * FROM projects WHERE proj_id=$projID";
	$resultID = mysqli_query( $linkID, $query );
	if ( ! $resultID ) {
		dataNotFound( $output, $query );

		return $output;
	} else {
		$output->addAttribute( "proj_id", $projID );
	}
	$row = mysqli_fetch_assoc( $resultID );
	if ( $projPass == $row['password'] && $row['password'] ) {
		//password is correct, and it's not some sort of null-like thing
		$query   = "INSERT INTO projusers (proj_id, user_id, user_level) VALUES ($projID, $userID, 1)";
		$success = mysqli_query( $linkID, $query );
		if ( $success ) {
			$user = $output->addChild( "user" );
			$user->addAttribute( "ID", $userID );
			$user->addAttribute( "added", true );

			return $output;
		} else {
			$user = $output->addChild( "user" );
			$user->addAttribute( "ID", $userID );
			$user->addAttribute( "added", false );
			updateFailed( $output, $query );

			return $output;
		}
	} else {
		//password is incorrect
		wrongPassword( $output );

		return $output;
	}

	return $output;
}

$userID    = $_REQUEST['uid'];
$pass_hash = $_REQUEST['pass_hash'];
$projID    = $_REQUEST['projID'];
$projPass  = $_REQUEST['projPass'];
$output    = joinProject( $userID, $pass_hash, $projID, $projPass );
print( $output->asXML() );
