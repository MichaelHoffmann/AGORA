package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class LoadProjectMapsModel extends EventDispatcher
	{
		public var projectMapList:XML;
		private var request:HTTPService;
		public function LoadProjectMapsModel()
		{
			super();
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().loadProjectMapsURL;
			request.resultFormat = "e4x";
			request.requestTimeout = 3;
			request.addEventListener(ResultEvent.RESULT, onResult);
			request.addEventListener(FaultEvent.FAULT, onFault);
		}
		
		public function sendRequest():void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			if(userSessionModel.loggedIn()){
				request.send({proj_id: AGORAModel.getInstance().agoraMapModel.projectID});	
			}
		}
		
		/**
		 * This is an event driven function that is called when the PHP returns without an error.
		 * It first places the result of the event into the projectList variable and then broadcasts
		 * that that we are now finished and have fetched the data from the projects.
		 */
		protected function onResult(event:ResultEvent):void{
			projectMapList = event.result as XML;
			FlexGlobals.topLevelApplication.agoraMenu.projects.onCorrectPassword(projectMapList);
			FlexGlobals.topLevelApplication.agoraMenu.myProjects.onCorrectPassword(projectMapList);
			dispatchEvent(new AGORAEvent(AGORAEvent.MY_PROJECTS_LIST_FETCHED));
		}
		
		/**
		 * If the PHP call resulted in an error, comes to here and broadcasts that we have faulted. 
		 */
		protected function onFault(event:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
	}
}