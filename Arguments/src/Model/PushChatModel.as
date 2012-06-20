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
		public function PushChatModel():void
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
			var temp:int = AGORAModel.getInstance().agoraMapModel.ID;
			if(!temp) temp = 0;
			request.send({username: userSessionModel.username, text: text, map_id: temp});
		}
		
		protected function onChatPushed(event:ResultEvent):void{			
			event.target.removeEventListener(ResultEvent.RESULT, onChatPushed);
			event.target.removeEventListener(FaultEvent.FAULT, onFault);
			dispatchEvent(new AGORAEvent(AGORAEvent.CHAT_FETCHED));
		}
		
		protected function onFault(event:FaultEvent):void{
			event.target.removeEventListener(ResultEvent.RESULT, onChatPushed);
			event.target.removeEventListener(FaultEvent.FAULT, onFault);
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
			
		}
		
		
	}
}
