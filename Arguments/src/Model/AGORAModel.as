package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	import ValueObjects.ArgumentScheme;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;

	public class AGORAModel extends EventDispatcher
	{
		private static var reference:AGORAModel;
		
		private var _language:String;
		public var schemeAndLanguage:Dictionary;
		public var dbSchemeHashMap:Dictionary;
		public var dbLanguageHashMap:Dictionary;
		public var mapListModel:MapListModel;
		public var myMapsModel:MyMapsModel;
		[Bindable]
		public var userSessionModel:UserSessionModel;
		public var agoraMapModel:AGORAMapModel;
		public var projectListModel:ProjectListModel;
		public var pushprojects:PushProject;
		public var myProjectsModel:ProjectsModel;
		public var loadProjMaps:LoadProjectMapsModel;
		public var categoryModel:CategoryModel;
		public var chatModel:ChatModel;
		public var pushChatModel:PushChatModel;
		public var moveToProject:Boolean;
		public var moveToWOA:Boolean;
		public var verifyProjModel:VerifyProjectMemberModel;
		public var publishMapModel:PublishMapModel;
		public var addUsers:AddUsers;
		public var removeUsers:RemoveUsers;
		public var moveMap:MoveMap;
		//makes sure that at a time, there is only one
		//pending request
		private var _requested:Boolean;
		
		private var _leafDelete:Boolean;
		
		//-------------------------------------Constructor------------------------------------------------------//
		public function AGORAModel(singletonEnforcement:SingletonEnforcementClass, target:IEventDispatcher=null)
		{
			super(target);
			
			mapListModel = new MapListModel;
			myMapsModel = new MyMapsModel;
			userSessionModel = new UserSessionModel;
			agoraMapModel = new AGORAMapModel;
			projectListModel = new ProjectListModel();
			myProjectsModel = new ProjectsModel;
			loadProjMaps = new LoadProjectMapsModel;
			categoryModel= new CategoryModel;
			chatModel = new ChatModel;
			pushChatModel = new PushChatModel;
			verifyProjModel = new VerifyProjectMemberModel;
			publishMapModel = new PublishMapModel;
			pushprojects = new PushProject();
			addUsers= new AddUsers();
			removeUsers=new RemoveUsers();
			moveMap=new MoveMap();
			reference = this;
			leafDelete = true;
			language = 'EN-US';
			moveToProject = false;
			moveToWOA = false;
			initializeHashMaps();
			
		}
		

		//-----------------------------Getters and Setters--------------------------------------------------------//

		public function get language():String
		{
			return _language;
		}

		public function set language(value:String):void
		{
			_language = value;
		}

		public function get requested():Boolean
		{
			return _requested;
		}

		public function set requested(value:Boolean):void
		{
			_requested = value;
		}

		public function get leafDelete():Boolean
		{
			return _leafDelete;
		}

		public function set leafDelete(value:Boolean):void
		{
			_leafDelete = value;
		}
		
		//---------------------------- Other public functions ---------------------------------------------//
		public function initializeHashMaps():void{
			
			var agoraParameters:AGORAParameters = AGORAParameters.getInstance();
			
			schemeAndLanguage = new Dictionary;
			schemeAndLanguage[agoraParameters.MPIfThen] = new ArgumentScheme(agoraParameters.MOD_PON, agoraParameters.IF_THEN);
			schemeAndLanguage[agoraParameters.MPimplies] = new ArgumentScheme(agoraParameters.MOD_PON, agoraParameters.IMPLIES);
			schemeAndLanguage[agoraParameters.MPnecessary] = new ArgumentScheme(agoraParameters.MOD_PON, agoraParameters.NECESSARY_CONDITION);
			schemeAndLanguage[agoraParameters.MPonlyif] = new ArgumentScheme(agoraParameters.MOD_PON, agoraParameters.ONLY_IF);
			schemeAndLanguage[agoraParameters.MPprovidedthat] = new ArgumentScheme(agoraParameters.MOD_PON, agoraParameters.PROVIDED_THAT);
			schemeAndLanguage[agoraParameters.MPsufficient] = new ArgumentScheme(agoraParameters.MOD_PON, agoraParameters.SUFFICIENT_CONDITION);
			schemeAndLanguage[agoraParameters.MPwhenever] = new ArgumentScheme(agoraParameters.MOD_PON, agoraParameters.WHENEVER);
			
			schemeAndLanguage[agoraParameters.MTifthen] = new ArgumentScheme(agoraParameters.MOD_TOL, agoraParameters.IF_THEN);
			schemeAndLanguage[agoraParameters.MTimplies] = new ArgumentScheme(agoraParameters.MOD_TOL, agoraParameters.IMPLIES);
			schemeAndLanguage[agoraParameters.MTnecessary] = new ArgumentScheme(agoraParameters.MOD_TOL, agoraParameters.NECESSARY_CONDITION);
			schemeAndLanguage[agoraParameters.MTonlyif] = new ArgumentScheme(agoraParameters.MOD_TOL, agoraParameters.ONLY_IF);
			schemeAndLanguage[agoraParameters.MTonlyifor] = new ArgumentScheme(agoraParameters.MOD_TOL, agoraParameters.ONLY_IF_OR);
			schemeAndLanguage[agoraParameters.MTonlyifand] = new ArgumentScheme(agoraParameters.MOD_TOL, agoraParameters.ONLY_IF_AND);
			schemeAndLanguage[agoraParameters.MTprovidedthat] = new ArgumentScheme(agoraParameters.MOD_TOL, agoraParameters.PROVIDED_THAT);
			schemeAndLanguage[agoraParameters.MTsufficient] = new ArgumentScheme(agoraParameters.MOD_TOL, agoraParameters.SUFFICIENT_CONDITION);
			schemeAndLanguage[agoraParameters.MTwhenever] = new ArgumentScheme(agoraParameters.MOD_TOL, agoraParameters.WHENEVER);
			
			schemeAndLanguage[agoraParameters.DisjSyl] = new ArgumentScheme(agoraParameters.DIS_SYLL, null);
			
			schemeAndLanguage[agoraParameters.NotAllSyll] = new ArgumentScheme(agoraParameters.NOT_ALL_SYLL, null);
			
			schemeAndLanguage[agoraParameters.CSifthen] = new ArgumentScheme(agoraParameters.COND_SYLL, agoraParameters.IF_THEN);
			schemeAndLanguage[agoraParameters.CSimplies] = new ArgumentScheme(agoraParameters.COND_SYLL, agoraParameters.CSimplies);
			
			dbSchemeHashMap = new Dictionary;
			dbSchemeHashMap[agoraParameters.MOD_PON] = agoraParameters.dbMP;
			dbSchemeHashMap[agoraParameters.MOD_TOL] = agoraParameters.dbMT;
			dbSchemeHashMap[agoraParameters.DIS_SYLL] = agoraParameters.dbDisjSyl;
			dbSchemeHashMap[agoraParameters.COND_SYLL] = agoraParameters.dbCS;
			dbSchemeHashMap[agoraParameters.NOT_ALL_SYLL] = agoraParameters.dbNotAllSyll;
			
			dbLanguageHashMap = new Dictionary;
			dbLanguageHashMap[agoraParameters.IF_THEN] = agoraParameters.DB_IF_THEN;
			dbLanguageHashMap[agoraParameters.IMPLIES] = agoraParameters.DB_IMPLIES;
			dbLanguageHashMap[agoraParameters.NECESSARY_CONDITION] = agoraParameters.DB_NECESSARY;
			dbLanguageHashMap[agoraParameters.ONLY_IF] = agoraParameters.DB_ONLY_IF;
			dbLanguageHashMap[agoraParameters.PROVIDED_THAT] = agoraParameters.DB_PROVIDED_THAT;
			dbLanguageHashMap[agoraParameters.SUFFICIENT_CONDITION] = agoraParameters.DB_SUFFICIENT;
			dbLanguageHashMap[agoraParameters.WHENEVER] = agoraParameters.DB_WHENEVER;
			
			
		}

		
		//----------------------------Get Instance--------------------------------------------------------//
		public static function getInstance():AGORAModel{
			if(!reference){
				reference = new AGORAModel(new SingletonEnforcementClass);
			}
			return reference;
		}
	}
}

class SingletonEnforcementClass{
	public function SingletonEnforcementClass(){
	}
}