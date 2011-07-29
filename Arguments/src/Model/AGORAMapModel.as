package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import components.Map;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class AGORAMapModel extends EventDispatcher
	{	
		private var _panelListHash:Object;
		
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
			
			panelListHash = new Object;
			timestamp = "0";
		}
		
		//-------------------------Getters and Setters--------------------------------//
		
		public function get panelListHash():Object
		{
			return _panelListHash;
		}
		
		public function set panelListHash(value:Object):void
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
								<textbox text=""/>
								<textbox text=""/>
								<node TID="1" Type="Universal" typed="0" is_positive="1"  x="2" y="3">
									<nodetext/><nodetext /><nodetext />
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
				
				
				//-------textboxes & nodetext----------//
				var simpleStatement:SimpleStatementModel = null;
				
				
				if(map.textbox is ArrayCollection){
					//read first textbox as statement
					simpleStatement = new SimpleStatementModel;
					
					simpleStatement.ID = map.textbox[0].ID;
					simpleStatement.text = map.textbox[0].text;
					statementModel.statement = simpleStatement;
					statementModel.nodeTextID = map.node.nodetext[0].ID;
					
					//read subsequent textboxes
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
					statementModel.statement = simpleStatement;
					statementModel.nodeTextID = map.node.nodetext.ID;
				}
				
				
				
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
			
			
			//Form a map of connections
			
			
			
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