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
	$query = "SELECT LAST_INSERT_ID()";
	$resultID = mysql_query($query, $linkID);
	$row = mysql_fetch_assoc($resultID);
	return $row['LAST_INSERT_ID()'];
}

function addUser($userID, $pass_hash, $projID, $proj_users, $level, $output) {
	$output->addAttribute("ID", $projID);
	global $dbName, $version;
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
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
	if (!checkLogin($userID, $pass_hash, $linkID)) {
		print $userID;
		print $pass_hash;
		print $dbName;
		incorrectLogin($output);
		return $output;
	}
	//Basic boilerplate is done.

	if (!checkForAdmin($projID, $userID, $linkID)) {
		notProjectAdmin($output);
		return $output;
	}
	
	$usersNotFound = "";
	$userNotFoundCount = 0;

	foreach ($proj_users as $otheruserID) {
		$userid = getUserIdFromUserName($otheruserID, $linkID);
		if ($userid == -1) {
			error_log("user not found !!", 0);
			$userNotFoundCount++;
			$usersNotFound .= " ".$otheruserID;
			continue;
		}
		$query = "INSERT INTO projusers (proj_id, user_id, user_level) VALUES ($projID, $userid, $level)";
		$success = mysql_query($query, $linkID);
		if ($success) {
			$otheruser = $output->addChild("user");
			$otheruser->addAttribute("ID", $otheruserID);
			$otheruser->addAttribute("added", true);
		} else {
			$otheruser = $output->addChild("user");
			$otheruser->addAttribute("ID", $otheruserID);
			$otheruser->addAttribute("added", false);
		}
	}
	
			if($userNotFoundCount>0){ 
			$otheruser = $output->addChild("userError");
			$otheruser->addAttribute("message", $usersNotFound);
			}
	return $output;
}

function removeUser($projID, $userID, $pass_hash, $userList, $output) {
	$output->addAttribute("ID", $projID);
	global $dbName, $version;
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
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

	foreach ($userList as $otheruserID) {
		if ($otheruserID == $userID) {
			error_log("Admin User cannot be removed..", 0);
			continue;
		}
		mysql_query("START TRANSACTION");
		$query = "DELETE FROM projusers WHERE proj_id=$projID AND user_id=$otheruserID";
		$success = mysql_query($query, $linkID);
		if ($success) {
			//Remove all of this user's maps from the project and make a new project for them.
			$getAutoProjName = generateAutoProjName($otheruserID, $linkID);
			$catname = $getAutoProjName['Name'];
			$newID = $getAutoProjName['Id'];
			error_log("error" . $newID . $catname, 0);
			/*$query = "INSERT INTO projects (user_id, title, is_hostile) VALUES
										($otheruserID, '$catname', 1)";
			$status = mysql_query($query, $linkID);
			$newID = getLastInsert($linkID);
			if(!$status){
				mysql_query("ROLLBACK");
				rolledBack($output);
				return $output;
			}*/

			$uquery = "UPDATE maps SET proj_id=$newID WHERE user_id=$otheruserID AND proj_id=$projID";
			$status = mysql_query($uquery, $linkID);

			//$query = "INSERT INTO category (category_name, is_project) VALUES ('$getAutoProjName', 1)";
			//$status = mysql_query($query, $linkID);
			if (!$status) {
				mysql_query("ROLLBACK");
				rolledBack($output);
				return $output;
			}
			$otheruser = $output->addChild("user");
			$otheruser->addAttribute("ID", $otheruserID);
			$otheruser->addAttribute("removed", true);
			mysql_query("COMMIT");
			//return $output;
		} else {
			$otheruser = $output->addChild("user");
			$otheruser->addAttribute("ID", $otheruserID);
			$otheruser->addAttribute("removed", false);
			updateFailed($output, $query);
			mysql_query("ROLLBACK");
			rolledBack($output);
			//return $output;
		}
	}
	error_log($output, 0);
	return $output;
}

function verifyUser($projID, $userID, $pass_hash, $output) {
	global $dbName, $version;
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
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
	if (!checkLogin($userID, $pass_hash, $linkID)) {
		incorrectLogin($output);
		return $output;
	}
	//Basic boilerplate is done.
	if (!checkForAdmin($projID, $userID, $linkID)) {
		notProjectAdmin($output);
		return $output;
	}
	$query = "SELECT * FROM projusers WHERE proj_id='$projID' AND user_id='$userID'";

	$success = mysql_query($query, $linkID);
	if (mysql_num_rows($success) > 0) {
		return true;
	} else {
		return false;
	}
	return $output;
}

function modifyUser($otheruserID, $projID, $userID, $level, $pass_hash, $output) {
	$output->addAttribute("ID", $projID);
	global $dbName, $version;
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
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
	if (!checkLogin($userID, $pass_hash, $linkID)) {
		incorrectLogin($output);
		return $output;
	}
	//Basic boilerplate is done.
	if (!checkForAdmin($projID, $userID, $linkID)) {
		notProjectAdmin($output);
		return $output;
	}
	$query = "UPDATE projusers SET user_level=$level WHERE proj_id=$projID AND user_id=$otheruserID";

	$success = mysql_query($query, $linkID);
	if ($success) {
		$otheruser = $output->addChild("user");
		$otheruser->addAttribute("ID", $otheruserID);
		$otheruser->addAttribute("modified", true);
		return $output;
	} else {
		$otheruser = $output->addChild("user");
		$otheruser->addAttribute("ID", $otheruserID);
		$otheruser->addAttribute("modified", false);
		updateFailed($output, $query);
		return $output;
	}
	return $output;
}

function makeAdmin($otheruserID, $projID, $userID, $pass_hash, $output) {
	$output->addAttribute("ID", $projID);
	global $dbName, $version;
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
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
	if (!checkLogin($userID, $pass_hash, $linkID)) {
		incorrectLogin($output);
		return $output;
	}
	//Basic boilerplate is done.
	if (!checkForAdmin($projID, $userID, $linkID)) {
		notProjectAdmin($output);
		return $output;
	}

	$username = getUserNameFromUserId($otheruserID, $linkID);
	if ($username == -1) {
		notValidUser($output);
		return $output;
	}

	$query = "UPDATE projusers SET user_level=9 WHERE proj_id=$projID AND user_id=$otheruserID";
	$success = mysql_query($query, $linkID);
	$query = "UPDATE projects SET user_id=$otheruserID WHERE proj_id=$projID";
	$success = mysql_query($query, $linkID);
	if ($success) {
		$otheruser = $output->addChild("user");
		$otheruser->addAttribute("ID", $otheruserID);
		$otheruser->addAttribute("modified", true);
	} else {
		$otheruser = $output->addChild("user");
		$otheruser->addAttribute("ID", $otheruserID);
		$otheruser->addAttribute("modified", false);
		updateFailed($output, $query);
	}

	$query = "UPDATE projusers SET user_level=1 WHERE proj_id=$projID AND user_id=$userID";
	$success = mysql_query($query, $linkID);
	if ($success) {
		$otheruser = $output->addChild("user");
		$otheruser->addAttribute("ID", $userID);
		$otheruser->addAttribute("modified", true);
	} else {
		$otheruser = $output->addChild("user");
		$otheruser->addAttribute("ID", $userID);
		$otheruser->addAttribute("modified", false);
		updateFailed($output, $query);
	}

	return $output;
}

$userID = mysql_real_escape_string($_REQUEST['uid']);
$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);
$projID = mysql_real_escape_string($_REQUEST['projID']);
//$otheruserID =  mysql_real_escape_string($_REQUEST['otheruserID']);
//$level = mysql_real_escape_string($_REQUEST['level']);
$action = $_REQUEST['action'];

header("Content-type: text/xml");
$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
$output = new SimpleXMLElement($xmlstr);

if ($action == "add") {
	$userList = $_REQUEST['usersList'];
	$level = 0;
	$output = addUser($userID, $pass_hash, $projID, $userList, $level, $output);
} else
	if ($action == "remove") {
		$userList = $_REQUEST['usersList'];
		$output = removeUser($projID, $userID, $pass_hash, $userList, $output);
	} else
		if ($action == "validate") {
			$output = validateUser($userID, $pass_hash, $projID, $output);
		} else
			if ($action == "modify") {
				$output = modifyUser($otheruserID, $projID, $userID, $level, $pass_hash, $output);
			} else
				if ($action == "makeAdmin") {
					$otheruserID = mysql_real_escape_string($_REQUEST['newAdminUserId']);
					$output = makeAdmin($otheruserID, $projID, $userID, $pass_hash, $output);
				} else {
					meaninglessQueryVariables($output, "The 'action' variable must be set to either add or remove.");
				}
error_log($output->asXML(), 0);
print $output->asXML();
?>