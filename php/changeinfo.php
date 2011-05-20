<?php
	require 'establish_link.php';
	/**
	*	Function for allowing a user to change his own information.
	*/
	function changeinfo($username, $pass_hash, $firstname, $lastname, $email, $url, $newpass)
	{
		$linkID= establishLink();
		mysql_select_db("agora", $linkID) or die ("Could not find database");
		$userclause = mysql_real_escape_string("$username");
		$passclause = mysql_real_escape_string("$pass_hash");
		$fnclause = mysql_real_escape_string("$firstname");
		$lnclause = mysql_real_escape_string("$lastname");
		$mailclause = mysql_real_escape_string("$email");
		$urlclause = mysql_real_escape_string("$url");
		$npclause = mysql_real_escape_string("$newpass");
		$query = "SELECT * FROM users WHERE username='$userclause' AND password='$pass_hash'";
		
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<login></login>";
		$xml = new SimpleXMLElement($xmlstr);
		
		$resultID = mysql_query($query, $linkID) or die("Data not found."); 
		$row = mysql_fetch_assoc($resultID);
		$uid = $row['user_id'];
		if($uid=="") // If user doesn't exist...
		{
			$xml->addAttribute("modified", false);
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

			$insID = mysql_query($iquery, $linkID) or die("Update failed for some reason."); 
			$xml->addAttribute("modified", true); // Successfully created the username.
		}
		return $xml;
	}
	
	$username = $_REQUEST['username'];  //TODO: Change this back to a GET when all testing is done.
	$pass_hash = $_REQUEST['pass_hash'];  //TODO: Change this back to a GET when all testing is done.
	$firstname = $_REQUEST['firstname']; //TODO: Change this back to a GET when all testing is done.
	$lastname = $_REQUEST['lastname']; //TODO: Change this back to a GET when all testing is done.
	$email = $_REQUEST['email']; //TODO: Change this back to a GET when all testing is done.
	$url = $_REQUEST['url']; //TODO: Change this back to a GET when all testing is done.
	$new_pass= $_REQUEST['newpass']; //TODO: Change this back to a GET when all testing is done.
	$xml = changeinfo($username, $pass_hash, $firstname, $lastname, $email, $url, $new_pass);
	print($xml->asXML());
?>