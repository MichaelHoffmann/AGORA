package Model
{
	
	import Controller.AGORAController;
	
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import com.adobe.crypto.MD5;
	import com.adobe.serialization.json.JSON;
	
	import flash.events.EventDispatcher;
	import classes.Language;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class PushProject extends EventDispatcher
	{
		public var projectList:XML;
		private var request:HTTPService;
		
		/**
		 * Constructor that takes in nothing and creates the object by first calling the EventDispatcher constructor and then
		 * setting up the HTTP request. Sets timeout to be 3
		 * 
		 * Adds two event listeners, one that calls onResult function for when the PHP returns normally and one that calls onFault
		 * for when it returns ungracefully
		 */
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
		
		/**
		 * Function that officially sends the HTTP request. This gets called when a new project has been created
		 * 
		 */
		public function sendRequest():void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			if(userSessionModel.loggedIn()){				
				var params:Object = {uid: userSessionModel.uid, pass_hash: userSessionModel.passHash, projID: 0, title: AGORAModel.getInstance().agoraMapModel.projectName, is_hostile: AGORAModel.getInstance().agoraMapModel.projectType,'user_count':AGORAModel.getInstance().agoraMapModel.numberUsers,'proj_users[]':AGORAModel.getInstance().agoraMapModel.projectUsers};		
				request.send(params);
			}
		}
		
		/**
		 * If the sendRequest method comes back normally, we enter here and broadcast PROJECT_PUSHED event
		 */
		protected function onResult(event:ResultEvent):void{
			//check for error
			if(event.result.hasOwnProperty("proj")){
				if(event.result.proj.hasOwnProperty("error")){
					dispatchEvent(new AGORAEvent(AGORAEvent.PROJECT_PUSH_FAILED));
					return;
				}
			}
			dispatchEvent(new AGORAEvent(AGORAEvent.PROJECT_PUSHED));
		}
		
		/**
		 * If the sendRequest method comes back poorly, we enter here and broadcast the FAULT event
		 */
		protected function onFault(event:FaultEvent)    :void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
	}
}