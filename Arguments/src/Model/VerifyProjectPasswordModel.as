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
	public class VerifyProjectPasswordModel extends EventDispatcher
	{
		private var request: HTTPService;
		public function VerifyProjectPasswordModel()
		{
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().joinProjectURL;
			request.resultFormat="e4x";
			request.addEventListener(ResultEvent.RESULT, onSuccessfulJoin);
			request.addEventListener(FaultEvent.FAULT, onFault);
		}
		
		public function send():void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			if(userSessionModel.loggedIn()){
				request.send({projID: AGORAModel.getInstance().agoraMapModel.projectID, pass_hash: AGORAModel.getInstance().agoraMapModel.projectPassword});	
			}
		}
		
		protected function onSuccessfulJoin(event:ResultEvent):void{
			Alert.show("Success! :D");
			dispatchEvent(new AGORAEvent(AGORAEvent.PROJECT_PASSWORD_VERIFIED));
		}
		
		protected function onFault(event:FaultEvent):void{
			Alert.show("Incorrect Password");
		}
	}
}