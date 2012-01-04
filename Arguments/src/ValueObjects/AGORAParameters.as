package ValueObjects
{
	import classes.Language;

	[Bindable]
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
		public var deleteURL:String;
		public var nameUpdateURL:String;
		public var gridWidth:int;
		public var version:String;
		
		
		
		//Error Codes TODO: Enter these in the Languages.xml
		public var ERROR_106:String;
		public var ERROR_103:String;
		
		//TODO: Update these in languages.xml
		public var UPDATE_MAP_INFO_FAILED:String;
		public var REGISTRATION_FAILED_MESSAGE:String;
		
		public var IF:String = "If";
		public var THEN:String = "then";
		public var OR:String = "or";
		public var AND:String = "and";
		
		public var THEREFORE:String;	
		
		//Labels
		public var READ_REGISTRATION_NOTE:String;
		
		//constants
		public var MOD_PON:String = "Modus Ponens";
		public var MOD_TOL:String = "Modus Tollens";
		public var COND_SYLL:String = "Conditional Syllogism";
		public var DIS_SYLL:String = "Disjunctive Syllogism";
		public var NOT_ALL_SYLL:String = "Not-All Syllogism";
		public var CONST_DILEM:String = "Constructive Dilemma";
		
		public var IF_THEN:String = "If-then";
		public var IMPLIES:String = "Implies";
		public var WHENEVER:String = "Whenever";
		public var ONLY_IF:String = "Only if";
		public var ONLY_IF_OR:String = "OnlyIfOR";
		public var ONLY_IF_AND:String = "OnlyIfAnd";
		public var PROVIDED_THAT:String = "Provided that";
		public var SUFFICIENT_CONDITION:String = "Sufficient condition";
		public var NECESSARY_CONDITION:String = "Necessary Condition";
		
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
			loadMapURL = "http://agora.gatech.edu/release/load_map.php";
			nameUpdateURL = "http://agora.gatech.edu/release/mapinfo.php";
			
			initialize();		
		}
		
		public function initialize():void{
			MAP_LOADING_FAILED = "Error occured when loading map";
			STATEMENT_TOGGLE_FAILED = "Error occurred when trying to toggle the type of statement";
			NETWORK_ERROR = "Unable to reach server. Please check your Internet connection...";
			EDIT_OTHER = "You do not have the permission to edit statements created by other users";
			
			gridWidth = 25;
			version = "11.9.28";
			reference = this;
			
			PROMPT_DELETE_SUPPORTED_STATEMENT = "Do you really want to delete this box and everything that leads to it? Yes / No";
			PROMPT_REGISTRATION_INFO = "NOTE: Registration is required in order to differentiate between people who participate in debates or collaborations. Every textbox in the AGORA argument maps will show the username of the author because it must be clear who claims what. Additionally, the following information will become visible by hovering over the username: first name; last name; URL (if provided). Later, we plan to add a function \"Send e-mail to [username]\" which will also be accessible by moving the mouse over the username. This function is useful because certain operations such as deleting a textbox or changing its content can only be performed by the creator of this box. +\n Your e-mail address will never be given out publicly. It will be used only for this contact-function and for the AGORA system to provide you with a replacement password in the event you forget your current one. \nPlease read the Privacy Policy which is accessible here.";
			SUPPORT_SAVEAS = "When you save this map under a new name, a copy of the map will be produced in which every statement is assigned to you as the author of this statement, even if the map has been produced in collaboration or by other people. This way you acquire all the permissions necessary to change whatever you want. If you don\'t change a statement, the name of the original author will pop when the mouse is moved over \'AU\' (for \'author\').";
			SUPPORT_CREATE_ARGUMENT = "Your selection will create a logically (deductively) valid argument, meaning that your conclusion is necessarily true if all your premises are true. The validity of your argument is guaranteed by the fact that you can only select one of those traditional argument forms that are logically valid, and by the fact that the software automatically creates an additional premise that makes your argument valid. This additional premise is called the \"enabler\" of your argument. If this automatically created enabler does not seem right to you, change the formulation of your reason and/or your claim, or the argument scheme, until the formulation fits and you can accept the truth of the enabler and all your reasons.";
			SUPPORT_CREATE_PROJECT_PASSWORD  = "Create a project password, different from your user password (required)";
			SUPPORT_CREATE_PROJECT = "Only the name of your project will be publicly visible. But everyone can request access to your project. In this case, the AGORA system will send an automatically created e-mail to you. This e-mail will contain the user name and e-mail address of this person so that you can decide whether you want to provide the access data to this person or not.";
			SUPPORT_CREATE_ARGUMENT_FROM_CLAIM = "The easiest way to construct an argument";
			SUPPORT_CREATE_ARGUMENT_FROM_ARG_SCHEME = "Choose this option if you want to use a scheme that is not available otherwise or to learn more about how argument schemes work (play around and see what happens)";
			SUPPORT_UNIVERSAL_PARTICULAR = "“Universal statement” is defined as a statement that can be falsified by one counterexample. Thus, laws, rules, and all statements that include “ought,” “should,” or other forms indicating normativity, are universal statements. Anything else is treated as a \"particular statement,\" including statements about possibilities.";
			SUPPORT_AUTHOR_INFORMATION = "“Universal statement” is defined as a statement that can be falsified by one counterexample. Thus, laws, rules, and all statements that include “ought,” “should,” or other forms indicating normativity, are universal statements. Anything else is treated as a \"particular statement,\" including statements about possibilities.";
			SUPPORT_CREATE_MAIN_CLAIM = "Keep in mind that a claim can be descriptive (“it is the case that …”) or normative (e.g., “we should do x”)";
			SUPPORT_ADD_REASON = "Add another reason if only the combination of two or more \"linked reasons\” can support your conclusion." +
				"For example, in the argument \"Peter's tomatoes will grow because he waters them regularly and they get enough sun light,\" both the reasons \"he waters them regularly\" and \"they get enough sun light\" need to be true to infer the conclusion. It is important to distinguish whether you need a combination of linked reasons to get to your conclusion or whether you have several independent reasons for the same conclusion.";
			PROMPT_UNIVERSAL_PARTICULAR = "Determine whether this\nstatement is a\n--particular statement\n--universal statement";
			SUPPORT_CHANGE_ARG_SCHEME = "Click to change your argument scheme";
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