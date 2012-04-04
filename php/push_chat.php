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
	function pull_chat($username, $text, $map_id, $time)
	{
		global $dbName, $version;
		header("Content-type: text/xml");
		$outputstr = "<?xml version='1.0' ?>\n<login version='$version'></login>";
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
		$query1 = "SELECT MAX(real_node_number) from chat"
		$resultID = mysql_query($query, $linkID); 
		if(!$resultID){
			dataNotFound($output, $query);
			return $output;
		}
		$row = mysql_fetch_assoc($resultID);
		if($row['real_node_number']){
			$query_update = "UPDATE chat SET username = '$username',  text = '$text', map_id = '$map_id', time = '$time' , real_node_number = $row['real_node_number']+1 WHERE node_number='($row[real_node_number]+1)%1000"
			$status = mysql_query($query_update, $linkID);
		}else{
			modifyOther($output);
			return false;
		}
		return $output;
	}
	
	$username = mysql_real_escape_string($_REQUEST['username']);
	$text = mysql_real_escape_string($_REQUEST['text']);
	$time = mysql_real_escape_string($_REQUEST['time']);
	$map_id = mysql_real_escape_string($_REQUEST['map_id']);
	$output = login($username, $pass_hash);
	print($output->asXML());
?>