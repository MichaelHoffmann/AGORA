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
 *    Function for allowing a user to change his own information.
 */
function changeinfo( $username, $pass_hash, $firstname, $lastname, $email, $url, $newpass, $secQ, $secA ) {
	global $version;
	header( "Content-type: text/xml" );
	$outputstr = "<?xml version='1.0' ?>\n<agora version='$version'/>\n";
	$output    = new SimpleXMLElement( $outputstr );
	$login     = $output->addChild( "login" );
	$linkID    = establishLink();
	if ( ! $linkID ) {
		badDBLink( $output );

		return $output;
	}
	$success = $output->addChild( "success" );

	$username_escaped  = mysqli_real_escape_string( $linkID, $username );
	$pass_hash_escaped = mysqli_real_escape_string( $linkID, $pass_hash );
	$firstname_escaped = mysqli_real_escape_string( $linkID, $firstname );
	$lastname_escaped  = mysqli_real_escape_string( $linkID, $lastname );
	$email_escaped     = mysqli_real_escape_string( $linkID, $email );
	$url_escaped       = mysqli_real_escape_string( $linkID, $url );
	$newpass           = mysqli_real_escape_string( $linkID, $newpass );
	$secQ              = mysqli_real_escape_string( $linkID, $secQ );
	$secA              = mysqli_real_escape_string( $linkID, $secA );

	$query    = "SELECT * FROM users WHERE username='$username_escaped' AND password='$pass_hash_escaped'";
	$resultID = mysqli_query( $linkID, $query );
	if ( ! $resultID || mysqli_num_rows( $resultID ) <= 0 ) {
		dataNotFoundUserNamePwd( $output );
		error_log( "usernot found", 0 );

		return $output;
	} else {
		$success->addAttribute( "foundIDandPass", true );
	}
	$row = mysqli_fetch_assoc( $resultID );
	$uid = $row['user_id'];
	$success->addAttribute( "uid ", $uid );


	$success->addAttribute( "username", $username );
	$success->addAttribute( "lastname ", $lastname );
	$success->addAttribute( "firstname ", $firstname );
	$success->addAttribute( "email ", $email );
	$success->addAttribute( "url ", $url );

	if ( ! $uid ) // If user doesn't exist...
	{
		$login->addAttribute( "modified", false );
	} else {
		//update the database
		if ( $newpass != "" ) {
			$iquery = "UPDATE users SET firstname='$firstname_escaped', 
				lastname='$lastname_escaped', password='$newpass', email='$email_escaped', securityQNum='$secQ',securityQAnswer='$secA',
				url='$url_escaped', last_login=NOW() WHERE user_id=$uid";
		} else {
			$iquery = "UPDATE users SET firstname='$firstname_escaped', 
				lastname='$lastname_escaped', email='$email_escaped', url='$url_escaped', securityQNum='$secQ',securityQAnswer='$secA',
				last_login=NOW() WHERE user_id=$uid";
		}

		$insID = mysqli_query( $linkID, $iquery );
		if ( ! $insID ) {
			updateFailed( $login, $iquery );

			return $output;
		} else {
			$login->addAttribute( "modified", true ); // Successfully created the username.
			if ( $newpass != "" ) {
				$success->addAttribute( "pass", $newpass );
				$pass_hash = $newpass;
			} else {
				$success->addAttribute( "pass", $pass_hash );
			}
		}
	}


	$query    = "SELECT * FROM users WHERE username='$username_escaped' AND password='$pass_hash_escaped'";
	$resultID = mysqli_query( $linkID, $query );
	if ( $resultID ) {
		$row     = mysqli_fetch_assoc( $resultID );
		$secQNum = $row['securityQNum'];
		if ( $secQNum != null ) {
			$success->addAttribute( "securityAnswerSet", true );
		} else {
			$success->addAttribute( "securityAnswerSet", false );
		}
		$secQCode    = $row['securityQNum'];
		$secQCodeSet = false;
		$secQCodeAns = "";
		if ( $secQCode != null ) {
			$secQCodeSet = true;
			$secQCodeAns = $row['securityQAnswer'];
		}
		$success->addAttribute( "secQCode", $secQCodeSet );
		$success->addAttribute( "secQCodeNum", $secQCode );
		$success->addAttribute( "secQCodeAns", $secQCodeAns );
	}


	return $output;
}

$username  = $_REQUEST['username'];
$firstname = $_REQUEST['firstname'];
$pass_hash = $_REQUEST['pass_hash'];
$lastname  = $_REQUEST['lastname'];
$email     = $_REQUEST['email'];
$url       = $_REQUEST['url'];
$secA      = $_REQUEST['secA'];
$secQ      = $_REQUEST['secQ'];
$newpass   = "";
if ( array_key_exists( "newpass", $_REQUEST ) ) {
	$newpass = $_REQUEST['newpass'];
}


$output = changeinfo( $username, $pass_hash, $firstname, $lastname, $email, $url, $newpass, $secQ, $secA );
print( $output->asXML() );