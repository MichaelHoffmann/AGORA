package Model
{
	import Controller.ArgumentController;
	import Controller.UserSessionController;
	
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
		private var request2: HTTPService;
		public function VerifyProjectPasswordModel()
		{
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().joinProjectURL;
			request.resultFormat="e4x";
			request.addEventListener(ResultEvent.RESULT, onSuccessfulJoin);
			request.addEventListener(FaultEvent.FAULT, onFault);
			request = new HTTPService;
			request2.url = AGORAParameters.getInstance().getMapFromProjURL;
			request2.resultFormat="e4x";
			request2.addEventListener(ResultEvent.RESULT, onGotMapID);
			request2.addEventListener(FaultEvent.FAULT, onFault);
		}
		
		public function send():void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			if(userSessionModel.loggedIn()){
				request.send({pass_hash: AGORAModel.getInstance().agoraMapModel.projectPassword, projID: AGORAModel.getInstance().agoraMapModel.projectID});	
			}
		}
		
		protected function onSuccessfulJoin(event:ResultEvent):void{
			var result:XML = event.result as XML;
			if(result.@project_count == "1"){
				
//				FlexGlobals.topLevelApplication.map.visible = true;
			} else{
				Alert.show("Incorrect Password");
			}
			dispatchEvent(new AGORAEvent(AGORAEvent.PROJECT_PASSWORD_VERIFIED));
		}
		
		protected function onGotMapID(event:ResultEvent):void{
			var result:XML = event.result as XML;
			if(result.@mapID){
				ArgumentController.getInstance().loadMap(result.@mapID);
			}
		}
		
		protected function onFault(event:FaultEvent):void{
			Alert.show("Incorrect Password");
		}
	}
}