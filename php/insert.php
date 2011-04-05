<?php
	function insert($xmlin, $userID)
	{
		//Standard SQL connection stuff
		$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
		mysql_select_db("agora", $linkID) or die ("Could not find database");
		
		//Dig the Map ID out of the XML
		$xml = new SimpleXMLElement($xmlin);
		$mapID = $xml['id'];
		
		//Check to see if the map already exists
		$mapClause = mysql_real_escape_string("$mapID");
		$query = "SELECT * FROM maps NATURAL JOIN users WHERE map_id = $mapClause";
		$resultID = mysql_query($query, $linkID) or die("Data not found."); 
		$row = mysql_fetch_assoc($resultID);
		
		//Check to see if this is the map author
		//If so, $ownMap is set to true.
		$author = $row['user_id'];
		$ownMap = false;
		if($author == $userID){
			$ownMap=true;
		}
		
		//If not, create it!
		
		//Validate nodes
		//Validate textboxes
		//Validate nodetext
		//Validate arguments
		//Validate connections
		
		//If ANY of the above failed, we bail out.
		
		//Loop across every thing,
			//decide whether to INSERT or UPDATE.
			//do that
	
		
		//Set up the basics of the output XML.
		/*
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<map></map>";
		$output = new SimpleXMLElement($xmlstr);
		return $output;
		*/
	}
	$xml = $_REQUEST['xml']; //TODO: Change this back to a GET when all testing is done.
	$userID = $_REQUEST['uid'];
	$output = insert($xml, $userID); 
	//print($output->asXML()); //TODO: turn this back on
?>