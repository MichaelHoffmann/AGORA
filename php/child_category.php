<?php
	require 'configure.php';
	require 'errorcodes.php';
	require 'establish_link.php';
function findChildCategory($parentCategory)
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
		$query = "SELECT * FROM category JOIN parent_categories ON parent_categories.category_id = category.category_id WHERE parent_categories.parent_category_name = $parentCategory ORDER BY category.category_name";
		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		
		if(mysql_num_rows($resultID)==0){
			$output->addAttribute("category_count", "0");
			//This is a better alternative than reporting an error.
			return $output;
		}else{
			$count = 0;
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
				$row = mysql_fetch_assoc($resultID);			
				$map = $output->addChild("category");
				$map->addAttribute("ID", $row['category_id']);
				$map->addAttribute("Name", $row['category_name']);
				$map->addAttribute("is_project", $row['is_project']);
				$count++;
			}
			$output->addAttribute("category_count",$count);
		}
		mysql_close($linkID);//closing the connection
		return $output;
	}
		
		
$parentCategory= ($_REQUEST['parentCategory']);
$output = findChildCategory($parentCategory);
print($output->asXML());
?>