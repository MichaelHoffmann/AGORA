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
	*	Add a map and move it to the project.
	*/
	function moveMapToProject($userID,$pass_hash,$map_id, $category_id){
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
		
		if(!checkLogin($userID, $pass_hash, $linkID)){
			incorrectLogin($output);
			return $output;
		}
		
		$pstats=isCategoryIdValidForAddMap($category_id,$linkID);
		$output->addAttribute("temp",$pstats);
		if($pstats==-1){
			projectNotFoundID($output);
			return $output;
		}
				
		//First, we check whether the user has authority to move the map into the project. 
		$checkQuery = "SELECT user_id FROM maps WHERE map_id=$map_id";
		$resultID = mysql_query($checkQuery, $linkID);
		$row = mysql_fetch_assoc($resultID);
		$uid = $row['user_id'];
		if($userID!=$uid){
			//User is attempting to move someone else's map.
			modifyOther($output);
			return $output;
		}
		if($pstats==1){
		$puQuery = "SELECT * FROM projects WHERE proj_id=$category_id";
		$resultID = mysql_query($puQuery, $linkID);
		if(!$resultID || mysql_num_rows($resultID)==0){
		//User is attempting to move map into a project he is not a member of
			notInProject($output, $puQuery);
			return $output;
		}
		//...and then only if he is a user of the project.
		$puQuery = "SELECT user_id FROM projusers WHERE proj_id=$category_id AND user_id=$userID";
		$resultID = mysql_query($puQuery, $linkID);
		if(!$resultID || mysql_num_rows($resultID)==0){
			//User is attempting to move map into a project he is not a member of
			notInProject($output, $puQuery);
			return $output;
		}
		}
		
		$query = "UPDATE category_map SET category_id='$category_id' WHERE map_id='$map_id'";
		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		$output->addAttribute("status", "true");
		return $output;
	}
	
	
	$userID = mysql_real_escape_string($_REQUEST['uid']);
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);	
	$category_id = mysql_real_escape_string($_REQUEST['category_id']);  //TODO: Change this back to a GET when all testing is done.
	$map_id = mysql_real_escape_string($_REQUEST['map_id']);
	$output=moveMapToProject($userID,$pass_hash,$map_id,$category_id);
	error_log($output->asXML());
	print($output->asXML());
?>