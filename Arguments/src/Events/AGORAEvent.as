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
		public static const LOGIN_STATUS_SET:String = "LogInStatus";
		public static const MAP_CREATED:String = "MapCreated";
		public static const ARGUMENT_CREATION_FAILED:String = "ArgumentCreationFailed";
		public static const MAP_CREATION_FAILED:String = "MapCreationFailed";
		public static const FIRST_CLAIM_ADDED:String = "FirstClaimAdded";
		public static const FIRST_CLAIM_FAILED:String = "FirstClaimFailed";
		public static const MAP_LOADED:String = "MapLoaded";
		public static const MAP_LOADING_FAILED:String = "MapLoadingFailed";
		public static const STATEMENT_TYPE_TOGGLED:String = "StatementTypeToggled";
		public static const STATEMENT_TYPE_TOGGLE_FAILED:String = "StatementTypeToggleFailed";
		public static const POSITIONS_UPDATED:String = "PositionsUpdated";
		public static const TEXT_SAVED:String = "TextSaved";
		public static const STATEMENT_ADDED:String = "StatementAdded";
		public static const ARGUMENT_CREATED:String = "ArgumentCreated";
		public static const STATEMENT_STATE_TO_EDIT:String = "StatementStateToEdit";
		public static const REASON_ADDED:String = "ReasonAdded";
		public static const ARGUMENT_TYPE_ADDED:String = "ArgumentTypeAdded";
		public static const ARGUMENT_SCHEME_SET:String = "ArgumentSchemeSet";
		public static const ARGUMENT_SAVED:String = "ArgumentSaved"; //dispatched when an argument scheme is set.
		public static const ARGUMENT_SAVE_FAILED:String = "ArgumentSaveFailed";//dispatched when selecting an argument scheme fails.
		public static const STATEMENTS_DELETED:String = "StatementsDeleted";
		public static const REASON_ADDITION_NOT_ALLOWED:String = "ReasonAdditionNotAllowed";
		public static const MAP_INFO_UPDATED:String = "MapInfoUpdated";
		public static const MAP_INFO_UPDATE_FAILED:String = "MapInfoUpdateFailed";
		public static const CREATING_OBJECTION_FAILED:String = "CreatingObjectionsFailed";
		public static const OBJECTION_CREATED:String = "ObjectionCreated";
		public static const UNLINK_SCHEME:String = "UnlinkScheme";
		public static const ARGUMENT_DELETED:String = "ArgumentDeleted";
		//ERROR EVENTS
		public static const ILLEGAL_MAP:String = "IllegalMap";
		
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