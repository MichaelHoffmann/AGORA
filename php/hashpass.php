<?php
	
	$password = $_REQUEST['password'];
	$salted_pass = $password . "AGORA";
	$hashed_pass = mysql_real_escape_string(md5($salted_pass));
	print $hashed_pass;
	
?>