<?php
require 'establish_link.php';
require 'errorcodes.php';

ini_set('error_reporting', E_ALL ^ E_NOTICE);
ini_set('display_errors', 1);
// Set time limit to indefinite execution
//ignore_user_abort(true);
set_time_limit(0);

// Set the ip and port we will listen on
$address = 'agora.gatech.edu';
$port = 1767; //agora.gatech.edu
// Create a TCP Stream socket
$sock = socket_create(AF_INET, SOCK_STREAM, 0);
// Bind the socket to an address/port
socket_bind($sock, $address, $port) or die('Could not bind to address');
// Start listening for connections
socket_listen($sock);
// Non block socket type
socket_set_nonblock($sock);
// Loop continuously
$read = array (
	$sock
);
while (true) {

	$changed_sockets = $read;
	$num_changed_sockets = socket_select($changed_sockets, $write = NULL, $except = NULL, NULL);
	$clients = $read;

	foreach ($changed_sockets as $socket) {
		if ($socket == $sock) {
			if (($client = socket_accept($sock)) < 0) {
				echo "socket_accept() failed: reason: " . socket_strerror($msgsock) . "\n";
				continue;
			} else {
				array_push($read, $client);
				//$msgs = pull_chat(0);
				//socket_write ( $client , $msgs , strlen($msgs) );
				echo "[" . date('Y-m-d H:i:s') . "] CONNECTED " . "(" . count($read_sockets) . "/" . SOMAXCONN . ")\n";
			}
		} else {
			$bytes = @ socket_recv($socket, $buffer, 2048, 0);
			if (preg_match("/policy-file-request/i", $buffer) || preg_match("/crossdomain/i", $buffer)) {
				echo "[" . date('Y-m-d H:i:s') . "] CROSSDOMAIN.XML REQUEST\n";
				$contents = "<?xml version=\"1.0\"?><!DOCTYPE cross-domain-policy SYSTEM \"http://www.adobe.com/xml/dtds/cross-domain-policy.dtd\"><cross-domain-policy><site-control permitted-cross-domain-policies=\"all\"/><allow-access-from domain=\"*\" to-ports=\"*\"/><allow-http-request-headers-from domain=\"*\" headers=\"*\"/><allow-http-request-headers-from domain=\"*\" secure=\"false\"/></cross-domain-policy>" . "\0";
				socket_write($socket, $contents);
				$contents = "";
				$index = array_search($socket, $read);
				unset ($read[$index]);
				socket_shutdown($socket, 2);
				socket_close($socket);
			}

			if (strlen($buffer) == 0) {
				$index = array_search($socket, $read);
				unset ($read[$index]);

				echo 'Client disconnected!', "\r\n";
				@ socket_shutdown($socket, 2);
				@ socket_close($socket);
			} else {
				$pos = strpos($buffer, ":");
				if ($pos) {
					$uname = substr($buffer, 0, $pos);
					$msg = substr($buffer, $pos +1, strlen($buffer));
					echo "$uname-$msg-";
					//echo "$msg $pos";
					if ($uname == "init") {
						echo "newconn";

					} else if ($uname == "udpate") {
						echo "update $msg";
							foreach ($clients AS $k => $v) {
								if ($v != $sock)
									socket_write($v, "update:" . $msg, strlen("update:" . $msg));
							}
					}
				}
			} //else
		}
	}

	//echo ".";
	sleep(1);
}
// Close the master sockets
socket_close($sock);

