<html>
	<head><title>Welcome</title>
	<link rel="stylesheet" href="http://localhost/styles/stylesheet.css" type="text/css" />
	</head>
	<body>
		<div id="header"><h1>Electronic Observation - Administration</h1></div>
		<div id="navigation">
			<table>
				<tr>
					<td><a href="../messages">Messages</a></td>
					<td><a href="../observers">Observers</a></td>
					<td><a href="../moderators">Moderators</a></td>
					<td><a href="logout">Logout</a></td>				
					</tr>
			</table>
		</div>
		<h3 style="color: #523165"><?php echo "Welcome " . $this->session->userdata['username'];?></h3>
		<div id="content">
			<div id="map">
			 <?php
		 	
			$link = '<iframe width="500" height="480" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="http://maps.google.com/?ie=UTF8&amp;output=embed&amp;z=12&amp;';
			$link = $link."saddr=$glatitude[0],$glongitude[0]&amp;daddr=$glatitude[1],$glongitude[1]";
			for($i=2;$i<count($glatitude);$i++){
				$link = $link."+to:$glatitude[$i]".","."$glongitude[$i]";
			}
			$link=$link.'"></iframe>';
			echo $link;
		?>
			</div>
			<div id="observerlist">
				<table width=100%>
					<tr style="text-align:center">
						<td><strong>Observer</strong></td>
						<td><strong>Observer ID</strong></td>
						<td><strong>Number</strong></td>
						<!-- <td><strong>Last Message Timestamp</strong></td>
						<td><strong>Approver</strong></td> -->
					</tr>					
					 <?php for($i=0;$i<count($observerlist);$i++) { ?>
					 <tr>
					 	<td><center><?php echo $observerlist[$i]['name'] ?></center></td>
					 	<td><center><?php echo $observerlist[$i]['id']?></center></td>
					 	<td><center><?php echo $observerlist[$i]['number'] ?></center></td>
					 	<!-- <td><?php echo $observer['timestamp'] ?></td>
					 	<td><?php echo $observer['approver'] ?></td> -->					
					</tr>
					<?php } ?>
				</table>			
			</div>			
		</div>
		
		
	</body>
</html>
