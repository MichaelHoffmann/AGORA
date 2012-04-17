package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	import ValueObjects.ChatDataVO;
	
	import components.AGORAMenu;
	import components.Map;
	
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
			request.addEventListener(ResultEvent.RESULT, onChatServiceResult);
			request.addEventListener(FaultEvent.FAULT, onChatServiceFault);
			addEventListener(AGORAEvent.CHAT_FETCHED,onChatFetched);

		}
		
		public function requestChat():void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			var chatdatavo:ChatDataVO = new ChatDataVO();
			chatdatavo.map_name  = AGORAModel.getInstance().agoraMapModel.name;
			chatdatavo.textMessage = "";
			chatdatavo.time = 99999999;
			chatdatavo.username = AGORAModel.getInstance().userSessionModel.username;
			request.send({map_name: "'" + chatdatavo.map_name + "'"});
		}
		
		protected function onChatFetched(event:ResultEvent):void{
			FlexGlobals.topLevelApplication.agoraMenu.chat.invalidateProperties();
			FlexGlobals.topLevelApplication.agoraMenu.chat.invalidateDisplayList();
			FlexGlobals.topLevelApplication.map.chat.invalidateProperties();
			FlexGlobals.topLevelApplication.map.chat.invalidateDisplayList();
		}
	
		protected function onChatServiceResult(event:ResultEvent):void{
			chat = event.result as XML;
			
			//event.target.removeEventListener(ResultEvent.RESULT, onChatServiceResult);
			//event.target.removeEventListener(FaultEvent.FAULT, onChatServiceFault);
			onChatFetched(event);
		}
		
		protected function onChatServiceFault(event:FaultEvent):void{
			//event.target.removeEventListener(ResultEvent.RESULT, onChatServiceResult);
			//event.target.removeEventListener(FaultEvent.FAULT, onChatServiceFault);
			FlexGlobals.topLevelApplication.agoraMenu.chat.chatField.text = "Network Error While Loading Chat Information";
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));

		}
		
	}
}