<?php
	/**
	*	Function for allowing users to confirm their login information.
	*	Returns XML containing the UID once the username and password hash are given.
	*/
	function login($username, $pass_hash)
	{
		//$linkID = mysql_connect("localhost", "root", "s3s@me123") or die ("Could not connect to database!");
		//$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
		$linkID = mysql_connect("localhost", "root", "root") or die ("Could not connect to database!");
		mysql_select_db("agora", $linkID) or die ("Could not find database");
		$userclause = mysql_real_escape_string("$username");
		$passclause = mysql_real_escape_string("$pass_hash");
		$query = "SELECT * FROM users WHERE username='$userclause' AND password='$passclause'";

		$resultID = mysql_query($query, $linkID) or die("Data not found."); 
		$row = mysql_fetch_assoc($resultID);
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<login></login>";
		$xml = new SimpleXMLElement($xmlstr);
		$xml->addAttribute("ID", $row['user_id']);
		$xml->addAttribute("firstname", $row['firstname']);
		$xml->addAttribute("lastname", $row['lastname']);
		
		return $xml;
	}
	
	$username = $_REQUEST['username'];  //TODO: Change this back to a GET when all testing is done.
	$pass_hash = $_REQUEST['pass_hash'];  //TODO: Change this back to a GET when all testing is done.
	$xml = login($username, $pass_hash);
	print($xml->asXML());
?>