<?php
	$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
	mysql_select_db("agora", $linkID) or die ("Could not find database");
	$mapID = 1; //TODO: read this from input somehow.
	$whereclause = mysql_real_escape_string($mapID);
	$query = "SELECT * FROM maps " . $whereclause; //WHERE mapID == something passed in....
	
?>