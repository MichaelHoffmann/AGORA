<?php
require 'configure.php';
require 'errorcodes.php';
require 'establish_link.php';
require 'utilfuncs.php';

function findChildCategory( $parentCategory, $verify, $userID, $parent_catid ) {
	global $version;
	header( "Content-type: text/xml" );
	$xmlstr = "<?xml version='1.0' ?>\n<list version='$version'></list>";
	$output = new SimpleXMLElement( $xmlstr );

	$linkID = establishLink();
	if ( ! $linkID ) {
		badDBLink( $output );

		return $output;
	}

	$parent_catid   = mysqli_real_escape_string( $linkID, $parent_catid );
	$parentCategory = mysqli_real_escape_string( $linkID, $parentCategory );
	$userID         = mysqli_real_escape_string( $linkID, $userID );

	// check before getting in ....
	if ( $verify ) {
		$checkIfProj = "SELECT * FROM category WHERE category_name=$parentCategory AND is_project=1";
		if ( $parent_catid != -1 ) {
			$checkIfProj = "SELECT * FROM category WHERE category_id=$parent_catid AND is_project=1";
		}

		$result_IsProj = mysqli_query( $linkID, $checkIfProj );
		if ( $result_IsProj && mysqli_num_rows( $result_IsProj ) > 0 ) {
			if ( $parent_catid == -1 ) {
				$category_id = getCategoryIDfromNameStr( $parentCategory, $linkID );
			} else {
				$category_id = $parent_catid;
			}

			$verifyProjMember = "SELECT proj_id FROM projusers 
												                    		WHERE proj_id=$category_id AND user_id = $userID";
			$result_VerifyMem = mysqli_query( $linkID, $verifyProjMember );
			if ( ! $result_VerifyMem || mysqli_num_rows( $result_VerifyMem ) <= 0 ) {
				$errorchild = $output->addChild( "error" );
				$errorchild->addAttribute( "Verified", "No" );
				$queryUsernameAndURL = "SELECT * FROM users inner join projusers on users.user_id=projusers.user_id WHERE projusers.proj_id = $category_id and projusers.user_level=9";
				$resultUNURL         = mysqli_query( $linkID, $queryUsernameAndURL );
				$row2                = mysqli_fetch_assoc( $resultUNURL );
				$errorchild->addAttribute( "project_admin_firstname", $row2["firstname"] );
				$errorchild->addAttribute( "project_admin_lastname", $row2["lastname"] );
				$errorchild->addAttribute( "admin_url", $row2["url"] );
				notInProject( $errorchild, $linkID );

				return $output;
			}
		}
	}


	$query = "SELECT * FROM category JOIN parent_categories ON parent_categories.category_id = category.category_id WHERE parent_categories.parent_category_name = $parentCategory ORDER BY category.category_name";
	if ( $parent_catid != -1 ) {
		$query = "SELECT * FROM category JOIN parent_categories ON parent_categories.category_id = category.category_id WHERE parent_categories.parent_categoryid = $parent_catid ORDER BY category.category_name";
	}
	$resultID = mysqli_query( $linkID, $query );
	if ( ! $resultID ) {
		dataNotFound( $output, $query );
		$output->addAttribute( "category_count", "0" );
		$output->addAttribute( "project_count", "0" );

		return $output;
	}

	if ( mysqli_num_rows( $resultID ) == 0 ) {
		$output->addAttribute( "category_count", "0" );
		$output->addAttribute( "project_count", "0" );

		//This is a better alternative than reporting an error.
		return $output;
	} else {
		$count     = 0;
		$projCount = 0;
		for ( $x = 0; $x < mysqli_num_rows( $resultID ); $x++ ) {
			$row = mysqli_fetch_assoc( $resultID );
			$map = $output->addChild( "category" );
			$map->addAttribute( "ID", $row['category_id'] );
			$map->addAttribute( "Name", $row['category_name'] );
			$map->addAttribute( "is_project", $row['is_project'] );
			$isprpject = $row['is_project'];
			if ( $isprpject == 1 ) {
				$projCount++;
			} else {
				$count++;
			}
		}
		$output->addAttribute( "category_count", $count );
		$output->addAttribute( "project_count", $projCount );
	}
	mysqli_close( $linkID ); //closing the connection

	return $output;
}

function findChildCategoryMoveProjects( $parentCategory, $userID, $parentcatid ) {
	global $version;
	header( "Content-type: text/xml" );
	$xmlstr = "<?xml version='1.0' ?>\n<list version='$version'></list>";
	$output = new SimpleXMLElement( $xmlstr );

	$linkID = establishLink();
	if ( ! $linkID ) {
		badDBLink( $output );

		return $output;
	}

	$parentcatid    = mysqli_real_escape_string( $linkID, $parentcatid );
	$parentCategory = mysqli_real_escape_string( $linkID, $parentCategory );
	$userID         = mysqli_real_escape_string( $linkID, $userID );

	$checkIfProj = "SELECT * FROM category WHERE category_name=$parentCategory AND is_project=1";
	if ( $parentcatid != -1 ) {
		$checkIfProj = "SELECT * FROM category WHERE category_id=$parentcatid AND is_project=1";
	}

	$result_IsProj = mysqli_query( $linkID, $checkIfProj );
	if ( $result_IsProj && mysqli_num_rows( $result_IsProj ) > 0 ) {
		if ( $parentcatid == -1 ) {
			$category_id = getCategoryIDfromNameStr( $parentCategory, $linkID );
		} else {
			$category_id = $parentcatid;
		}

		$verifyProjMember = "SELECT proj_id FROM projusers 
										                    		WHERE proj_id=$category_id AND user_id = $userID";
		$result_VerifyMem = mysqli_query( $linkID, $verifyProjMember );
		if ( ! $result_VerifyMem || mysqli_num_rows( $result_VerifyMem ) <= 0 ) {
			$errorchild = $output->addChild( "error" );
			$errorchild->addAttribute( "Verified", "No" );
			$queryUsernameAndURL = "SELECT * FROM users inner join projusers on users.user_id=projusers.user_id WHERE projusers.proj_id = $category_id and projusers.user_level=9";
			$resultUNURL         = mysqli_query( $linkID, $queryUsernameAndURL );
			$row2                = mysqli_fetch_assoc( $resultUNURL );
			$errorchild->addAttribute( "project_admin_firstname", $row2["firstname"] );
			$errorchild->addAttribute( "project_admin_lastname", $row2["lastname"] );
			$errorchild->addAttribute( "admin_url", $row2["url"] );
			notInProject( $errorchild, $linkID );

			return $output;
		}
	}


	$query = "SELECT * FROM category JOIN parent_categories ON parent_categories.category_id = category.category_id WHERE parent_categories.parent_category_name = $parentCategory ORDER BY category.category_name";
	if ( $parentcatid != -1 ) {
		$query = "SELECT * FROM category JOIN parent_categories ON parent_categories.category_id = category.category_id WHERE parent_categories.parent_categoryid = $parentcatid ORDER BY category.category_name";
	}
	$resultID = mysqli_query( $linkID, $query );
	if ( ! $resultID ) {
		dataNotFound( $output, $query );

		return $output;
	}

	if ( mysqli_num_rows( $resultID ) == 0 ) {
		$output->addAttribute( "category_count", "0" );
		$output->addAttribute( "project_count", "0" );

		//This is a better alternative than reporting an error.
		return $output;
	} else {
		$count     = 0;
		$projCount = 0;
		for ( $x = 0; $x < mysqli_num_rows( $resultID ); $x++ ) {
			$row = mysqli_fetch_assoc( $resultID );
			$map = $output->addChild( "category" );
			$map->addAttribute( "ID", $row['category_id'] );
			$map->addAttribute( "Name", $row['category_name'] );
			$isprpject = $row['is_project'];
			if ( $isprpject == 1 ) {
				$projCount++;
			} else {
				$count++;
			}
			$map->addAttribute( "is_project", $row['is_project'] );
		}
		$output->addAttribute( "category_count", $count );
		$output->addAttribute( "project_count", $projCount );
	}
	mysqli_close( $linkID ); //closing the connection

	return $output;
}

$parentCategory    = $_REQUEST['parentCategory'];
$parentCategoryIDD = -1;
if ( array_key_exists( "usecatid", $_REQUEST ) ) {
	$useid = $_REQUEST['usecatid'];
	if ( $useid == 1 ) {
		$parentCategoryIDD = $_REQUEST['parentCategoryID'];
	}
}

$action = "map";

if ( array_key_exists( "action", $_REQUEST ) ) {
	$action = $_REQUEST['action'];
	$uid    = $_REQUEST['uid'];
	if ( $action == "projects" ) {
		$output = findChildCategoryMoveProjects( $parentCategory, $uid, $parentCategoryIDD );
	} else {
		$output = findChildCategory( $parentCategory, true, $uid, $parentCategoryIDD );
	}
} else {
	$output = findChildCategory( $parentCategory, false, -1, $parentCategoryIDD );
}
print ( $output->asXML() );
