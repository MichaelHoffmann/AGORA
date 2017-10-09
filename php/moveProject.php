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
	global $version;
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0' ?>\n<list version='$version'></list>";
	$output = new SimpleXMLElement($xmlstr);

	$linkID = establishLink();
	if (!$linkID) {
		badDBLink($output);
		return $output;
	}

	if ( ! checkLogin( $uid, $passhash, $linkID ) ) {
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

	// check if private project is being moved !!!
	$username = getUserNameFromUserId($uid,$linkID);
	$query    = "SELECT * FROM category WHERE category_id=$category_id AND category_name='$username'";
	$resultID = mysqli_query( $linkID, $query );
	if ( $resultID && mysqli_num_rows( $resultID ) > 0 ) {
		privateProjectMovePath($output);
		return $output;
	}

	$target_proj_id = mysqli_real_escape_string( $linkID, $target_proj_id );
	$category_id    = mysqli_real_escape_string( $linkID, $category_id );
	$uid            = mysqli_real_escape_string( $linkID, $uid );

	$checkIfProj   = "SELECT * FROM category WHERE category_id=$target_proj_id
			        AND is_project=1";
	$result_IsProj = mysqli_query( $linkID, $checkIfProj );
	if ( $result_IsProj && mysqli_num_rows( $result_IsProj ) > 0 ) {
		$output->addAttribute("Proj", "Yes");
		$verifyProjMember = "SELECT proj_id FROM projusers 
		                    		WHERE proj_id=$target_proj_id AND user_id = $uid";
		$result_VerifyMem = mysqli_query( $linkID, $verifyProjMember );
		if ( ! mysqli_num_rows( $result_VerifyMem ) > 0 ) {
			$output->addAttribute("Verified", "No");
			notProjectTargetUser($output);
			return $output;
		}
	}
	// get the children of the project and check for cyclic paths ..
	$vistedNodes = Array ();
	// Form the hierarchy for the projects ...			
	$query    = "SELECT c.category_id catid,c.category_name catname,child.category_id pcCatId,child.parent_categoryid,c.is_project FROM category AS c LEFT JOIN `parent_categories` AS child ON c.category_id = child.category_id";
	$resultID = mysqli_query( $linkID, $query );
	$catMap   = Array();
	if ( $resultID && mysqli_num_rows( $resultID ) > 0 ) {
		for ( $x = 0; $x < mysqli_num_rows( $resultID ); $x++ ) {
			$row      = mysqli_fetch_assoc( $resultID );
			$catIdVal = $row['catid'];
			// details ...
			$catParent = $row['parent_categoryid'];
			if ($catParent != NULL) {
				$catMap[$catIdVal] = $catParent;
			}
		}
	}	
	$vistedNodes = fetchTreeNodesForProj($target_proj_id,$catMap, $vistedNodes);	
	if(array_key_exists($category_id,$vistedNodes)){
		$output->addAttribute("Verified", "No");
			cyclicPathPrevented($output);
			return $output;
	}
	
	$checkIfCatLeaf = "SELECT * FROM category WHERE category_id=$target_proj_id
			        AND is_project=0";
	$result_IsProj  = mysqli_query( $linkID, $checkIfCatLeaf );
	if ( mysqli_num_rows( $result_IsProj ) > 0 ) {
		$output->addAttribute("Proj", "No");
		$verifyProjMember  = "SELECT * FROM parent_categories inner join category on parent_categories.category_id = category.category_id
				                    		WHERE parent_categoryid=$target_proj_id and category.is_project=0";
		$result_VerifyLeaf = mysqli_query( $linkID, $verifyProjMember );
		if ( mysqli_num_rows( $result_VerifyLeaf ) > 0 ) {
			$output->addAttribute("Verified", "No");
			notProjectDestination($output);
			return $output;
		}
	}
	
	$parent_catname = getCategoryNamefromID($target_proj_id,$linkID);
	$parent_catname = mysqli_real_escape_string( $linkID, $parent_catname );
	$query          = "UPDATE parent_categories SET parent_categoryid=$target_proj_id,parent_category_name='$parent_catname' WHERE category_id=$category_id";
	$output->addAttribute("Category", $category_id);
	$resultID = mysqli_query( $linkID, $query );
	if (!$resultID) {
		dataNotFound($output, $query);
		return $output;
	}
	return $output;
}

$category_id    = $_REQUEST['proj_id']; //TODO: Change this back to a GET when all testing is done.
$target_proj_id = $_REQUEST['target_proj_id'];
$uid            = $_REQUEST['uid'];
$passhash       = $_REQUEST['pass_hash'];

$output = moveProject($uid, $passhash, $category_id, $target_proj_id);
print ($output->asXML());
