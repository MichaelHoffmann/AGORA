<?php

require_once ('connection.php');
require_once ('./org/democracy/vo/User.php');

class Login {

    public function verify_login($username,$password){

		$npassword = sha1($password);
		//$npassword = ($password);
		$query = "select first_name, last_name from administrators where userid='$username' and password='$npassword'";
		
		$results = mysql_query($query, get_connection());
		
		$ret = null;
		while($row = mysql_fetch_object($results)){
			$tmp = new User();
		    $tmp->first_name = $row->first_name;
		    $tmp->last_name = $row->last_name;
		    $ret = $tmp;
		 
		}
		
		mysql_free_result($results);
		
		return $ret;	
	}
}
?>