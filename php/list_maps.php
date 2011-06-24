<?php
	require 'establish_link.php';
	/**
	*	File for getting the map list.
	*/
	$linkID= establishLink();
	mysql_select_db("agora", $linkID) or die ("Could not find database");
	$query = "SELECT * FROM maps INNER JOIN users ON users.user_id = maps.user_id  AND maps.is_deleted=0";
	$resultID = mysql_query($query, $linkID) or die("Data not found."); 
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0' ?>\n<list></list>";
	$xml = new SimpleXMLElement($xmlstr);
	if(mysql_num_rows($resultID)==0){
		$fail=$xml->addChild("error");
		$fail->addAttribute("text", "There are no maps in the list! Query was: $uquery");
		return false;
	}

	for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
		$row = mysql_fetch_assoc($resultID);
		if($row['is_deleted']){
			$fail = $xml->addChild("error");
			$fail->addAttribute("Map has been deleted.");
		}
		$map = $xml->addChild("map");
		$map->addAttribute("ID", $row['map_id']);
		$map->addAttribute("title", $row['title']);
		$map->addAttribute("creator", $row['username']);
	}
	print($xml->asXML());
?>