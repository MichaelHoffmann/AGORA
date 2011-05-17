package classes
{
	import components.LoginWindow;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.controls.Alert;

	public class UserData
	{
		public static var userNameStr:String ="";
		public static var _passHashStr:String="";
		public static var valid:int = 0;;
	    private static var _uid:int = 0;
		public static var timestamp:String="";
		
		public function UserData()
		{
		}
		public static function set passHashStr(value:String):void
		{
			_passHashStr = value;
		}
		public static function get passHashStr(): String
		{
			return _passHashStr;
		}
		public static function get uid():int
		{
			return _uid;	
		}
		
		private static function verifyUser(event:Event, object:LoginWindow):void
		{
			var xml:XML = XML(event.target.data);
			if(xml.@ID.length() == 1)
			{
				_uid = xml.@ID[0];
			}
			else
			{
				userNameStr = "";
			}
			object.verifyLogin();
		}
		
		public static function isValid():Boolean
		{
			if(_uid != 0)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public static function validateUser(userName:String, passHash:String, object:LoginWindow):void
		{
			userNameStr = userName;
			var urlLoader:URLLoader = new URLLoader;
			var request:URLRequest = new URLRequest;
			request.url = "http://agora.gatech.edu/dev/login.php";
			request.data = new URLVariables("username="+userName+"&pass_hash="+passHash);
			request.method = URLRequestMethod.GET;
			urlLoader.addEventListener(Event.COMPLETE,function(event:Event):void{verifyUser(event,object)});
			urlLoader.load(request);
		}
		
		
	}
}