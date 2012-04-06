package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import flash.events.EventDispatcher;
	import mx.controls.Alert;
	import mx.controls.List;
	import mx.core.FlexGlobals;
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class ChatModel extends EventDispatcher
	{
		
		public var chat:XML;
		private var request: HTTPService;
		
		public function ChatModel()
		{	
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().chatPullURL;
			request.resultFormat="e4x";
			request.addEventListener(ResultEvent.RESULT, onChatFetched);
			request.addEventListener(FaultEvent.FAULT, onFault);
		}
		
		public function requestChat():void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			request.send({username: userSessionModel.username, time: 1,  map_id: 0});
		}
		
		protected function onChatFetched(event:ResultEvent):void{
			chat = event.result as XML;
			dispatchEvent(new AGORAEvent(AGORAEvent.CHAT_FETCHED));
		}
		
		protected function onFault(event:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
		
	}
}