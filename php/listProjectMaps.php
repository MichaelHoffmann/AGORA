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
	function listMapsInProject($userID,$pass_hash, $category_id){
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
		
		if(isCategoryIdValid($category_id,$linkID)){
			projectNotFoundID($output);
			return $output;
		}
				
		// Only if he is a user of the project.
		$puQuery = "SELECT user_id FROM projusers WHERE proj_id=$category_id AND user_id=$userID";
		$resultID = mysql_query($puQuery, $linkID);
		if(!$resultID || mysql_num_rows($resultID)==0){
			//User is attempting to move map into a project he is not a member of
			notInProject($output, $puQuery);
			return $output;
		}
		
		$query = "SELECT * FROM category INNER JOIN category_map ON category.category_id = category_map.category_id INNER JOIN maps ON category_map.map_id = maps.map_id where category.category_id=$category_id and maps.is_deleted=false ORDER BY maps.title";
		$resultID = mysql_query($query, $linkID);
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		if(mysql_num_rows($resultID)==0){
			$output->addAttribute("maps_count", "0");
			//This is a better alternative than reporting an error.
			return $output;
		}else{
			$count = 0;
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){
				$row = mysql_fetch_assoc($resultID);
				$map = $output->addChild("map");
				$map->addAttribute("MapID", $row['map_id']);
				$map->addAttribute("MapTitle", $row['title']);
				$map->addAttribute("MapType", $row['map_type']);				
				$count++;
			}
			$output->addAttribute("maps_count", $count);
		}

		return $output;
	}
	
	$userID = mysql_real_escape_string($_REQUEST['uid']);
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);	
	$category_id = mysql_real_escape_string($_REQUEST['category_id']);  //TODO: Change this back to a GET when all testing is done.
	$output=listMapsInProject($userID,$pass_hash,$category_id);
	error_log($output->asXML());
	print($output->asXML());
?>