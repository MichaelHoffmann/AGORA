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
	*	Function for getting the project Details.
	*/
	function getDuplicateMapDetails(){ 
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

		$query = "SELECT * FROM maps m INNER JOIN users u ON m.user_id = u.user_id";
		$resultID = mysql_query($query, $linkID);
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		if(mysql_num_rows($resultID)==0){
			$proj->addAttribute("user_count", "0");
			return $output;
		}else{
			$count = 0 ;
			$duplicateMaps =  array();
			$duplicateOwners = array();
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){
				$row = mysql_fetch_assoc($resultID);
				$name = $row['title'];
				$id = $row['map_id'];
				$username = $row['username'];
				$query = "SELECT * FROM maps m INNER JOIN users u ON m.user_id = u.user_id and m.title = '$name'";
				$resultIDmap = mysql_query($query, $linkID);
				if($resultIDmap && mysql_num_rows($resultIDmap)>1){
					if(!in_array($name,$duplicateMaps)){ 
					$duplicateMaps[$count] = $name;				
					$duplicateOwners[$count++] = $username;	
					}			
				}							
		}
		
		for($dupCnt=0;$dupCnt<count($duplicateMaps);$dupCnt++){
			
			error_log($duplicateMaps[$dupCnt]." -- ".$duplicateOwners[$dupCnt],0);	
		}		
		return $output;
	}
	}

	
	getDuplicateMapDetails();
	
?>



