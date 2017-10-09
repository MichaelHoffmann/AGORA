<?php
	require 'configure.php';
	require 'errorcodes.php';
	require 'establish_link.php';
function findSubCategory()
{
		global  $version;
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0' ?>\n<list version='$version'></list>";
		$output = new SimpleXMLElement($xmlstr);
		
		$linkID= establishLink();
		if(!$linkID){
			badDBLink($output);
			return $output;
		}
		$query = "SELECT * FROM category JOIN parent_categories ON parent_categories.category_id = 
		category.category_id WHERE parent_categories.parent_category_name='lobby' ORDER BY category.category_name";
		$resultID = mysqli_query($linkID, $query);
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		if(mysqli_num_rows($resultID)==0){
			$output->addAttribute("category_count", "0");
			//This is a better alternative than reporting an error.
			return $output;
		}else{
			$count=0;
			for($x = 0 ; $x < mysqli_num_rows($resultID) ; $x++){
				$row = mysqli_fetch_assoc($resultID);
				$map = $output->addChild("category");
				$map->addAttribute("ID", $row['category_id']);
				$map->addAttribute("Name", $row['category_name']);
				$count++;
			}
					$output->addAttribute("category_count", $count);
						$output->addAttribute("project_count", "0");
		}
		mysqli_close($linkID);//closing the connection
		return $output;
	}


//$parentCategory= mysqli_real_escape_string($_REQUEST['parentCategory']);
$output = findSubCategory();
print($output->asXML());