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
	//Used to test handling of special characters in an attempt to solve a bug.
	
	$uid = $_REQUEST['uid'];
	print "User ID: $uid\n<BR>";
	$xmlin = $_REQUEST['xml'];
	print htmlspecialchars("Input XML: $xmlin", ENT_QUOTES);
	print("\n<BR>");
	try{
		$xml = new SimpleXMLElement($xmlin);
	}catch(Exception $e){
		print "Could not read XML\n<BR>";
	}
	$xmlstr = htmlspecialchars($xml->asXML(), ENT_QUOTES);
	print "XML as read: $xmlstr\n<BR>";
?>