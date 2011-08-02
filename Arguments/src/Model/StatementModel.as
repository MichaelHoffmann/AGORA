package Model
{
	
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	[Bindable]
	public class StatementModel extends EventDispatcher
	{
		
		public static const DISJUNCTION:String = "Disjunction";
		public static const IMPLICATION:String = "Implication";
		public static const INFERENCE:String = "Inference";
		public static const UNIVERSAL:String = "Universal";
		public static const PARTICULAR:String = "Particular";
		
		private var _author:String;
		private var _statement:SimpleStatementModel;
		private var _statements:Vector.<SimpleStatementModel>;
		private var _negated:Boolean;
		private var _connectingString:String;
		private var _complexStatement:Boolean;
		private var _supportingArguments:Vector.<InferenceModel>;
		private var _inference:InferenceModel;
		private var _firstClaim:Boolean;
		private var _statementType:String;
		private var _ID:int;
		private var _nodeTextIDs:Vector.<int>;
		private var _xgrid:int;
		private var _ygrid:int;
		
		
		private var toggleStatementTypeService:HTTPService;
		
		
		public function StatementModel(target:IEventDispatcher=null)
		{
			super(target);
			statements = new Vector.<SimpleStatementModel>(0,false);
			supportingArguments = new Vector.<InferenceModel>(0,false);
			nodeTextIDs = new Vector.<int>(0,false);
			
			//create toggleStatementTypeService
			toggleStatementTypeService = new HTTPService;
			toggleStatementTypeService.url = AGORAParameters.getInstance().insertURL;
			toggleStatementTypeService.addEventListener(ResultEvent.RESULT, onToggleTypeServiceResult);
			toggleStatementTypeService.addEventListener(FaultEvent.FAULT, onFault);
		}

		
		//--------------------Getters and Setters------------------//
		
		public function get author():String
		{
			return _author;
		}

		public function set author(value:String):void
		{
			_author = value;
		}

		public function get ygrid():int
		{
			return _ygrid;
		}

		public function set ygrid(value:int):void
		{
			_ygrid = value;
		}

		public function get xgrid():int
		{
			return _xgrid;
		}

		public function set xgrid(value:int):void
		{
			_xgrid = value;
		}

		public function get nodeTextIDs():Vector.<int>
		{
			return _nodeTextIDs;
		}

		public function set nodeTextIDs(value:Vector.<int>):void
		{
			_nodeTextIDs = value;
		}

		public function get ID():int
		{
			return _ID;
		}

		public function set ID(value:int):void
		{
			_ID = value;
		}

		public function get statementType():String
		{
			return _statementType;
		}

		public function set statementType(value:String):void
		{
			_statementType = value;
		}

		public function get firstClaim():Boolean
		{
			return _firstClaim;
		}

		public function set firstClaim(value:Boolean):void
		{
			_firstClaim = value;
		}

		public function get inference():InferenceModel
		{
			return _inference;
		}

		public function set inference(value:InferenceModel):void
		{
			_inference = value;
		}

		public function get supportingArguments():Vector.<InferenceModel>
		{
			return _supportingArguments;
		}

		public function set supportingArguments(value:Vector.<InferenceModel>):void
		{
			_supportingArguments = value;
		}

		public function get complexStatement():Boolean
		{
			return _complexStatement;
		}

		public function set complexStatement(value:Boolean):void
		{
			_complexStatement = value;
		}

		public function get connectingString():String
		{
			return _connectingString;
		}

		public function set connectingString(value:String):void
		{
			_connectingString = value;
		}

		public function get negated():Boolean
		{
			return _negated;
		}

		public function set negated(value:Boolean):void
		{
			_negated = value;
		}

		public function get statements():Vector.<SimpleStatementModel>
		{
			return _statements;
		}

		public function set statements(value:Vector.<SimpleStatementModel>):void
		{
			_statements = value;
		}

		public function get statement():SimpleStatementModel
		{
			return _statement;
		}

		public function set statement(value:SimpleStatementModel):void
		{
			_statement = value;
		}
		
		//----------------------- other public functions -------------//
		public static function getObject(xml:XML):StatementModel{
			return new StatementModel;	
		}
		
		public function hasStatement(id:int):Boolean{
			for each(var simpleStatement:SimpleStatementModel in statements){
				if(simpleStatement.ID == id){
					return true;
				}
			}
			return false;
		}
		
		
		public function getStatement(id:int):SimpleStatementModel{
			for each(var simpleStatement:SimpleStatementModel in statements){
				if(id == simpleStatement.ID){
					return simpleStatement;
				}
			}
			return null;
		}
		
		//------------------ Toggle Statement Type ------------------------//
		public function toggleType():void{
			var requestXML:XML = <map ID={AGORAModel.getInstance().agoraMapModel.ID} />;
			var nodeXML:XML = getXML();
			nodeXML.@Type = nodeXML.@Type == UNIVERSAL? PARTICULAR: UNIVERSAL;
			requestXML.appendChild(nodeXML);
			toggleStatementTypeService.send({uid: AGORAModel.getInstance().userSessionModel.uid, pass_hash:AGORAModel.getInstance().userSessionModel.passHash, xml:requestXML});
		}
		
		protected function onToggleTypeServiceResult(event:ResultEvent):void{
			//check for error
			statementType = statementType == UNIVERSAL? PARTICULAR: UNIVERSAL;
			dispatchEvent(new AGORAEvent(AGORAEvent.STATEMENT_TYPE_TOGGLED, null, ID));
		}
		
		//----------------- Generic Fault Handler -------------------------//
		protected function onFault( fault:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
		
		//---------------------- Forming StatmentModels ---------------//
		public static function createStatementFromObject(obj:Object):StatementModel{
			var statementModel:StatementModel = new StatementModel;
			statementModel.ID = obj.ID;
			return statementModel;
		}
		
		public static function createStatmentFromXML(xml:XML):StatementModel{
			var statementModel:StatementModel = new StatementModel;
			return statementModel;
		}
		
		public function getXML():XML{
			var xml:XML = <node></node>;
			xml.@ID = ID;
			xml.@Type = statementType;
			xml.@typed = 0;
			xml.@is_positive = negated? 0 : 1;
			xml.@x = xgrid;
			xml.@y = ygrid;
			return xml;
		}
	}
}