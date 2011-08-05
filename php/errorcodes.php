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
	100-series: Errors involving the database
	200-series: Errors involving email
	300-series: Errors involving users doing things they shouldn't be
	
	*/
	
	/*
		These functions are all similar.
		They are intended to be generic XML error output.
		As such, they take the current SimpleXML node as input and will add a child.
		That child with have error text for human readability,
			as well as a numeric code for client software use.
			
		Errors that also print out the query naturally require the query to be passed in.
	*/
	
	function noTime($output){
		$fail=$xml->addChild("error");
		$fail->addAttribute("text", "Time has ceased to exist. Could not get timestamp from server.");
		$fail->addAttribute("code", 0);
	}
	
	function metaError($output){
		$fail=$output->addChild("error");
		$fail->addAttribute("text", "Due to a prior error, all remaining commands are being rejected");
	}
	
	function badDBLink($output){
		$fail=$output->addChild("error");
		$fail->addAttribute("text", "Could not establish link to the database server");
		$fail->addAttribute("code", 101);
	}
	
	function databaseNotFound($output){
		$fail=$output->addChild("error");
		$fail->addAttribute("text", "Could not find database");
		$fail->addAttribute("code", 102);
	}
	
	function rolledBack($output){
		$fail=$output->addChild("error");
		$fail->addAttribute("text", "The queries have been rolled back!");
		$fail->addAttribute("code", 103);
	}
	
	//Only for "generic" data errors.
	function dataNotFound($output, $query){
		$fail=$login->addChild("error");
		$fail->addAttribute("text", "Data not found. Query was: $query");
		$fail->addAttribute("code", 104);	
	}
	
	//Only for "generic" insert errors.
	function insertFailed($output, $iquery){
		$fail=$login->addChild("error");
		$fail->addAttribute("text", "Could not add this data to the database. Query was: $iquery");
		$fail->addAttribute("code", 105);	
	}
	
	//Only for "generic" update errors.
	function updateFailed($output, $uquery){
		$fail=$login->addChild("error");
		$fail->addAttribute("text", "Could not update the database. Query was: $uquery");
		$fail->addAttribute("code", 106);	
	}
	
	//Only for "generic" delete errors.
	function deleteFailed($output, $query){
		$fail=$login->addChild("error");
		$fail->addAttribute("text", "Could not delete that from the database. Query was: $query");
		$fail->addAttribute("code", 107);	
	}
	
	function mailSendFailed($output){
		$fail=$output->addChild("error");
		$fail->addAttribute("text", "The mail could not be sent");
		$fail->addAttribute("code", 201);
	}
	
	function incorrectLogin($output){
		$fail=$output->addChild("error");
		$fail->addAttribute("text", "Your login information is incorrect.");
		$fail->addAttribute("code", 301);
	}
	
	function poorXML($output){
		$fail=$output->addChild("error");
		$fail->addAttribute("text", "Improperly formatted input XML!");
		$fail->addAttribute("code", 302);
	}
	
	function modifyOther($output){
		$fail=$output->addChild("error");
		$fail->addAttribute("text", "You are attempting to modify or delete someone else's work or a nonexistent item. This is not possible.");
		$fail->addAttribute("code", 303);
	}
	
	function accessDeleted($output){
		$fail = $output->addChild("error");
		$fail->addAttribute("text", "The item you are trying to access has been deleted.");
		$fail->addAttribute("code", 304);
	}
	/*
	The difference here is that the prior function is for when you are looking something up specifically, then checking its status.
	The following one is for when the query itself has "WHERE is_deleted=0" or something similar, so you can't tell if it ever existed.
	*/
	function nonexistent($output, $query){
		$fail=$xml->addChild("error");
		$fail->addAttribute("text", "The item you are trying to access either does not exist or has been deleted. Query was: $query");
		$fail->addAttribute("code", 305);
	}
	
	function repeatEmail($output){
		$fail=$xml->addChild("error");
		$fail->addAttribute("text", "That e-mail address has already been used to register an account.");
		$fail->addAttribute("code", 306);
	}
	
	function repeatUsername($output){
		$fail=$xml->addChild("error");
		$fail->addAttribute("text", "An account with that username already exists.");
		$fail->addAttribute("code", 307);
	}
	
	function cannotDeleteFromNonexistent($output){
		$fail=$output->addChild("error");
		$fail->addAttribute("text", "This map does not exist, therefore you cannot remove things from this map.");
		$fail->addAttribute("code", 308);
	}
	
?>