<?php

$password    = $_REQUEST['password'];
$salted_pass = $password . "AGORA";
$hashed_pass = md5( $salted_pass );
print $hashed_pass;

