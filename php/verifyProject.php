<?php
	require 'configure.php';
	require 'errorcodes.php';
	require 'establish_link.php';
	require 'utilfuncs.php';

	function verifyProj($projID,$pass_hash,$userID)
	{
		global $dbName, $version;
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<list version='$version'></list>";
		$output = new SimpleXMLElement($xmlstr);
		$linkID= establishLink();
		if(!$linkID){
			badDBLink($output);
			return $output;
		}
		$status=mysql_select_db($dbName, $linkID);
		if(!$status){
			 databaseNotFound($output);
			 return $output;
		}

		if(!checkLogin($userID, $pass_hash, $linkID)){
			incorrectLogin($output);
			return $output;
		}

		$query = "SELECT * FROM projusers WHERE proj_id=$projID AND user_id=$userID";
		$query2 = "SELECT * FROM projusers WHERE proj_id=$projID";
		
		$result = mysql_query($query, $linkID);
		$result2 = mysql_query($query2, $linkID);
		if(mysql_num_rows($result) == 0){
			$output->addAttribute("verified", false);
			for($x = 0 ; $x < mysql_num_rows($result2) ; $x++){ 
				$row = mysql_fetch_assoc($result2);	
				if($row["user_level"] == 9){
					$admin_id = $row["user_id"];
					$queryUsernameAndURL = "SELECT firstname, lastname, url FROM users WHERE user_id = '$admin_id'";
					$resultUNURL = mysql_query($queryUsernameAndURL, $linkID);
					$row2 = mysql_fetch_assoc($resultUNURL);
					$output->addAttribute("project_admin_firstname", $row2["firstname"]);
					$output->addAttribute("project_admin_lastname", $row2["lastname"]);
					$output->addAttribute("admin_url", $row2["url"]);
					return $output;
				}
			}
		} else {
			$output->addAttribute("verified", true);
			
		}
		return $output;
	}
		
$projID= $_REQUEST['projID'];
$pass_hash=mysql_real_escape_string($_REQUEST['pass_hash']);
$userID = $_REQUEST['user_id'];
$output = verifyProj($projID,$pass_hash,$userID);
print($output->asXML());
?>