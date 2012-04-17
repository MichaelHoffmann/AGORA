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
		public static const OBJECTION:String = "Objection";
		
		private var _author:String;
		//Enabler, Objection or a generic statement - Statement is the default option
		private var _statementFunction:String;
		private var _statement:SimpleStatementModel;
		private var _statements:Vector.<SimpleStatementModel>;
		private var _negated:Boolean;
		private var _connectingString:String;
		private var _complexStatement:Boolean;
		private var _supportingArguments:Vector.<ArgumentTypeModel>;
		private var _argumentTypeModel:ArgumentTypeModel;
		private var _firstClaim:Boolean;
		//Universal or Particular
		private var _statementType:String;
		private var _ID:int;
		private var _nodeTextIDs:Vector.<int>;
		private var _xgrid:int;
		private var _ygrid:int;		
		private var _deleteState:Boolean;
		private var _enablerVisible:Boolean;
		private var _parentStatement:StatementModel;
		
		private var toggleStatementTypeService:HTTPService;
		private var saveTextService:HTTPService;
		private var addArgumentService:HTTPService;
		private var deleteStatements:HTTPService;
		private var addObjection:HTTPService;
		
		
		private var mapModel:AGORAMapModel;
		public var objections:Vector.<StatementModel>;
		
		public function StatementModel(modelType:String=STATEMENT, target:IEventDispatcher=null)
		{
			super(target);
			mapModel = AGORAModel.getInstance().agoraMapModel;
			statementFunction = STATEMENT;
			objections = new Vector.<StatementModel>;
			statements = new Vector.<SimpleStatementModel>(0,false);
			supportingArguments = new Vector.<ArgumentTypeModel>(0,false);
			statement = new SimpleStatementModel;
			statement.parent = this;
			nodeTextIDs = new Vector.<int>(0,false);
			statementFunction = modelType;
			deleteState = true;
			connectingString = IMPLICATION;
			
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
			addArgumentService.addEventListener(FaultEvent	.FAULT, onFault);
			
			//delete statements service
			deleteStatements = new HTTPService;
			deleteStatements.url = AGORAParameters.getInstance().deleteURL;
			deleteStatements.addEventListener(ResultEvent.RESULT, onDeleteStatementResult);
			deleteStatements.addEventListener(FaultEvent.FAULT, onFault);
			AGORAModel.getInstance().agoraMapModel.newStatementAdded(this);	
			
			
			//add an objection
			addObjection = new HTTPService;
			addObjection.url = AGORAParameters.getInstance().insertURL;
			addObjection.addEventListener(ResultEvent.RESULT, onObjectionAdded);
			addObjection.addEventListener(FaultEvent.FAULT, onFault);
		}
		
		
		//--------------------Getters and Setters------------------//

		public function get parentStatement():StatementModel
		{
			return _parentStatement;
		}

		public function set parentStatement(value:StatementModel):void
		{
			_parentStatement = value;
		}

		public function get deleteState():Boolean
		{
			return _deleteState;
		}
		
		public function set deleteState(value:Boolean):void
		{
			_deleteState = value;
		}
		
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
			if(argumentTypeModel == null && statementFunction==STATEMENT){
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
		
		//does not push new nodetextIDs
		public function addTemporaryStatement():void{
			var simpleStatement:SimpleStatementModel = new SimpleStatementModel;
			simpleStatement.parent = this;
			simpleStatement.ID = SimpleStatementModel.TEMPORARY;
			simpleStatement.forwardList.push(statement);
			statements.push(simpleStatement);
		}
		
		public function hasArgument(argumentTypeModel:ArgumentTypeModel):Boolean{
			for each(var object:Object in supportingArguments){
				if(object == argumentTypeModel){
					return true;
				}
			}
			return false;
		}
		
		public function setDeleteState():void{
			if(supportingArguments.length > 0 || (argumentTypeModel && argumentTypeModel.inferenceModel.supportingArguments.length > 0)){
				deleteState = false;
			}else{
				deleteState = true;
			}
		}
		
		public function addToSupportingArguments(atm:ArgumentTypeModel):void{
			supportingArguments.push(atm);
		}
		
		public function removeFromSupportingArguments(atm:ArgumentTypeModel):void{
			var index:int = supportingArguments.indexOf(atm);
			if(index != -1){
				supportingArguments.splice(index, 1);
			}
			setDeleteState();
		}
		
		//------------------ Delete Function ------------------------------//
		public function deleteMe():void{
			var inputXML:XML = <map ID={AGORAModel.getInstance().agoraMapModel.ID} />;
			var statementXML:XML = <node ID={ID} />;
			
			if(this.statementFunction == INFERENCE){
				for each(var stmt:StatementModel in argumentTypeModel.reasonModels){
					inputXML.appendChild(<node ID={stmt.ID} />);
				}
			}
			else if(this.statementFunction == StatementModel.STATEMENT){
				if(this.argumentTypeModel.reasonModels.length == 1){
					inputXML.appendChild(<node ID = {argumentTypeModel.inferenceModel.ID} />);
				}
			}
			inputXML.appendChild(statementXML);
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			deleteStatements.send({uid:userSessionModel.uid, pass_hash:userSessionModel.passHash,xml:inputXML});
		}
		
		protected function onDeleteStatementResult(event:ResultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.STATEMENTS_DELETED, null, this));
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
			if(event.result.hasOwnProperty("map")){
				if(event.result.map.hasOwnProperty("error")){
					dispatchEvent(new AGORAEvent(AGORAEvent.STATEMENT_TYPE_TOGGLE_FAILED, null, this));
				}
			}else{
				trace("server's code might have changed...");
			}
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
			
			var connectionXML:XML  = <connection TID="9" type="Unset" x={x} y={ygrid +12} targetnodeID={ID}>
										<sourcenode TID="12" nodeTID="6" />
										<sourcenode TID="13" nodeTID="4" />
									 </connection>;

			addArgumentXML.appendChild(reasonNodeXML);
			addArgumentXML.appendChild(inferenceXML);
			addArgumentXML.appendChild(connectionXML);
			addArgumentService.send({uid:AGORAModel.getInstance().userSessionModel.uid, pass_hash: AGORAModel.getInstance().userSessionModel.passHash, xml:addArgumentXML.toXMLString()});
		}
		
		protected function onAddArgumentServiceResponse(event:ResultEvent):void{
			if(!event.result.map.hasOwnProperty("error")){
				var map:MapValueObject = new MapValueObject(event.result.map, true);
				var statementModelHash:Dictionary = new Dictionary;
				var simpleStatementModelHash:Dictionary = new Dictionary;
				var argumentTypeModel:ArgumentTypeModel = new ArgumentTypeModel;
				
				for each(var nodeObject:NodeValueObject in map.nodeObjects){
					statementModel = StatementModel.createStatementFromObject(nodeObject);
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
			else{
				dispatchEvent(new AGORAEvent(AGORAEvent.ARGUMENT_CREATION_FAILED, null, null));
			}
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
			//will always be false when called from
			//the function that handles insert.php's response
			if(obj.type == StatementModel.INFERENCE){
				statementModel = new StatementModel(INFERENCE);
			}else{
				statementModel = new StatementModel;
			}
			statementModel.ID = obj.ID;
			return statementModel;
		}
		
		//------------------- Objections -----------------------------//
		public function object(x:int):void{
				var y:int;
				if(objections.length == 0){
					y = ygrid + 10;
				}
				else{
					y = objections[objections.length-1].ygrid;
				}
				var requestXML:XML = <map ID={mapModel.ID}><textbox TID="3" text="" /><node TID="4" Type="Objection" typed="0" is_positive="0" x={x} y={y} ><nodetext TID="5" textboxTID="3" /></node><connection TID="6" type="Objection" x="0" y="0" targetnodeID={ID}><sourcenode TID="7" nodeTID="4"/></connection></map>;
				var userSession:UserSessionModel = AGORAModel.getInstance().userSessionModel; 
				addObjection.send({uid:userSession.uid, pass_hash: userSession.passHash, xml:requestXML});
		}
		
		protected function onObjectionAdded(event:ResultEvent):void{
			var map:MapValueObject = new MapValueObject(event.result, true);
			if(map.hasOwnProperty('error')){
				dispatchEvent(new AGORAEvent(AGORAEvent.CREATING_OBJECTION_FAILED, null, this));
				return;
			}
			dispatchEvent(new AGORAEvent(AGORAEvent.OBJECTION_CREATED, null, this));
		}
		
		public function addObjectionStatement(objection:StatementModel):void{
			for each(var objectionStatement:StatementModel in objections){
				if(objectionStatement == objection){
					return;
				}
			}
			objections.push(objection);
		}
		
		public function getXML():XML{
			var xml:XML = <node></node>;
			xml.@ID = ID;
			switch(statementFunction){
				case INFERENCE:
				xml.@Type = INFERENCE;
				break;
				case OBJECTION:
				xml.@Type = OBJECTION;
				break;
				case STATEMENT:
				xml.@Type = statementType;
				break;
			};
			xml.@typed = 0;
			xml.@is_positive = negated? 0 : 1;
			xml.@x = xgrid;
			xml.@y = ygrid;
			return xml;
		}
	}
}