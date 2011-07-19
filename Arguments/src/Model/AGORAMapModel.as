package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class AGORAMapModel extends EventDispatcher
	{
		
		private var createMapService: HTTPService;
		private var createNodeService: HTTPService;
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
		}
		
		//-------------------------Getters and Setters--------------------------------//
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
		
		//----------------------- Reinitializing the model ----------------------------------//
		public function reinitializeModel():void{
			
		}
		
		//----------------------- Generic Fault Event  Handler-------------------------------//
		protected function onFault(event:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));	
		}
	}
}