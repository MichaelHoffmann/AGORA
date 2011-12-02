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
	*	Function for allowing a user to change his own information.
	*/
	function changeinfo($username, $pass_hash, $firstname, $lastname, $email, $url, $newpass)
	{
		global $dbName, $version;
		header("Content-type: text/xml");
		$outputstr = "<?xml version='1.0' ?>\n<agora version='$version'/>\n";
		$output = new SimpleXMLElement($outputstr);
		$login = $output->addChild("login");
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
		
		$query = "SELECT * FROM users WHERE username='$username' AND password='$pass_hash'";
		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		
		$row = mysql_fetch_assoc($resultID);
		$uid = $row['user_id'];
		if($uid=="") // If user doesn't exist...
		{
			$login->addAttribute("modified", false);
		}else{
			//update the database
			if($newpass!="")
			{
				$iquery= "UPDATE users SET firstname='$firstname', 
				lastname='$lastname', password='$newpass', email='$email', 
				url='$url', last_login=NOW() WHERE user_id=$uid";
			}
			else
			{
				$iquery = "UPDATE users SET firstname='$firstname', 
				lastname='$lastname', email='$email', url='$url', 
				last_login=NOW() WHERE user_id=$uid";
			}

			$insID = mysql_query($iquery, $linkID);
			if(!$insID){
				updateFailed($login, $iquery);
				return $output;
			}else{
				$login->addAttribute("modified", true); // Successfully created the username.
			}
		}
		return $output;
	}

	$username = mysql_real_escape_string($_REQUEST['username']);
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);
	$firstname = mysql_real_escape_string($_REQUEST['firstname']);
	$lastname = mysql_real_escape_string($_REQUEST['lastname']);
	$email = mysql_real_escape_string($_REQUEST['email']);
	$url = mysql_real_escape_string($_REQUEST['url']);
	$new_pass= mysql_real_escape_string($_REQUEST['newpass']);
	$output = changeinfo($username, $pass_hash, $firstname, $lastname, $email, $url, $new_pass);
print($output->asXML());
?>