package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	import ValueObjects.ArgumentScheme;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	public class AGORAModel extends EventDispatcher
	{
		private static var reference:AGORAModel;
		
		public var schemeAndLanguage:Dictionary;
		public var dbSchemeHashMap:Dictionary;
		public var dbLanguageHashMap:Dictionary;
		
		public var mapListModel:MapListModel;
		
		public var myMapsModel:MyMapsModel;
		
		[Bindable]
		public var userSessionModel:UserSessionModel;
		
		public var agoraMapModel:AGORAMapModel;
		
		
		private var _state:int;
		public static const MENU:int = 0;
		public  static const MAP:int = 1;
		
		private var _leafDelete:Boolean;
		
		//-------------------------------------Constructor------------------------------------------------------//
		public function AGORAModel(singletonEnforcement:SingletonEnforcementClass, target:IEventDispatcher=null)
		{
			super(target);
			
			mapListModel = new MapListModel;
			myMapsModel = new MyMapsModel;
			userSessionModel = new UserSessionModel;
			agoraMapModel = new AGORAMapModel;
			
			state = MENU;
			reference = this;
		
			leafDelete = true;
			
			initializeHashMaps();
			
		}
		
		
		//-----------------------------Getters and Setters--------------------------------------------------------//

		public function get leafDelete():Boolean
		{
			return _leafDelete;
		}

		public function set leafDelete(value:Boolean):void
		{
			_leafDelete = value;
		}

		public function get state():int
		{
			return _state;
		}

		public function set state(value:int):void
		{
			if(_state != value){
			 	_state = value;
				dispatchEvent(new AGORAEvent(AGORAEvent.APP_STATE_SET));
			}
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
			schemeAndLanguage[agoraParameters.MPwhenever] = new ArgumentScheme(agoraParameters.MOD_PON, agoraParameters.WHENEVER);
			
			schemeAndLanguage[agoraParameters.MTifthen] = new ArgumentScheme(agoraParameters.MOD_TOL, agoraParameters.IF_THEN);
			schemeAndLanguage[agoraParameters.MTimplies] = new ArgumentScheme(agoraParameters.MOD_TOL, agoraParameters.IMPLIES);
			schemeAndLanguage[agoraParameters.MTnecessary] = new ArgumentScheme(agoraParameters.MOD_TOL, agoraParameters.NECESSARY_CONDITION);
			schemeAndLanguage[agoraParameters.MTonlyif] = new ArgumentScheme(agoraParameters.MOD_TOL, agoraParameters.ONLY_IF);
			schemeAndLanguage[agoraParameters.MTonlyiffor] = new ArgumentScheme(agoraParameters.MOD_TOL, agoraParameters.ONLY_IF);
			schemeAndLanguage[agoraParameters.MTprovidedthat] = new ArgumentScheme(agoraParameters.MOD_TOL, agoraParameters.PROVIDED_THAT);
			schemeAndLanguage[agoraParameters.MTsufficient] = new ArgumentScheme(agoraParameters.MOD_TOL, agoraParameters.SUFFICIENT_CONDITION);
			schemeAndLanguage[agoraParameters.MTwhenever] = new ArgumentScheme(agoraParameters.MOD_TOL, agoraParameters.WHENEVER);
			
			schemeAndLanguage[agoraParameters.DisjSyl] = new ArgumentScheme(agoraParameters.DIS_SYLL, null);
			
			schemeAndLanguage[agoraParameters.NotAllSyll] = new ArgumentScheme(agoraParameters.NOT_ALL_SYLL, null);
			
			schemeAndLanguage[agoraParameters.CSifthen] = new ArgumentScheme(agoraParameters.COND_SYLL, agoraParameters.IF_THEN);
			schemeAndLanguage[agoraParameters.CSimplies] = new ArgumentScheme(agoraParameters.CSimplies, agoraParameters.CSimplies);
			
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