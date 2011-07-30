package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import components.Map;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class AGORAMapModel extends EventDispatcher
	{	
		private var _panelListHash:Dictionary;
		private var _connectionListHash:Dictionary;
		private var _newPanels:ArrayCollection;
		private var _newConnections:ArrayCollection;
		
		private var createMapService: HTTPService;
		private var createNodeService: HTTPService;
		private var createFirstClaim: HTTPService;
		private var loadMapService: HTTPService;
		
		private var _name:String;
		private var _description:String;
		private var _timestamp:String;
		private var _ID:int;
		
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
			createFirstClaim.url = AGORAParameters.getInstance().insertURL;
			createFirstClaim.addEventListener(ResultEvent.RESULT, onAddFirstClaimResult);
			createFirstClaim.addEventListener(FaultEvent.FAULT, onFault);
			
			//create load map service
			loadMapService = new HTTPService();
			loadMapService.url = AGORAParameters.getInstance().loadMapURL;
			loadMapService.addEventListener(ResultEvent.RESULT, onLoadMapModelResult);
			loadMapService.addEventListener(FaultEvent.FAULT, onFault);
			
			panelListHash = new Dictionary;
			
			newPanels = new ArrayCollection;
			newConnections = new ArrayCollection;
			timestamp = "0";
		}
		
		//-------------------------Getters and Setters--------------------------------//
		

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
								<node TID="1" Type="Universal" typed="0" is_positive="1"  x="2" y="3">
									<nodetext/>
								</node>
						   </map>;	
			
			createFirstClaim.send({uid:AGORAModel.getInstance().userSessionModel.uid, pass_hash: AGORAModel.getInstance().userSessionModel.passHash, xml:mapXML});
		}
		
		protected function onAddFirstClaimResult(event:ResultEvent):void{
			//create statement model
			var map:Object = event.result.map;
			
			try{
				var statementModel:StatementModel = new StatementModel;
				
				//---------node----------//
				statementModel.ID = map.node.ID;
				statementModel.complexStatement = false;
				
				//-------textboxes & nodetext----------//
				var simpleStatement:SimpleStatementModel = null;
				
				if(map.textbox is ArrayCollection){
					trace("first claim as complex statement...");//shouldn't occur because there is no use case that allows this.
					for(var i:int=1; i < ArrayCollection(map.textbox).length; i++){
						simpleStatement = new SimpleStatementModel;
						simpleStatement.ID = map.textbox[i].ID;
						simpleStatement.text = map.textbox[i].text;
						statementModel.statements.push(simpleStatement);
						statementModel.nodeTextIDs.push(map.node.nodetext[i].ID);
					}		
				}
				else{
					simpleStatement = new SimpleStatementModel;
					simpleStatement.ID = map.textbox.ID;
					simpleStatement.text = map.textbox.text;
					statementModel.statements.push(simpleStatement);
					statementModel.nodeTextIDs.push(map.node.nodetext.ID);
				}
				statementModel.firstClaim = true;
				
			}catch(error:Error){
				trace("OnAddFirstClaimResult: Error occurred in reading XML");
				trace(error.message);
			}
			
			//push it to the model
			panelListHash[statementModel.ID] = statementModel;
			
			//raise event 
			dispatchEvent(new AGORAEvent(AGORAEvent.FIRST_CLAIM_ADDED, null, statementModel));	
		}
		
		//----------------------- Load New Data ----------------------------------------------//
		public function loadMapModel():void{
			loadMapService.send({map_id:ID.toString(),timestamp:timestamp});		
		}
		
		protected function onLoadMapModelResult(event:ResultEvent):void{
			trace('map loaded');
			var map:Object = event.result.map;
			
			try{
				//update timestamp
				timestamp = map.timestamp;
				
				//Form a map of textboxes
				var textboxHash:Object = new Object;
				if(map.hasOwnProperty("textbox")){
					var simpleStatement:SimpleStatementModel = null;
					if(map.textbox is ArrayCollection){
						for each(var obj:Object in map.textbox){
							simpleStatement = SimpleStatementModel.createSimpleStatementFromObject(obj);
							textboxHash[obj.ID] = simpleStatement;
						}
					}
					else{
						simpleStatement = SimpleStatementModel.createSimpleStatementFromObject(map.textbox);
						textboxHash[map.textbox.ID] = simpleStatement;
					}
				}
				
				//Form a map of nodes
				var nodeHash:Object = new Object;
				if(map.hasOwnProperty("node")){
					var statementModel:StatementModel = null;
					if(map.node is ArrayCollection){
						for each(obj in map.node){
							if(obj.Type == "Inference"){
								statementModel = InferenceModel.createStatementFromObject(obj);
								(statementModel as InferenceModel).typed = obj.Typed == 1? true:false;
							}else
							{
								statementModel = StatementModel.createStatementFromObject(obj);
							}
							statementModel.author = obj.Author;
							statementModel.xgrid = obj.x;
							statementModel.ygrid = obj.y;
							nodeHash[obj.ID] = statementModel;
						}	
					}
					else{
						obj = map.node;
						if(obj.Type == "Inference"){
							statementModel = InferenceModel.createStatementFromObject(obj);
							(statementModel as InferenceModel).typed = obj.Typed == 1? true:false;
						}else
						{
							statementModel = StatementModel.createStatementFromObject(obj);
						}
						statementModel.author = obj.Author;
						statementModel.xgrid = obj.x;
						statementModel.ygrid = obj.y;
						nodeHash[obj.ID] = statementModel;
					}
				}
				
				//Form a map of connections
				var connectionsHash:Object = new Object;
				if(map.hasOwnProperty("connection")){
					var argumentTypeModel:ArgumentTypeModel;
					if(map.connection is ArrayCollection){
						for each(obj in map.connection){
							//create a ArgumentTypeModel
							if(obj.deleted != 0){
								argumentTypeModel = ArgumentTypeModel.createArgumentTypeFromObject(obj);
								argumentTypeModel.dbType = obj.type;
								argumentTypeModel.claimModel = nodeHash[obj.targetnode];
								argumentTypeModel.xgrid = obj.x;
								argumentTypeModel.ygrid = obj.y;
								argumentTypeModel.typed = obj.typed == 1? true:false;
								
								if(obj.hasOwnProperty("sourcenode")){
									if(obj.sourcenode is ArrayCollection){
										for each(var argElements:Object in obj.sourcenode){
											if(nodeHash[argElements.nodeID] is InferenceModel){
												argumentTypeModel.inferenceModel = nodeHash[argElements.nodeID];
											}
											else{
												argumentTypeModel.reasonModels.push(nodeHash[argElements.nodeID]);
											}
										}	
									}
									else{
										trace("error: Only one sourcenode found!");
									}
									argumentTypeModel.logicClass.link();
								}		
							}
						}
					}
					else{
						obj = map.connection;
						if(obj.deleted != 0){
							argumentTypeModel = ArgumentTypeModel.createArgumentTypeFromObject(obj);
							argumentTypeModel.dbType = obj.type;
							argumentTypeModel.claimModel = nodeHash[obj.targetnode];
							argumentTypeModel.xgrid = obj.x;
							argumentTypeModel.ygrid = obj.y;
							argumentTypeModel.typed = obj.typed == 1? true:false;
							
							if(obj.hasOwnProperty("sourcenode")){
								if(obj.sourcenode is ArrayCollection){
									for each(argElements in obj.sourcenode){
										if(nodeHash[argElements.nodeID] is InferenceModel){
											argumentTypeModel.inferenceModel = nodeHash[argElements.nodeID];
										}
										else{
											argumentTypeModel.reasonModels.push(nodeHash[argElements.nodeID]);
										}
									}	
								}
								else{
									trace("error: Only one sourcenode found!");
								}
								argumentTypeModel.logicClass.link();
							}		
						}
					}
				}
				
				//Set Text for every node
				//Add new elements to Model
				for each(var node:StatementModel in nodeHash){
					newPanels.addItem(node);
					panelListHash[node.ID] = node;
				}
				
				for each(var connection:ArgumentTypeModel in connectionsHash){
					newConnections.addItem(connection);
					connectionListHash[connection.ID] = connection;
				}
				dispatchEvent(new AGORAEvent(AGORAEvent.MAP_LOADED));
				
			}catch(error:Error){
				trace("Error in reading update to Map");
				dispatchEvent(new AGORAEvent(AGORAEvent.MAP_LOADING_FAILED));
			}
			
			
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