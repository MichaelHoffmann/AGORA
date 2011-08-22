package Model
{
	import Controller.LoadController;
	
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	import ValueObjects.ConnectionValueObject;
	import ValueObjects.MapValueObject;
	import ValueObjects.NodeValueObject;
	import ValueObjects.NodetextValueObject;
	import ValueObjects.SourcenodeValueObject;
	import ValueObjects.TextboxValueObject;
	
	import com.adobe.protocols.dict.Dict;
	
	import components.Map;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class AGORAMapModel extends EventDispatcher
	{	
		private var _panelListHash:Dictionary;
		private var _connectionListHash:Dictionary;
		private var _textboxListHash:Dictionary;
		private var _newPanels:ArrayCollection;
		private var _newConnections:ArrayCollection;
		
		private var createMapService: HTTPService;
		private var createNodeService: HTTPService;
		private var createFirstClaim: HTTPService;
		private var loadMapService: HTTPService;
		private var updatePositionsService:HTTPService;
		
		private var _name:String;
		private var _description:String;
		private var _timestamp:String;
		private var _ID:int;
		
		private var _statementWidth:int;
		
		
		private var _mapConstructedFromArgument:Boolean;
		
		public function AGORAMapModel(target:IEventDispatcher=null)
		{	
			super(target);
			
			//create map service
			createMapService = new HTTPService;
			createMapService.url = AGORAParameters.getInstance().insertURL;
			createMapService.addEventListener(ResultEvent.RESULT,  onMapCreated);
			createMapService.addEventListener(FaultEvent.FAULT, onFault);
			
			//create first claim service
			createFirstClaim = new HTTPService;
			//Below statement is enabled when the xml is required for 
			//debugging
			//createFirstClaim.resultFormat = "e4x";
			createFirstClaim.url = AGORAParameters.getInstance().insertURL;
			createFirstClaim.addEventListener(ResultEvent.RESULT, onAddFirstClaimResult);
			createFirstClaim.addEventListener(FaultEvent.FAULT, onFault);
			
			//create load map service
			loadMapService = new HTTPService();
			loadMapService.url = AGORAParameters.getInstance().loadMapURL;
			loadMapService.addEventListener(ResultEvent.RESULT, onLoadMapModelResult);
			loadMapService.addEventListener(FaultEvent.FAULT, onFault);
			
			//create update positions service
			updatePositionsService = new HTTPService();
			updatePositionsService.url = AGORAParameters.getInstance().insertURL;
			updatePositionsService.addEventListener(ResultEvent.RESULT, updatePositionServiceResult);
			updatePositionsService.addEventListener(FaultEvent.FAULT, onFault);
			
			
			
			panelListHash = new Dictionary;
			connectionListHash = new Dictionary;
			textboxListHash = new Dictionary;
			
			newPanels = new ArrayCollection;
			newConnections = new ArrayCollection;
			timestamp = "0";
			statementWidth = 8;
		}
		
		//-------------------------Getters and Setters--------------------------------//
		
		
		public function get mapConstructedFromArgument():Boolean
		{
			return _mapConstructedFromArgument;
		}
		
		public function set mapConstructedFromArgument(value:Boolean):void
		{
			_mapConstructedFromArgument = value;
		}
		
		public function get textboxListHash():Dictionary
		{
			return _textboxListHash;
		}
		
		public function set textboxListHash(value:Dictionary):void
		{
			_textboxListHash = value;
		}
		
		public function get statementWidth():int
		{
			return _statementWidth;
		}
		
		public function set statementWidth(value:int):void
		{
			_statementWidth = value;
		}
		
		public function get connectionListHash():Dictionary
		{
			return _connectionListHash;
		}
		
		public function set connectionListHash(value:Dictionary):void
		{
			_connectionListHash = value;
		}
		
		public function get newConnections():ArrayCollection
		{
			return _newConnections;
		}
		
		public function set newConnections(value:ArrayCollection):void
		{
			_newConnections = value;
		}
		
		public function get newPanels():ArrayCollection
		{
			return _newPanels;
		}
		
		public function set newPanels(value:ArrayCollection):void
		{
			_newPanels = value;
		}
		
		public function get panelListHash():Dictionary
		{
			return _panelListHash;
		}
		
		public function set panelListHash(value:Dictionary):void
		{
			_panelListHash = value;
		}
		
		public function get ID():int
		{
			return _ID;
		}
		
		public function set ID(value:int):void
		{
			_ID = value;
		}
		
		public function get timestamp():String
		{
			return _timestamp;
		}
		
		public function set timestamp(value:String):void
		{
			_timestamp = value;
		}
		
		public function get description():String
		{
			return _description;
		}
		
		public function set description(value:String):void
		{
			_description = value;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		
		//----------------------- Create a New Map --------------------------------------------//
		public function createMap(mapName:String):void{
			var xmlForMap:XML = <map id="0" title={mapName}></map>;
			var usModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			createMapService.send({uid:usModel.uid, pass_hash:usModel.passHash, xml:xmlForMap.toXMLString()});
		}
		
		protected function onMapCreated(resultEvent:ResultEvent):void{
			var mapMetaData:MapMetaData = new MapMetaData;
			mapMetaData.mapID = resultEvent.result.map.ID;
			dispatchEvent(new AGORAEvent(AGORAEvent.MAP_CREATED, null, mapMetaData));
		}
		
		//-----------------------Add First Claim---------------------------------------------//
		public function addFirstClaim():void{
			var mapXML:XML=<map id={ID}>
								<textbox text=""/>
								<node TID="1" Type={StatementModel.PARTICULAR} typed="0" is_positive="1"  x="2" y="3">
									<nodetext/>
								</node>
						   </map>;	
			createFirstClaim.send({uid:AGORAModel.getInstance().userSessionModel.uid, pass_hash: AGORAModel.getInstance().userSessionModel.passHash, xml:mapXML});
		}
		
		protected function onAddFirstClaimResult(event:ResultEvent):void{
			//create statement model
			var map:MapValueObject = new MapValueObject(event.result.map, true);
			try{
				var statementModel:StatementModel = StatementModel.createStatementFromObject(map.nodeObjects[0]);
				
				//-------textboxes & nodetext----------//
				var simpleStatement:SimpleStatementModel = null;
				simpleStatement = SimpleStatementModel.createSimpleStatementFromObject(map.textboxes[0], statementModel);
				//When first statement is created, there will not be any text
				simpleStatement.hasOwn = true;
				simpleStatement.forwardList.push(statementModel.statement);
				statementModel.statements.push(simpleStatement);
				statementModel.nodeTextIDs.push(map.nodeObjects[0].nodetexts[0].ID);
				
				textboxListHash[simpleStatement.ID] = simpleStatement;
				
			}catch(error:Error){
				trace("OnAddFirstClaimResult: Error occurred in reading XML");
				trace(error.message);
			}
			
			//push it to the model
			panelListHash[statementModel.ID] = statementModel;
			newPanels.addItem(statementModel);
			
			//raise event 
			dispatchEvent(new AGORAEvent(AGORAEvent.FIRST_CLAIM_ADDED, null, statementModel));	
		}
		
		//----------------------- Notify new statement model -----------------------------//
		public function newStatementAdded(statementModel:StatementModel):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.STATEMENT_ADDED, null, statementModel));
		}
		
		//----------------------- Load New Data ----------------------------------------------//
		public function loadMapModel():void{
			loadMapService.send({map_id:ID.toString(),timestamp:timestamp});		
		}
		
		protected function onLoadMapModelResult(event:ResultEvent):void{
			trace('map loaded');
			var mapXMLRawObject:Object = event.result.map;
			var map:MapValueObject = new MapValueObject(mapXMLRawObject);
			
			try{
				//update timestamp
				timestamp = map.timestamp;
				
				//Form a map of nodes
				var obj:Object;
				var nodeHash:Dictionary = new Dictionary;
				var textboxHash:Dictionary = new Dictionary;
				
				//read nodes and create Statment Models
				//parseNode(map, nodeHash, textboxHash);
				processNode(map.nodeObjects,nodeHash, textboxHash);
				
				//Form a map of connections
				var connectionsHash:Dictionary = new Dictionary;
				//parseConnection(map, connectionsHash, nodeHash);
				processConnection(map.connections, connectionsHash, nodeHash);
				
				//read and set text - This should be performed after links are created
				processTextbox(map.textboxes, textboxHash);
				
				//add new elements to Model
				for each(var node:StatementModel in nodeHash){
					if(!panelListHash.hasOwnProperty(node.ID)){
						newPanels.addItem(node);
						panelListHash[node.ID] = node;				
					}
				}
				
				for each(var connection:ArgumentTypeModel in connectionsHash){	
					if(!connectionListHash.hasOwnProperty(connection.ID)){
						newConnections.addItem(connection);
						connectionListHash[connection.ID] = connection;
					}
				}
				
				for each(var textbox:SimpleStatementModel in textboxHash){
					textboxListHash[textbox.ID] = textbox;
				}
				dispatchEvent(new AGORAEvent(AGORAEvent.MAP_LOADED));
				
			}
			catch(error:Error){
				trace(error.message);
				trace("Error in reading update to Map");
				dispatchEvent(new AGORAEvent(AGORAEvent.MAP_LOADING_FAILED));
			}			
		}
		
		//---------------------- Process Node ---------------------------------------------------------//
		protected function processNode(obj:Vector.<NodeValueObject>, nodeHash:Dictionary, textboxHash:Dictionary):Boolean{
			var statementModel:StatementModel;
			for each(var nodeVO:NodeValueObject in obj){
				if(!nodeVO.deleted){
					//Set attributes
					if(!panelListHash.hasOwnProperty(nodeVO.ID)){
						statementModel = StatementModel.createStatementFromObject(nodeVO);
					}else{
						statementModel = panelListHash[nodeVO.ID];
					}
					
					if(nodeVO.type == StatementModel.INFERENCE){
						statementModel.statementFunction = StatementModel.INFERENCE;
					}
					else
					{
						statementModel.statementFunction = StatementModel.STATEMENT;	
					}
					
					statementModel.author = nodeVO.author;
					statementModel.statementType = nodeVO.type;
					statementModel.xgrid = nodeVO.x;
					statementModel.ygrid = nodeVO.y;
					nodeHash[nodeVO.ID] = statementModel;
					processNodeText(nodeVO, nodeHash, textboxHash);
				}
			}
			return true;
		}
		
		protected function processNodeText(nodeVO:NodeValueObject, nodeHash:Dictionary, textboxHash:Dictionary):Boolean{
			var statementModel:StatementModel = nodeHash[nodeVO.ID];
			var simpleStatement:SimpleStatementModel;
			for each(var nodetextVO:NodetextValueObject in nodeVO.nodetexts){
				if(!statementModel.hasStatement(nodetextVO.textboxID)){
					simpleStatement = new SimpleStatementModel;
					simpleStatement.forwardList.push(statementModel.statement);
					simpleStatement.ID = nodetextVO.textboxID;
					simpleStatement.parent = statementModel;
					statementModel.statements.push(simpleStatement);
					statementModel.nodeTextIDs.push(nodetextVO.ID);
					textboxHash[simpleStatement.ID] = simpleStatement;
				}
				
			}
			return true;
		}
		
		protected function processConnection(objs:Vector.<ConnectionValueObject>, connectionsHash:Dictionary, nodeHash:Dictionary):Boolean{
			var argumentTypeModel:ArgumentTypeModel;
			var result:Boolean;
			for each(var obj:ConnectionValueObject in objs){
				if(!obj.deleted){
					if(!connectionListHash.hasOwnProperty(obj.connID)){
						argumentTypeModel = ArgumentTypeModel.createArgumentTypeFromObject(obj);
					}else{
						argumentTypeModel = connectionListHash[obj.connID];
					}
					argumentTypeModel.dbType = obj.type;
					if(nodeHash.hasOwnProperty(obj.targetnode)){
						argumentTypeModel.claimModel = nodeHash[obj.targetnode];
					}
					else{
						argumentTypeModel.claimModel = panelListHash[obj.targetnode];
					}
					argumentTypeModel.xgrid = obj.x;
					argumentTypeModel.ygrid = obj.y;
					connectionsHash[obj.connID] = argumentTypeModel;
					processSourceNode(obj, connectionsHash, nodeHash);	
				}
				
			}
			return true;
		}
		
		protected function processSourceNode(obj:ConnectionValueObject, connectionsHash:Dictionary, nodeHash:Dictionary):Boolean{
			var argumentTypeModel:ArgumentTypeModel = connectionsHash[obj.connID];
			for each(var argElements:SourcenodeValueObject in obj.sourcenodes){
				if(nodeHash.hasOwnProperty(argElements.nodeID)){
					if(StatementModel(nodeHash[argElements.nodeID]).statementFunction == StatementModel.INFERENCE){
						argumentTypeModel.inferenceModel = nodeHash[argElements.nodeID];
						StatementModel(nodeHash[argElements.nodeID]).argumentTypeModel = argumentTypeModel;
					}
					else{
						if(!argumentTypeModel.hasReason(argElements.nodeID)){
							argumentTypeModel.reasonModels.push(nodeHash[argElements.nodeID]);
							StatementModel(nodeHash[argElements.nodeID]).argumentTypeModel = argumentTypeModel;
						}
					}
				}
				else{ //read earlier
					if(StatementModel(panelListHash[argElements.nodeID]).statementFunction == StatementModel.INFERENCE){
						argumentTypeModel.inferenceModel = panelListHash[argElements.nodeID];
						StatementModel(panelListHash[argElements.nodeID]).argumentTypeModel = argumentTypeModel;
					}
					else{
						if(!argumentTypeModel.hasReason(argElements.nodeID)){
							argumentTypeModel.reasonModels.push(panelListHash[argElements.nodeID]);
							StatementModel(	panelListHash[argElements.nodeID]).argumentTypeModel = argumentTypeModel;
						}
					}
				}
			}
			return true;
		}
		
		protected function processTextbox(textboxes:Vector.<TextboxValueObject>, textboxHash:Dictionary):Boolean{
			var simpleStatement:SimpleStatementModel;
			for each(var obj:TextboxValueObject in textboxes){
				if(!obj.deleted){
					//fetch simpleStatementModel from Dictionary
					if(textboxHash.hasOwnProperty(obj.ID)){
						simpleStatement = textboxHash[obj.ID];
						simpleStatement.text = obj.text;
						if(obj.text == SimpleStatementModel.DEPENDENT_TEXT){
							simpleStatement.hasOwn = false;
						}
					}	
					else{
						simpleStatement = textboxListHash[obj.ID];
						simpleStatement.text = obj.text;
					}
				}
			}
			return true;
		}
		
		//----------------------- Updating position -----------------------------------------//
		public function updatePosition(model:Object, xgridDiff:int, ygridDiff:int):void{
			//get the current model
			var statementModel:StatementModel;
			var inferenceModel:InferenceModel;
			var argumentTypeModel:ArgumentTypeModel;
			
			var xmlRequest:XML = <map ID={ID} />;
			var queue:Vector.<Object> = new Vector.<Object>;
			queue.push(model);
			
			while(queue.length > 0){
				model = queue.pop();
				if(model is InferenceModel){
					inferenceModel = InferenceModel(model);		
				}
				else if(model is StatementModel){
					statementModel = StatementModel(model);
					var xmlChild:XML = statementModel.getXML();
					xmlChild.@x = int(xmlChild.@x) + xgridDiff;
					xmlChild.@y = int(xmlChild.@y) + ygridDiff;
					xmlRequest.appendChild(xmlChild);
				}
				else if(model is ArgumentTypeModel){
					argumentTypeModel = ArgumentTypeModel(model);
				}
				updatePositionsService.send({uid:AGORAModel.getInstance().userSessionModel.uid, pass_hash:AGORAModel.getInstance().userSessionModel.passHash, xml:xmlRequest});
			}
		}
		
		protected function updatePositionServiceResult(result:ResultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.POSITIONS_UPDATED));
		}
		
		//----------------------- Reinitializing the model ----------------------------------//
		public function reinitializeModel():void{	
		}
		
		//----------------------- Generic Fault Event  Handler-------------------------------//
		protected function onFault(event:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));	
		}
		
	}
}