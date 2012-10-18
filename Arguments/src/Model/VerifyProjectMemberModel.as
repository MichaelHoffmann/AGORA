package Model
{
	import Controller.AGORAController;
	import Controller.ArgumentController;
	import Controller.UserSessionController;
	
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	import ValueObjects.ChatDataVO;
	
	import classes.Language;
	
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.controls.List;
	import mx.core.FlexGlobals;
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	

	public class VerifyProjectMemberModel extends EventDispatcher
	{
		private var request: HTTPService;
		private var loadProjMaps:LoadProjectMapsModel;
		public var verified:Boolean;
		private var currTime:Date;
		public function VerifyProjectMemberModel()
		{
			currTime = new Date;
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().joinProjectURL;
			request.resultFormat="e4x";
			request.addEventListener(ResultEvent.RESULT, onSuccessfulJoin);
			request.addEventListener(FaultEvent.FAULT, onFault);
			verified = false;
		}
		
		public function send():void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			currTime = new Date;
			if(userSessionModel.loggedIn()){
				request.send({pass_hash: userSessionModel.passHash, projID: AGORAModel.getInstance().agoraMapModel.projectID,
					user_id: userSessionModel.uid});	
			}
		}
		
		protected function onSuccessfulJoin(event:ResultEvent):void{
			
			var result:XML = event.result as XML;
			if(result.@verified != 1){
				verified = false;
				Alert.show(Language.lookup('NotMember') + 
					result.@project_admin_firstname + " " + result.@project_admin_lastname + '\n' + "URL: " + result.@admin_url);
				AGORAModel.getInstance().agoraMapModel.projectID = AGORAModel.getInstance().agoraMapModel.tempprojectID;				
				AGORAModel.getInstance().agoraMapModel.projID = AGORAModel.getInstance().agoraMapModel.tempprojID;	
				return;
			}
			
			verified = true;
			dispatchEvent(new AGORAEvent(AGORAEvent.PROJECT_USER_VERIFIED));
		}
		
		protected function onGotMapID(event:ResultEvent):void{
			var result:XML = event.result as XML;
			if(result.@mapID){
				ArgumentController.getInstance().loadMap(result.@mapID);
			}
		}
		
		protected function onFault(event:FaultEvent):void{
			Alert.show(Language.lookup('NotProjMember'));
		}
	}
}