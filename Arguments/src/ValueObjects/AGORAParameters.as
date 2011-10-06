package ValueObjects
{
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
		public var gridWidth:int;
		public var version:String;
		
		//prompts
		public var MAP_LOADING_FAILED:String;
		public var STATEMENT_TOGGLE_FAILED:String;
		public var NETWORK_ERROR:String;
		public var EDIT_OTHER:String;
		
		
		public var IF:String = "If";
		public var THEN:String = "then";
		public var OR:String = "or";
		public var AND:String = "and";
	
		//constants
		public  var MOD_PON:String = "Modus Ponens";
		public  var MOD_TOL:String = "Modus Tollens";
		public  var COND_SYLL:String = "Conditional Syllogism";
		public  var DIS_SYLL:String = "Disjunctive Syllogism";
		public  var NOT_ALL_SYLL:String = "Not-All Syllogism";
		public  var CONST_DILEM:String = "Constructive Dilemma";
		
		public  var IF_THEN:String = "If-then";
		public  var IMPLIES:String = "Implies";
		public  var WHENEVER:String = "Whenever";
		public  var ONLY_IF:String = "Only if";
		public  var ONLY_IF_OR:String = "OnlyIfOR";
		public  var ONLY_IF_AND:String = "OnlyIfAnd";
		public  var PROVIDED_THAT:String = "Provided that";
		public  var SUFFICIENT_CONDITION:String = "Sufficient condition";
		public  var NECESSARY_CONDITION:String = "Necessary Condition";
		
		public  const DB_IF_THEN:String = "ifthen";
		public  const DB_IMPLIES:String = "implies";
		public  const DB_WHENEVER:String = "whenever";
		public  const DB_ONLY_IF:String = "onlyif";
		public  const DB_PROVIDED_THAT:String = "providedthat";
		public  const DB_SUFFICIENT:String = "sufficient";
		public  const DB_NECESSARY:String = "necessary";
		
		public  const MPIfThen:String = "MPifthen";
		public  const MPimplies:String = "MPimplies";
		public  const MPwhenever:String = "MPwhenever";
		public  const MPonlyif:String = "MPonlyif";
		public  const MPprovidedthat:String = "MPprovidedthat";
		public  const MPsufficient:String = "MPsufficient";
		public  const MPnecessary:String = "MPnecessary";
		public  const dbMP:String = "MP";
		public  const MTifthen:String = "MTifthen";
		public  const MTimplies:String = "MTimplies";
		public  const MTwhenever:String = "MTwhenever";
		public  const MTonlyif:String = "MTonlyif";
		public  const MTonlyiffor:String = "MTonlyiffor";
		public  const MTprovidedthat:String = "MTprovidedthat";
		public  const MTsufficient:String = "MTsufficient";
		public  const MTnecessary:String = "MTnecessary";
		public  const dbMT:String = "MT";
		public  const DisjSyl:String = "DisjSyl";
		public  const dbDisjSyl:String = "DisjSyl";
		public  const NotAllSyll:String = "NotAllSyl";
		public  const dbNotAllSyll:String = "NotAllSyl";
		public  const EQiff:String = "EQiff";
		public  const EQnecsuf:String = "EQnecsuf";
		public  const EQ:String = "EQ";
		public  const CSifthen:String = "CSifthen";
		
		public  const CSimplies:String = "CSimplies";
		public  const dbCS:String = "CS";
		public  const CDaltclaim:String = "CDaltclaim";
		public  const CDpropclaim:String = "CDpropclaim";
		public  const dbCD:String = "CD";
		public  const Unset:String = "Unset";
		
		
		
		public function AGORAParameters()
		{
			listMapsURL = "http://agora.gatech.edu/rework/list_maps.php";
			myMapsURL = "http://agora.gatech.edu/rework/my_maps.php";
			
			loginURL = "http://agora.gatech.edu/dev/login.php";
			registrationURL = "http://agora.gatech.edu/rework/register.php";
			mapRemoveURL = "http://agora.gatech.edu/rework/remove_map.php";
			deleteURL = "http://agora.gatech.edu/rework/remove.php";
			insertURL = "http://agora.gatech.edu/rework/insert.php";
			loadMapURL = "http://agora.gatech.edu/rework/load_map.php";
			
			MAP_LOADING_FAILED = "Error occured when loading map";
			STATEMENT_TOGGLE_FAILED = "Error occurred when trying to toggle the type of statement";
			NETWORK_ERROR = "Unable to reach server. Please check your Internet connection...";
			EDIT_OTHER = "You do not have the permission to edit statements created by other users";
			
			gridWidth = 25;
			version = "11.8.30";
			reference = this;
		}
		
		public static function getInstance():AGORAParameters{
			if(!reference){
				reference = new AGORAParameters;
			}
			return reference;
		}
	}
}