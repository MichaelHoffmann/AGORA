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
	function insertFailed($output, $query){
		$fail=$login->addChild("error");
		$fail->addAttribute("text", "Could not add this data to the database. Query was: $query");
		$fail->addAttribute("code", 105);	
	}
	
	//Only for "generic" update errors.
	function insertFailed($output, $query){
		$fail=$login->addChild("error");
		$fail->addAttribute("text", "Could update the database. Query was: $query");
		$fail->addAttribute("code", 106);	
	}
	
	function mailSendFailed($output){
		$fail=$output->addChild("error");
		$fail->addAttribute("text", "The mail could not be sent");
		$fail->addAttribute("code", 201);
	}
	
	function incorrectLogin($output){
		$fail=$output->addChild("error");
		$fail->addAttribute("text", "Incorrect Login!");
		$fail->addAttribute("code", 301);
	}
	
	function poorXML($output){
		$fail=$output->addChild("error");
		$fail->addAttribute("text", "Improperly formatted input XML!");
		$fail->addAttribute("code", 302);
	}
	
	function modifyOtherTB($output){
		$fail=$output->addChild("error");
		$fail->addAttribute("text", "You are attempting to modify someone else's work or a nonexistent textbox. This is not permissible.");
		$fail->addAttribute("code", 303);
	}
	
	
?>