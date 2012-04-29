package Model
{
	
	import Controller.AGORAController;
	
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import com.adobe.crypto.MD5;
	
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class PushProject extends EventDispatcher
	{
		public var projectList:XML;
		private var request:HTTPService;
		public function PushProject()
		{
			super();
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().pushProjectsURL;
			request.resultFormat = "e4x";
			request.requestTimeout = 3;
			request.addEventListener(ResultEvent.RESULT, onResult);
			request.addEventListener(FaultEvent.FAULT, onFault);
		}
		
		public function sendRequest():void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			if(userSessionModel.loggedIn()){
				request.send({uid: userSessionModel.uid, pass_hash: userSessionModel.passHash, 
					newpass: AGORAModel.getInstance().agoraMapModel.projectPassword, projID: 0, title: AGORAModel.getInstance().agoraMapModel.name, is_hostile: 0});	
			}
		}
		
		protected function onResult(event:ResultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.PROJECT_PUSHED));
		}
		
		protected function onFault(event:FaultEvent)    :void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
	}
}