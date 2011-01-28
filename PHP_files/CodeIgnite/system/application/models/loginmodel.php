<?php

class LoginModel extends Model {
	function LoginModel(){
		parent::Model();
		$this->load->database();
	}
	
	function verifyLogin($username,$password){
		$npassword = sha1($password);
		$sql="select first_name,last_name,id from users where user_id=\"$username\" and password=\"$npassword\"";
		$query = $this->db->query($sql);
		return $query->row();
			
	}
}
