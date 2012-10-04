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
	* Check-Login function separated out for widespread use.
	* Note that error handling is the caller's responsibility.
	*/
	function checkLogin($userID, $pass_hash, $linkID)
	{
		$query = "SELECT * FROM users WHERE user_ID='$userID' AND password='$pass_hash'";
		$resultID = mysql_query($query, $linkID);
		if($resultID && mysql_num_rows($resultID)>0){
			return true;
		}else{
			return false;
		}
	}

	/**
	* Function for converting code to UTF-8.
	* Licensed under the W3C Software License
	* License can be found here: http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231
	* Code comes from here: http://w3.org/International/questions/qa-forms-utf-8.html
	*/
	function to_utf8( $string ) {
		if ( preg_match('%^(?:
			[\x09\x0A\x0D\x20-\x7E]            # ASCII
			| [\xC2-\xDF][\x80-\xBF]             # non-overlong 2-byte
			| \xE0[\xA0-\xBF][\x80-\xBF]         # excluding overlongs
			| [\xE1-\xEC\xEE\xEF][\x80-\xBF]{2}  # straight 3-byte
			| \xED[\x80-\x9F][\x80-\xBF]         # excluding surrogates
			| \xF0[\x90-\xBF][\x80-\xBF]{2}      # planes 1-3
			| [\xF1-\xF3][\x80-\xBF]{3}          # planes 4-15
			| \xF4[\x80-\x8F][\x80-\xBF]{2}      # plane 16
			)*$%xs', $string) ) {
			return $string;
		} else {
			return iconv( 'CP1252', 'UTF-8', $string);
		}
	}

	function checkForAdmin($projID, $userID, $linkID){
		//There are two ways a person can be an "admin" of a project.
		//The first is that the person is the owner of the project ($userID==projects.user_id)
		$query = "SELECT user_id FROM projects WHERE proj_id=$projID";
		$resultID = mysql_query($query, $linkID);
		$row = mysql_fetch_assoc($resultID);
		if($userID == $row['user_id']){
			return true;
		}
		//The other is that the person is an administrator of the project.
		//(9 = projusers.user_level WHERE project=$projID AND user_id=$userID)
		$query = "SELECT user_level FROM projusers WHERE proj_id=$projID AND user_id=$userID";
		$resultID = mysql_query($query, $linkID);
		$row = mysql_fetch_assoc($resultID);
		if(9 == $row['user_level']){
			return true;
		}
		return false;
	}

	/**
		A function which will check whether:
		1. The map is in a project
		2. If 1 is true, then it checks if the user is in the corresponding project's user list
		It returns false if:
		-The map is not in a project at all
		-The user is not in the project the map is in
		It returns true if:
		-The map is in a project
		AND
		-The user in question is also in a project.
	*/
	function isUserInMapProject($userID, $mapID, $linkID){

		//Some of the basic SQL error handling will be omitted.
		//Queries should not fail at this point.
		$query = "SELECT proj_id FROM maps WHERE map_id = $mapID";
		$resultID = mysql_query($query, $linkID);
		if(!$resultID){
			return false;
			//The map isn't even showing up. The caller will get errors elsewhere.
		}
		$row = mysql_fetch_assoc($resultID);
		$projID = $row['proj_id'];
		if(!$projID){
			return false;
			//The map is not in a project
		}
		$pquery = "SELECT user_id FROM projects WHERE proj_id = $projID";
		$resultID = mysql_query($pquery, $linkID);
		$row = mysql_fetch_assoc($resultID);
		$proj_owner = $row['user_id'];
		if($userID==$proj_owner){
			return true;
			//The project's owner has rights to any map in the project
		}
		$puquery = "SELECT user_id FROM projusers WHERE proj_id = $projID AND user_id = $userID";
		$resultID = mysql_query($puquery, $linkID);
		if($resultID && mysql_num_rows($resultID)>0){
			return true;
			//The user is in the project
		}
		return false;
	}

	function isUserInProjectSpace($userID, $projID, $linkID){
		$puquery = "SELECT * FROM projusers WHERE proj_id = $projID AND user_id = $userID";
		$resultID = mysql_query($puquery, $linkID);
		if($resultID && mysql_num_rows($resultID)>0){
			return true;
			//The user is in the project
		}
		error_log("got user proj status",0);
		return false;
	}

	function isProjectNameTaken($projName, $linkID){

		$puquery = "SELECT * FROM projects WHERE title ='$projName'";
		$resultID = mysql_query($puquery, $linkID);
		if((!$resultID) || (mysql_num_rows($resultID)>0)){
			return true;
			//The name already taken
		}

	// Check in category as well ... ...
		$puquery = "SELECT * FROM category WHERE category_name ='$projName'";
		$resultID = mysql_query($puquery, $linkID);
		if((!$resultID) || (mysql_num_rows($resultID)>0)){
					return true;
					//The name already taken
		}

		return false;
	}
	
	function isProjectNameTakenEdit($projName, $linkID,$projID){
		$puquery = "SELECT * FROM projects WHERE title ='$projName' and proj_id!=$projID";
		$resultID = mysql_query($puquery, $linkID);
		if((!$resultID) || (mysql_num_rows($resultID)>0)){
			return true;
			//The name already taken
		}
	// Check in category as well ... ...
		$puquery = "SELECT * FROM category WHERE category_name ='$projName' and category_id!=$projID";
		$resultID = mysql_query($puquery, $linkID);
		if((!$resultID) || (mysql_num_rows($resultID)>0)){
					return true;
					//The name already taken
		}
		return false;
	}
		function isCategoryIdValid($catId, $linkID){
		$puquery = "SELECT * FROM category WHERE category_id =$catId";
		$resultID = mysql_query($puquery, $linkID);
		if($resultID && mysql_num_rows($resultID)>0){
					return false;
		}
		return true;
	}


	function getUserIdFromUserName($username,$linkID){
		$query = "SELECT * FROM users WHERE username='$username'";
		$resultID = mysql_query($query, $linkID);
		error_log($username,0);
		if(!$resultID){
			error_log("got userid for -1",0);
			return -1;
		}
		if((mysql_num_rows($resultID)==0)){
			error_log("got userid for -1 -1",0);
			return -1;
		}
		$row = mysql_fetch_assoc($resultID);
		if($row['is_deleted']){
			return -1;
		}
		$newuser = $row['user_id'];
		error_log("got userid for ",0);
		error_log($newuser,0);
		return $row['user_id'];
	}


function getUserNameFromUserId($userid,$linkID){
		$query = "SELECT * FROM users WHERE user_id='$userid'";
		$resultID = mysql_query($query, $linkID);
		error_log($userid,0);
		if(!$resultID){
			error_log("got userid for -1",0);
			return -1;
		}
		if(mysql_num_rows($resultID)==0){
			error_log("got userid for -1 -1",0);
			return -1;
		}
		$row = mysql_fetch_assoc($resultID);
		if($row['is_deleted']){
			return -1;
		}
		$newuser = $row['username'];
		return $newuser;
	}


	function getCategoryNamefromID($cat_id,$linkID){

		$query = "SELECT * FROM category WHERE category_id=$cat_id";
			$resultID = mysql_query($query, $linkID);
			error_log($cat_id,0);
			if(!$resultID){
				error_log("not matching categories found",0);
				return null;
			}

			if((mysql_num_rows($resultID)==0)){
				error_log("not matching categories found",0);
				return null;
			}
			$row = mysql_fetch_assoc($resultID);
			$cat_name = $row['category_name'];
			error_log("got cat name for ",0);
			error_log($cat_name,0);
			return $cat_name;

	}
	
	function getCategoryIDfromName($cat_name,$linkID){
			$query = "SELECT * FROM category WHERE category_name='$cat_name'";
			$resultID = mysql_query($query, $linkID);
			if(!$resultID){
				error_log("not matching categories found",0);
				return null;
			}

			if((mysql_num_rows($resultID)==0)){
				error_log("not matching categories found",0);
				return null;
			}
			$row = mysql_fetch_assoc($resultID);
			$cat_id = $row['category_id'];
			return $cat_id;
	}

	function getProjectNamefromID($projID,$linkID){

			$query = "SELECT * FROM projects WHERE proj_id=$projID";
				$resultID = mysql_query($query, $linkID);
	//			error_log($cat_id,0);
				if(!$resultID){
					error_log("not matching projects found",0);
					return null;
				}

				if((mysql_num_rows($resultID)==0)){
					error_log("not matching project found",0);
					return null;
				}
				$row = mysql_fetch_assoc($resultID);
				$cat_name = $row['title'];
				error_log("got proj name for ",0);
				error_log($cat_name,0);
				return $cat_name;

	}

	function generateAutoProjName($userId,$linkID){
					$parentDetail = Array();
					$username = getUserNameFromUserId($userId,$linkID);
				// check for valid parent cat .... else create a new private project .. ..
					$query="SELECT category_id,category_name FROM category WHERE category_name='$username'";
					$found_category_id=mysql_query($query, $linkID);
					if( !$found_category_id || mysql_num_rows($found_category_id) < 1){
					$create_private_proj="INSERT INTO category (category_name, is_project) VALUES ((SELECT username FROM users WHERE user_id='$userId'), 1)";
					$create_parent_link="INSERT INTO parent_categories (category_id, parent_category_name) 
										VALUES ((SELECT category_id FROM category WHERE category_name=(SELECT username FROM users WHERE user_id='$userId')),'Private, for individual users')";
					$make_user_admin = "INSERT INTO projusers (proj_id, user_id, user_level) VALUES 
											((SELECT category_id FROM category WHERE category_name=(SELECT username FROM users WHERE user_id='$userId')), '$userId', 9)";
					mysql_query($create_private_proj, $linkID);
					$parent_cat = getLastInsert($linkID);
					mysql_query($create_parent_link, $linkID);
					mysql_query($make_user_admin, $linkID);
					$query="SELECT category_id,category_name FROM category WHERE category_name='$username'";
					$found_category_id=mysql_query($query, $linkID);
					}
					$row = mysql_fetch_assoc($found_category_id);
					$parent_cat = $row['category_id'];
					$parent_name = $row['category_name'];
					$parentDetail['Id']=$parent_cat;
					$parentDetail['Name']=$parent_name;																											
					return $parentDetail;
				/*$projNameTemp = $username." Automatically created project";
				$gotMatch = false;
				$projNameSelQ = $projNameTemp."%";
				error_log($projNameSelQ,0);
				$query = "SELECT * FROM projects WHERE title like '$projNameSelQ'";
				$resultID = mysql_query($query, $linkID);
				if(!$resultID || mysql_num_rows($resultID)==0){
					$gotMatch=true;
				}

				$arraynames = array();
				if(!$gotMatch){
						for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){
						$row = mysql_fetch_assoc($resultID);
						$namechosen = $row['title'];
						$arraynames[$namechosen] = $x;
						}
						for($x = 0 ; $x < count($arraynames)+1 ; $x++){
							$newtempname = $projNameTemp." ".($x+1);
							if(!array_key_exists($newtempname,$arraynames)){
							$projNameTemp = $newtempname;
							break;
							}
						}
				}*/
				

	}
	
	function fetchTreeXmlForProj($pid,$catmap,$catnames,$root,$tree) {
	
		// to prevent cyclic tree structures ...
		if(array_key_exists($pid,$tree)){
			return;	
		}
		
		if(array_key_exists($pid,$catmap)){
			$parent = $catmap[$pid];
			if($parent!=0){
			$parentnode = fetchTreeXmlForProj($parent,$catmap,$catnames,$root,$tree);
			$node = $parentnode->addChild("child");
			$pdetails = $catnames[$pid];
			$node->addAttribute("pid",$pid);
			$node->addAttribute("pname",$pdetails['name']);
			$node->addAttribute("isproject",$pdetails['isproject']);
			$tree[$pid]=$pid;
			return $parentnode;
			}
		}
		
			$pdetails = $catnames[$pid];
			$root->addAttribute("pid",$pid);
			$root->addAttribute("pname",$pdetails['name']);
			$root->addAttribute("isproject",$pdetails['isproject']);
			$tree[$pid]=$pid;
			return $root;
		
	}

?>