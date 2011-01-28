<html>
	<head><title>Messages</title>

	<link rel="stylesheet" href="http://localhost/styles/stylesheet.css" />
	</head>
	<body>
	<h1 id="header">Messages</h1>
	<div id="navigation">
			<table>
				<tr>
					<td><a href="#">Messages</a></td>
					<td><a href="observers">Observers</a></td>
					<td><a href="moderators">Moderators</a></td>
					<td><a href="admin/logout">Logout</a></td>				
					</tr>
			</table>
		</div>
		<h3 style="color: #523165"><?php echo "Welcome " . $this->session->userdata['username'];?></h3>
		<h4><?php echo $message; ?></h4>		
		<div id="content">	
		<div id="map">
		<?php
			if(empty($refresh)){
				$refresh="on";
			}
			if($refresh=="on"){
				echo "<h3>Auto Refresh is On</h3>";
		?>
		<meta http-equiv="refresh" content=5 />
		<?php
		}
		else{
			echo "<h3>Auto refresh is off</h3>";
		}
		?>	
		<table>
			<tr><td>		
		</table>
		 <?php
		 	
			$link = '<iframe width="500" height="480" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="http://maps.google.com/?ie=UTF8&amp;output=embed&amp;z=12&amp;';
			if(isset($glatitude[0])){			
				$link = $link."saddr=$glatitude[0],$glongitude[0]&amp";
				$link=$link.'"></iframe>';
				echo $link;
			}
		?>
			</td>
			<td>
			<?php
				$link = '<iframe width="500" height="480" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="http://maps.google.com/?ie=UTF8&amp;output=embed&amp;z=12&amp;';
				if(isset($glatitude[1])){			
					$link = $link."daddr=$glatitude[1],$glongitude[1]";
					$link=$link.'"></iframe>';
					echo $link;
				}
			?>
			</td>
			</tr>
			</table>
		</div>
		<br />
		<br />
		<div id="form">
			<?php
					$this->load->helper('form');
					echo form_open('messages/sortbyobservers');
			?>
				<table>
					<tr>
						<td>
							<strong>Observer ID:</strong>	
						</td>
						<td><input type="text" name="observer_id" /></td>
						<td><input type="submit" value="Sort By Observer ID" /></td>
					</tr>
				</table>
			</form>		
			<?php				

				echo form_open('messages/set_refresh');
			?> 
					<input type="radio" name="refresh" value="on" />Refresh On
					<br />
					<input type="radio" name="refresh" value="off" />Refresh Off
					<br />
					<input type="submit" value="Set" />				
				</form>
							
			
		</div>		
			<div id="observerlist">
				<table width=100% border=6>
					<tr style="text-align:center">
						<td width=5%><strong>Response ID</strong></td>
						<td width=10%><strong>Category</strong></td>						
						<td width=35%><strong>Question</strong></td>
						<td width=35%><strong>Response</strong></td>
						<td width=5%><strong>Observer</strong></td>
						
					</tr>	
						
 					<?php
 						if(isset($messages)){
 						
	 						for($i=0;$i<count($messages);$i++){
 						?>
 							<tr style="text-align:center">
								<td width=5%><?php echo $responseid[$i]; ?></td>
								<td><?php echo $category[$i]; ?></td>
								<td width=25%><?php echo $question[$i]; ?></td>
								<td width=25%><?php echo $answer[$i]; ?></td>
								<td width=35%><?php echo $observer[$i]; ?></td>
								<!-- <td><?php echo $approver[$i] ?></td>
								<td><?php echo $timestamp[$i] ?></td>
								<td width=10%><?php echo $latitude[$i].",".$longitude[$i] ?></td> --> 	
							</tr>
					<?php
							}
						}
					?>
 				</div>
 		
 		</div>
 	</body>
 </html>
