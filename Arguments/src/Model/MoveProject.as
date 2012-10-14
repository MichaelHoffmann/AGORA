package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import classes.Language;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class MoveProject extends EventDispatcher
	{
		public var category:XML;
		private var request: HTTPService;
		private var requestChildren: HTTPService;
		private var MoveProjectIntoProject:HTTPService;
		public function MoveProject(target:IEventDispatcher=null)
		{
			super(target);
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().categoryURL;
			request.resultFormat="e4x";
			request.addEventListener(ResultEvent.RESULT, onCategoryFetched);
			request.addEventListener(FaultEvent.FAULT, onFault);
			requestChildren = new HTTPService;
			requestChildren.url = AGORAParameters.getInstance().childCategoryURL;
			requestChildren.resultFormat="e4x";
			requestChildren.addEventListener(ResultEvent.RESULT, onCategoryFetchedLowlevel);
			requestChildren.addEventListener(FaultEvent.FAULT, onFault);
			MoveProjectIntoProject = new HTTPService;
			MoveProjectIntoProject.url = AGORAParameters.getInstance().moveprojectToProjectURL;
			MoveProjectIntoProject.resultFormat="e4x";
			MoveProjectIntoProject.addEventListener(ResultEvent.RESULT, onProjectMoved);
			MoveProjectIntoProject.addEventListener(FaultEvent.FAULT, onFault);
		}
		
		public function sendForTopLevel():void{
			request.send();
		}
		
		public function moveProject(proj_id:int, target_proj_id:int):void{
			MoveProjectIntoProject.send({proj_id: proj_id, target_proj_id: target_proj_id,
				uid: AGORAModel.getInstance().userSessionModel.uid,
				pass_hash: AGORAModel.getInstance().userSessionModel.passHash});
		}
		
		public function sendForChildren(categoryName:String):void{
			requestChildren.send({parentCategory: "'"+categoryName+"'",action:'projects',uid:AGORAModel.getInstance().userSessionModel.uid});
		}
		protected function onCategoryFetched(event:ResultEvent):void{
			category= event.result as XML;
			dispatchEvent(new AGORAEvent(AGORAEvent.CATEGORY_FETCHED_FOR_MOVEPROJECT));
		}
		
		protected function onCategoryFetchedLowlevel(event:ResultEvent):void{
			category= event.result as XML;
			var result:XML = event.result as XML;
			if(result.hasOwnProperty("error") && result.error.@Verified != 1){
				Alert.show(Language.lookup('NotProjMember') + 
					result.error.@project_admin_firstname + " " + result.error.@project_admin_lastname + '\n' + "URL: " + result.error.@admin_url);
				return;
			}
			dispatchEvent(new AGORAEvent(AGORAEvent.CATEGORY_FETCHED_FOR_MOVEPROJECT));
		}
		protected function onProjectMoved(event:ResultEvent):void{
			if(event.result.hasOwnProperty("error")){
				if(event.result.error.@code == "311" || event.result.error.@code == 311)
					FlexGlobals.topLevelApplication.moveProject.informationLabel.text = Language.lookup("NotProjMemberProjects");
				else
					FlexGlobals.topLevelApplication.moveProject.informationLabel.text = Language.lookup("UnsuccessfullyPublishedProject");
			} else {
				FlexGlobals.topLevelApplication.moveProject.informationLabel.text = Language.lookup("SuccessfullyPublishedProject");
				FlexGlobals.topLevelApplication.moveProject.okayButton.visible = false;
				FlexGlobals.topLevelApplication.moveProject.cancelButton.label = Language.lookup('OK');				
			}
			dispatchEvent(new AGORAEvent(AGORAEvent.PROJECT_MOVED));
		}
		protected function onFault(event:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
	}
}