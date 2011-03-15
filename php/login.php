<?php

	function login($username, $pass_hash)
	{
		$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
		mysql_select_db("agora", $linkID) or die ("Could not find database");
		$whereclause = mysql_real_escape_string("WHERE username = $username AND password = $pass_hash");
		$query = "SELECT * FROM users " . $whereclause;

		$resultID = mysql_query($query, $linkID) or die("Data not found."); 
		$row = mysql_fetch_assoc($resultID);
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<login>";
		$xml = new SimpleXMLElement($xmlstr);
		$xml->addAttribute("ID", $row['user_id']);
		return $xml;
	}
	
	$username = $_REQUEST['username'];  //TODO: Change this back to a GET when all testing is done.
	$pass_hash = $_REQUEST['pass_hash'];  //TODO: Change this back to a GET when all testing is done.
	$xml = login($user_id, $pass_hash);
	print($xml->asXML());
?>