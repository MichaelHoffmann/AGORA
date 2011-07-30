package Events
{
	import flash.events.Event;
	
	public class AGORAEvent extends Event
	{
		static public  const FAULT:String = "Fault";
		static public const MAP_LIST_FETCHED:String = "MapListFetched";
		static public const MY_MAPS_LIST_FETCHED:String = "MyMapsListFetched";
		public static const AUTHENTICATED:String = "Authenticated";
		public static const USER_INVALID:String = "UserInvalid";
		public static const REGISTRATION_SUCCEEDED:String = "RegistrationSucceeded";
		public static const REGISTRATION_FAILED:String = "RegistrationFailed";
		public static const MAPS_DELETED:String = "MapsDeleted";
		public static const MAPS_DELETION_FAILED:String = "MapsDeletionFailed";
		public static const APP_STATE_SET:String = "AppStateSet";
		public static const SINGNED_OUT:String = "SignedOut";
		public static  const LOGIN_STATUS_SET:String = "LogInStatus";
		public static const MAP_CREATED:String = "MapCreated";
		public static const MAP_CREATION_FAILED:String = "MapCreationFailed";
		public static const FIRST_CLAIM_ADDED:String = "FirstClaimAdded";
		public static const MAP_LOADED:String = "MapLoaded";
		public static const MAP_LOADING_FAILED:String = "MapLoadingFailed";
		
		public var xmlData:XML;
		public var eventData:Object;
		
		public function AGORAEvent(type:String, xmlData:XML=null, eventData:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.xmlData = xmlData;
			this.eventData = eventData;	
		}
	}
}