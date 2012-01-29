package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class MapListModel extends EventDispatcher
	{
		public static var reference:MapListModel;
		public var mapListXML:XML;
		private var requestMapService:HTTPService;
		
		public function MapListModel(target:IEventDispatcher=null)
		{
			super(target);
			reference = this;
			requestMapService = new HTTPService;
			requestMapService.resultFormat = "e4x";
			requestMapService.requestTimeout = 10;
			requestMapService.url = AGORAParameters.getInstance().listMapsURL;
			requestMapService.addEventListener(ResultEvent.RESULT, onRequestMapsServiceResult);
			requestMapService.addEventListener(FaultEvent.FAULT, onRequestMapsServiceFault);	
		}
		
		public function requestMapList():void{
			requestMapService.send();
		}	
		
		protected function onRequestMapsServiceResult(event:ResultEvent):void{
			mapListXML = event.result as XML;
			dispatchEvent(new AGORAEvent(AGORAEvent.MAP_LIST_FETCHED));
		}
		
		protected function onRequestMapsServiceFault(event:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
	}
}