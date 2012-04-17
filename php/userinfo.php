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
	*	Function for getting a particular user's information
	*/
	function user_info($username){
		global $dbName, $version;
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<user version='$version'></user>";
		$output = new SimpleXMLElement($xmlstr);
		
		$linkID= establishLink();
		if(!$linkID){
			badDBLink($output);
			return $output;
		}
		
		$status = mysql_select_db($dbName, $linkID);
		if(!$status){
			databaseNotFound($output);
			return $output;
		}
		
		$query = "SELECT * FROM users WHERE username='$username'";
		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		
		if(mysql_num_rows($resultID)==0){
			$fail=$output->addChild("error");
			$fail->addAttribute("text", "There is no user with this name! Query was: $query");
			$fail->addAttribute("code", 305);
			//Calling this an error is perhaps a bit strong, but an empty list seems uninformative ...
			/*
				This error code matches nonexistent() from errorcodes.php, but a custom message seemed better
			*/
			return $output;
		}else{
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
				$row = mysql_fetch_assoc($resultID);
				if($row['is_deleted']){
					$fail = $output->addChild("error");
					$fail->addAttribute("text", "User's account has been deleted. For user protection, we do not give out information from deleted accounts.");
					$fail->addAttribute("code", 304);
					/*
						Error code matches accessDeleted() from errorcodes.php, but wanted a custom error message
					*/
				}
				$output->addAttribute("username", $row['username']);
				$output->addAttribute("firstname", $row['firstname']);
				$output->addAttribute("lastname", $row['lastname']);
				//$output->addAttribute("email", $row['email']);
				$output->addAttribute("ID", $row['user_id']);
			}
		}
		return $output;
	}
	$username = mysql_real_escape_string($_REQUEST['username']);  //TODO: Change this back to a GET when all testing is done.
	$output=user_info($username);
	print($output->asXML());
?>