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
		public static const FORGOT_PASSWORD_SEARCHUSER:String = "ForgotPasswordSearchUser";
		public static const FORGOT_PASSWORD_SECQUESTION:String = "ForgotPasswordSecQ";
		public static const FORGOT_PASSWORD_SEARCHUSERERROR:String = "ForgotPasswordSearchUserError";
		public static const FORGOT_PASSWORD_SECQERROR:String = "ForgotPasswordSecQError";
		public static const FORGOT_PASSWORD_TICKETVALID:String = "ResetPasswordTicketValid";
		public static const FORGOT_PASSWORD_TICKETINVALID:String = "ResetPasswordTicketInValid";
		public static const MAPS_DELETED:String = "MapsDeleted";
		public static const MAPS_DELETION_FAILED:String = "MapsDeletionFailed";
		public static const SINGNED_OUT:String = "SignedOut";
		public static const LOGIN_STATUS_SET:String = "LogInStatus";
		public static const MAP_CREATED:String = "MapCreated";
		public static const MAP_SAVEDAS:String = "MapSavedAS";
		public static const MAP_SAVEDASFAULT:String = "MapSavedASFault";
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
		public static const PROJECT_LIST_FETCHED:String = "ProjectListFetched";
		public static const PROJECT_PUSHED:String = "ProjectPushed";
		public static const PROJECT_PUSH_FAILED:String = "ProjectPushedFailed";
		public static const PROJECTS_LIST_FETCHED:String = "ProjectsListFetched";
		public static const CATEGORY_FETCHED:String = "CategoryFetched";
		public static const CHAT_FETCHED:String = "ChatFetched";
		public static const CHAT_PUSHED:String = "ChatPushed";
		public static const MAP_FETCHED:String ="MapFetched";
		public static const CONTRIBUTIONS_FETCHED:String = "ContributionsFetched";
		public static const CHILD_PROJECT_FETCHED:String = "ChildprojectFetched";
		public static const CHILD_MAP_FETCHED:String = "ChildMapFetched";
		public static const PROJECT_USER_VERIFIED:String = "ProjectJoined";
		public static const MAP_ADDED:String = "MapAdded";
		public static const PROJECT_MOVED:String = "ProjectMoved";
		public static const CATEGORY_FETCHED_FOR_PUBLISH:String = "CategoryFetchedForPublish";
		public static const CATEGORY_FETCHED_FOR_MOVEPROJECT:String = "CategoryFetchedForMoveProject";
		public static const MAP_PUBLISHED:String = "MapPublished";
		public static const PROJECT_PUBLISHED:String = "ProjectPublished";
		public static const REGISTRATION_DATA_GOTTEN:String = "RegistrationDataGotten";
		public static const ADD_USERS_FAILED:String = "AddUsersFailed";
		public static const ADDED_USERS:String = "AddedUsers";
		public static const REMOVE_USERS_FAILED:String = "RemoveUsersFailed";
		public static const REMOVED_USERS:String = "RemovedUsers";
		public static const PROJECT_FETCHED:String = "ProjectFetched";
		public static const EDIT_PROJECT_FAILED:String = "EditProjectFailed";
		public static const EDITED_PROJECT:String = "EditedProject";
		public static const ADMIN_CHANGE_FAILED:String = "AdminChangeFailed";
		public static const ADMIN_CHANGED:String = "AdminChanged";
		public static const DELETE_PROJECT_FAILED:String = "DeleteProjectFailed";
		public static const DELETED_PROJECT:String = "DeletedProject";
		public static const PROJECTS_DETAILS ="ProjDetails";
		public static const PROJECTS_SUB_DETAILS="UpdateSubs";
		public static const PROJECTS_MAP_DETAILS="UpdateMaps "
		public static const PROJECTS_USER_DETAILS="UpdateUsers "
		public static const GET_CHAIN_FAILED="ChainFailed";
		public static const CHAIN_LOADED="ChainLoaded";

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