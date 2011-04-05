<?php
	function insert($xml)
	{
		//Standard SQL connection stuff
		$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
		mysql_select_db("agora", $linkID) or die ("Could not find database");
		
		//Dig the Map ID out of the XML
		
		//Check to see if the map already exists
		//$mapClause = mysql_real_escape_string("$mapID");
		
		//If not, create it!
		
		//Validate nodes
		//Validate textboxes
		//Validate nodetext
		//Validate arguments
		//Validate connections
		
		
		//Insert/update everything
		
		//Set up the basics of the output XML.
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<map></map>";
		$output = new SimpleXMLElement($xmlstr);
		return $output;
	}
	$xml = $_REQUEST['xml']; //TODO: Change this back to a GET when all testing is done.
	$output = insert($xml); 
	print($output->asXML());
?>