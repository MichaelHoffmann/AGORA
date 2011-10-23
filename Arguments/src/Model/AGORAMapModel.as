package Model
{
	import Controller.LoadController;
	import Controller.UserSessionController;
	import Controller.logic.LogicFetcher;
	import Controller.logic.ParentArg;
	
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
	import mx.states.State;
	
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
		private var _deletedList:Vector.<Object>;
		
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
			//	loadMapService.resultFormat="e4x";
			loadMapService.addEventListener(ResultEvent.RESULT, onLoadMapModelResult);
			loadMapService.addEventListener(FaultEvent.FAULT, onFault);
			
			//create update positions service
			updatePositionsService = new HTTPService();
			updatePositionsService.url = AGORAParameters.getInstance().insertURL;
			updatePositionsService.resultFormat = "e4x";
			updatePositionsService.addEventListener(ResultEvent.RESULT, updatePositionServiceResult);
			updatePositionsService.addEventListener(FaultEvent.FAULT, onFault);
			
			
			reinitializeModel();
			statementWidth = 8;
		}
		
		//-------------------------Getters and Setters--------------------------------//
		
		public function get deletedList():Vector.<Object>
		{
			return _deletedList;
		}
		
		public function set deletedList(value:Vector.<Object>):void
		{
			_deletedList = value;
		}
		
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
								<textbox TID="10" text=""/>
								<node TID="1" Type={StatementModel.PARTICULAR} typed="0" is_positive="1"  x="2" y="3">
									<nodetext TID="2" textboxTID="10" />
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
		
		public function newArgumentTypeModelAdded(argumentTypeModel:ArgumentTypeModel):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.ARGUMENT_TYPE_ADDED, null, argumentTypeModel));
		}
		
		//----------------------- Load New Data ----------------------------------------------//
		public function loadMapModel():void{
			loadMapService.send({map_id:ID.toString(),timestamp:timestamp});		
		}
		
		protected function onLoadMapModelResult(event:ResultEvent):void{
			trace('map loaded');
			deletedList = new Vector.<Object>;
			//trace(event.result.toXMLString());
			var mapXMLRawObject:Object = event.result.map;
			var map:MapValueObject = new MapValueObject(mapXMLRawObject);
			//try{
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
			//}
			//catch(error:Error){
			//	trace(error.message);
			//	trace("Error in reading update to Map");
			//	dispatchEvent(new AGORAEvent(AGORAEvent.MAP_LOADING_FAILED));
			//}
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
			
			//update enablers after deletion
			for each(var deletedObject:Object in deletedList){
				if(deletedObject is StatementModel){
					var sm:StatementModel = deletedObject as StatementModel;
					var aTM:ArgumentTypeModel = sm.argumentTypeModel;
					if(aTM.reasonModels.length > 0){
						//aTM.reasonModels[0].statements[0].updateStatementTexts();
						var logicController:ParentArg = LogicFetcher.getInstance().logicHash[aTM.logicClass];
						logicController.formText(aTM);
					}
				}
			}
			
			dispatchEvent(new AGORAEvent(AGORAEvent.MAP_LOADED));
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
				else{
					if(panelListHash.hasOwnProperty(nodeVO.ID)){
						var statementM:StatementModel = panelListHash[nodeVO.ID];
						if(statementM.statementFunction == StatementModel.STATEMENT){
							if(!statementM.firstClaim){
								var index:int = statementM.argumentTypeModel.reasonModels.indexOf(statementM);
								statementM.argumentTypeModel.reasonModels.splice(index, 1);
							}
						}
						deletedList.push(statementM);
						delete panelListHash[nodeVO.ID];
					}
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
					simpleStatement.ID = nodetextVO.textboxID;
					//should not push statement into statements[i], if 
					// the statement's parent is an Inference rule.
					//This is because in the formtext function,
					//both the statement and statements[i] are 
					//modified simultaneously.
					simpleStatement.parent = statementModel;
					if(statementModel.statementFunction != StatementModel.INFERENCE){
						simpleStatement.addDependentStatement(statementModel.statement);
					}
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
					
					if(!argumentTypeModel.claimModel.hasArgument(argumentTypeModel)){
						argumentTypeModel.claimModel.addToSupportingArguments(argumentTypeModel);
					}
					
					argumentTypeModel.xgrid = obj.x;
					argumentTypeModel.ygrid = obj.y;
					
					
					connectionsHash[obj.connID] = argumentTypeModel;
					processSourceNode(obj, connectionsHash, nodeHash);
					dispatchEvent(new AGORAEvent(AGORAEvent.ARGUMENT_SCHEME_SET, null, argumentTypeModel));
					
				}
				else{
					if(connectionListHash.hasOwnProperty(obj.connID)){
						var argumentTypeM:ArgumentTypeModel = connectionListHash[obj.connID];
						var claimModel:StatementModel = argumentTypeM.claimModel;
						var index:int = claimModel.supportingArguments.indexOf(argumentTypeM);
						claimModel.supportingArguments.splice(index, 1);
						deletedList.push(argumentTypeM);
						delete connectionListHash[obj.connID];
					}
				}
				
			}
			return true;
		}
		
		protected function processSourceNode(obj:ConnectionValueObject, connectionsHash:Dictionary, nodeHash:Dictionary):Boolean{
			var argumentTypeModel:ArgumentTypeModel = connectionsHash[obj.connID];
			for each(var argElements:SourcenodeValueObject in obj.sourcenodes){
				if(!argElements.deleted){
					//node read in the current update
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
					else{ //read earlier and hence in the global hash
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
						if(obj.text == SimpleStatementModel.DEPENDENT_TEXT){
							simpleStatement.hasOwn = false;
						}
						else{
							simpleStatement.hasOwn = true;
						}
					}	
					else{
						simpleStatement = textboxListHash[obj.ID];
					}
					if(simpleStatement){
						if(simpleStatement.hasOwn){
							simpleStatement.text = obj.text;
						}			
					}
					else{
						trace(obj.ID + ' is not deleted and not associated with any node');
					}
				}
				else{
					if(textboxListHash.hasOwnProperty(obj.ID)){
						delete textboxListHash[obj.ID];
					}
				}
			}
			return true;
		}
		
		//----------------------- Updating position -----------------------------------------// 
		public function moveStatement(model:Object, diffx:int, diffy:int):void{
			var requestXML:XML = <map ID={ID} />;
			if(model is ArgumentTypeModel){
				var atm:ArgumentTypeModel = ArgumentTypeModel(model);
				var claimModel:StatementModel = atm.claimModel;
				if( atm == claimModel.supportingArguments[0] ){
					requestXML = moveSupportingStatements(atm, 0, diffy, requestXML);
				}else{
					requestXML = moveSupportingStatements(atm, diffx, diffy, requestXML);
				}
			}else if(model is StatementModel){
				var sm:StatementModel = StatementModel(model);
				var argumentTypeModel:ArgumentTypeModel = sm.argumentTypeModel;
				if(sm.statementFunction == StatementModel.STATEMENT){
					if(argumentTypeModel != null){
						for each(var reason:StatementModel in argumentTypeModel.reasonModels){
							if(reason == sm ){
								if(reason != argumentTypeModel.reasonModels[0])
								{
									requestXML = moveSupportingStatements(reason, diffx, diffy, requestXML);	
								}else{
									requestXML = moveSupportingStatements(reason, 0, diffy, requestXML);
								}
							}else{
								requestXML = moveSupportingStatements(reason, 0, diffy, requestXML); 
							}
						}
					}else{
						requestXML = moveSupportingStatements(sm, diffx, diffy, requestXML);
					}
				}
				else if(sm.statementFunction == StatementModel.INFERENCE){
					requestXML = moveSupportingStatements(sm, diffx, 0, requestXML);
				}
			}
			
			var usm:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			updatePositionsService.send({uid: usm.uid, pass_hash: usm.passHash, xml:requestXML});
		}
		
		protected function updatePositionServiceResult(event:ResultEvent):void{
			trace(event.result.toXMLString());
			dispatchEvent(new AGORAEvent(AGORAEvent.POSITIONS_UPDATED, null, null));
		}
		
		protected function moveSupportingStatements(model:Object, diffx:int, diffy:int, requestXML:XML):XML{
			var list:Vector.<Object> = new Vector.<Object>;
			list.push(model);
			var atm:ArgumentTypeModel;
			var reason:StatementModel;
			var inferenceModel:StatementModel;
			var statementModel:StatementModel;
			
			var xml:XML;
			//forming xml for requesting update in positions
			//argument map considered as a tree, and a 
			//depth first traversal is done
			while(list.length > 0){
				var object:Object = list.pop();
				if(object is ArgumentTypeModel){
					atm = ArgumentTypeModel(object);
					xml = atm.getXML();
					xml.@x = int(xml.@x) + diffx;
					xml.@y = int(xml.@y) + diffy;
					requestXML.appendChild(xml);
					list.push(atm.inferenceModel);
					for each(reason in atm.reasonModels){
						list.push(reason);
					}
				}else if(object is StatementModel){
					statementModel = StatementModel(object);
					xml = statementModel.getXML();
					for(var i:int=0; i<statementModel.nodeTextIDs.length; i++){
						xml.appendChild(<nodetext ID={statementModel.nodeTextIDs[i]} textboxID={statementModel.statements[i].ID} />);
					}
					xml.@x = int(xml.@x) + diffx;
					xml.@y = int(xml.@y) + diffy;
					requestXML.appendChild(xml);
					for each(atm in statementModel.supportingArguments){
						list.push(atm);
					}
				}
			}
			return requestXML;
		}
		
		//----------------------- Reinitializing the model ----------------------------------//
		public function reinitializeModel():void{
			
			panelListHash = new Dictionary;
			connectionListHash = new Dictionary;
			textboxListHash = new Dictionary;
			
			newPanels = new ArrayCollection;
			newConnections = new ArrayCollection;
			
			timestamp = "0";
		}
		
		//----------------------- Generic Fault Event  Handler-------------------------------//
		protected function onFault(event:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));	
		}
		
	}
}