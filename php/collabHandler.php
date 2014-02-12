<?php
require 'establish_link.php';
require 'errorcodes.php';

ini_set ( 'error_reporting' , E_ALL ^ E_NOTICE );
ini_set ( 'display_errors' , 1 );
// Set time limit to indefinite execution
//ignore_user_abort(true);
set_time_limit ( 0 );

// Set the ip and port we will listen on
$address = 'agora.gatech.edu' ; $port = 1768 ;
// Create a TCP Stream socket
$sock = socket_create ( AF_INET , SOCK_STREAM , 0 );
// Bind the socket to an address/port
socket_bind ( $sock , $address , $port ) or die( 'Could not bind to address' );
// Start listening for connections
socket_listen ( $sock );
// Non block socket type
socket_set_nonblock ( $sock );
// Loop continuously
$read = array($sock);
$mapclients = array();
$mapunames = array();
$nodenames = array();
while ( true )
{

	$changed_sockets = $read;
	$num_changed_sockets = socket_select($changed_sockets, $write = NULL, $except = NULL, NULL);
	$clients = $read;

	foreach($changed_sockets as $socket)
	{
		if ($socket == $sock)
		{
			if (($client = socket_accept($sock)) < 0)
			{
				echo "socket_accept() failed: reason: " . socket_strerror($msgsock) . "\n";
				continue;
			}
			else
			{
				array_push($read, $client);
			//$msgs = pull_chat(0);
			//socket_write ( $client , $msgs , strlen($msgs) );
				echo "[".date('Y-m-d H:i:s')."] CONNECTED "."(".count($read_sockets)."/".SOMAXCONN.")\n";
			}
		} else
		{
			$bytes = @socket_recv($socket, $buffer, 2048, 0);
			if (preg_match("/policy-file-request/i", $buffer) || preg_match("/crossdomain/i", $buffer))
			{
				echo "[".date('Y-m-d H:i:s')."] CROSSDOMAIN.XML REQUEST\n";
				$contents="<?xml version=\"1.0\"?><!DOCTYPE cross-domain-policy SYSTEM \"http://www.adobe.com/xml/dtds/cross-domain-policy.dtd\"><cross-domain-policy><site-control permitted-cross-domain-policies=\"all\"/><allow-access-from domain=\"*\" to-ports=\"*\"/><allow-http-request-headers-from domain=\"*\" headers=\"*\"/><allow-http-request-headers-from domain=\"*\" secure=\"false\"/></cross-domain-policy>"."\0";
				socket_write($socket,$contents);
				$contents="";
				$index = array_search($socket, $read);
				unset($read[$index]);
				socket_shutdown($socket, 2);
				socket_close($socket);
			}

			if (strlen($buffer) == 0)
			{
				$index = array_search($socket, $read);
				unset($read[$index]);

				echo 'Client disconnected!',"\r\n";
				@socket_shutdown($socket, 2);
				@socket_close($socket);
			}
			else
			{
				$pos = strpos($buffer,":");
				if($pos){
					$uname = substr($buffer,0,$pos);
					$msg = substr($buffer,$pos+1,strlen($buffer));
						$pos = strpos($msg,":");
						$ustr = substr($msg,$pos+1,strlen($msg));
						$msg = substr($msg,0,$pos);
						$nodeid = "";
						if($uname == "initNode" || $uname == "initNodeC"){
							$pos = strpos($ustr,":");
							$nodeid = substr($ustr,$pos+1,strlen($ustr));
							$ustr = substr($ustr,0,$pos);
						}
						
					if($uname == "init" || $uname == "initNode" || $uname == "initNodeC"){
						echo " $ustr on this map $msg ";
					//	$msgs = pull_chat($msg);
					//  write all user names cnt:username1:uname2 ***
					$msgs = "";
					$cnt=0;
					$sendNodeInfo=false;
					
							// init handler code
							if(($uname == "initNode" || $uname == "initNodeC") && $nodenames[$msg] ==null ){
							$nodelinknames = array();
							$nodelinknamesATTR = array();		
							if($uname != "initNodeC")
							$nodelinknamesATTR[0] = time();//timestamp
							else
							$nodelinknamesATTR[0] = -1;//timestamp
							
							$nodelinknamesATTR[1] = $ustr;				
							$nodelinknames[$nodeid]= $nodelinknamesATTR;
							$nodenames[$msg] = $nodelinknames;							
							}else if($uname == "init" && $mapunames[$msg]==null){
							$arrayunames = array();
							$arrayunames[$ustr]=time();//timestamp
							$mapunames[$msg] = $arrayunames;
							}
												
					//	socket_write ( $socket , $msgs , strlen($msgs) );
						if($mapclients[$msg]==null)
						{
							$arraysclnts = array($socket);
							$mapclients[$msg] = $arraysclnts;
							$sendNodeInfo=true;							
						}else{
							$arraysclnts = $mapclients[$msg];
							if(!array_search($socket,$arraysclnts)){ 
									$sendNodeInfo=true;							
							
							array_push($arraysclnts, $socket);
							$mapclients[$msg] = $arraysclnts;	
							}
						}			
						
									
							$currtime = time();
					
							if($uname == "initNode" || $uname == "initNodeC"){
							$msgs = "nodeInfo:";
							$nodelinknames = $nodenames[$msg];
							if($nodelinknames[$nodeid]==null || $nodelinknames[$nodeid][1] == $ustr ){
							$nodelinknamesATTR = $nodelinknames[$nodeid];	
							echo "nodelevel";
							if($uname == "initNodeC"){ 
							$nodelinknamesATTR[0] = -1;// delete mode
							}
							else								
							$nodelinknamesATTR[0] = time();//timestamp
							$nodelinknamesATTR[1] = $ustr;				
							$nodelinknames[$nodeid]= $nodelinknamesATTR;
							$nodenames[$msg] = $nodelinknames;	
							}
																				
							$cnt=0;
							foreach ($nodelinknames as $key => $value) {
    									echo $currtime." ";
    									if($value[0] > ($currtime - 200)){
    											$msgs = $msgs.$key.":".$value[1].":";	
    											$cnt++;
    									}else{
    											unset($nodelinknames[$key]);
    									}    																
							}	
							$nodenames[$msg] = $nodelinknames;	
							print_r($nodenames);
							echo "Nodessss";	
							
							}else{
								
							$arrayunames = $mapunames[$msg];
							$arrayunames[$ustr]=$currtime;   //timestamp	
													
							$cnt=0;
							foreach ($arrayunames as $key => $value) {
    								if($key != $ustr){
    									echo $currtime." ";
    									if($value > ($currtime - 60)){
    											$msgs = $msgs.$key.":";	
    											$cnt++;
    									}else{
    											unset($arrayunames[$key]);
    									}
    								}    								
							}	
							$mapunames[$msg] = $arrayunames;	
							print_r($mapunames);					
							}	
						
						
						// retrn string 
						if($uname == "initNode" || $uname == "initNodeC"){
						//$msgs = ":".$msgs;	
						echo $msgs." ------------".$uname;
						socket_write ( $socket , $msgs , strlen($msgs) );
						
						// now write to all other clients connected on this map
						
						$stat = array_key_exists($msg, $mapclients);
						if($stat) {
							$arrclients = $mapclients[$msg];
							foreach ( $arrclients AS $k => $v )
							{
								$index = array_search($v, $read);
								if(!$index)
									unset($arrclients[$k]);
								else if($v!=$socket){
									socket_write($v, $msgs, strlen($msgs));
								}
							}
						}
						
							}else{
						$msgs = $cnt.":".$msgs;	
						echo $msgs." ** ".$uname;
						socket_write ( $socket , $msgs , strlen($msgs) );						
						
						// send extra node info as well
						$msgs = "nodeInfo:";
						$nodelinknames = $nodenames[$msg];
						
						if($sendNodeInfo && $nodelinknames!=null){
						echo $sendNodeInfo." -- ".$nodelinknames;
							foreach ($nodelinknames as $key => $value) {
    									if($value[0] > ($currtime - 200)){
    											$msgs = $msgs.$key.":".$value[1].":";	
    											$cnt++;
    									}else{
    											unset($nodelinknames[$key]);
    									}    																
							}	
							$nodenames[$msg] = $nodelinknames;	
							echo $msgs." ------------";
							usleep(50);
							socket_write ( $socket , $msgs , strlen($msgs) );						
						}
						
						
						}						
					}
				}
			} 
		}
	}

	//echo ".";
	sleep ( 1 );
}
// Close the master sockets
socket_close ( $sock );

function getListofUsrs($msg,$uname,$currtime){
	
	
}

function getUserIdFromUserName($username,$linkID){
		$query = "SELECT * FROM users WHERE username='$username'";
		$resultID = mysql_query($query, $linkID);
		if(!$resultID){
			return -1;
		}
		if((mysql_num_rows($resultID)==0)){
			return -1;
		}
		$row = mysql_fetch_assoc($resultID);
		if($row['is_deleted']){
			return -1;
		}
		$newuser = $row['user_id'];
		return $row['user_id'];
	}



?>
