package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class ProjectsModel extends EventDispatcher
	{
		public var projectList:XML;
		private var request:HTTPService;
		
		public function ProjectsModel()
		{
			super();
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().myProjectsURL;
			request.resultFormat = "e4x";
			request.requestTimeout = 3;
			request.addEventListener(ResultEvent.RESULT, onResult);
			request.addEventListener(FaultEvent.FAULT, onFault);
		}
		
		public function sendRequest():void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			if(userSessionModel.loggedIn()){
				request.send({uid: userSessionModel.uid, pass_hash: userSessionModel.passHash});	
			}
		}
		
		protected function onResult(event:ResultEvent):void{
			projectList = event.result as XML;
			dispatchEvent(new AGORAEvent(AGORAEvent.MY_PROJECTS_LIST_FETCHED));
		}
		
		protected function onFault(event:FaultEvent)    :void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
	}
}