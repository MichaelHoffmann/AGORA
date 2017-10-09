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
	function login($username, $pass_hash)
	{
		global $version;
		header("Content-type: text/xml");
		$outputstr = "<?xml version='1.0' ?>\n<login version='$version'></login>";
		$output = new SimpleXMLElement($outputstr);
		$linkID= establishLink();
		if(!$linkID){
			badDBLink($output);
			return $output;
		}

		$username   = mysqli_real_escape_string( $linkID, $username );
		$pass_hash  = mysqli_real_escape_string( $linkID, $pass_hash);
		$query = "SELECT * FROM users WHERE username='$username' AND password='$pass_hash'";

		$resultID = mysqli_query( $linkID, $query );
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		$row = mysqli_fetch_assoc( $resultID );
		if($row['user_id']){
			$output->addAttribute("ID", $row['user_id']);
			$output->addAttribute("firstname", $row['firstname']);
			$output->addAttribute("lastname", $row['lastname']);
			$output->addAttribute("url", $row['url']);
			$output->addAttribute("email", $row['email']);
			$output->addAttribute("userName", $row['username']);
			$secQCode = $row['securityQNum'];
			$secQCodeSet = false;
			$secQCodeAns="";
			 if($secQCode!=null){
			 	$secQCodeSet=true;
			 	$secQCodeAns = $row['securityQAnswer'];
			 }
			$output->addAttribute("secQCode", $secQCodeSet);
			$output->addAttribute("secQCodeNum", $secQCode);
			$output->addAttribute("secQCodeAns", $secQCodeAns);
		}else{
			incorrectLogin($output);
			return $output;
		}
		return $output;
	}

	$output = login($_REQUEST['username'], $_REQUEST['pass_hash']);
	print($output->asXML());
