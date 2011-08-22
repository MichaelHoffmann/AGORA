package Model
{
	
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	import ValueObjects.ConnectionValueObject;
	import ValueObjects.MapValueObject;
	import ValueObjects.NodeValueObject;
	import ValueObjects.NodetextValueObject;
	import ValueObjects.TextboxValueObject;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
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
		public static const STATEMENT:String = "Statement";
		public static const UNIVERSAL:String = "Universal";
		public static const PARTICULAR:String = "Particular";
		
		private var _author:String;
		private var _statementFunction:String;
		private var _statement:SimpleStatementModel;
		private var _statements:Vector.<SimpleStatementModel>;
		private var _negated:Boolean;
		private var _connectingString:String;
		private var _complexStatement:Boolean;
		private var _supportingArguments:Vector.<ArgumentTypeModel>;
		private var _argumentTypeModel:ArgumentTypeModel;
		private var _firstClaim:Boolean;
		private var _statementType:String;
		private var _ID:int;
		private var _nodeTextIDs:Vector.<int>;
		private var _xgrid:int;
		private var _ygrid:int;		
		
		private var _enablerVisible:Boolean;
		
		private var toggleStatementTypeService:HTTPService;
		private var saveTextService:HTTPService;
		private var addArgumentService:HTTPService;
		
		public function StatementModel(modelType:String=STATEMENT, target:IEventDispatcher=null)
		{
			super(target);
			statements = new Vector.<SimpleStatementModel>(0,false);
			supportingArguments = new Vector.<ArgumentTypeModel>(0,false);
			statement = new SimpleStatementModel;
			statement.parent = this;
			nodeTextIDs = new Vector.<int>(0,false);
			statementFunction = modelType;
			
			
			//create toggleStatementTypeService
			toggleStatementTypeService = new HTTPService;
			toggleStatementTypeService.url = AGORAParameters.getInstance().insertURL;
			toggleStatementTypeService.addEventListener(ResultEvent.RESULT, onToggleTypeServiceResult);
			toggleStatementTypeService.addEventListener(FaultEvent.FAULT, onFault);
			
			//create save text service
			saveTextService = new HTTPService;
			saveTextService.url = AGORAParameters.getInstance().insertURL;
			saveTextService.addEventListener(ResultEvent.RESULT, onSaveTextServiceResult);
			saveTextService.addEventListener(FaultEvent.FAULT, onFault);
			
			//add argument service
			addArgumentService = new HTTPService;
			addArgumentService.url = AGORAParameters.getInstance().insertURL;
			addArgumentService.addEventListener(ResultEvent.RESULT, onAddArgumentServiceResponse);
			addArgumentService.addEventListener(FaultEvent.FAULT, onFault);
			
			AGORAModel.getInstance().agoraMapModel.newStatementAdded(this);
			
			
			
		}
		
		
		//--------------------Getters and Setters------------------//
		
		
	
		public function get argumentTypeModel():ArgumentTypeModel
		{
			return _argumentTypeModel;
		}

		public function set argumentTypeModel(value:ArgumentTypeModel):void
		{
			_argumentTypeModel = value;
		}

		public function get statementFunction():String
		{
			return _statementFunction;
		}
		
		public function set statementFunction(value:String):void
		{
			_statementFunction = value;
			if(_statementFunction == INFERENCE){
				statementType = UNIVERSAL;
			}
		}
		
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
			//return _firstClaim;
			if(argumentTypeModel == null){
				return true;
			}else{
				return false;
			}
			
		}
		
		public function get supportingArguments():Vector.<ArgumentTypeModel>
		{
			return _supportingArguments;
		}
		
		public function set supportingArguments(value:Vector.<ArgumentTypeModel>):void
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
		
		//----------------- Add Supporting Argument -----------------------//
		public function addSupportingArgument(x:int):void{
			var statementWidth:int = AGORAModel.getInstance().agoraMapModel.statementWidth;
			
			var addArgumentXML:XML =<map ID={AGORAModel.getInstance().agoraMapModel.ID}>
										<textbox text="" TID="1"/>
										<textbox text={SimpleStatementModel.DEPENDENT_TEXT} TID="10" />
										<textbox text={SimpleStatementModel.DEPENDENT_TEXT} TID="11" />
									</map>;
			
			var reasonNodeXML:XML = <node TID= "4" Type="Particular" typed="0" is_positive="1" x={x} y={ygrid + 25}>
											<nodetext TID="5" textboxTID="1"/>
									</node>;
			
			var inferenceXML:XML =  <node TID="6" Type="Inference" typed="0" is_positive="1" x={x + 15} y={ygrid + 12}>
											<nodetext TID="7" textboxTID="10"/>
											<nodetext TID="8" textboxTID="11"/>
									</node>;
			
			var connectionXML:XML  = <connection TID="9" type="Unset" x={x} y={ygrid + 12} targetnodeID={ID}>
										<sourcenode TID="12" nodeTID="6" />
										<sourcenode TID="13" nodeTID="4" />
									 </connection>;
			
			addArgumentXML.appendChild(reasonNodeXML);
			addArgumentXML.appendChild(inferenceXML);
			addArgumentXML.appendChild(connectionXML);	
			addArgumentService.send({uid:AGORAModel.getInstance().userSessionModel.uid, pass_hash: AGORAModel.getInstance().userSessionModel.passHash, xml:addArgumentXML.toXMLString()});
		}
		
		
		protected function onAddArgumentServiceResponse(event:ResultEvent):void{
			var map:MapValueObject = new MapValueObject(event.result.map, true);
			var statementModelHash:Dictionary = new Dictionary;
			var simpleStatementModelHash:Dictionary = new Dictionary;
			var argumentTypeModel:ArgumentTypeModel = new ArgumentTypeModel;
			
			for each(var nodeObject:NodeValueObject in map.nodeObjects){
				statementModel = StatementModel.createStatementFromObject(nodeObject);
				/*
				for each(var nodetext:NodetextValueObject in nodeObject.nodetexts){
				statementModel.nodeTextIDs.push(nodetext.ID);
				var simpleStatementModel:SimpleStatementModel = new SimpleStatementModel();
				simpleStatementModel.ID = nodetext.textboxID;
				simpleStatementModel.parent = statementModel;
				simpleStatementModel.forwardList.push(statementModel.statement);
				statementModel.statements.push(simpleStatementModel);
				simpleStatementModelHash[simpleStatementModel.ID] = simpleStatementModel;
				}
				*/
				statementModelHash[statementModel.ID] = statementModel;
			}
			
			for each(var connection:ConnectionValueObject in map.connections){
				
				argumentTypeModel.ID = connection.connID;
				argumentTypeModel.reasonsCompleted = false;
			}
			
			for each(var statementModel:StatementModel in statementModelHash)
			{
				AGORAModel.getInstance().agoraMapModel.panelListHash[statementModel.ID] = statementModel;
				AGORAModel.getInstance().agoraMapModel.newPanels.addItem(statementModel);
			}
			
			var mapModel:AGORAMapModel = AGORAModel.getInstance().agoraMapModel;
			
			AGORAModel.getInstance().agoraMapModel.connectionListHash[argumentTypeModel.ID] = argumentTypeModel;
			AGORAModel.getInstance().agoraMapModel.newConnections.addItem(argumentTypeModel);
			
			dispatchEvent(new AGORAEvent(AGORAEvent.ARGUMENT_CREATED, null, argumentTypeModel));
			
		}
		
		
		//---------------- save statement Texts --------------------------//
		public function saveTexts():void{
			var requestXML:XML = <map ID={AGORAModel.getInstance().agoraMapModel.ID} />;
			for each(var simpStatement:SimpleStatementModel in statements){
				if(simpStatement.hasOwn){
					requestXML.appendChild(<textbox ID={simpStatement.ID} text={simpStatement.text} />)
				}
			}
			saveTextService.send({uid: AGORAModel.getInstance().userSessionModel.uid, pass_hash:AGORAModel.getInstance().userSessionModel.passHash, xml:requestXML});
			
		}
		protected function onSaveTextServiceResult(event:ResultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.TEXT_SAVED, null, this));
		}
		
		//----------------- Generic Fault Handler -------------------------//
		protected function onFault( fault:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
		
		//---------------------- Forming StatmentModels ---------------//
		public static function createStatementFromObject(obj:NodeValueObject):StatementModel{
			var statementModel:StatementModel;
			if(obj.type == StatementModel.INFERENCE){
				statementModel = new StatementModel(INFERENCE);
			}else{
				statementModel = new StatementModel;
			}
			statementModel.ID = obj.ID;
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