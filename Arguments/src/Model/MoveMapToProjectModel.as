package Model
{
	import flash.events.EventDispatcher;
	import Controller.AGORAController;
	import Controller.ArgumentController;
	import Controller.UserSessionController;
	
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	import ValueObjects.ChatDataVO;
		
	import mx.controls.Alert;
	import mx.controls.List;
	import mx.core.FlexGlobals;
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class MoveMapToProjectModel extends EventDispatcher
	{
		private var request: HTTPService;
		public function MoveMapToProjectModel()
		{
			
			super();
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().moveMapToProjectURL;
			request.resultFormat="e4x";
			request.addEventListener(ResultEvent.RESULT, onSuccessfulJoin);
			request.addEventListener(FaultEvent.FAULT, onFault);
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
				//Potentially violating MVC. Need someone to help me consider this..
				var loadProjMaps:LoadProjectMapsModel = new LoadProjectMapsModel;
				loadProjMaps.sendRequest();
			} else {
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