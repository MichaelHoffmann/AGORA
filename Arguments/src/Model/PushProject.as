package Model
{
	
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import com.adobe.crypto.MD5;
	
	import flash.events.EventDispatcher;
	
	import mx.core.FlexGlobals;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class PushProject
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
				request.send({uid: userSessionModel.uid, pass_hash: userSessionModel.passHash, projID: 0, newpass: MD5.hash(FlexGlobals.topLevelApplication.map.lamWorld.password), title: AGORAModel.getInstance().agoraMapModel.name, is_hostile: 0});	
			}
		}
		
		protected function onResult(event:ResultEvent):void{
			projectList = event.result as XML;
//			dispatchEvent(new AGORAEvent(AGORAEvent.MY_PROJECTS_LIST_FETCHED));
		}
		
		protected function onFault(event:FaultEvent)    :void{
//			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
	}
}