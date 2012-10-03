<?php
require 'configure.php';
require 'errorcodes.php';
require 'establish_link.php';
require 'utilfuncs.php';

function findChildCategories($projID, $userID, $pass_hash) {
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

	if (!checkLogin($userID, $pass_hash, $linkID)) {
		incorrectLogin($output);
		return $output;
	}

	// check before getting in ....
	$checkIfProj = "SELECT * FROM category WHERE category_id=$projID AND is_project=1";
	$result_IsProj = mysql_query($checkIfProj, $linkID);
	if ($result_IsProj && mysql_num_rows($result_IsProj) > 0) {
		$verifyProjMember = "SELECT proj_id FROM projusers WHERE proj_id=$projID AND user_id = $userID";
		$result_VerifyMem = mysql_query($verifyProjMember, $linkID);
		if (!$result_VerifyMem || mysql_num_rows($result_VerifyMem) <= 0) {
			$errorchild = $output->addChild("error");
			$errorchild->addAttribute("Verified", "No");
			notInProject($errorchild, $linkID);
			return $output;
		}
	}

	$query = "SELECT * FROM category JOIN parent_categories ON parent_categories.category_id = category.category_id WHERE parent_categories.parent_categoryid = $projID ORDER BY category.category_name";
	$resultID = mysql_query($query, $linkID);
	if (!$resultID) {
		dataNotFound($output, $query);
		return $output;
	}

	if (mysql_num_rows($resultID) == 0) {
		$output->addAttribute("project_count", "0");
		return $output;
	} else {
		$count = 0;
		$projCount = 0;
		for ($x = 0; $x < mysql_num_rows($resultID); $x++) {
			$row = mysql_fetch_assoc($resultID);
			$map = $output->addChild("child");
			$map->addAttribute("projID", $row['category_id']);
			$map->addAttribute("name", $row['category_name']);
			$isprpject = $row['is_project'];
			if ($isprpject == 1) {
				$projCount++;
			} else {
				$count++;
			}
			$map->addAttribute("is_project", $row['is_project']);
		}
		$output->addAttribute("project_count", $projCount);
	}
	mysql_close($linkID); //closing the connection
	return $output;
}
$parentCategory = ($_REQUEST['projID']);
$pass_hash = $_REQUEST['pass_hash'];
$uid = $_REQUEST['uid'];
$output = findChildCategories($parentCategory, $uid, $pass_hash);
print ($output->asXML());
?>