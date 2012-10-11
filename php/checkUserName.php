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
function checkUserNamesinFile() {
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
	$myFile = "C:\Users\lokesh\Desktop\AGORA\ValidatorTool\sample1.csv";
	$fh = fopen($myFile, 'r');
	while (!feof($fh)) {
		$theData = fgets($fh);
		$theData = trim($theData,"\r\n");
		$found = getUserIdFromUserName($theData,$linkID);
		if($found==-1)
		error_log($theData." not found", 0);
	}
	fclose($fh);

}
$output = checkUserNamesinFile();
?>