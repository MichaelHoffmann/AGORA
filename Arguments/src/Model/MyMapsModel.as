package Model
{
	import Events.NetworkEvent;
	
	import ValueObjects.AGORAParameters;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class MyMapsModel extends EventDispatcher
	{
		public var myMapsXML:XML;
		public function MyMapsModel(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function requestMapList():void{
			var requestMapService:HTTPService = new HTTPService;
			requestMapService.resultFormat = "e4x";
			requestMapService.url = AGORAParameters.getInstance().listMapsURL;
			requestMapService.addEventListener(ResultEvent.RESULT, onRequestMapsServiceResult);
			requestMapService.addEventListener(FaultEvent.FAULT, onRequestMapsServiceFault);
			requestMapService.send();
		}
	
		private function onRequestMapsServiceResult(event:ResultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onRequestMapsServiceResult);
			event.target.removeEventListener(FaultEvent.FAULT, onRequestMapsServiceFault);
			myMapsXML = event.result as XML;
			dispatchEvent(new NetworkEvent(NetworkEvent.MAP_LIST_FETCHED));
		}
		
		private function onRequestMapsServiceFault(event:FaultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onRequestMapsServiceResult);
			event.target.removeEventListener(FaultEvent.FAULT, onRequestMapsServiceFault);
			dispatchEvent(new NetworkEvent(NetworkEvent.FAULT));
		}
		
	}
}