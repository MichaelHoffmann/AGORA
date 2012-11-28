package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.controls.List;
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class ProjectListModel extends EventDispatcher
	{
		public var projectList:XML;
		private var request: HTTPService;
		
		public function ProjectListModel()
		{
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().projectListURL;
			request.resultFormat="e4x";
			request.addEventListener(ResultEvent.RESULT, onProjectListFetched);
			request.addEventListener(FaultEvent.FAULT, onFault);
		}
		
		public function requestProjectList():void{

			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			if(userSessionModel.loggedIn()){
				var params:Object = {uid: userSessionModel.uid, pass_hash: userSessionModel.passHash};
				request.send(params);
			}
		}
		
		protected function onProjectListFetched(event:ResultEvent):void{
			projectList = event.result as XML;
			dispatchEvent(new AGORAEvent(AGORAEvent.PROJECT_LIST_FETCHED));
		}
		
		protected function onFault(event:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
		
		
	}
}