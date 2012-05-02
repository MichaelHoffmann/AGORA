package Model
{
	import Controller.AGORAController;
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
		
		public function send(mapID:int, projID:int):void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			if(userSessionModel.loggedIn()){
				request.send({map_id: mapID, proj_id: projID});	
			}
		}
		
		protected function onSuccessfulJoin(event:ResultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.MAP_ADDED));
		}
		
		
		protected function onFault(event:FaultEvent):void{
			Alert.show("Could not move the map to the selected project"); //To translate
		}
	}
}