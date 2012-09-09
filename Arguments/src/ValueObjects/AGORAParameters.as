package ValueObjects
{
	import classes.Language;
	
	[Bindable]
	public class AGORAParameters
	{
		public static var reference:AGORAParameters;
		public var createMapHereURL:String;
		public var listMapsURL:String; 
		public var myMapsURL:String;
		public var loginURL:String;
		public var registrationURL:String;
		public var getProjectsURL:String;
		public var mapRemoveURL:String;
		public var insertURL:String;
		public var loadMapURL:String;
		public var projectListURL:String;
		public var deleteURL:String;
		public var nameUpdateURL:String;
		public var gridWidth:int;
		public var version:String;
		public var myProjectsURL:String;
		public var pushProjectsURL:String;
		public var joinProjectURL:String;
		public var loadProjectMapsURL:String;
		public var getMapFromProjURL:String;
		public var publishMapURL:String;
		public var categoryURL:String;
		public var childCategoryURL:String;
		public var chatPushURL:String;
		public var chatPullURL:String;
		public var childMapURL:String;
		public var mapToPrivateProjURL:String;
		public var pullRegistrationURL:String;
		public var changeInfoURL:String;
		public var projectDetailsURL:String;
		
		
		
		//Error Codes TODO: Enter these in the Languages.xml
		public var ERROR_106:String;
		public var ERROR_103:String;
		
		//TODO: Update these in languages.xml
		public var UPDATE_MAP_INFO_FAILED:String;
		public var REGISTRATION_FAILED_MESSAGE:String;
		
		public var IF:String = Language.lookup("ArgIf");
		public var THEN:String = Language.lookup("ArgThen");
		public var OR:String = Language.lookup("ArgOr");
		public var AND:String = Language.lookup("ArgAnd");
		
		public var THEREFORE:String;	
		
		//Labels
		public var READ_REGISTRATION_NOTE:String;
		public var TOS:String;
		
		//constants
		public var MOD_PON:String = Language.lookup("ModusPonens");;
		public var MOD_TOL:String = Language.lookup("ModusTollens");
		public var COND_SYLL:String = Language.lookup("ConSyl");
		public var DIS_SYLL:String = Language.lookup("DisjunctSyl");
		public var NOT_ALL_SYLL:String = Language.lookup("NotAllSyl");
		
		public var IF_THEN:String = Language.lookup("IfThen");;
		public var IMPLIES:String = Language.lookup("Implies");
		public var WHENEVER:String = Language.lookup("Whenever");
		public var ONLY_IF:String = Language.lookup("OnlyIf");
		public var ONLY_IF_OR:String = Language.lookup("OnlyIf") + Language.lookup("ArgOr");
		public var ONLY_IF_AND:String = Language.lookup("OnlyIf") + Language.lookup("ArgAnd");
		public var PROVIDED_THAT:String = Language.lookup("ProvidedThat");
		public var SUFFICIENT_CONDITION:String = Language.lookup("SufficientCond");
		public var NECESSARY_CONDITION:String = Language.lookup("NecessaryCond");
		
		public const DB_IF_THEN:String = "ifthen";
		public const DB_IMPLIES:String = "implies";
		public const DB_WHENEVER:String = "whenever";
		public const DB_ONLY_IF:String = "onlyif";
		public const DB_PROVIDED_THAT:String = "providedthat";
		public const DB_SUFFICIENT:String = "sufficient";
		public const DB_NECESSARY:String = "necessary";
		
		public const MPIfThen:String = "MPifthen";
		public const MPimplies:String = "MPimplies";
		public const MPwhenever:String = "MPwhenever";
		public const MPonlyif:String = "MPonlyif";
		public const MPprovidedthat:String = "MPprovidedthat";
		public const MPsufficient:String = "MPsufficient";
		public const MPnecessary:String = "MPnecessary";
		public const dbMP:String = "MP";
		public const MTifthen:String = "MTifthen";
		public const MTimplies:String = "MTimplies";
		public const MTwhenever:String = "MTwhenever";
		public const MTonlyif:String = "MTonlyif";
		public const MTonlyifand:String = "MTonlyifand";
		public const MTonlyifor:String = "MTonlyifor";
		public const MTprovidedthat:String = "MTprovidedthat";
		public const MTsufficient:String = "MTsufficient";
		public const MTnecessary:String = "MTnecessary";
		public const dbMT:String = "MT";
		public const DisjSyl:String = "DisjSyl";
		public const dbDisjSyl:String = "DisjSyl";
		public const NotAllSyll:String = "NotAllSyl";
		public const dbNotAllSyll:String = "NotAllSyl";
		public const EQiff:String = "EQiff";
		public const EQnecsuf:String = "EQnecsuf";
		public const EQ:String = "EQ";
		public const CSifthen:String = "CSifthen";
		
		public const CSimplies:String = "CSimplies";
		public const dbCS:String = "CS";
		public const CDaltclaim:String = "CDaltclaim";
		public const CDpropclaim:String = "CDpropclaim";
		public const dbCD:String = "CD";
		public const Unset:String = "Unset";
		
		//prompts
		public var MAP_LOADING_FAILED:String;
		public var STATEMENT_TOGGLE_FAILED:String;
		public var NETWORK_ERROR:String;
		public var EDIT_OTHER:String;
		public var PROMPT_REGISTRATION_INFO:String;
		public var PROMPT_DELETE_SUPPORTED_STATEMENT:String;
		public var PROMPT_MT_ONLY_IF:String;
		public var SUPPORT_SAVEAS:String;
		public var SUPPORT_CREATE_ARGUMENT:String;
		public var SUPPORT_CREATE_PROJECT_PASSWORD:String; // yet to be implemented
		public var SUPPORT_CREATE_PROJECT:String;
		public var SUPPORT_CREATE_ARGUMENT_FROM_CLAIM:String;
		public var SUPPORT_CREATE_ARGUMENT_FROM_ARG_SCHEME:String;
		public var SUPPORT_UNIVERSAL_PARTICULAR:String;	
		public var SUPPORT_AUTHOR_INFORMATION:String;
		public var SUPPORT_CREATE_MAIN_CLAIM:String;
		public var SUPPORT_ADD_REASON:String;
		public var PROMPT_UNIVERSAL_PARTICULAR:String;
		public var SUPPORT_CHANGE_ARG_SCHEME:String;
		public var SUPPORT_EQUIVALENCE:String;
		public var SUPPORT_MP:String;
		public var SUPPORT_MT:String;
		public var SUPPORT_DISSYLL:String;
		public var SUPPORT_NOTALLSYLL:String;
		public var SUPPORT_CD:String;
		public var SUPPORT_CS:String;
		public var SUPPORT_EW:String;
		public var SUPPORT_ARGUMENT_SCHEME_COMPLETED:String;
		public var SUPPORT_ADD_OBJECTION:String;
		public var SUPPORT_SELECT_ARG_SCHEME:String;
		
		//labels
		public var DONE:String;
		public var NOTE:String;
		public var OK:String;
		public var SAVE_AND_HOME:String;
		public var SAVE_AS: String;
		public var ADD_SUPPORTING_STATEMENT:String;
		public var ADD_OBJECTION:String;
		
		//agreements
		public var REGISTRATION_NOTE:String;
		
		
		public function AGORAParameters()
		{
			
			listMapsURL = "http://agora.gatech.edu/release/list_maps.php";
			myMapsURL = "http://agora.gatech.edu/release/my_maps.php";
			loginURL = "http://agora.gatech.edu/release/login.php";
			registrationURL = "http://agora.gatech.edu/release/register.php";
			mapRemoveURL = "http://agora.gatech.edu/release/remove_map.php";
			deleteURL = "http://agora.gatech.edu/release/remove.php";
			insertURL = "http://agora.gatech.edu/release/insert.php";
			loadMapURL = "http://agora.gatech.edu/release/load_map1.php";
			nameUpdateURL = "http://agora.gatech.edu/release/mapinfo.php";
			projectListURL = "http://agora.gatech.edu/release/list_projects.php";
			myProjectsURL = "http://agora.gatech.edu/release/my_projects.php";
			pushProjectsURL = "http://agora.gatech.edu/release/projects.php";
			joinProjectURL = "http://agora.gatech.edu/release/verifyProject.php";
			loadProjectMapsURL = "http://agora.gatech.edu/release/load_project_maps.php";
			getMapFromProjURL = "http://agora.gatech.edu/release/getMapFromProjID.php";
			publishMapURL = "http://agora.gatech.edu/release/publishMap.php";
			categoryURL= "http://agora.gatech.edu/release/category.php"; //category
			chatPushURL= "http://agora.gatech.edu/release/push_chat.php"; //chat
			chatPullURL= "http://agora.gatech.edu/release/pull_chat.php"; //chat
			childCategoryURL = "http://agora.gatech.edu/release/child_category.php";
			childMapURL="http://agora.gatech.edu/release/map_category.php";
			createMapHereURL = "http://agora.gatech.edu/release/create_map_in_current_category.php";
			mapToPrivateProjURL = "http://agora.gatech.edu/release/map_to_private_project.php";
			pullRegistrationURL = "http://agora.gatech.edu/release/pull_registration_info.php";
			changeInfoURL="http://agora.gatech.edu/release/changeinfo.php";
			projectDetailsURL = "http://agora.gatech.edu/release/projectdetails.php";

			initialize();		
		}
		
		public function initialize():void{
		
			gridWidth = 25;
			version = "11.9.28";
			reference = this;
			
			PROMPT_MT_ONLY_IF = Language.lookup('SelectLanguageForm');
			THEREFORE = Language.lookup('Therefore');
			SUPPORT_SELECT_ARG_SCHEME = Language.lookup('InterArgScheme');
			DONE = Language.lookup('Done');
			ERROR_106 = Language.lookup('Error106');
			ERROR_103 = Language.lookup('Error103');
			UPDATE_MAP_INFO_FAILED = Language.lookup('UpdateMapInfoFailed');
			REGISTRATION_FAILED_MESSAGE = Language.lookup('RegistrationFailed');
			REGISTRATION_NOTE = Language.lookup('RegistrationNote');
			READ_REGISTRATION_NOTE = Language.lookup('ReadRegistrationNote');
			TOS = Language.lookup('TermsOfService');
			NOTE = Language.lookup('Note');
			OK = Language.lookup('OK');
			SAVE_AND_HOME = Language.lookup('SaveAndHome');
			SAVE_AS = Language.lookup('SaveMapAs');
			ADD_SUPPORTING_STATEMENT = Language.lookup('AddArgument');
			ADD_OBJECTION = Language.lookup('AddObjection');
		}
		
		public static function getInstance():AGORAParameters{
			if(!reference){
				reference = new AGORAParameters;
			}
			return reference;
		}
	}
}