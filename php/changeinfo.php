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
		
		$userclause = mysql_real_escape_string("$username");
		$passclause = mysql_real_escape_string("$pass_hash");
		$fnclause = mysql_real_escape_string("$firstname");
		$lnclause = mysql_real_escape_string("$lastname");
		$mailclause = mysql_real_escape_string("$email");
		$urlclause = mysql_real_escape_string("$url");
		$npclause = mysql_real_escape_string("$newpass");
		$query = "SELECT * FROM users WHERE username='$userclause' AND password='$pass_hash'";
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
			if($npclause!="")
			{
				$iquery= "UPDATE users SET firstname='$fnclause', lastname='$lnclause',	password='$npclause',
						email='$mailclause', url='$urlclause', last_login=NOW() WHERE user_id=$uid";
			}
			else
			{
				$iquery = "UPDATE users SET firstname='$fnclause', lastname='$lnclause', email='$mailclause', 
						url='$urlclause', last_login=NOW() WHERE user_id=$uid";
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

$username = $_REQUEST['username'];  //TODO: Change this back to a GET when all testing is done.
$pass_hash = $_REQUEST['pass_hash'];  //TODO: Change this back to a GET when all testing is done.
$firstname = $_REQUEST['firstname']; //TODO: Change this back to a GET when all testing is done.
$lastname = $_REQUEST['lastname']; //TODO: Change this back to a GET when all testing is done.
$email = $_REQUEST['email']; //TODO: Change this back to a GET when all testing is done.
$url = $_REQUEST['url']; //TODO: Change this back to a GET when all testing is done.
$new_pass= $_REQUEST['newpass']; //TODO: Change this back to a GET when all testing is done.
$output = changeinfo($username, $pass_hash, $firstname, $lastname, $email, $url, $new_pass);
print($output->asXML());
?>