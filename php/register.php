<?php

	function register($username, $pass_hash, $firstname, $lastname, $email, $url)
	{
		$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
		mysql_select_db("agora", $linkID) or die ("Could not find database");
		$userclause = mysql_real_escape_string("$username");
		$passclause = mysql_real_escape_string("$pass_hash");
		$fnclause = mysql_real_escape_string("$firstname");
		$lnclause = mysql_real_escape_string("$lastname");
		$mailclause = mysql_real_escape_string("$email");
		$urlclause = mysql_real_escape_string("$url");
		$query = "SELECT * FROM users WHERE username='$userclause'";
	
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<login></login>";
		$xml = new SimpleXMLElement($xmlstr);
		
		$resultID = mysql_query($query, $linkID) or die("Data not found."); 
		$row = mysql_fetch_assoc($resultID);
		if($row['user_id']=="") // If user doesn't exist...
		{
			//insert into the database
			$iquery= "INSERT INTO users (is_deleted, firstname, lastname, username, password, email, url, user_level, created_date, last_login) VALUES (FALSE, '$fnclause', '$lnclause', '$userclause', '$passclause', '$mailclause', '$urlclause', 1, NOW(), NOW())";
			$insID = mysql_query($iquery, $linkID) or die("Insertion failed for some reason."); 
			$xml->addAttribute("created", true); // Successfully created the username.
		}else{
			$xml->addAttribute("exists", true); // Username exists. Do NOT add to the db!
		}
		return $xml;
	}
	
	$username = $_REQUEST['username'];  //TODO: Change this back to a GET when all testing is done.
	$pass_hash = $_REQUEST['pass_hash'];  //TODO: Change this back to a GET when all testing is done.
	$firstname = $_REQUEST['firstname']; //TODO: Change this back to a GET when all testing is done.
	$lastname = $_REQUEST['lastname']; //TODO: Change this back to a GET when all testing is done.
	$email = $_REQUEST['email']; //TODO: Change this back to a GET when all testing is done.
	$url = $_REQUEST['url']; //TODO: Change this back to a GET when all testing is done.
	
	$xml = register($username, $pass_hash, $firstname, $lastname, $email, $url);
	print($xml->asXML());
?>