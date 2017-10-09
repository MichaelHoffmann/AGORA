<?php
/**
 *    Moves the map created into the user's private project
 */
require 'configure.php';
require 'errorcodes.php';
require 'establish_link.php';
require 'utilfuncs.php';

function mapToPrivateProject( $userID, $pass_hash, $mapID ) {
	global $version;
	header( "Content-type: text/xml" );
	$outputstr = "<?xml version='1.0' ?>\n<publish version='$version'></publish>";
	$output    = new SimpleXMLElement( $outputstr );
	$linkID    = establishLink();
	if ( ! $linkID ) {
		badDBLink( $output );

		return $output;
	}
	if ( ! checkLogin( $userID, $pass_hash, $linkID ) ) {
		incorrectLogin( $output );

		return $output;
	}

	$userID = mysqli_real_escape_string( $linkID, $userID );
	$mapID  = mysqli_real_escape_string( $linkID, $mapID );

	$query             = "SELECT category_id FROM category WHERE category_name='$userID'";
	$found_category_id = mysqli_query( $linkID, $query );
	if ( mysqli_num_rows( $found_category_id ) < 1 ) {
		$create_private_proj = "INSERT INTO category (category_name, is_project) VALUES ((SELECT username FROM users WHERE user_id='$userID'), 1)";
		$create_parent_link  = "INSERT INTO parent_categories (category_id, parent_category_name,parent_categoryid) 
								VALUES ((SELECT category_id FROM category WHERE category_name=(SELECT username FROM users WHERE user_id='$userID')),'Private, for individual users',38)";
		$make_user_admin     = "INSERT INTO projusers (proj_id, user_id, user_level) VALUES 
									((SELECT category_id FROM category WHERE category_name=(SELECT username FROM users WHERE user_id='$userID')), '$userID', 9)";
		mysqli_query( $linkID, $create_private_proj );
		mysqli_query( $linkID, $create_parent_link );
		if ( mysqli_query( $linkID, $make_user_admin ) ) {
			$output->addAttribute( "MadeAdmin", 1 );
		} else {
			$output->addAttribute( "MadeAdmin", mysqli_error( $linkID ) );
		}

		$output->addAttribute( "NewCat", "True" );
	}
	$create_map_link = "INSERT INTO category_map (map_id, category_id) VALUES ('$mapID',(SELECT category_id FROM category WHERE category_name=(SELECT username FROM users WHERE user_id='$userID')))";
	mysqli_query( $linkID, $create_map_link );
	$output->addAttribute( "Category", $userID );

	return $output;
}

$userID    = $_REQUEST['user_id']; //TODO: Change this back to a GET when all testing is done.
$mapID     = $_REQUEST['map_id'];
$pass_hash = $_REQUEST['pass_hash'];
$output    = mapToPrivateProject( $userID, $pass_hash, $mapID );
print( $output->asXML() );

