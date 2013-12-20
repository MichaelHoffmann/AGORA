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
	*	File for searching maps.
	*	HTTP Query variables:
	*	type: the type of search that can be performed.
	*			Current options are: title, text, titleandtext, user
	*	query: the text to use as the search query. Case-insensitive.
	*
	*/
	
	function search_db($query,$type,$id){
		global $dbName, $version;
		//basic XML output initialization
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<AGORA/>";
		$output = new SimpleXMLElement($xmlstr);
		//Standard SQL connection stuff
		$linkID= establishLink();
		$output->addAttribute("mainId", $id);
		if(!$linkID){
			badDBLink($output);
			return $output;
		}
		$status=mysql_select_db($dbName, $linkID);
		if(!$status){
			databaseNotFound($output);
			return $output;
		}
		
		//Query passed in gets used here.
		$resultID = mysql_query($query, $linkID);
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		
		if(mysql_num_rows($resultID)==0){
			//This is a better alternative than reporting an error.
			return $output;
		}else{
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
				$row = mysql_fetch_assoc($resultID);
				$map = $output->addChild("map");
				$map = processMap($map,$row,$query);
			}
		}
		
		return $output;
	}
	
	
	function processMap($map,$row,$query)
	{
				$map->addAttribute("ID", $row['map_id']);
				$map->addAttribute("title", $row['title']);	
				$map->addAttribute("perm", $row['perm']);	
				$map->addAttribute("p", $query);		
				return $map;
	}
	
	
	function searchUser($userId,$type,$userID){
		$query = "SELECT maps.map_id, maps.title, maps.modified_date, maps.user_id,projusers.user_id as perm FROM maps INNER JOIN users ON users.user_id = maps.user_id left JOIN category_map ON  maps.map_id = category_map.map_id  left JOin projusers on category_map.category_id=projusers.proj_id and projusers.user_id = $userID WHERE users.user_id=$userId Group By map_id ORDER BY maps.title LIMIT 0,100 ";
		return search_db($query,$type,$userId);
	}
	
	function searchProj($userId,$type,$userID){
			$query = "SELECT maps.map_id, maps.title, maps.modified_date, maps.user_id,curr.user_id as perm FROM maps INNER JOIN category_map ON category_map.map_id = maps.map_id Inner JOin projusers on category_map.category_id=projusers.proj_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id = $userID WHERE category_map.category_id=$userId Group BY map_id ORDER BY maps.title LIMIT 0,100 ";
		return search_db($query,$type,$userId);
	}
	
	function searchMain($sType, $sQuery,$userID){
		switch($sType){
			case 1:
				return searchproj($sQuery,$sType,$userID);
				break;
			
			case 2:
				return searchUser($sQuery,$sType,$userID);
				break;
			
		}	
	}
	
	
	$userID = mysql_real_escape_string($_REQUEST['uid']);  //TODO: Change this back to a GET when all testing is done.
	$sType = mysql_real_escape_string($_REQUEST['type']);  //TODO: Change this back to a GET when all testing is done.
	$sQuery = mysql_real_escape_string($_REQUEST['query']);  //TODO: Change this back to a GET when all testing is done.
	$output = searchMain($sType, $sQuery,$userID);
	print $output->asXML();
	
	
	
?>