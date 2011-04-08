<?php
	function insert($xmlin, $userID)
	{
		//Standard SQL connection stuff
		//$linkID = mysql_connect("localhost", "root", "s3s@me123") or die ("Could not connect to database!");
		$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
		mysql_select_db("agora", $linkID) or die ("Could not find database");
		
		//Dig the Map ID out of the XML
		$xml = new SimpleXMLElement($xmlin);
		$mapID = $xml['id'];
		$mapClause = mysql_real_escape_string("$mapID");
		//Check to see if the map already exists
		if($mapClause==0){
			//If not, create it!
			$iquery = "INSERT INTO MAPS (user_id, title, description, created_date, modified_date) VALUES
										($userID, 'Example', 'Described', NOW(), NOW())";
			mysql_query($iquery, $linkID);						
			$query = "SELECT LAST_INSERT_ID()";
			$resultID = mysql_query($query, $linkID);
			$row = mysql_fetch_assoc($resultID);
			$mapClause = $row['LAST_INSERT_ID()'];  // returning zero for some reason...?
		}

		$query = "SELECT * FROM maps NATURAL JOIN users WHERE map_id = $mapClause" or die ("Cannot get map!");

		$resultID = mysql_query($query, $linkID); 
		$row = mysql_fetch_assoc($resultID);
		
		//Check to see if this is the map author
		//If so, $ownMap is set to true.
		
		$author = $row['user_id'];
		print "Author: $author  Map: $mapClause <BR>";
		$ownMap = false;
		if($author == $userID){
			$ownMap=true;
		}
		
		
		//Validate nodes
		//Validate textboxes
		//Validate nodetext
		//Validate arguments
		//Validate connections
		
		//If ANY of the above failed, we bail out.
		
		//Loop across every thing,
			//decide whether to INSERT or UPDATE.
			//do that
		mysql_query("START TRANSACTION");
		
		if(true){
			mysql_query("COMMIT");
		}else{
			mysql_query("ROLLBACK");
		}
		
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