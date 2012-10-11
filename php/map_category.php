<?php
	require 'configure.php';
	require 'errorcodes.php';
	require 'establish_link.php';
	require 'utilfuncs.php';
	
function findMapCategory($parentCategory)
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
		$query = "(SELECT * FROM maps JOIN category_map ON maps.map_id = category_map.map_id JOIN users ON users.user_id = maps.user_id 
				JOIN category ON category_map.category_id = category.category_id WHERE maps.is_deleted = 0 
				AND category_map.category_id = ( SELECT category_id FROM category WHERE category.category_name = $parentCategory ))";
		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		
		
		if(mysql_num_rows($resultID)==0){
			$output->addAttribute("map_count", "0");
			//This is a better alternative than reporting an error.
			return $output;
		}else{
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
				$row = mysql_fetch_assoc($resultID);			
				$map = $output->addChild("map");
				$map->addAttribute("ID", $row['map_id']);
				$map->addAttribute("Name", $row['title']);
				$map->addAttribute("creator", $row['username']);
				$map->addAttribute("last_modified", $row['modified_date']);
				$map->addAttribute("proj_id", $row['proj_id']);
				$map->addAttribute("firstname", $row['firstname']);
				$map->addAttribute("lastname", $row['lastname']);
				$map->addAttribute("url", $row['url']);
			}
		}
			
		$category_id = getCategoryIDfromName($parentCategory,$linkID);
		$query = "SELECT * FROM category child inner join `parent_categories` parent on child.category_id=parent.category_id inner join projects p on child.category_id=proj_id inner join users u on p.user_id=u.user_id  where parent_categoryid = $category_id and is_project=1";
		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}	
		
		if(mysql_num_rows($resultID)==0){
			$output->addAttribute("project_count", "0");
			return $output;
		}else{
			for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){ 
				$row = mysql_fetch_assoc($resultID);			
				$map = $output->addChild("project");
				$map->addAttribute("category_id", $row['category_id']);
				$map->addAttribute("category_name", $row['category_name']);
				$map->addAttribute("user_id", $row['user_id']);
				$map->addAttribute("type", $row['is_hostile']);
				$map->addAttribute("firstname", $row['firstname']);
				$map->addAttribute("lastname", $row['lastname']);
				$map->addAttribute("url", $row['url']);
			}				
		}
		mysql_close($linkID);//closing the connection
		return $output;
	}
		
		
$parentCategory= ($_REQUEST['parentCategory']);
$output = findMapCategory($parentCategory);
error_log($output->asXML(),0);
print($output->asXML());
?>