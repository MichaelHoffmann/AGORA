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
require 'configure.php';
require 'errorcodes.php';
require 'establish_link.php';
	require 'utilfuncs.php';
/**
*	Function for getting the map list.
*/
function moveProject($uid, $passhash, $category_id, $target_proj_id) {
	global $dbName, $version;
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0' ?>\n<list version='$version'></list>";
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

	$checkLogin = "SELECT user_id FROM users WHERE user_id='$uid' AND password='$passhash'";
	if (!mysql_query($checkLogin, $linkID)) {
		incorrectLogin($output);
		return $output;
	}

	//Basic boilerplate is done.
	if (!checkForAdmin($category_id, $uid, $linkID)) {
		notProjectAdmin($output);
		return $output;
	}
	
	//Basic boilerplate is done.
	if ($category_id == $target_proj_id) {
		notProperProjectMovePath($output);
		return $output;
	}

	$checkIfProj = "SELECT * FROM category WHERE category_id=$target_proj_id
			        AND is_project=1";
	$result_IsProj = mysql_query($checkIfProj, $linkID);
	if (mysql_num_rows($result_IsProj) > 0) {
		$output->addAttribute("Proj", "Yes");
		$verifyProjMember = "SELECT proj_id FROM projusers 
		                    		WHERE proj_id=$target_proj_id AND user_id = $uid";
		$result_VerifyMem = mysql_query($verifyProjMember, $linkID);
		if (!mysql_num_rows($result_VerifyMem) > 0) {
			$output->addAttribute("Verified", "No");
			notProjectTargetUser($output);
			return $output;
		}
	}
	
	$checkIfCatLeaf = "SELECT * FROM category WHERE category_id=$target_proj_id
			        AND is_project=0";
	$result_IsProj = mysql_query($checkIfCatLeaf, $linkID);
	if (mysql_num_rows($result_IsProj) > 0) {
		$output->addAttribute("Proj", "No");
		$verifyProjMember = "SELECT category_id FROM parent_categories 
		                    		WHERE parent_categoryid=$target_proj_id";
		$result_VerifyLeaf = mysql_query($verifyProjMember, $linkID);
		if (mysql_num_rows($result_VerifyLeaf) > 0) {
			$output->addAttribute("Verified", "No");
			notProjectDestination($output);
			return $output;
		}
	}
	
	$parent_catname = getCategoryNamefromID($target_proj_id,$linkID);
	$query = "UPDATE parent_categories SET parent_categoryid=$target_proj_id,parent_category_name='$parent_catname' WHERE category_id=$category_id";
	$output->addAttribute("Category", $category_id);
	$resultID = mysql_query($query, $linkID);
	if (!$resultID) {
		dataNotFound($output, $query);
		return $output;
	}
	return $output;
}
$category_id = mysql_real_escape_string($_REQUEST['proj_id']); //TODO: Change this back to a GET when all testing is done.
$target_proj_id = mysql_real_escape_string($_REQUEST['target_proj_id']);
$uid = mysql_real_escape_string($_REQUEST['uid']);
$passhash = mysql_real_escape_string($_REQUEST['pass_hash']);

$output = moveProject($uid, $passhash, $category_id, $target_proj_id);
print ($output->asXML());
?>