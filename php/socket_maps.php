<?php
require 'establish_link.php';
require 'errorcodes.php';

ini_set( 'error_reporting', E_ALL ^ E_NOTICE );
ini_set( 'display_errors', 1 );
// Set time limit to indefinite execution
//ignore_user_abort(true);
set_time_limit( 0 );

// Set the ip and port we will listen on
$address = 'agora.gatech.edu';
$port    = 1763;
// Create a TCP Stream socket
$sock = socket_create( AF_INET, SOCK_STREAM, 0 );
// Bind the socket to an address/port
socket_bind( $sock, $address, $port ) or die( 'Could not bind to address' );
// Start listening for connections
socket_listen( $sock );
// Non block socket type
socket_set_nonblock( $sock );
// Loop continuously
$read       = array( $sock );
$mapclients = array();
while ( true ) {

	$changed_sockets     = $read;
	$num_changed_sockets = socket_select( $changed_sockets, $write = null, $except = null, null );
	$clients             = $read;

	foreach ( $changed_sockets as $socket ) {
		if ( $socket == $sock ) {
			if ( ( $client = socket_accept( $sock ) ) < 0 ) {
				echo "socket_accept() failed: reason: " . socket_strerror( $msgsock ) . "\n";
				continue;
			} else {
				array_push( $read, $client );
				//$msgs = pull_chat(0);
				//socket_write ( $client , $msgs , strlen($msgs) );
				echo "[" . date( 'Y-m-d H:i:s' ) . "] CONNECTED " . "(" . count( $read_sockets ) . "/" . SOMAXCONN . ")\n";
			}
		} else {
			$bytes = @socket_recv( $socket, $buffer, 2048, 0 );
			if ( preg_match( "/policy-file-request/i", $buffer ) || preg_match( "/crossdomain/i", $buffer ) ) {
				echo "[" . date( 'Y-m-d H:i:s' ) . "] CROSSDOMAIN.XML REQUEST\n";
				$contents = "<?xml version=\"1.0\"?><!DOCTYPE cross-domain-policy SYSTEM \"http://www.adobe.com/xml/dtds/cross-domain-policy.dtd\"><cross-domain-policy><site-control permitted-cross-domain-policies=\"all\"/><allow-access-from domain=\"*\" to-ports=\"*\"/><allow-http-request-headers-from domain=\"*\" headers=\"*\"/><allow-http-request-headers-from domain=\"*\" secure=\"false\"/></cross-domain-policy>" . "\0";
				socket_write( $socket, $contents );
				$contents = "";
				$index    = array_search( $socket, $read );
				unset( $read[ $index ] );
				socket_shutdown( $socket, 2 );
				socket_close( $socket );
			}

			if ( strlen( $buffer ) == 0 ) {
				$index = array_search( $socket, $read );
				unset( $read[ $index ] );

				echo 'Client disconnected!', "\r\n";
				@socket_shutdown( $socket, 2 );
				@socket_close( $socket );
			} else {
				$pos = strpos( $buffer, ":" );
				if ( $pos ) {
					$uname = substr( $buffer, 0, $pos );
					$msg   = substr( $buffer, $pos + 1, strlen( $buffer ) );
					echo "$uname-$msg-";
					//echo "$msg $pos";
					if ( $uname == "init" ) {
						echo "$msg mapid";
						$msgs = pull_chat( $msg );
						socket_write( $socket, $msgs, strlen( $msgs ) );
						if ( $mapclients[ $msg ] == null ) {
							$arraysclnts        = array( $socket );
							$mapclients[ $msg ] = $arraysclnts;
						} else {
							$arraysclnts = $mapclients[ $msg ];
							array_push( $arraysclnts, $socket );
							$mapclients[ $msg ] = $arraysclnts;
						}
					} else {
						$pos   = strpos( $msg, ":" );
						$mapid = substr( $msg, 0, $pos );
						$msg   = substr( $msg, $pos + 1, strlen( $msg ) );
						echo "$mapid-$msg";
						push_chat( $uname, $msg, $mapid );
						$stat = array_key_exists( $mapid, $mapclients );
						if ( $stat ) {
							$arrclients = $mapclients[ $mapid ];
							foreach ( $arrclients AS $k => $v ) {
								$index = array_search( $v, $read );
								if ( ! $index ) {
									unset( $arrclients[ $k ] );
								} else if ( $v != $sock ) {
									socket_write( $v, $uname . ":" . $msg, strlen( $uname . ":" . $msg ) );
								}
							}
						}
					}
				}
			} //else
		}
	}

	//echo ".";
	sleep( 1 );
}
// Close the master sockets
socket_close( $sock );


function push_chat( $username, $text, $map_id ) {
	global $version;
	$outputstr = "<?xml version='1.0' ?>\n<chat version='$version'></chat>";
	$output    = new SimpleXMLElement( $outputstr );
	$linkID    = establishLink();
	if ( ! $linkID ) {
		badDBLink( $output );

		return $output;
	}

	$username = mysqli_real_escape_string( $linkID, $username );
	$text     = mysqli_real_escape_string( $linkID, $text );
	$userid   = getUserIdFromUserName( $username, $linkID );
	if ( $userid == -1 ) {
		return;
	}


	$query    = "INSERT INTO chat (username,chat_text,map_id) VALUES ('$username','$text','$map_id')";
	$resultID = mysqli_query( $linkID, $query );
	if ( ! $resultID ) {
		dataNotFound( $output, $query );

		return $output;
	} else {
		$map = $output->addChild( "chat" );
		$map->addAttribute( "Added", true );
	}

	return $output;
}

function pull_chat( $map_id ) {
	$messages = "";
	$linkID   = establishLink();
	if ( ! $linkID ) {
		return $messages;
	}
	$query = "SELECT * FROM chat WHERE map_id=$map_id and username!= '' ORDER BY node_number desc LIMIT 50";

	$result = mysqli_query( $linkID, $query );
	if ( ! $result ) {
		return $messages;
	}

	$row = mysqli_fetch_assoc( $result );
	if ( $row['username'] ) {
		for ( $x = 0; $x < mysqli_num_rows( $result ); $x++ ) {
			$messages = $row['username'] . ": " . $row['chat_text'] . "\n" . $messages;
			$row      = mysqli_fetch_assoc( $result );
		}
	} else {
		return $messages;
	}

	mysqli_close( $linkID );

	return $messages;
}

function getUserIdFromUserName( $username, $linkID ) {
	$username = mysqli_real_escape_string( $linkID, $username );
	$query    = "SELECT * FROM users WHERE username='$username'";
	$resultID = mysqli_query( $linkID, $query );
	if ( ! $resultID ) {
		return -1;
	}
	if ( ( mysqli_num_rows( $resultID ) == 0 ) ) {
		return -1;
	}
	$row = mysqli_fetch_assoc( $resultID );
	if ( $row['is_deleted'] ) {
		return -1;
	}

	return $row['user_id'];
}



