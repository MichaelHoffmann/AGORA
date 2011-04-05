<?php
	function insert($map_id)
	{
		//Standard SQL connection stuff
		$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
		mysql_select_db("agora", $linkID) or die ("Could not find database");
		$whereclause = mysql_real_escape_string("$mapID");
		
		//Set up the basics of the XML.
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<map></map>";
		$xml = new SimpleXMLElement($xmlstr);
	}
	$map_id = $_REQUEST['map_id'];  //TODO: Change this back to a GET when all testing is done.
	$xml = $_REQUEST['xml']; //TODO: Change this back to a GET when all testing is done.
	$output = insert($map_id); 
	print($output->asXML());
?>