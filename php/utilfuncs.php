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
		if(mysql_num_rows($resultID)>0){
			return true;
			//The user is in the project
		}
		return false;
	}
	
?>