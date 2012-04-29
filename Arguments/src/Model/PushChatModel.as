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
		
		/**
		 * Creates a chatmodel object. This constructor simply creates the HTTP request
		 * 
		 * Success: onChatPushed
		 * Fail: onFault 
		 */
		public function ChatModel():void
		{	
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().chatPushURL;
			request.resultFormat="e4x";
			request.addEventListener(ResultEvent.RESULT, onChatPushed);
			request.addEventListener(FaultEvent.FAULT, onFault);
		}
		
		/**
		 * Sends a chat data value object filled with the proper information to the database once the user hits send
		 * in the chat box
		 */
		public function pushChat(text:String):void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			var chatdatavo:ChatDataVO = new ChatDataVO;
			chatdatavo.map_name = AGORAModel.getInstance().agoraMapModel.name;
			chatdatavo.textMessage = text;
			chatdatavo.username = userSessionModel.username;
			userSessionModel.push_chat(chatdatavo);
		}
		
		/**
		 * This is called on a successful return from the PHP
		 */
		protected function onChatPushed(event:ResultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.CHAT_PUSHED));
		}
		
		/**
		 * This is called on a unsuccessful return from the PHP
		 */
		protected function onFault(event:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
		
		
	}
}
