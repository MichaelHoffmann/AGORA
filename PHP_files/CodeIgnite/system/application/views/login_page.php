<html>
	<head>
		<title>Login</title>
		
	
		<div id="header"><h1>Election Observation - Administrator Login</h1></div>
		<h2><?php echo $info ?></h2>
		<h3>Please log in with your username and password to continue</h3>
		<?php
			$this->load->helper('form');
			
			echo form_open('login/authenticate');
			
			$username_input=array('name' => 'username','id' => 'username');
			$password_input=array('name'=>'password','id'=> 'password');
		?>
		<div id="form">
		<table>
			<tr>
				<td>Username</td>
				<td><?php echo form_input($username_input); ?></td>
			</tr>
			<tr>
				<td>Password</td>
				<td><?php echo form_password($password_input);?></td>
			</tr>
			<tr>
				<td><?php echo form_submit('Login','Login');?></td>
			</tr>
		</table>
		</div>
		<?php				
			echo form_close();
		?>
	</body>
</html>
	
			