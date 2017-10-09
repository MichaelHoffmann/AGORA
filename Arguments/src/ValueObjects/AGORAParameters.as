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
		public var mapPermURL:String;
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
		public var childProjectsURL:String;
		public var chatPushURL:String;
		public var chatPullURL:String;
		public var childMapURL:String;
		public var childProjectURL:String;
		public var mapToPrivateProjURL:String;
		public var pullRegistrationURL:String;
		public var changeInfoURL:String;
		public var projectDetailsURL:String;
		public var listProjMaps:String;
		public var moveMapToProjectURL:String;
		public var projUsersURL:String;
		public var myContributionsURL:String;
		public var moveprojectToProjectURL:String;
		public var delProjURL:String;
		public var forgotpasswordURL:String;
		public var resetpasswordURL:String;
		public var saveMapAsUrl:String;
		public var catChainURL:String;
		public var searchURL:String;
		public var searchShowURL:String;

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
		public var SUPPORT_SAVEANDHOME:String;
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
		public var ARGUMENT_FOR_CLAIM:String;
		public var SUPPORTING_STATEMENT:String;
		public var OBJECTION:String;
		public var DEFEAT_STATEMENT_BY_COUNTER_EXAMPLE:String;
		public var EQUIVALENT_REFORMULATION:String;
		public var FRIENDLY_AMENDMENT:String;
		public var REFERENCE:String;
		public var DISTINCTION:String;
		public var DEFINITION:String;
		public var COMMENT:String;
		public var QUESTION:String;
		public var LINK_TO_ANOTHER_MAP:String;
		public var LINK_TO_RESOURCES:String;
		public var REPLACEMENT:String;
		
		//agreements
		public var REGISTRATION_NOTE:String;
		
		
		public function AGORAParameters()
		{
			var baseURL:String = "http://localhost/~joshua/agora/php/";
			listMapsURL = baseURL + "list_maps.php";
			myMapsURL = baseURL + "my_maps.php";
			loginURL = baseURL + "login.php";
			registrationURL = baseURL + "register.php";
			mapRemoveURL = baseURL + "remove_map.php";
			deleteURL = baseURL + "remove.php";
			insertURL = baseURL + "insert.php";
			loadMapURL = baseURL + "load_map1.php";
			nameUpdateURL = baseURL + "mapinfo.php";
			mapPermURL = baseURL + "mapPermissionsCheck.php";
			projectListURL = baseURL + "list_projects.php";
			myProjectsURL = baseURL + "my_projects.php";
			pushProjectsURL = baseURL + "projects.php";
			joinProjectURL = baseURL + "verifyProject.php";
			loadProjectMapsURL = baseURL + "load_project_maps.php";
			getMapFromProjURL = baseURL + "getMapFromProjID.php";
			publishMapURL = baseURL + "publishMap.php";
			categoryURL= baseURL + "category.php"; //category
			chatPushURL= baseURL + "push_chat.php"; //chat
			chatPullURL= baseURL + "pull_chat.php"; //chat
			childCategoryURL = baseURL + "child_category.php";
			childProjectsURL = baseURL + "child_projects.php";
			childMapURL=baseURL + "map_category.php";
			childProjectURL=baseURL + "project_category.php";
			createMapHereURL = baseURL + "create_map_in_current_category.php";
			mapToPrivateProjURL = baseURL + "map_to_private_project.php";
			pullRegistrationURL = baseURL + "pull_registration_info.php";
			changeInfoURL=baseURL + "changeinfo.php";
			forgotpasswordURL=baseURL + "forgot_pass.php";
			projectDetailsURL = baseURL + "projectdetails.php";
			listProjMaps = baseURL + "listProjectMaps.php";
			moveMapToProjectURL = baseURL + "moveMapToProject.php";
			projUsersURL = baseURL + "projusers.php";
			myContributionsURL = baseURL + "my_contributions.php";
			delProjURL = baseURL + "delProject.php";
			moveprojectToProjectURL = baseURL + "moveProject.php";
			saveMapAsUrl = baseURL + "saveMapAs.php";
			catChainURL = baseURL + "projectHierarchy.php";
			searchURL = baseURL + "agorasearch.php";
			searchShowURL = baseURL + "agorashowsearch.php";

			initialize();		
		}
		
		public function initialize():void{
		
			gridWidth = 25;
			version = "11.9.28";
			reference = this;
			EDIT_OTHER = Language.lookup('EditOther');

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
			SUPPORT_SAVEANDHOME = Language.lookup('SaveAndHomeHelp');
			SUPPORT_SAVEAS = Language.lookup('SaveMapAsHelp');
			ADD_SUPPORTING_STATEMENT = Language.lookup('AddArgument');
			ADD_OBJECTION = Language.lookup('AddObjection');
			ARGUMENT_FOR_CLAIM = Language.lookup('AddArgument');
			SUPPORTING_STATEMENT = Language.lookup('AddSupport');
			OBJECTION = Language.lookup('AddObjection');
			DEFEAT_STATEMENT_BY_COUNTER_EXAMPLE = Language.lookup('AddDefeatStatement');
			EQUIVALENT_REFORMULATION = Language.lookup('AddEqForm');
			FRIENDLY_AMENDMENT = Language.lookup('AddFA');
			REFERENCE = Language.lookup('AddReference');
			DISTINCTION = Language.lookup('AddDistinction');
			DEFINITION = Language.lookup('AddDef');
			COMMENT = Language.lookup('AddComment');
			QUESTION = Language.lookup('AddQ');
			LINK_TO_ANOTHER_MAP = Language.lookup('AddLinkToMap');
			LINK_TO_RESOURCES = Language.lookup('AddLinkToResource');
			REPLACEMENT = Language.lookup('AddReplacement');
		}
		
		public static function getInstance():AGORAParameters{
			if(!reference){
				reference = new AGORAParameters;
			}
			return reference;
		}
	}
}