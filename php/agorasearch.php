<?php
/**
 * AGORA - an interactive and web-based argument mapping tool that stimulates reasoning,
 * reflection, critique, deliberation, and creativity in individual argument construction
 * and in collaborative or adversarial settings.
 * Copyright (C) 2011 Georgia Institute of Technology
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

require 'configure.php';
require 'errorcodes.php';
require 'establish_link.php';
require 'utilfuncs.php';

/**
 *    File for searching maps.
 *    HTTP Query variables:
 *    type: the type of search that can be performed.
 *            Current options are: title, text, titleandtext, user
 *    query: the text to use as the search query. Case-insensitive.
 *
 */

function search_db( $query, $type, $queryC ) {
	global $dbName, $version;
	//basic XML output initialization
	header( "Content-type: text/xml" );
	$xmlstr = "<?xml version='1.0' ?>\n<AGORA version='$version'/>";
	$output = new SimpleXMLElement( $xmlstr );
	//Standard SQL connection stuff
	$linkID = establishLink();
	if ( ! $linkID ) {
		badDBLink( $output );

		return $output;
	}


	//Query passed in gets used here.
	$resultID = mysqli_query( $linkID, $query );
	if ( ! $resultID ) {
		dataNotFound( $output, $query );

		return $output;
	}
	//$output->addAttribute("q", $query);
	if ( mysqli_num_rows( $resultID ) == 0 ) {
		$output->addAttribute( "map_count", "0" );
		$output->addAttribute( "map_count1", $query );

		//This is a better alternative than reporting an error.
		return $output;
	} else {
		for ( $x = 0; $x < mysqli_num_rows( $resultID ); $x++ ) {
			$row = mysqli_fetch_assoc( $resultID );
			$map = $output->addChild( "map" );
			$map = processMap( $map, $row, $type );

		}
	}


	//Query passed in gets used here.
	$resultIDC = mysqli_query( $linkID, $queryC );
	if ( ! $resultIDC ) {
		dataNotFound( $output, $queryC );

		return $output;
	}
	if ( $resultIDC != null && mysqli_num_rows( $resultIDC ) > 0 ) {
		$row = mysqli_fetch_assoc( $resultIDC );
		$map = $output->addChild( "meta" );
		$map->addAttribute( "Cnt", $row['cnt'] );
	}

	return $output;
}


function processMap( $map, $row, $type ) {

	if ( $type == 1 || $type == "usersMaps" || $type == -1 ) {
		$map->addAttribute( "ID", $row['map_id'] );
		$map->addAttribute( "title", $row['title'] );
		$map->addAttribute( "creator", $row['username'] );
		$map->addAttribute( "last_modified", $row['modified_date'] );
		$map->addAttribute( "usersC", $row['usersC'] );
		$map->addAttribute( "textC", $row['textC'] );
		$map->addAttribute( "concl", $row['concl'] );
		// permissions check ..
		if ( $type == -1 && ( $row['perm'] == "" || $row['perm'] == null ) ) {
			$map->addAttribute( "perm", "-1" );
		} else {
			$map->addAttribute( "perm", $row['perm'] );
		}
		$map->addAttribute( "url", $row['url'] );
		$map->addAttribute( "ttype", "maps" );
		$map->addAttribute( "isproj", $row['isproj'] );

	} else if ( $type == 2 || $type == "usersProj" ) {
		$map->addAttribute( "ID", $row['proj_id'] );
		$map->addAttribute( "title", $row['title'] );
		$map->addAttribute( "creator", $row['username'] );
		$map->addAttribute( "mapsC", $row['mapsC'] );
		$map->addAttribute( "usersC", $row['usersC'] );
		$map->addAttribute( "perm", $row['perm'] );
		$map->addAttribute( "url", $row['url'] );
		$map->addAttribute( "ttype", "proj" );

	} else if ( $type == "users" ) {
		$map->addAttribute( "ID", $row['user_id'] );
		$map->addAttribute( "creator", $row['username'] );
		$map->addAttribute( "mapsC", $row['mapsC'] );
		$map->addAttribute( "projC", $row['projC'] );
		$map->addAttribute( "url", $row['url'] );
		$map->addAttribute( "ttype", "users" );

	}

	return $map;
}

// maps

function collectMapIds( $query ) {

	$linkID  = establishLink();
	$oparray = array();
	if ( ! $linkID ) {
		return $oparray;
	}

	//Query passed in gets used here.
	$resultID = mysqli_query( $linkID, $query );
	if ( ! $resultID ) {
		return $oparray;
	}
	if ( mysqli_num_rows( $resultID ) == 0 ) {
		return $oparray;
	} else {
		for ( $x = 0; $x < mysqli_num_rows( $resultID ); $x++ ) {
			$row = mysqli_fetch_assoc( $resultID );
			array_push( $oparray, $row['map_id'] );
		}
	}

	return $oparray;

}

function search_by_mapId( $text, $type, $userID, $start ) {
	$linkID = establishLink();
	if ( ! $linkID ) {
		return;
	}

	$text   = mysqli_real_escape_string( $linkID, $text );
	$userID = mysqli_real_escape_string( $linkID, $userID );

	$query  = "SELECT maps.map_id, maps.title, users.username,users.url, maps.modified_date,is_project as isproj, count( distinct projusers.user_id ) as usersC, count( distinct textboxes.textbox_id) as textC, textboxes.text as concl,curr.user_id as perm FROM maps INNER JOIN users ON users.user_id = maps.user_id Inner Join category_map on maps.map_id=category_map.map_id inner join category on category_map.category_id=category.category_id left JOin projusers on category_map.category_id=projusers.proj_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id = $userID inner join textboxes on maps.map_id=textboxes.map_id WHERE maps.map_id = '$text' AND maps.is_deleted=0 GROUP BY map_id ORDER BY curr.user_id desc,maps.title, textboxes.textbox_id LIMIT 26";
	$queryC = "SELECT count(distinct maps.map_id) as cnt FROM maps INNER JOIN users ON users.user_id = maps.user_id Inner Join category_map on maps.map_id=category_map.map_id Inner JOin projusers on category_map.category_id=projusers.proj_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id = $userID inner join textboxes on maps.map_id=textboxes.map_id WHERE maps.map_id = '$text' AND maps.is_deleted=0 GROUP BY maps.map_id ORDER BY curr.user_id desc,maps.title, textboxes.textbox_id ";

	return search_db( $query, $type, $queryC );
}

function search_by_title( $text, $type, $userID, $start ) {
	$linkID = establishLink();
	if ( ! $linkID ) {
		return;
	}

	$text   = mysqli_real_escape_string( $linkID, $text );
	$userID = mysqli_real_escape_string( $linkID, $userID );

	$query  = "SELECT maps.map_id, maps.title, users.username,users.url, maps.modified_date, count( distinct projusers.user_id ) as usersC, count( distinct textboxes.textbox_id) as textC, textboxes.text as concl,curr.user_id as perm FROM maps INNER JOIN users ON users.user_id = maps.user_id Inner Join category_map on maps.map_id=category_map.map_id Inner JOin projusers on category_map.category_id=projusers.proj_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id = $userID inner join textboxes on maps.map_id=textboxes.map_id WHERE $text AND maps.is_deleted=0 GROUP BY map_id ORDER BY curr.user_id desc,maps.title, textboxes.textbox_id LIMIT $start,26";
	$queryC = "SELECT count(maps.map_id) as cnt FROM maps INNER JOIN users ON users.user_id = maps.user_id Inner Join category_map on maps.map_id=category_map.map_id Inner JOin projusers on category_map.category_id=projusers.proj_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id = $userID inner join textboxes on maps.map_id=textboxes.map_id WHERE $text AND maps.is_deleted=0 GROUP BY map_id ORDER BY curr.user_id desc,maps.title, textboxes.textbox_id ";

	return search_db( $query, $type, $queryC );
}

function search_by_text( $text, $type, $userID, $start ) {
	$linkID = establishLink();
	if ( ! $linkID ) {
		return;
	}

	$text   = mysqli_real_escape_string( $linkID, $text );
	$userID = mysqli_real_escape_string( $linkID, $userID );

	$query  = "SELECT maps.map_id, maps.title, maps.modified_date, maps.user_id, users.username,users.url,count( distinct projusers.user_id ) as usersC, count( distinct textboxes.textbox_id) as textC, textboxes.text as concl,curr.user_id as perm FROM maps INNER JOIN users ON users.user_id = maps.user_id Inner Join category_map on maps.map_id=category_map.map_id Inner JOin projusers on category_map.category_id=projusers.proj_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id = $userID inner join textboxes on maps.map_id=textboxes.map_id WHERE maps.map_id IN (SELECT DISTINCT map_id FROM `textboxes` WHERE $text) GROUP BY map_id ORDER BY curr.user_id desc,maps.title, textboxes.textbox_id LIMIT $start,26";
	$queryC = "SELECT count(maps.map_id) as cnt FROM maps INNER JOIN users ON users.user_id = maps.user_id Inner Join category_map on maps.map_id=category_map.map_id Inner JOin projusers on category_map.category_id=projusers.proj_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id = $userID inner join textboxes on maps.map_id=textboxes.map_id WHERE maps.map_id IN (SELECT DISTINCT map_id FROM `textboxes` WHERE $text) GROUP BY map_id ORDER BY curr.user_id desc,maps.title, textboxes.textbox_id ";

	return search_db( $query, $type, $queryC );
}

function search_by_title_and_text( $text, $text2, $type, $userID, $start ) {
	$linkID = establishLink();
	if ( ! $linkID ) {
		return;
	}

	$text   = mysqli_real_escape_string( $linkID, $text );
	$userID = mysqli_real_escape_string( $linkID, $userID );

	$query  = "SELECT maps.map_id, maps.title, maps.modified_date, maps.user_id, users.username,users.url,count( distinct projusers.user_id ) as usersC, count( distinct textboxes.textbox_id) as textC, textboxes.text as concl,curr.user_id as perm FROM maps INNER JOIN users ON users.user_id=maps.user_id Inner Join category_map on maps.map_id=category_map.map_id Inner JOin projusers on category_map.category_id=projusers.proj_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id = $userID inner join textboxes on maps.map_id=textboxes.map_id WHERE maps.map_id IN (SELECT DISTINCT map_id FROM `textboxes` WHERE $text2) OR $text AND maps.is_deleted=0 ORDER BY curr.user_id desc,maps.title LIMIT $start,26";
	$queryC = "SELECT count(maps.map_id) as cnt FROM maps INNER JOIN users ON users.user_id=maps.user_id Inner Join category_map on maps.map_id=category_map.map_id Inner JOin projusers on category_map.category_id=projusers.proj_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id = $userID inner join textboxes on maps.map_id=textboxes.map_id WHERE maps.map_id IN (SELECT DISTINCT map_id FROM `textboxes` WHERE $text2) OR $text AND maps.is_deleted=0 ORDER BY curr.user_id desc,maps.title ";

	return search_db( $query, $type, $queryC );
}

function search_by_title_and_text_andUser( $text, $text2, $text3, $b1, $b2, $type, $userID, $start, $dateC, $dateM, $sortBy, $order ) {

	$q1      = "";
	$q2      = "";
	$q3      = "";
	$adminId = -1;

	$linkID = establishLink();
	if ( ! $linkID ) {
		return;
	}
	if ( $text3 != "" ) {
		$adminId = getUserIdFromUserName( $text3, $linkID );
	}

	$b1     = mysqli_real_escape_string( $linkID, $b1 );
	$b2     = mysqli_real_escape_string( $linkID, $b2 );
	$userID = mysqli_real_escape_string( $linkID, $userID );
	$start  = mysqli_real_escape_string( $linkID, $start );
	$dateC  = mysqli_real_escape_string( $linkID, $dateC );
	$dateM  = mysqli_real_escape_string( $linkID, $dateM );

	if ( $text != "" ) {
		$text = mysqli_real_escape_string( $linkID, $text );
		$q1   = "( $text )";
		if ( $text2 != "" ) {
			$q1 = $q1 . " $b1 ";
		} else if ( $adminId != -1 && $adminId != null ) {
			$q1 = $q1 . " $b2 ";
		}
	}

	if ( $text2 != "" ) {
		$text2    = str_replace( "$", " SELECT DISTINCT map_id FROM textboxes WHERE ", $text2 );
		$text2    = mysqli_real_escape_string( $linkID, $text2 );
		$mapsidss = collectMapIds( $text2 );
		$q2       = ' maps.map_id IN (' . implode( ',', array_map( 'intval', $mapsidss ) ) . ')';
		if ( $adminId != -1 && $adminId != null ) {
			$q2 = $q2 . " $b2 ";
		}
	}

	if ( $adminId != null && $adminId != -1 ) {
		$q3 = " ( maps.user_id = $adminId )";
	}

	$q4    = "";
	$q5    = "";
	$conn1 = "(";
	$conn2 = ")";
	if ( $q1 == "" && $q2 == "" && $q3 == "" ) {
		$conn1 = $conn2 = "";
	}
	if ( $dateC > 0 ) {
		if ( $q1 == "" && $q2 == "" && $q3 == "" ) {
			$q4 = "maps.created_date BETWEEN SYSDATE() - INTERVAL $dateC DAY AND SYSDATE() ";
		} else {
			$q4 = "$b1 maps.created_date BETWEEN SYSDATE() - INTERVAL $dateC DAY AND SYSDATE() ";
		}
	}

	if ( $dateM > 0 ) {
		if ( $q1 == "" && $q2 == "" && $q3 == "" && $q4 == "" ) {
			$q5 = "maps.modified_date BETWEEN SYSDATE() - INTERVAL $dateM DAY AND SYSDATE() ";
		} else {
			$q5 = "$b1 maps.modified_date BETWEEN SYSDATE() - INTERVAL $dateM DAY AND SYSDATE() ";
		}
	}

	// sort and order string
	$sortByStr = getSortByMapsStr( $sortBy );
	$orderStr  = getOrderByMapsStr( $order );


	$query  = "SELECT maps.map_id, maps.title, maps.modified_date, maps.user_id, users.username,users.url,count( distinct projusers.user_id ) as usersC, count( distinct textboxes.textbox_id) as textC, textboxes.text as concl,curr.user_id as perm,is_project as isproj FROM maps INNER JOIN users ON users.user_id=maps.user_id Inner Join category_map on maps.map_id=category_map.map_id inner join category on category_map.category_id=category.category_id left JOin projusers on category_map.category_id=projusers.proj_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id = $userID inner join textboxes on maps.map_id=textboxes.map_id WHERE (is_project=0 or curr.user_id=$userID ) and maps.is_deleted=0 And $conn1  $q1 $q2 $q3 $conn2 $q4 $q5  GROUP BY map_id,perm  ORDER BY $sortByStr $orderStr LIMIT $start,26";
	$queryC = "SELECT count(distinct maps.map_id) as cnt FROM maps INNER JOIN users ON users.user_id=maps.user_id Inner Join category_map on maps.map_id=category_map.map_id inner join category on category_map.category_id=category.category_id left JOin projusers on category_map.category_id=projusers.proj_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id = $userID inner join textboxes on maps.map_id=textboxes.map_id WHERE (is_project=0 or curr.user_id=$userID ) and maps.is_deleted=0 And $conn1  $q1 $q2 $q3 $conn2 $q4 $q5  ORDER BY $sortByStr $orderStr ";

	return search_db( $query, $type, $queryC );
}

function getSortByMapsStr( $sortBy ) {

	switch ( $sortBy ) {
		case 1:
			return "maps.title";
		case 2:
			return "users.username";
		case 3:

			return "concl";
		case 5:

			return "textC";
		case 4:

			return "usersC";
		default:
			return "maps.title";
	}
}

function getSortByProjStr( $sortBy ) {
	switch ( $sortBy ) {
		case 1:
			return "projects.title";
		case 2:
			return "users.username";
		case 5:
			return "mapsC";
		case 4:
			return "usersC";
		default:
			return "projects.title";
	}

}

function getSortByUsersStr( $sortBy ) {
	switch ( $sortBy ) {
		case 1:
			return "users.username";
		case 3:
			return "mapsC";
		case 4:
			return "projC";
		default:
			return "users.username";
	}

}

function getOrderByMapsStr( $sortBy ) {
	if ( $sortBy == 2 ) {
		return "desc";
	}

	return "asc";
}


function search_by_user( $text, $type, $userID, $start ) {
	$query  = "SELECT maps.map_id, maps.title, maps.modified_date, maps.user_id, users.username,users.url,count( distinct projusers.user_id ) as usersC, count( distinct textboxes.textbox_id) as textC, textboxes.text as concl,curr.user_id as perm FROM maps INNER JOIN users ON users.user_id = maps.user_id Inner Join category_map on maps.map_id=category_map.map_id Inner JOin projusers on category_map.category_id=projusers.proj_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id = $userID inner join textboxes on maps.map_id=textboxes.map_id WHERE users.username LIKE '%$text%' OR users.firstname LIKE '%$text%' OR users.lastname LIKE '%$text%' GROUP BY map_id ORDER BY curr.user_id desc,maps.title, textboxes.textbox_id LIMIT $start,26";
	$queryC = "SELECT count(distinct maps.map_id) as cnt FROM maps INNER JOIN users ON users.user_id = maps.user_id Inner Join category_map on maps.map_id=category_map.map_id Inner JOin projusers on category_map.category_id=projusers.proj_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id = $userID inner join textboxes on maps.map_id=textboxes.map_id WHERE users.username LIKE '%$text%' OR users.firstname LIKE '%$text%' OR users.lastname LIKE '%$text%' ORDER BY curr.user_id desc,maps.title, textboxes.textbox_id ";

	return search_db( $query, $type, $queryC );
}

function searchMaps_by_user( $owner, $type, $userID, $start ) {
	$query  = "SELECT maps.map_id, maps.title, maps.modified_date, maps.user_id, users.username,users.url,count( distinct projusers.user_id ) as usersC, count( distinct textboxes.textbox_id) as textC, textboxes.text as concl,curr.user_id as perm FROM maps INNER JOIN users ON users.user_id = maps.user_id Inner Join category_map on maps.map_id=category_map.map_id Inner JOin projusers on category_map.category_id=projusers.proj_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id = $userID inner join textboxes on maps.map_id=textboxes.map_id WHERE maps.user_id = $owner GROUP BY map_id ORDER BY curr.user_id desc,maps.title, textboxes.textbox_id LIMIT $start,26";
	$queryC = "SELECT count(distinct maps.map_id) as cnt FROM maps INNER JOIN users ON users.user_id = maps.user_id Inner Join category_map on maps.map_id=category_map.map_id Inner JOin projusers on category_map.category_id=projusers.proj_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id = $userID inner join textboxes on maps.map_id=textboxes.map_id WHERE maps.user_id = $owner  ORDER BY curr.user_id desc,maps.title, textboxes.textbox_id ";

	return search_db( $query, $type, $queryC );
}

// projs
function searchproj( $text, $text2, $adminIdStr, $b1, $b2, $type, $userID, $start, $special, $dateC, $dateM, $sortBy, $order ) {
	$linkID = establishLink();
	if ( ! $linkID ) {
		return;
	}
	$q1      = "";
	$q2      = "";
	$q3      = "";
	$adminId = -1;
	if ( $adminIdStr != "" ) {
		$adminId = getUserIdFromUserName( $adminIdStr, $linkID );
	}

	$b1     = mysqli_real_escape_string( $linkID, $b1 );
	$b2     = mysqli_real_escape_string( $linkID, $b2 );
	$userID = mysqli_real_escape_string( $linkID, $userID );
	$start  = mysqli_real_escape_string( $linkID, $start );
	$dateC  = mysqli_real_escape_string( $linkID, $dateC );
	$dateM  = mysqli_real_escape_string( $linkID, $dateM );

	if ( $text != "" ) {
		$text = mysqli_real_escape_string( $linkID, $text );
		$q1   = "( $text )";
		if ( $text2 != "" ) {
			$q1 = $q1 . " $b1 ";
		} else if ( $adminId != -1 && $adminId != null ) {
			$q1 = $q1 . " $b2 ";
		}
	}

	if ( $text2 != "" ) {
		$q2 = "( $text2 )";
		if ( $adminId != -1 && $adminId != null ) {
			$q2 = $q2 . " $b2 ";
		}
	}

	if ( $adminId != null && $adminId != -1 ) {
		$adminId = mysqli_real_escape_string( $linkID, $adminId );
		$q3      = " ( projects.user_id=$adminId )";
	}

	$q4 = "";
	$q5 = "";
	if ( $dateC > 0 ) {
		$q4 = "and projects.created_date BETWEEN SYSDATE() - INTERVAL $dateC DAY AND SYSDATE() ";
	}

	if ( $dateM > 0 ) {
		$q5 = "and projects.modified_date BETWEEN SYSDATE() - INTERVAL $dateC DAY AND SYSDATE() ";
	}

	// sort and order string
	$sortByStr = getSortByProjStr( $sortBy );
	$orderStr  = getOrderByMapsStr( $order );


	$query  = "SELECT projects.proj_id,projects.title,count(distinct category_map.map_id) as mapsC, count(distinct projusers.user_id) as usersC, users.username,users.url,curr.user_id as perm FROM projects inner join category on projects.proj_id=category.category_id left join category_map on projects.proj_id = category_map.category_id inner join maps on category_map.map_id = maps.map_id inner join projusers on projects.proj_id = projusers.proj_id inner join users on projects.user_id = users.user_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id=$userID where category.is_project = 1 and ( $q1 $q2 $q3) $q4 $q5 group by projects.proj_id order by $sortByStr $orderStr LIMIT $start,26";
	$queryC = "SELECT count(distinct projects.proj_id) as cnt FROM projects inner join category on projects.proj_id=category.category_id left join category_map on projects.proj_id = category_map.category_id inner join maps on category_map.map_id = maps.map_id inner join projusers on projects.proj_id = projusers.proj_id inner join users on projects.user_id = users.user_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id=$userID where category.is_project = 1 and ( $q1 $q2 $q3) $q4 $q5  order by $sortByStr $orderStr ";

	return search_db( $query, $type, $queryC );
}

// projs
function searchproj1( $text, $adminIdStr, $type, $userID, $start, $special ) {
	$linkID = establishLink();
	if ( ! $linkID ) {
		return;
	}
	if ( $adminIdStr != "" ) {
		$adminId = getUserIdFromUserName( $adminIdStr, $linkID );
	}

	$query2 = '';
	$query1 = $text;

	if ( $adminId != null && $adminId != -1 ) {
		if ( $special == null ) {
			$query2 = "and projects.user_id=$adminId";
		} else {
			$special = $special . " and projusers.user_id=$adminId";
		}
	}

	if ( $text != null ) {
		$query1 = "and $query1";
	}

	$query  = "SELECT projects.proj_id,title,count(distinct category_map.map_id) as mapsC, count(distinct projusers.user_id) as usersC, users.username,users.url,curr.user_id as perm FROM projects inner join category on projects.proj_id=category.category_id left join category_map on projects.proj_id = category_map.category_id inner join projusers on projects.proj_id = projusers.proj_id $special inner join users on projects.user_id = users.user_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id=$userID where category.is_project = 1 $query1 $query2 group by projects.proj_id order by curr.user_id desc,projects.title LIMIT $start,26";
	$queryC = "SELECT count(distinct projects.proj_id) as cnt FROM projects inner join category on projects.proj_id=category.category_id left join category_map on projects.proj_id = category_map.category_id inner join projusers on projects.proj_id = projusers.proj_id $special inner join users on projects.user_id = users.user_id left join users as curr on projusers.user_id = curr.user_id and curr.user_id=$userID where category.is_project = 1 $query1 $query2 order by curr.user_id desc,projects.title ";

	return search_db( $query, $type, $queryC );
}


function search( $sType, $sQuery, $s2Query, $type, $userID, $start ) {
	switch ( $sType ) {
		//This makes it simple enough to add more types later on.
		case "title":
			return search_by_title( $sQuery, $type, $userID, $start );
			break;

		case "text":
			return search_by_text( $sQuery, $type, $userID, $start );
			break;

		case "titleandtext":
			return search_by_title_and_text( $sQuery, $s2Query, $type, $userID, $start );
			break;

		case "user":
			return search_by_user( $sQuery, $type, $userID, $start );
			break;

		case "mapid":
			return search_by_mapId( $sQuery, $type, $userID, $start );
			break;
	}
}


function searchUser( $text, $adminIdStr, $type, $start, $userID, $sortBy, $order ) {
	$linkID = establishLink();
	if ( ! $linkID ) {
		return;
	}

	$text       = mysqli_real_escape_string( $linkID, $text );
	$adminIdStr = mysqli_real_escape_string( $linkID, $adminIdStr );
	$start      = mysqli_real_escape_string( $linkID, $start );
	$userID     = mysqli_real_escape_string( $linkID, $userID );

	$query2 = '';
	$query1 = '';
	if ( $type == "users" ) {
		$query1 = "and ( $text or $adminIdStr )";

		// sort and order string
		$sortByStr = getSortByUsersStr( $sortBy );
		$orderStr  = getOrderByMapsStr( $order );

		$query  = "select users.user_id, users.username,users.url, count(distinct projects.proj_id) as projC, count(distinct maps.map_id) as mapsC from users left join maps on users.user_id = maps.user_id left join projects on users.user_id = projects.user_id where maps.is_deleted =0 $query1 group by users.user_id order by $sortByStr $orderStr LIMIT $start,26";
		$queryC = "select count(distinct users.user_id) as cnt from users left join maps on users.user_id = maps.user_id left join projects on users.user_id = projects.user_id where maps.is_deleted =0 $query1  order by $sortByStr $orderStr ";

		return search_db( $query, $type, $queryC );
	} else if ( $adminIdStr != null ) {
		if ( $type == "usersMaps" ) {
			$adminId = getUserIdFromUserName( $adminIdStr, $linkID );

			return searchMaps_by_user( $adminId, $type, $userID, $start );

		} else if ( $type == "usersProj" ) {

			return searchproj1( "", $adminIdStr, $type, $userID, $start, "and projusers.user_level=1" );
		}

	}


}

function searchMain( $sType, $sQuery, $s2Query, $uvname, $b1, $b2, $type, $userID, $start, $dateC, $dateM, $sortBy, $order ) {
	switch ( $type ) {
		case 1:
			if ( $sType != "mapid" ) {
				return search_by_title_and_text_andUser( $sQuery, $s2Query, $uvname, $b1, $b2, $type, $userID, $start, $dateC, $dateM, $sortBy, $order );
			} else {
				return search_by_mapId( $sQuery, -1, $userID, $start );
			}
		case 2:
			return searchproj( $sQuery, $s2Query, $uvname, $b1, $b2, $type, $userID, $start, null, $dateC, $dateM, $sortBy, $order );
		case 3:
			return searchUser( $s2Query, $sQuery, $sType, $start, $userID, $sortBy, $order );
			break;

	}
}

$userID  = $_REQUEST['uid'];  //TODO: Change this back to a GET when all testing is done.
$type    = $_REQUEST['searchType'];  //TODO: Change this back to a GET when all testing is done.
$sType   = $_REQUEST['type'];  //TODO: Change this back to a GET when all testing is done.
$sQuery  = $_REQUEST['query'];  //TODO: Change this back to a GET when all testing is done.
$start   = $_REQUEST['index'];   //TODO: Change this back to a GET when all testing is done.
$s2Query = "";
$uvname  = "";
if ( array_key_exists( "query2", $_REQUEST ) ) {
	$s2Query = ( $_REQUEST['query2'] );  //TODO: Change this back to a GET when all testing is done.
}
if ( array_key_exists( "uvname", $_REQUEST ) ) {
	$uvname = $_REQUEST['uvname'];  //TODO: Change this back to a GET when all testing is done.
}
$b1 = $_REQUEST['b1'];  //TODO: Change this back to a GET when all testing is done.
$b2 = $_REQUEST['b2'];  //TODO: Change this back to a GET when all testing is done.

$dateC = $_REQUEST['dateC'];  //TODO: Change this back to a GET when all testing is done.
$dateM = $_REQUEST['dateM'];  //TODO: Change this back to a GET when all testing is done.

$sortBy = $_REQUEST['sortBy'];  //TODO: Change this back to a GET when all testing is done.
$order  = $_REQUEST['order'];  //TODO: Change this back to a GET when all testing is done.

$output = searchMain( $sType, $sQuery, $s2Query, $uvname, $b1, $b2, $type, $userID, $start, $dateC, $dateM, $sortBy, $order );
print $output->asXML();
