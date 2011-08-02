package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
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
			newPanels.addItem(statementModel);
			
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
				
				//Form a map of nodes
				var obj:Object;
				var nodeHash:Dictionary = new Dictionary;
				var textboxHash:Dictionary = new Dictionary;
				var result:Boolean;
				
				//read nodes and create Statment Models
				result = parseNode(map, nodeHash, textboxHash);
				if(!result){
					dispatchEvent(new AGORAEvent(AGORAEvent.MAP_LOADING_FAILED));
					return;
				}
				
				//Form a map of connections
				var connectionsHash:Dictionary = new Dictionary;
				result = parseConnection(map, connectionsHash, nodeHash);
				if(!result){
					dispatchEvent(new AGORAEvent(AGORAEvent.MAP_LOADING_FAILED));
					return;
				}
				
				
				//read and set text - This should be performed after links are created
				result = parseTextox(map, textboxHash);
				if(!result){
					dispatchEvent(new AGORAEvent(AGORAEvent.MAP_LOADING_FAILED));
					return;
				}
				
				//add new elements to Model
				for each(var node:StatementModel in nodeHash){
					if(!panelListHash.hasOwnProperty(node.ID)){
						newPanels.addItem(node);
						panelListHash[node.ID] = node;				
					}
				}
				
				for each(var connection:ArgumentTypeModel in connectionsHash){	
					newConnections.addItem(connection);
					connectionListHash[connection.ID] = connection;
				}
				
				dispatchEvent(new AGORAEvent(AGORAEvent.MAP_LOADED));
				
				
			}
			catch(error:Error){
				trace(error.message);
				trace("Error in reading update to Map");
				dispatchEvent(new AGORAEvent(AGORAEvent.MAP_LOADING_FAILED));
			}
			
			
		}
		
		//---------------------- Parsing Node ---------------------------------------------------------//
		protected function parseNode(map:Object, nodeHash:Dictionary, textboxHash:Dictionary):Boolean{
			if(map.hasOwnProperty("node")){
				var statementModel:StatementModel = null;
				var obj:Object;
				var result:Boolean;
				//If there are multiple nodes in the returned XML
				if(map.node is ArrayCollection){
					for each(obj in map.node){
						result = processNode(obj,nodeHash,textboxHash);
						if(!result){
							return false;
						}
					}	
				}
					//If there is only one node in the returned XML
				else{
					obj = map.node;
					result = processNode(obj,nodeHash, textboxHash);
					if(!result){
						return false;
					}
				}
			}
			return true;
		}
		
		protected function processNode(obj:Object, nodeHash:Dictionary, textboxHash:Dictionary):Boolean{
			var statementModel:StatementModel;
			if(obj.deleted == "0"){
				//Set attributes
				if(!panelListHash.hasOwnProperty(obj.ID)){
					if(obj.Type == "Inference"){
						statementModel = InferenceModel.createStatementFromObject(obj);
						(statementModel as InferenceModel).typed = obj.Typed == 1? true:false;
					}else
					{
						statementModel = StatementModel.createStatementFromObject(obj);
					}
				}else{
					statementModel = panelListHash[obj.ID];
				}
				statementModel.author = obj.Author;
				statementModel.statementType = obj.Type;
				statementModel.xgrid = obj.x;
				statementModel.ygrid = obj.y;
				nodeHash[obj.ID] = statementModel;
				
				var result:Boolean = parseNodeText(obj, nodeHash, textboxHash);
				if(!result){
					return false;
				}
			}
			return true;
		}
		
		//----------------------- Parse Nodetexts -------------------------------------------//
		protected function parseNodeText(obj:Object, nodeHash:Dictionary, textboxHash:Dictionary):Boolean{
			//read nodetexts and create simpleStatement Models
			var statementModel:StatementModel = nodeHash[obj.ID];
			var result:Boolean;
			if(obj.hasOwnProperty("nodetext")){
				var simpleStatement:SimpleStatementModel;
				var nodetext:Object;
				//multiple nodetexts
				if(obj.nodetext is ArrayCollection){
					for each(nodetext in obj.nodetext){
						result = processNodeText(nodetext,obj,nodeHash,textboxHash);
						if(!result){
							return false;
						}
					}
				}
				else{//single nodetext
					nodetext = obj.nodetext;
					result = processNodeText(nodetext,obj, nodeHash, textboxHash);
					if(!result){
						return false;
					}
				}
				
			}else{
				trace("Node has no node text");
			}
			return true;
		}
		
		protected function processNodeText(nodetext:Object, node:Object,  nodeHash:Dictionary, textboxHash:Dictionary):Boolean{
			var statementModel:StatementModel = nodeHash[node.ID];
			var simpleStatement:SimpleStatementModel;
			if(!statementModel.hasStatement(nodetext.ID)){
				simpleStatement = new SimpleStatementModel;
				simpleStatement.ID = nodetext.textboxID;
			}
			else{
				simpleStatement = statementModel.getStatement(nodetext.ID);
			}
			
			if(!statementModel.hasStatement(simpleStatement.ID)){
				statementModel.statements.push(simpleStatement);
				statementModel.nodeTextIDs.push(nodetext.ID);
			}
			
			textboxHash[simpleStatement.ID] = simpleStatement;
			return true;
		}
		
		//----------------------- Parsing Connections ---------------------------------------//
		/**
		 * Parses connections in the map
		 **/
		protected function parseConnection(map:Object, connectionsHash:Dictionary, nodeHash:Dictionary):Boolean{
			var obj:Object;
			var result:Boolean;
			if(map.hasOwnProperty("connection")){
				var argumentTypeModel:ArgumentTypeModel;
				if(map.connection is ArrayCollection){
					for each(obj in map.connection){
						result = processConnection(obj, connectionsHash, nodeHash);
						if(!result){
							return false;
						}
					}
				}
				else{
					obj = map.connection;
					result = processConnection(obj, connectionsHash, nodeHash);
					if(!result){
						return false;
					}
				}
			}
			
			return true;
		}
		
		protected function processConnection(obj:Object, connectionsHash:Dictionary, nodeHash:Dictionary):Boolean{
			var argumentTypeModel:ArgumentTypeModel;
			var result:Boolean;
			if(obj.deleted != 0){
				if(connectionListHash.hasOwnProperty(obj.ID)){
					argumentTypeModel = ArgumentTypeModel.createArgumentTypeFromObject(obj);
				}else{
					argumentTypeModel = connectionListHash[obj.ID];
				}
				argumentTypeModel.dbType = obj.type;
				argumentTypeModel.claimModel = nodeHash[obj.targetnode];
				argumentTypeModel.xgrid = obj.x;
				argumentTypeModel.ygrid = obj.y;
				argumentTypeModel.typed = obj.typed == 1? true:false;
				connectionsHash[obj.ID] = argumentTypeModel;
				
				result = parseSourceNode(obj, nodeHash, connectionsHash);
				if(!result){
					return false;
				}	
			}
			return true;
		}
		
		//----------------------- Parsing Source Nodes --------------------------------------//
		protected function parseSourceNode(obj:Object, nodeHash:Dictionary, connectionsHash:Dictionary):Boolean
		{
			if(obj.hasOwnProperty("sourcenode")){
				if(obj.sourcenode is ArrayCollection){
					for each(var argElements:Object in obj.sourcenode){
						//If read in this loading phase
						var result:Boolean = processSourceNode(argElements,obj,connectionsHash, nodeHash);
						if(!result){
							return false;
						}
					}	
				}
				else{
					trace("error: Only one sourcenode found!");
					return false;
				}
			}
			var argumentTypeModel:ArgumentTypeModel = connectionsHash[obj.ID];
			argumentTypeModel.logicClass.link();
			return true;
		}
		
		protected function processSourceNode(argElements:Object, obj:Object, connectionsHash:Dictionary, nodeHash:Dictionary):Boolean{
			var argumentTypeModel:ArgumentTypeModel;
			if(nodeHash.hasOwnProperty(argElements.nodeID)){
				if(nodeHash[argElements.nodeID] is InferenceModel){
					argumentTypeModel.inferenceModel = nodeHash[argElements.nodeID];
				}
				else{
					if(!argumentTypeModel.hasReason(argElements.nodeID)){
						argumentTypeModel.reasonModels.push(nodeHash[argElements.nodeID]);
					}
				}
			}
			else{ //read earlier
				if(panelListHash[argElements.nodeID] is InferenceModel){
					argumentTypeModel.inferenceModel = panelListHash[argElements.nodeID];
				}
				else{
					if(!argumentTypeModel.hasReason(argElements.nodeID)){
						argumentTypeModel.reasonModels.push(panelListHash[argElements.nodeID]);
					}
				}
			}
			return true;
		}
		
		//----------------------- Parsing Textboxes -----------------------------------------//
		protected function parseTextox(map:Object, textboxHash:Dictionary):Boolean{
			var obj:Object;
			var simpleStatement:SimpleStatementModel;
			var result:Boolean;
			if(map.hasOwnProperty("textbox")){
				//many textboxes
				if(map.textbox is ArrayCollection){
					for each(obj in map.textbox){
						result = processTextbox(obj, textboxHash);
						if(!result){
							return false;
						}
					}
				}
				else{
					obj = map.textbox;
					result = processTextbox(obj, textboxHash);
					if(!result){
						return false;
					}
				}
			}
			return true;
		}
		
		protected function processTextbox(obj:Object, textboxHash:Dictionary):Boolean{
			var simpleStatement:SimpleStatementModel;
			if(obj.deleted == "0"){
				//fetch simpleStatementModel from Dictionary
				simpleStatement = textboxHash[obj.ID];
				//update text
				simpleStatement.text = obj.text;
				if(obj.text == SimpleStatementModel.DEPENDENT_TEXT){
					simpleStatement.hasOwn = false;
				}
			}
			return true;
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