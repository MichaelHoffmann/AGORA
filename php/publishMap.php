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
	/**
	*	Function for getting the map list.
	*/
	function moveMapToProject($map_id,$category_id, $uid, $passhash){
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

		$checkLogin = "SELECT user_id FROM users WHERE user_id='$uid' AND password='$passhash'";
		if(!mysql_query($checkLogin, $linkID)){
			incorrectLogin($output);
			return $output;
		}

		$checkIfProj = "SELECT * FROM category WHERE category_id=$category_id
		        AND is_project=1";
		$result_IsProj = mysql_query($checkIfProj, $linkID);
					$projart = $output->addChild("Proj");
		if($result_IsProj && mysql_num_rows($result_IsProj) > 0){
			$projart = $projart->addAttribute("isproject","1");
			$verifyProjMember = "SELECT proj_id FROM projusers 
                    		WHERE proj_id=$category_id AND user_id = $uid";
			$result_VerifyMem = mysql_query($verifyProjMember, $linkID);
			if(!mysql_num_rows($result_VerifyMem) > 0){
				$output->addAttribute("Verified", "No");
				notInProject($output,$linkID);
				return $output;
			}
		}else{
			$projart = $projart->addAttribute("isproject","0");
		}
		$query = "UPDATE category_map SET category_id=$category_id WHERE map_id='$map_id'";
		$output->addAttribute("Category", $category_id);
		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		return $output;
	}
	$category_id = mysql_real_escape_string($_REQUEST['current_category']);  //TODO: Change this back to a GET when all testing is done.
	$map_id = mysql_real_escape_string($_REQUEST['map_id']);
	$uid = mysql_real_escape_string($_REQUEST['uid']);
	$passhash = mysql_real_escape_string($_REQUEST['passhash']);

	$output=moveMapToProject($map_id,$category_id, $uid, $passhash);
	print($output->asXML());
?>