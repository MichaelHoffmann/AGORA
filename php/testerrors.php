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
	
	require 'errorcodes.php';
	
	header("Content-type: text/xml");
	$outputstr = "<?xml version='1.0' ?>\n<map version='$version'></map>";
	$output = new SimpleXMLElement($outputstr);
	$query = "example query";
	$iquery = "example insert";
	$uquery = "example update";
	noTime($output);
	metaError($output);
	badDBLink($output);
	databaseNotFound($output);
	rolledBack($output);
	dataNotFound($output, $query);
	insertFailed($output, $iquery);
	updateFailed($output, $uquery);
	deleteFailed($output, $query);
	mailSendFailed($output);
	incorrectLogin($output);
	poorXML($output);
	modifyOther($output);
	accessDeleted($output);
	nonexistent($output, $query);
	repeatEmail($output);
	repeatUsername($output);
	cannotDeleteFromNonexistent($output);	
	print($output->asXML());
?>