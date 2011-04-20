<?php
	function checkLogin($userID, $pass_hash, $linkID)
	{
		$userclause = mysql_real_escape_string("$userID");
		$passclause = mysql_real_escape_string("$pass_hash");
		$query = "SELECT * FROM users WHERE user_ID='$userID' AND password='$passclause'";
		$resultID = mysql_query($query, $linkID) or die("Data not found."); 
		//$row = mysql_fetch_assoc($resultID);
		if(mysql_num_rows($resultID)>0){
			return true;
		}else{
			return false;
		}
	}
	function remove($xmlin, $userID, $pass_hash)
	{
	//Standard SQL connection stuff
		//$linkID = mysql_connect("localhost", "root", "s3s@me123") or die ("Could not connect to database!");
		$linkID = mysql_connect("localhost", "root", "") or die ("Could not connect to database!");
		mysql_select_db("agora", $linkID) or die ("Could not find database");

		if(!checkLogin($userID, $pass_hash, $linkID)){
			print "Incorrect login!";
			return;
		}
	}

	$xmlparam = $_REQUEST['xml']; //TODO: Change this back to a GET when all testing is done.
	$userID = $_REQUEST['uid'];
	$pass_hash = $_REQUEST['pass_hash'];
	$output = remove($xmlparam, $userID, $pass_hash); 
	//print($output->asXML()); //TODO: turn this back on
?>