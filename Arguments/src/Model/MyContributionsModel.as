package Model
{
	import Controller.AGORAController;
	
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.controls.List;
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class MyContributionsModel extends EventDispatcher
	{
		public var category: XML;
		public var map:XML;
		public var project:XML;
		public var contributions:XML;
		private var request: HTTPService;
		private var requestChildren: HTTPService;
		private var requestChildMap: HTTPService;
		private var requestChildProject: HTTPService;
		private var requestContributions: HTTPService;
		public function MyContributionsModel()
		{
			
			requestContributions = new HTTPService;
			requestContributions.url = AGORAParameters.getInstance().myContributionsURL;
			requestContributions.resultFormat="e4x";
			requestContributions.addEventListener(ResultEvent.RESULT, onContributionsFetched);
			requestContributions.addEventListener(FaultEvent.FAULT, onFault);
			requestChildren = new HTTPService;
			requestChildren.url = AGORAParameters.getInstance().childCategoryURL;
			requestChildren.resultFormat="e4x";
			requestChildren.addEventListener(ResultEvent.RESULT, onChildCategoryFetched);
			requestChildren.addEventListener(FaultEvent.FAULT, onFault);
			requestChildMap = new HTTPService;
			requestChildMap.url = AGORAParameters.getInstance().childMapURL;
			requestChildMap.resultFormat="e4x";
			requestChildMap.addEventListener(ResultEvent.RESULT, onMapFetched);
			requestChildMap.addEventListener(FaultEvent.FAULT, onFault);
			requestChildProject = new HTTPService;
			requestChildProject.url = AGORAParameters.getInstance().projectDetailsURL;
			requestChildProject.resultFormat="e4x";
			requestChildProject.addEventListener(ResultEvent.RESULT, onProjectFetched);
			requestChildProject.addEventListener(FaultEvent.FAULT, onFault);
		}
		
		public function requestCategory():void{
			
			request.send();
		}
		
		protected function onContributionsFetched(event:ResultEvent):void
		{
			contributions = event.result as XML;
			dispatchEvent(new AGORAEvent(AGORAEvent.CONTRIBUTIONS_FETCHED));
			
		}
		protected function onChildCategoryFetched(event:ResultEvent):void{
			category= event.result as XML;
			//dispatchEvent(new AGORAEvent(AGORAEvent.CATEGORY_FETCHED));
		}

		protected function onMapFetched(event:ResultEvent):void{
			map = event.result as XML;
			dispatchEvent(new AGORAEvent(AGORAEvent.CHILD_MAP_FETCHED));
		}
		
		protected function onProjectFetched(event:ResultEvent):void{
			project = event.result as XML;
			dispatchEvent(new AGORAEvent(AGORAEvent.CHILD_PROJECT_FETCHED));
		}
		
		protected function onFault(event:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
		
		public function requestChildCategories(categoryName:String):void{
			requestChildren.send({parentCategory: categoryName });
			//requestChildMap.send({parentCategory: "'" + categoryName + "'"});
			
			requestChildMap.send({parentCategory: "'" + categoryName + "'"});
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			if(userSessionModel.loggedIn()){
				var params:Object = {uid: userSessionModel.uid, pass_hash: userSessionModel.passHash ,projID:-1, projName:categoryName};
				requestChildProject.send(params);
			}
		}
		
		public function requestMyContributions():void{
			map=null;
			project=null;
		//	requestChildren.send({parentCategory: "'" + categoryName + "'"});
			//requestChildMap.send({parentCategory: "'" + categoryName + "'"});
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			var params:Object = {uid: userSessionModel.uid, pass_hash: userSessionModel.passHash};
			requestContributions.send(params);
		
		/*	if(userSessionModel.loggedIn()){
				var params:Object = {uid: userSessionModel.uid, pass_hash: userSessionModel.passHash ,projID:-1, projName:categoryName};
				requestChildProject.send(params);
			}*/
		}
		
	}
}// ActionScript file