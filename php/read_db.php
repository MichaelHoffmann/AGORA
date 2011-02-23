<?php

	$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
	mysql_select_db("agora", $linkID) or die ("Could not find database");
	$query = "SELECT * FROM nodes NATURAL JOIN nodetext NATURAL JOIN textboxes NATURAL JOIN node_types";
	$resultID = mysql_query($query, $linkID) or die("Data not found."); 
	echo("<FONT face=\"Gill Sans Mono\">");
	echo("&nbsp;&nbsp;ID |&nbsp;&nbsp;&nbsp;Type&nbsp;&nbsp;&nbsp;| Text<BR>");
	for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
		$row = mysql_fetch_assoc($resultID);
		echo("&nbsp;&nbsp;&nbsp;" . $row['node_id'] . " | " . $row['type'] . " | " . $row['text']);
		echo("<BR>-------------------------</BR>");
	}
	echo("</FONT>");
?>