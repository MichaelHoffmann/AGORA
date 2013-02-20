<?php


/**
AGORA - an interactive and web-based argument mapping tool that stimulates reasoning,
		reflection, critique, deliberation, and creativity in individual argument construction
		and in collaborative or adversarial settings.
Copyright (C) 2011 Georgia Institute of Technology

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/
require 'configure.php';
require 'errorcodes.php';
require 'establish_link.php';
require 'utilfuncs.php';
/**
*	Function for getting the project list.
*/
function list_projects($userID, $pass_hash) {
	global $dbName, $version;
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0' ?>\n<list version='$version'></list>";
	$output = new SimpleXMLElement($xmlstr);

	$linkID = establishLink();
	if (!$linkID) {
		badDBLink($output);
		return $output;
	}
	$status = mysql_select_db($dbName, $linkID);
	if (!$status) {
		databaseNotFound($output);
		return $output;
	}

	if (!checkLogin($userID, $pass_hash, $linkID)) {
		incorrectLogin($output);
		return $output;
	}
	$projectListing = $output->addChild("ProjectList");
	$mapsListing = $output->addChild("MapsList");

		// list of maps i have added modified ! 
		$query = "SELECT maps.map_id,maps.title,maps.user_id,count(node_id),username FROM maps INNER JOIN nodes ON maps.map_id = nodes.map_id INNER JOIN users ON maps.user_id = users.user_id where maps.user_id!=$userID and nodes.user_id=$userID and maps.is_deleted=0 and nodes.is_deleted=0 group by maps.map_id ORDER BY maps.title";
		$resultID = mysql_query($query, $linkID);
		if (!$resultID) {
			dataNotFound($output, $query);
			return $output;
		}
		if (mysql_num_rows($resultID) == 0) {
			$output->addAttribute("map_count", "0");
			//This is a better alternative than reporting an error.
			//return $output;
		} else {
			$count = 0;
			$projects = Array ();
			for ($x = 0; $x < mysql_num_rows($resultID); $x++) {
				$row = mysql_fetch_assoc($resultID);
				$map = $mapsListing->addChild("map");
				$map->addAttribute("ID", $row['map_id']);
				$map->addAttribute("title", $row['title']);
				$map->addAttribute("creator", $row['username']);
				$map->addAttribute("creatorid", $row['user_id']);
				$count++;
			}
			$output->addAttribute("map_count", $count);
		}
	$query = "SELECT * FROM projects INNER JOIN users ON users.user_id = projects.user_id INNER JOIN projusers ON projects.proj_id = projusers.proj_id inner join parent_categories par on projects.proj_id = par.category_id inner join category c on par.parent_categoryid = c.category_id where projusers.user_id=$userID and projusers.user_level=1 ORDER BY projects.title";
	$resultID = mysql_query($query, $linkID);
	if (!$resultID) {
		dataNotFound($output, $query);
		return $output;
	}
	if (mysql_num_rows($resultID) == 0) {
		$output->addAttribute("proj_count", "0");
		//This is a better alternative than reporting an error.
		return $output;
	} else {
		$count = 0;
		$projects = Array ();
		$projectPath = $output->addChild("Path");
		for ($x = 0; $x < mysql_num_rows($resultID); $x++) {
			$row = mysql_fetch_assoc($resultID);
			$proj = $projectListing->addChild("proj");
			$proj->addAttribute("ID", $row['proj_id']);
			$projects[$x] = $row['proj_id'];
			$proj->addAttribute("title", $row['title']);
			$proj->addAttribute("creator", $row['username']);
			$proj->addAttribute("role", $row['user_level']);
			$proj->addAttribute("type", $row['is_hostile']);
			$proj->addAttribute("parent_name", $row['category_name']);
			$proj->addAttribute("parent_id", $row['parent_categoryid']);
			$proj->addAttribute("is_myprivate", "0");
			$count++;
		}
		$output->addAttribute("proj_count", $count);
	
	/*


			// Form the hierarchy for the projects ...			
			$query = "SELECT c.category_id catid,c.category_name catname,child.category_id pcCatId,child.parent_categoryid,c.is_project FROM category as c left join `parent_categories` as child on c.category_id = child.category_id";
			$resultID = mysql_query($query, $linkID);
			$catMap = Array ();
			$catNameMap = Array ();
			if ($resultID && mysql_num_rows($resultID) > 0) {
				for ($x = 0; $x < mysql_num_rows($resultID); $x++) {
					$row = mysql_fetch_assoc($resultID);
					$detailsMap = Array ();
					$catIdVal = $row['catid'];
					// details ...
					$catName = $row['catname'];
					$catParent = $row['parent_categoryid'];
					$catType = $row['is_project'];
					$detailsMap['name'] = $catName;
					$detailsMap['isproject'] = $catType;
					if ($catParent != NULL) {
						$catMap[$catIdVal] = $catParent;
					}
					$catNameMap[$catIdVal] = $detailsMap;
				}
			}

			for ($x = 0; $x < count($projects); $x++) {
				$pid = $projects[$x];
				header("Content-type: text/xml");
				$vistedNodes = Array ();
				$path = $projectPath->addChild("path");
				$hierarchy = fetchTreeXmlForProj($pid, $catMap, $catNameMap, $path, $vistedNodes);
			}
*/
		}
		return $output;
	}

	$userID = mysql_real_escape_string($_REQUEST['uid']);
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);
	$output = list_projects($userID, $pass_hash);
	error_log($output->asXML(), 0);
	print ($output->asXML());
?>