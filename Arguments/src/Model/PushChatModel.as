package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	import ValueObjects.ChatDataVO;
	
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.controls.List;
	import mx.core.FlexGlobals;
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class PushChatModel extends EventDispatcher
	{
		
		private var request: HTTPService;
		public function ChatModel():void
		{	
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().chatPushURL;
			request.resultFormat="e4x";
			request.addEventListener(ResultEvent.RESULT, onChatPushed);
			request.addEventListener(FaultEvent.FAULT, onFault);
		}
		
		public function pushChat(text:String):void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			var chatdatavo:ChatDataVO = new ChatDataVO;
			chatdatavo.map_type = 0;
			chatdatavo.textMessage = text;
			chatdatavo.time = 99999999;
			chatdatavo.username = userSessionModel.username;
			userSessionModel.push_chat(chatdatavo);
		}
		
		protected function onChatPushed(event:ResultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.CHAT_PUSHED));
		}
		
		protected function onFault(event:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
		
		
	}
}
