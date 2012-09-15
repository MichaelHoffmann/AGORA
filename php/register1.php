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
	* Function allowing user to register a new account.
	*/
	function register($username, $pass_hash, $firstname, $lastname, $email, $url, $url2, $url3)
	{
		global $dbName, $version;
		header("Content-type: text/xml");
		$outputstr = "<?xml version='1.0' ?>\n<AGORA version='$version'/>";
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
			
		$equery = "SELECT * FROM users WHERE email='$email'";
		$eResultID = mysql_query($equery, $linkID); 
		if(!$eResultID){
			dataNotFound($output, $equery);
			return $output;
		}
		$erow = mysql_fetch_assoc($eResultID);
		if($erow['email']!=""){
			repeatEmail($output);
			return $output;
		}
		$query = "SELECT * FROM users WHERE username='$username'";
		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		$row = mysql_fetch_assoc($resultID);
		
		if($row['user_id']=="") // If user doesn't exist...
		{
			//insert into the database
			$iquery= "INSERT INTO users (is_deleted, firstname, lastname, username, password, email, url, user_level, created_date, last_login) VALUES (FALSE, '$firstname', '$lastname', '$username', '$pass_hash', '$email', '$url', 1, NOW(), NOW())";
			$insID = mysql_query($iquery, $linkID); 
			if(!$insID){
				insertFailed($output, $iquery);
				return $output;
			}
			$login=$output->addChild("login");
			$login->addAttribute("created", true); // Successfully created the username.
		}else{
			$login=$output->addChild("error");
			$login->addAttribute("text", "That username already exists!"); // Username exists. Do NOT add to the db!
		}
		return $output;
	}
	
	$username = mysql_real_escape_string($_REQUEST['username']);  //TODO: Change this back to a GET when all testing is done.
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);
	$firstname = mysql_real_escape_string($_REQUEST['firstname']);
	$lastname = mysql_real_escape_string($_REQUEST['lastname']);
	$email = mysql_real_escape_string($_REQUEST['email']);
	$url = mysql_real_escape_string($_REQUEST['url']);
	$url2 = mysql_real_escape_string($_REQUEST['url2']);
	$url3 = mysql_real_escape_string($_REQUEST['url3']);
	
	$output = register($username, $pass_hash, $firstname, $lastname, $email, $url);
	print($output->asXML());
?>
