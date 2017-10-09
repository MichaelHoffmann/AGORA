<?php
	require 'configure.php';
	require 'errorcodes.php';
	require 'establish_link.php';
function getMap($projID)
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

		$query = "SELECT * FROM maps WHERE proj_id=$projID";
		$resultID = mysqli_query( $linkID, $query );
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		if(mysqli_num_rows($resultID)==0){
			$output->addAttribute("project_count", "0");
			//This is a better alternative than reporting an error.
			return $output;
		}else{
			for($x = 0 ; $x < mysqli_num_rows($resultID) ; $x++){
				$output->addAttribute("project_count", "1");

				$row = mysqli_fetch_assoc($resultID);
				$map = $output->addChild("proj");
				$map->addAttribute("ID", $row['map_id']);
				$map->addAttribute("Name", $row['title']);
			}
		}
		mysqli_close($linkID);//closing the connection
		return $output;
	}
		
$projID= ($_REQUEST['projID']);
$output = getMap($projID);
print($output->asXML());
