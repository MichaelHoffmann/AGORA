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
		public var insertURL:String;
		public var loadMapURL:String;
		
		public var gridWidth:int;
		
		//prompts
		public var MAP_LOADING_FAILED:String;
		public var STATEMENT_TOGGLE_FAILED:String;
		public var NETWORK_ERROR:String;
	
		
		public function AGORAParameters()
		{
			listMapsURL = "http://agora.gatech.edu/dev/list_maps.php";
			myMapsURL = "http://agora.gatech.edu/dev/my_maps.php";
			loginURL = "http://agora.gatech.edu/dev/login.php";
			registrationURL = "http://agora.gatech.edu/dev/register.php";
			mapRemoveURL = "http://agora.gatech.edu/dev/remove_map.php";
			insertURL = "http://agora.gatech.edu/dev/insert.php";
			loadMapURL = "http://agora.gatech.edu/dev/load_map.php";
			
			MAP_LOADING_FAILED = "Error occured when loading map";
			STATEMENT_TOGGLE_FAILED = "Error occurred when trying to toggle the type of statement";
			NETWORK_ERROR = "Unable to reach server. Please check your Internet connection...";
			
			
			gridWidth = 25;
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