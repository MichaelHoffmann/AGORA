<?php
	require 'checklogin.php';
	require 'establish_link.php';
	
	/**
	*	File for getting the list of maps a specific user has made.
	*/
	
	$userID = mysql_real_escape_string($_REQUEST['uid']);
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);
	
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0' ?>\n<list></list>";
	$xml = new SimpleXMLElement($xmlstr);
	
	$linkID= establishLink();
	mysql_select_db("agora", $linkID) or die ("Could not find database");
	if(!checkLogin($userID, $pass_hash, $linkID)){
		$fail = $xml->addChild("error");
		$fail->addAttribute("text", "Login failed!");
		return;
	}
	
	$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id WHERE maps.user_id=$userID AND maps.is_deleted=0";
	$resultID = mysql_query($query, $linkID) or die("Data not found."); 
	if(mysql_num_rows($resultID)==0){
		$fail=$xml->addChild("error");
		$fail->addAttribute("text", "There are no maps in the list! Query was: $uquery");
		return false;
	}

	for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
		$row = mysql_fetch_assoc($resultID);
		$map = $xml->addChild("map");
		$map->addAttribute("ID", $row['map_id']);
		$map->addAttribute("title", $row['title']);
		$map->addAttribute("creator", $row['username']);
	}
	print($xml->asXML());
?>