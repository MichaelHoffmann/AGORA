package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	import ValueObjects.ChatDataVO;
	
	import classes.Language;
	
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
		
		/**
		 * Creates the ChatModel(CM) object. Simply instantiates the HTTP Request and configures it to use the appropriate 
		 * configurations.
		 * 
		 * This also adds the event listeners to the request; where it goes is discernable by the resulting function call. The 
		 * methods for both the failure and success are contained within this class. See those comments for more detail.
		 * 
		 * Success: onChatServiceResult
		 * Failure: onChatServiceFault 
		 * 
		 * Generic Class Wide Event Listener: onChatFetched
		 */
		public function ChatModel()
		{	
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().chatPullURL;
			request.resultFormat="e4x";
			request.addEventListener(ResultEvent.RESULT, onChatServiceResult);
			request.addEventListener(FaultEvent.FAULT, onChatServiceFault);
			
		}
		
		/**
		 * The send request for chat. Populates a Chat Data Value Object and sends it off. There
		 * is more to this than meets the eye. This function gets called repeatedly so the 
		 * population here corrects issues with the population of cdvo.
		 */
		public function requestChat():void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			var temp:int = AGORAModel.getInstance().agoraMapModel.ID;
			if(!temp) temp = 0;
			request.send({map_id: temp});
		}
		
		
		/**
		 * This is called upon successfully leaving the PHP. Populates the value object and calls onChatFetched to
		 * invalidate the displays
		 */
		protected function onChatServiceResult(event:ResultEvent):void{
			chat = event.result as XML;
			
			dispatchEvent(new AGORAEvent(AGORAEvent.CHAT_FETCHED));
			
		}
		
		/**
		 * This is called upon unsuccessfully leaving the PHP. Displays an error message in the chat window
		 */
		protected function onChatServiceFault(event:FaultEvent):void{
			FlexGlobals.topLevelApplication.rightSidePanel.chat.chatField.text = Language.lookup('ChatError');
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
		
	}
}