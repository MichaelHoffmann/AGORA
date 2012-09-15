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

	/**
		List of variables for project creation:
		uid: ID number for the user
		pass_hash: The hash of the user's password
		projID: If any value PHP treats as false (use 0 for neatness), we are creating a new project. Otherwise, we're updating a project.
		newpass: The hash of the project's password. Only needed for creating a project with one, or updating a project's password. When left blank, it means that the project's password is set to NULL, which makes it so that the only way in is for the administrator to explicitly add users in the project/user management system (rather than e-mailing everyone the password so they can add themselves). -- not used
		title: Title of the project. Only needed for creating a project or changing the project's title.
		is_hostile: If 1, then the project is a "debate" project - maps behave the same as a normal map; the project is effectively an access-limiting tool. If the project is a "collabortive" project, then anyone can edit anything.
		proj_users: list of users who are given access to this project.
	**/
	require 'configure.php';
	require 'errorcodes.php';
	require 'establish_link.php';
	require 'utilfuncs.php';

	function getLastInsert($linkID)
	{
		$query = "SELECT LAST_INSERT_ID()";
		$resultID = mysql_query($query, $linkID);
		$row = mysql_fetch_assoc($resultID);
		return $row['LAST_INSERT_ID()'];
	}

	function runPCatMigration(){
		
			global $dbName, $version;
			header("Content-type: text/xml");
			$xmlstr = "<?xml version='1.0'?>\n<migration version='$version'></migration>";
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
		
			$query="SELECT parent_categories.category_id categoryid,parent_categories.parent_category_name as pcategoryname ,parent_categories.parent_categoryid as pcategoryid, category.category_id as cid ,category.category_name as cname FROM `parent_categories` inner join category on parent_categories.parent_category_name = category.category_name";
			$resultID = mysql_query($query, $linkID);
			if(mysql_num_rows($resultID)==0){				
				return $output;
			}else{
				$count = 0 ;
				for($x = 0 ; $x < mysql_num_rows($resultID) ; $x++){
				$row = mysql_fetch_assoc($resultID);
				$pid = $row['cid'];
				$cid = $row['categoryid'];
				$query1 = "UPDATE parent_categories SET parent_categoryid=$pid WHERE category_id=$cid";
				$upresultID = mysql_query($query1, $linkID);
				}
			}
		//This is a lame hack that shouldn't be needed, but it'll work.
		$output->addAttribute("status", "1");
		return $output;
	}

	

	$output = runPCatMigration();
	
	print($output->asXML());
?>