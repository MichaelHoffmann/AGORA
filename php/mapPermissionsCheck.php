<?php


/*
 * Created on Feb 1, 2014
 *
 * To change the template for this generated file go to
 * Window - Preferences - PHPeclipse - PHP - Code Templates
 */
require 'configure.php';
require 'errorcodes.php';
require 'establish_link.php';
require 'utilfuncs.php';

function testPermissions($userID, $text) {

	global $dbName, $version;
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0'?>\n<map version='$version'></map>";
	$output = new SimpleXMLElement($xmlstr);
	$linkID = establishLink();
	if (!$linkID) {
		badDBLink($output);
		return $output;
	}
	$status = mysql_select_db($dbName, $linkID);
	if (!$status) {
		databaseNotFound($output);
		return $output;
	}

	// check for map permissions first
	$queryP = "SELECT maps.map_id,maps.proj_id, maps.title,maps.map_type,maps.created_date, category_map.category_id,projects.is_hostile,users.username,users.url FROM maps INNER JOIN users ON users.user_id = maps.user_id inner JOIN category_map on maps.map_id=category_map.map_id left join projects on projects.proj_id=category_map.category_id WHERE maps.is_deleted = 0 and maps.map_id=$text";
	$resultIDP = mysql_query($queryP, $linkID);
	if ($resultIDP && mysql_num_rows($resultIDP) != 0) {
		$row = mysql_fetch_assoc($resultIDP);
		if ($row['proj_id']) {
			//Map is in a project.
			//Confirm that the project allows the user to open a map
			if (!isUserInMapProject($userID, $text, $linkID)) {
				mapAccessFailed($output);
				return $output;
			}
		}
	} else {
		mapAccessFailed($output);
		return $output;
	}
	
	$output->addAttribute("ID", $row['map_id']);
	$output->addAttribute("title", $row['title']);
	$output->addAttribute("username", $row['username']);
	$output->addAttribute("url", $row['url']);
	$output->addAttribute("firstname", $row['firstname']);
	$output->addAttribute("lastname", $row['lastname']);	
	$output->addAttribute("message", true);	
	return $output;
}

$userID = mysql_real_escape_string($_REQUEST['uid']);
$mapId = mysql_real_escape_string($_REQUEST['mapid']);
$output = testPermissions($userID, $mapId);
print ($output->asXML());
?>
					