<html>
	<head><title>Login</title></head>
	<body>
		<h3>Please log in with your username and password to continue</h3>
		<?php
			$this->load->helper('form');
			
			echo form_open('login');
			
			$username_input=array('name' => 'username','id' => 'username');
			$password_input=array('name'=>'password','id'=> 'password');
		
			echo form_input($username_input);
			echo form_password($username_password);
			
			echo form_submit('Login','Login');
			echo form_close();
		?>
	</body>
</html>
	
			