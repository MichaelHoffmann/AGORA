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
	*	Function for allowing users to confirm their login information.
	*	Returns XML containing the UID once the username and password hash are given.
	*/
	function getRegistrationInfo($uid)
	{
		global $dbName, $version;
		header("Content-type: text/xml");
		$outputstr = "<?xml version='1.0' ?><regInfo version='$version'></regInfo>";
		$output = new SimpleXMLElement($outputstr);
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
		$query = "SELECT username,firstname,lastname,email,url FROM users WHERE user_id=$uid";
		
		$result = mysql_query($query, $linkID); 
		if(!$result){
			dataNotFound($output, $query);
			return $output;
		}

		$row = mysql_fetch_assoc($result);
		if($row['username']){
			$user = $output->addChild("user");
			$output->addAttribute("username", $row['username']);
			$output->addAttribute("firstname", $row['firstname']);
			$output->addAttribute("lastname", $row['lastname']);
			$output->addAttribute("email", $row['email']);
			$output->addAttribute("url", $row['url']);

		}else{

			dataNotFound($output);
			return $output;
		}
		
		mysql_close($linkID);
		return $output;
	}

	$uid = mysql_real_escape_string($_REQUEST['uid']);
	$output = getRegistrationInfo($uid);
	print($output->asXML());
?>