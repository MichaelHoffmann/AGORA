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
	* Check-Login function separated out for widespread use.
	*/
	function checkLogin($userID, $pass_hash, $linkID)
	{
		$userclause = mysqli_real_escape_string( $linkID, $userID );
		$passclause = mysqli_real_escape_string( $linkID, $pass_hash );
		$query      = "SELECT * FROM users WHERE user_ID='$userID' AND password='$passclause'";
		$resultID = mysqli_query( $linkID, $query ) or die( "Data not found." );
		if ( mysqli_num_rows( $resultID ) > 0 ) {
			return true;
		}else{
			return false;
		}
	}
