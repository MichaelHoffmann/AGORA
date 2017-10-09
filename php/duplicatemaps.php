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
	function getDuplicateMapDetails($output){
		global $version;
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
		$output = new SimpleXMLElement($xmlstr);
		$linkID= establishLink();
		if(!$linkID){
			badDBLink($output);
			return $output;
		}

		$query    = "SELECT * FROM maps m INNER JOIN users u ON m.user_id = u.user_id and m.is_deleted=0";
		$resultID = mysqli_query( $linkID, $query );
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		if ( mysqli_num_rows( $resultID ) == 0 ) {
			$proj->addAttribute("user_count", "0");
			return $output;
		}else{
			$count = 0 ;
			$duplicateMaps =  array();
			$duplicateOwners = array();
			for ( $x = 0; $x < mysqli_num_rows( $resultID ); $x++ ) {
				$row         = mysqli_fetch_assoc( $resultID );
				$name        = $row['title'];
				$id          = $row['map_id'];
				$username    = $row['username'];
				$query       = "SELECT * FROM maps m INNER JOIN users u ON m.user_id = u.user_id and m.title = '$name' and m.is_deleted=0";
				$resultIDmap = mysqli_query( $linkID, $query );
				if ( $resultIDmap && mysqli_num_rows( $resultIDmap ) > 1 ) {
					if(!in_array($name,$duplicateMaps)){ 
					$duplicateMaps[$count] = $name;		
					$duplicateOwners[$count++] = $id;				
					//$duplicateOwners[$count++] = $username;	
					}			
				}							
		}
		$duplicatemapsStr = "";
		for($dupCnt=0;$dupCnt<count($duplicateMaps);$dupCnt++){
			$duplicatemapsStr = $duplicateMaps[$dupCnt]." -- ".$duplicateOwners[$dupCnt];	
			$details = $output->addChild("details");
			$details->addAttribute("maps",$duplicatemapsStr);			
			checkIfNameIsUnique($duplicateMaps[$dupCnt],$duplicateOwners[$dupCnt],$linkID);
		}				
	}
			return $output;
	}
	
		function checkIfNameIsUnique($projName,$id,$linkID){
				$query   = "SELECT * FROM maps m INNER JOIN users u ON m.user_id = u.user_id and m.title = '$projName' and m.map_id != $id and m.is_deleted=0";
			$resultIDmap = mysqli_query( $linkID, $query );
				error_log("chagning".$projName,0);
			if ( $resultIDmap && mysqli_num_rows( $resultIDmap ) > 0 ) {
				for ( $x = 0; $x < mysqli_num_rows( $resultIDmap ); $x++ ) {
					$row = mysqli_fetch_assoc( $resultIDmap );
								error_log("chagning",0);
								$name = $row['title'];
								$id1 = $row['map_id'];
								$username = $row['username'];
								$newName = $name.($x+1)."-".$username;
								error_log("chagning".$name." ".$newName,0);
								$query1 = "UPDATE maps set title='$newName' where map_id = $id1";
					$updateMapQuery     = mysqli_query( $linkID, $query1 );
							}
			     }
	}	

header("Content-type: text/xml");
$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
$output = new SimpleXMLElement($xmlstr);	
$output = getDuplicateMapDetails($output);
error_log($output->asXML(),0);
print $output->asXML();




