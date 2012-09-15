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
	/**
	*	Function for allowing users to confirm their login information.
	*	Returns XML containing the UID once the username and password hash are given.
	*/
	function create_map_in_current_category($username ,$pass_hash ,$currCat,$map_id)
	{
		global $dbName, $version;
		header("Content-type: text/xml");
		$outputstr = "<?xml version='1.0' ?>\n<mapToCategory version='$version'></mapToCategory>";
		$output = new SimpleXMLElement($outputstr);
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
		$query = "INSERT INTO category_map (map_id, category_id) 
				VALUES ('$map_id',
					(
					 SELECT category_id 
					 FROM category 
					 WHERE category_name = '$currCat'
					))";
		$resultID = mysql_query($query, $linkID);
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}

		return $output;
	}
	$username = mysql_real_escape_string($_REQUEST['username']);
	$pass_hash = mysql_real_escape_string($_REQUEST['pass_hash']);
	$currCat= mysql_real_escape_string($_REQUEST['currCat']);
	$map_id= mysql_real_escape_string($_REQUEST['mapID']);
	$output = create_map_in_current_category($username ,$pass_hash ,$currCat,$map_id);
	print($output->asXML());
?>