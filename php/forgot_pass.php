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
/**
*	Function for emailing users who forget their password.
*/

class Cipher {
	private $securekey, $iv;
	function __construct($textkey) {
		$this->securekey = hash('sha256', $textkey, TRUE);
		$this->iv = mcrypt_create_iv(32);
	}
	function encrypt($input) {
		return base64_encode(mcrypt_encrypt(MCRYPT_RIJNDAEL_256, $this->securekey, $input, MCRYPT_MODE_ECB, $this->iv));
	}
	function decrypt($input) {
		return trim(mcrypt_decrypt(MCRYPT_RIJNDAEL_256, $this->securekey, base64_decode($input), MCRYPT_MODE_ECB, $this->iv));
	}
}

function getLastInsert($linkID) {
	$query = "SELECT LAST_INSERT_ID()";
	$resultID = mysql_query($query, $linkID);
	$row = mysql_fetch_assoc($resultID);
	return $row['LAST_INSERT_ID()'];
}

function forgot_pass($username) {
	global $dbName, $version;
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0' ?>\n<AGORA version='$version'/>\n";
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
	$query = "SELECT * FROM users WHERE username='$username'";
	$resultID = mysql_query($query, $linkID);
	if (!$resultID) {
		dataNotFound($output, $query);
		return $output;
	}
	$row = mysql_fetch_assoc($resultID);
	$uid = $row['user_id'];
	$secQstn = $row['securityQNum'];

	if (!$uid) {
		nonexistent($output, $query);
		return $output;
	}

	if ($secQstn == null || $secQstn == "") {
		nonexistentSecQs($output);
		return $output;
	}
	$email = $row['email'];
	$status = $output->addChild("success");
	$status->addAttribute("userId", $uid);
	$status->addAttribute("securityQNum", $secQstn);
	return $output;
}

function reset_passwordLink($username, $secanswer) {
	global $dbName, $version, $serverurlpath;
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0' ?>\n<AGORA version='$version'/>\n";
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
	$query = "SELECT * FROM users WHERE username='$username'";
	$resultID = mysql_query($query, $linkID);
	if (!$resultID) {
		dataNotFound($output, $query);
		return $output;
	}
	$row = mysql_fetch_assoc($resultID);
	$uid = $row['user_id'];
	$secQstn = $row['securityQNum'];
	$secAnswer = $row['securityQAnswer'];
	$email = $row['email'];

	if (!$uid) {
		nonexistent($output, $query);
		return $output;
	}

	if ($secQstn == null || $secQstn == "") {
		nonexistentSecQs($output, $query);
		return $output;
	}

	if ($secanswer != $secAnswer) {
		nonmatchSecQs($output, $query);
		return $output;
	}
	// username-Uid // ticket // Time //
	$query = "INSERT INTO password_requests (user_id,time_request) VALUES ($uid,NOW())";
	mysql_query($query, $linkID);
	$reqId = getLastInsert($linkID);

	$cipher = new Cipher('a1g6o9r13a01'); // cipher used for encryption .. 
	$urlParam = $username . ":" . $uid . ":" . $reqId;
	$encryptedtext = $cipher->encrypt($urlParam);
	error_log("->encrypt = $encryptedtext<br />");
	/*$decryptedtext = $cipher->decrypt($encryptedtext);
	error_log("->decrypt = $decryptedtext<br />");*/

	$message = wordwrap("Your password reset link for the AGORA system is: $serverurlpath" . "resetPassword.html?resetticket=" . urlencode($encryptedtext), 70);
	error_log("->encrypt = $message<br />");
	$headers = 'From: webmaster@agora.gatech.edu' . "\r\n" .
	'Reply-To: webmaster@agora.gatech.edu' . "\r\n" .
	'X-Mailer: PHP/' . phpversion();
	try {
		mail($email, 'AGORA password reset link', $message, $headers);
	} catch (Exception $e) {
		mailSendFailed($output);
	}
	$status = $output->addChild("success");
	return $output;

}

function checkTicket($ticket) {
	global $dbName, $version, $serverurlpath;
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0' ?>\n<AGORA version='$version'/>\n";
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

	$cipher = new Cipher('a1g6o9r13a01'); // cipher used for encryption .. 
	$decryptedtext = $cipher->decrypt($ticket);
	error_log("->decrypt = $decryptedtext");

	$params = explode(":", $decryptedtext);

	if (count($params)!=3) {
		nonmatchTicket($output);
		return $output;	
	}
		// check for valid entries ..
	$username = $params[0];
	$uid = $params[1];
	$ticketid = $params[2];
	$query = "SELECT * FROM password_requests WHERE user_id=$uid and pr_id=$ticketid";
	$resultID = mysql_query($query, $linkID);

	$row = mysql_fetch_assoc($resultID);
	$uid = $row['pr_id'];
	if (!$uid) {
		nonmatchTicket($output);
		return $output;	
	}	

	// return	
	$status = $output->addChild("success");
	$status->addAttribute("username",$username);
	return $output;

}

function savePassword($ticket,$newpwd) {
	global $dbName, $version;
	header("Content-type: text/xml");
	$xmlstr = "<?xml version='1.0' ?>\n<AGORA version='$version'/>\n";
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
	
	$cipher = new Cipher('a1g6o9r13a01'); // cipher used for encryption .. 
	$decryptedtext = $cipher->decrypt($ticket);
	error_log("->decrypt = $decryptedtext");
	$params = explode(":", $decryptedtext);
	if (count($params)!=3) {
		nonmatchTicket($output);
		return $output;	
	}
	// check for valid entries ..
	$username = $params[0];
	$uid = $params[1];
	$ticketid = $params[2];
	$query = "SELECT * FROM password_requests WHERE user_id=$uid and pr_id=$ticketid";
	$resultID = mysql_query($query, $linkID);

	$row = mysql_fetch_assoc($resultID);
	$uid = $row['pr_id'];
	if (!$uid) {
		nonmatchTicket($output);
		return $output;	
	}	

	$query = "SELECT * FROM users WHERE username='$username'";
	$resultID = mysql_query($query, $linkID);
	$row = mysql_fetch_assoc($resultID);
	$uid = $row['user_id'];
	if (!$uid) {
		nonexistent($output, $query);
		return $output;
	}
	$email = $row['email'];
	$status = $output->addChild("userId");
	$status->addAttribute("userId", $uid);

	//Salt the password:
	//$salted_pass = $password . "AGORA";
	//$hashed_pass = mysql_real_escape_string(md5($salted_pass));
	$uquery = "UPDATE users SET password='$newpwd' WHERE user_id = $uid";
	$qxml = $output->addChild("query");
	$qxml->addAttribute("text", "$uquery");
	$resultID = mysql_query($uquery, $linkID);
	if (!$resultID) {
		updateFailed($output, $uquery);
		return $output;
	}
	$message = wordwrap("Your password was changed for AGORA System.", 70);
	$headers = 'From: webmaster@agora.gatech.edu' . "\r\n" .
	'Reply-To: webmaster@agora.gatech.edu' . "\r\n" .
	'X-Mailer: PHP/' . phpversion();
	try {
		mail($email, 'AGORA forgotten password update', $message, $headers);
	} catch (Exception $e) {
		mailSendFailed($output);
	}
return $output;
}

$action = mysql_real_escape_string($_REQUEST['action']);
if ($action == "searchuser") {
	$username = mysql_real_escape_string($_REQUEST['username']); //TODO: Change this back to a GET when all testing is done.
	$output = forgot_pass($username);
}
elseif ($action == "resetPasswordLink") {
	$username = mysql_real_escape_string($_REQUEST['username']); //TODO: Change this back to a GET when all testing is done.
	$secanswer = mysql_real_escape_string($_REQUEST['secanswer']); //TODO: Change this back to a GET when all testing is done.
	//$secqstn = mysql_real_escape_string($_REQUEST['secqstn']); //TODO: Change this back to a GET when all testing is done.
	$output = reset_passwordLink($username, $secanswer);
}
elseif ($action == "checkticket") {
	$ticket = urldecode($_REQUEST['ticket']); //TODO: Change this back to a GET when all testing is done.
	$output = checkTicket($ticket);
}else if($action == "savepwd"){
	$ticket = urldecode($_REQUEST['ticket']); //TODO: Change this back to a GET when all testing is done.
	$newpwd = mysql_real_escape_string($_REQUEST['newpwd']);
	$output = savePassword($ticket,$newpwd);
}

print $output->asXML();
?>