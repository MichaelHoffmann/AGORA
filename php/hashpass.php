<?php
	
	$password = $_REQUEST['password'];  //TODO: Change this back to a GET when all testing is done.
	$salted_pass = $password . "AGORA";
	$hashed_pass = mysql_real_escape_string(md5($salted_pass));
	print $hashed_pass;
	
?>