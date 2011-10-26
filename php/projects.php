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
		proj_pass: The hash of the project's password. Only needed for creating a project with one, or updating a project's password. Can be left blank, in which case the project's password will be NULL and people cannot use it to join a project.
		title: Title of the project. Only needed for creating a project or changing the project's title.
		is_hostile: If 1, then the project is a "debate" project - maps behave the same as a normal map; the project is effectively an access-limiting tool. If the project is a "collabortive" project, then anyone can edit anything.
		
	**/
	require 'configure.php';
	require 'errorcodes.php';
	require 'establish_link.php';
	require 'utilfuncs.php';
	
	
	function createProject($userID, $pass_hash, $proj_pass, $title, $is_hostile){
		global $dbName, $version;
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
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
	}
	
	function editProject($userID, $pass_hash, $projID, $proj_pass, $title, $is_hostile){
		global $dbName, $version;
		header("Content-type: text/xml");
		$xmlstr = "<?xml version='1.0'?>\n<project version='$version'></project>";
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
	}
	
	$userID = $_REQUEST['uid'];
	$pass_hash = $_REQUEST['pass_hash'];
	$projID = $_REQUEST['projID'];
	$proj_pass = $_REQUEST['proj_pass']
	$title = $_REQUEST['title'];
	$is_hostile = $_REQUEST['is_hostile'];
	if(!$projID){
		$output = createProject($userID, $pass_hash, $proj_pass, $title, $is_hostile);
	}else{
		$output = editProject($userID, $pass_hash, $projID, $proj_pass, $title, $is_hostile);
	}
	print($output->asXML());
?>