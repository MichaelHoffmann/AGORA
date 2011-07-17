package ValueObjects
{
	public class AGORAParameters
	{
		public static var reference:AGORAParameters;
		public var listMapsURL:String; 
		public var myMapsURL:String;
		public var loginURL:String;
		public var registrationURL:String;
		public var mapRemoveURL:String;
	
		
		public function AGORAParameters()
		{
			listMapsURL = "http://agora.gatech.edu/dev/list_maps.php";
			myMapsURL = "http://agora.gatech.edu/dev/my_maps.php";
			loginURL = "http://agora.gatech.edu/dev/login.php";
			registrationURL = "http://agora.gatech.edu/dev/register.php";
			mapRemoveURL = "http://agora.gatech.edu/dev/remove_map.php";
			
			reference = this;
		}
		
		public static function getInstance():AGORAParameters{
			if(!reference){
				reference = new AGORAParameters;
			}
			return reference;
		}
	}
}