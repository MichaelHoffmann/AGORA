<?php
	require 'configure.php';
	require 'errorcodes.php';
	require 'establish_link.php';
require 'utilfuncs.php';
function findChildCategory($parentCategory, $verify, $userID) {
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
	// check before getting in ....
	if ($verify) {
		$checkIfProj = "SELECT * FROM category WHERE category_name='$parentCategory' AND is_project=1";
		$result_IsProj = mysql_query($checkIfProj, $linkID);
		if ($result_IsProj && mysql_num_rows($result_IsProj) > 0) {
			$category_id = getCategoryIDfromName($parentCategory, $linkID);
			$verifyProjMember = "SELECT proj_id FROM projusers 
									                    		WHERE proj_id=$category_id AND user_id = $userID";
			$result_VerifyMem = mysql_query($verifyProjMember, $linkID);
			if (!$result_VerifyMem || mysql_num_rows($result_VerifyMem) <= 0) {
				$errorchild = $output->addChild("error");
				$errorchild->addAttribute("Verified", "No");
				$queryUsernameAndURL = "SELECT * FROM users inner join projusers on users.user_id=projusers.user_id WHERE projusers.proj_id = $category_id and projusers.user_level=9";
				$resultUNURL = mysql_query($queryUsernameAndURL, $linkID);
				$row2 = mysql_fetch_assoc($resultUNURL);
				$errorchild->addAttribute("project_admin_firstname", $row2["firstname"]);
				$errorchild->addAttribute("project_admin_lastname", $row2["lastname"]);
				$errorchild->addAttribute("admin_url", $row2["url"]);
				notInProject($errorchild, $linkID);
				return $output;
			}
		}
	}
	$query = "SELECT * FROM category JOIN parent_categories ON parent_categories.category_id = category.category_id WHERE parent_categories.parent_category_name = '$parentCategory' ORDER BY category.category_name";
	$resultID = mysql_query($query, $linkID);
	if (!$resultID) {
		dataNotFound($output, $query);
		return $output;
	}
	if (mysql_num_rows($resultID) == 0) {
		$output->addAttribute("category_count", "0");
		$output->addAttribute("project_count", "0");
		//This is a better alternative than reporting an error.
		return $output;
	} else {
		$count = 0;
		$projCount = 0;
		for ($x = 0; $x < mysql_num_rows($resultID); $x++) {
			$row = mysql_fetch_assoc($resultID);
			$map = $output->addChild("category");
			$map->addAttribute("ID", $row['category_id']);
			$map->addAttribute("Name", $row['category_name']);
			$map->addAttribute("is_project", $row['is_project']);
			$isprpject = $row['is_project'];
			if ($isprpject == 1) {
				$projCount++;
			} else {
				$count++;
			}
		}
		$output->addAttribute("category_count", $count);
		$output->addAttribute("project_count", $projCount);
	}
	mysql_close($linkID); //closing the connection
	return $output;
}
function findChildCategoryMoveProjects($parentCategory, $userID) {
	global $dbName, $version;
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0' ?>\n<list version='$version'></list>";
	$output = new SimpleXMLElement($xmlstr);
		$linkID= establishLink();
		if(!$linkID){
			badDBLink($output);
			return $output;
		}
		$status=mysql_select_db($dbName, $linkID);
		if(!$status){
			databaseNotFound($output);
			return $output;
		}
	// check before getting in ....
	$checkIfProj = "SELECT * FROM category WHERE category_name='$parentCategory' AND is_project=1";
	$result_IsProj = mysql_query($checkIfProj, $linkID);
	if ($result_IsProj && mysql_num_rows($result_IsProj) > 0) {
		$category_id = getCategoryIDfromName($parentCategory, $linkID);
		$verifyProjMember = "SELECT proj_id FROM projusers 
				                    		WHERE proj_id=$category_id AND user_id = $userID";
		$result_VerifyMem = mysql_query($verifyProjMember, $linkID);
		if (!$result_VerifyMem || mysql_num_rows($result_VerifyMem) <= 0) {
			$errorchild = $output->addChild("error");
			$errorchild->addAttribute("Verified", "No");
			$queryUsernameAndURL = "SELECT * FROM users inner join projusers on users.user_id=projusers.user_id WHERE projusers.proj_id = $category_id and projusers.user_level=9";
			$resultUNURL = mysql_query($queryUsernameAndURL, $linkID);
			$row2 = mysql_fetch_assoc($resultUNURL);
			$errorchild->addAttribute("project_admin_firstname", $row2["firstname"]);
			$errorchild->addAttribute("project_admin_lastname", $row2["lastname"]);
			$errorchild->addAttribute("admin_url", $row2["url"]);
			notInProject($errorchild, $linkID);
			return $output;
		}
	}

		
		
		
	$query = "SELECT * FROM category JOIN parent_categories ON parent_categories.category_id = category.category_id WHERE parent_categories.parent_category_name = '$parentCategory' ORDER BY category.category_name";
	$resultID = mysql_query($query, $linkID);
	if (!$resultID) {
		dataNotFound($output, $query);
		return $output;
	}
	if (mysql_num_rows($resultID) == 0) {
		$output->addAttribute("category_count", "0");
			$output->addAttribute("project_count", "0");
		//This is a better alternative than reporting an error.
		return $output;
	} else {
		$count = 0;
		$projCount =0;
		for ($x = 0; $x < mysql_num_rows($resultID); $x++) {
			$row = mysql_fetch_assoc($resultID);
			$map = $output->addChild("category");
			$map->addAttribute("ID", $row['category_id']);
			$map->addAttribute("Name", $row['category_name']);
			$isprpject = $row['is_project'];
			if($isprpject==1){
				$projCount++;
			}else{
				$count++;
			}
			$map->addAttribute("is_project", $row['is_project']);
		}
		$output->addAttribute("category_count", $count);
		$output->addAttribute("project_count", $projCount);
	}
	mysql_close($linkID); //closing the connection
	return $output;
}
$parentCategory= ($_REQUEST['parentCategory']);
$action = "map";

if (array_key_exists("action", $_REQUEST)) {
	$action = $_REQUEST['action'];
	$uid = $_REQUEST['uid'];
if ($action == "projects") {
	$output = findChildCategoryMoveProjects($parentCategory, $uid);
} else {
		$output = findChildCategory($parentCategory, true, $uid);
	}
} else {
	$output = findChildCategory($parentCategory, false, -1);
}
print($output->asXML());
?>