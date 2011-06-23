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
	require 'establish_link.php';
	/**
	*	Function for emailing users who forget their password.
	*/
	function forgot_pass($username)
	{
		$linkID= establishLink();
		mysql_select_db("agora", $linkID) or die ("Could not find database");
		$userclause = mysql_real_escape_string("$username");
		$query = "SELECT * FROM users WHERE username='$userclause'";
		$resultID = mysql_query($query, $linkID) or die("Data not found."); 
		$row = mysql_fetch_assoc($resultID);
		$uid = $row['user_id'];
		$email = $row['email'];
		print("User ID found: " . $uid);
		
		// Generate the new password
		// List of possible characters chosen to minimize confusion
		// No O/0 or 1/l/I nonsense here!
		// Unfortunately I'm not sure this is going to work well for the Russians...
		// They can paste it into the textbox though.
		$possible = "2346789bcdfghjkmnpqrtvwxyzBCDFGHJKLMNPQRTVWXYZ";
		// we refer to the length of $possible a few times, so let's grab it now
		$maxlength = strlen($possible);
		$password = "";
		for($i=0; $i<8; $i++)
		{
			$password .= substr($possible, mt_rand(0, $maxlength-1), 1);
		}
		//We need to change password and email user afterwards.
		//If changing password fails, we need to reset to the old password in case user finally remembers.
		
		print "<BR>$password";
		//First thing first: create the Hash of the password - that's what we store.
		//Salt the password:
		$salted_pass = $password . "AGORA";
		$hashed_pass = mysql_real_escape_string(md5($salted_pass));
		
		$uquery = "UPDATE users SET password='$hashed_pass' WHERE user_id = $uid";
		print "<BR>$uquery<BR>";
		
		$resultID = mysql_query($uquery, $linkID) or die("Could not update database");
		$message = wordwrap("Your new password for the AGORA system is:\n $password", 70);
		$headers = 'From: webmaster@agora.gatech.edu' . "\r\n" . 
			'Reply-To: webmaster@agora.gatech.edu' . "\r\n" .
			'X-Mailer: PHP/' . phpversion();
		mail($email, 'AGORA forgotten password update', $message, $headers);
		
		print "<BR>E-mail sent!</BR>";
		
		
	}
	
	$username = $_REQUEST['username'];  //TODO: Change this back to a GET when all testing is done.
	forgot_pass($username);

?>