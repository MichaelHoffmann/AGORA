<?php
	/**
	* Establish-link function separated out for widespread use.
	*/
	function establishLink()
	{
		//$linkID = mysql_connect("localhost", "root", "s3s@me123") or die ("Could not connect to database!");
		$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
		//$linkID = mysql_connect("localhost", "root", "root") or die ("Could not connect to database!");
		return $linkID;
	}
?>