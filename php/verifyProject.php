<?php
	require 'configure.php';
	require 'errorcodes.php';
	require 'establish_link.php';
	require 'utilfuncs.php';

	function verifyProj($projID,$pass_hash,$userID)
	{
		global $version;
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<list version='$version'></list>";
		$output = new SimpleXMLElement($xmlstr);
		$linkID= establishLink();
		if(!$linkID){
			badDBLink($output);
			return $output;
		}

		if(!checkLogin($userID, $pass_hash, $linkID)){
			incorrectLogin($output);
			return $output;
		}

		$projID = mysqli_real_escape_string( $linkID, $projID );
		$userID = mysqli_real_escape_string( $linkID, $userID );

		$checkIfProj   = "SELECT * FROM category WHERE category_id=$projID AND is_project=0";
		$result_IsProj = mysqli_query( $linkID, $checkIfProj );
		if ( $result_IsProj && mysqli_num_rows( $result_IsProj ) > 0 ) {
			$output->addAttribute("verified", true);
			return $output;
		}
		$query = "SELECT * FROM projusers WHERE proj_id=$projID AND user_id=$userID";
		$query2 = "SELECT * FROM projusers WHERE proj_id=$projID";

		$result  = mysqli_query( $linkID, $query );
		$result2 = mysqli_query( $linkID, $query2 );
		if ( mysqli_num_rows( $result ) == 0 ) {
			$output->addAttribute("verified", false);
			for ( $x = 0; $x < mysqli_num_rows( $result2 ); $x++ ) {
				$row = mysqli_fetch_assoc( $result2 );
				if($row["user_level"] == 9){
					$admin_id            = $row["user_id"];
					$queryUsernameAndURL = "SELECT firstname, lastname,username, url FROM users WHERE user_id = '$admin_id'";
					$resultUNURL         = mysqli_query( $linkID, $queryUsernameAndURL );
					$row2                = mysqli_fetch_assoc( $resultUNURL );
					$output->addAttribute("project_admin_firstname", $row2["firstname"]);
					$output->addAttribute("project_admin_lastname", $row2["lastname"]);
					$output->addAttribute("project_admin_username", $row2["username"]);
					$output->addAttribute("admin_url", $row2["url"]);
					return $output;
				}
			}
		} else {
			$output->addAttribute("verified", true);
			
		}
		return $output;
	}
		
$projID    = $_REQUEST['projID'];
$pass_hash = $_REQUEST['pass_hash'];
$userID    = $_REQUEST['user_id'];
$output    = verifyProj($projID,$pass_hash,$userID);
print($output->asXML());
