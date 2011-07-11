package Events
{
	import flash.events.Event;
	
	public class NetworkEvent extends Event
	{
		static public  const FAULT:String = "Fault";
		static public const MAP_LIST_FETCHED:String = "Map Loaded";
		public static const AUTHENTICATED:String = "Authenticated";
		public static const USER_INVALID:String = "User Invalid";
		public static const REGISTRATION_SUCCEEDED:String = "Registration Succeeded";
		public static const REGISTRATION_FAILED:String = "Registration Failed";
		
		public function NetworkEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}