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
/**
 * Function allowing user to register a new account.
 */
function register( $username, $pass_hash, $firstname, $lastname, $email, $url, $url2, $url3 ) {
	global $version;
	header( "Content-type: text/xml" );
	$outputstr = "<?xml version='1.0' ?>\n<AGORA version='$version'/>";
	$output    = new SimpleXMLElement( $outputstr );
	$linkID    = establishLink();
	if ( ! $linkID ) {
		badDBLink( $output );

		return $output;
	}

	$username  = mysqli_real_escape_string( $linkID, $username );  //TODO: Change this back to a GET when all testing is done.
	$pass_hash = mysqli_real_escape_string( $linkID, $pass_hash );
	$firstname = mysqli_real_escape_string( $linkID, $firstname );
	$lastname  = mysqli_real_escape_string( $linkID, $lastname );
	$email     = mysqli_real_escape_string( $linkID, $email );
	$url       = mysqli_real_escape_string( $linkID, $url );
	$url2      = mysqli_real_escape_string( $linkID, $url2 );
	$url3      = mysqli_real_escape_string( $linkID, $url3 );

	$equery    = "SELECT * FROM users WHERE email='$email'";
	$eResultID = mysqli_query( $linkID, $equery );
	if ( ! $eResultID ) {
		dataNotFound( $output, $equery );

		return $output;
	}
	$erow = mysqli_fetch_assoc( $eResultID );
	if ( $erow['email'] != "" ) {
		repeatEmail( $output );

		return $output;
	}
	$query    = "SELECT * FROM users WHERE username='$username'";
	$resultID = mysqli_query( $linkID, $query );
	if ( ! $resultID ) {
		dataNotFound( $output, $query );

		return $output;
	}
	$row = mysqli_fetch_assoc( $resultID );

	if ( $row['user_id'] == "" ) // If user doesn't exist...
	{
		//insert into the database
		$iquery = "INSERT INTO users (is_deleted, firstname, lastname, username, password, email, url, user_level, created_date, last_login) VALUES (FALSE, '$firstname', '$lastname', '$username', '$pass_hash', '$email', '$url', 1, NOW(), NOW())";
		$insID  = mysqli_query( $linkID, $iquery );
		if ( ! $insID ) {
			insertFailed( $output, $iquery );

			return $output;
		}
		$login = $output->addChild( "login" );
		$login->addAttribute( "created", true ); // Successfully created the username.
	} else {
		$login = $output->addChild( "error" );
		$login->addAttribute( "text", "That username already exists!" ); // Username exists. Do NOT add to the db!
	}

	return $output;
}

$username  = $_REQUEST['username'];  //TODO: Change this back to a GET when all testing is done.
$pass_hash = $_REQUEST['pass_hash'];
$firstname = $_REQUEST['firstname'];
$lastname  = $_REQUEST['lastname'];
$email     = $_REQUEST['email'];
$url       = $_REQUEST['url'];
$url2      = $_REQUEST['url2'];
$url3      = $_REQUEST['url3'];

$output = register( $username, $pass_hash, $firstname, $lastname, $email, $url, $url2, $url3 );
print( $output->asXML() );

