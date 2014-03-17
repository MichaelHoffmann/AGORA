package Model 
{
	import Controller.AGORAController;
	import Events.*;
	
	import ValueObjects.*;
	
	import classes.Language;
	
	import flash.events.*;
	
	import mx.controls.*;
	import mx.core.FlexGlobals;
	import mx.rpc.events.*;
	import mx.rpc.http.*;
	
	public class MoveMap extends flash.events.EventDispatcher
	{
		public function MoveMap()
		{

			super();
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().moveMapToProjectURL;
			this.request.resultFormat = "e4x";
			request.requestTimeout = 3;
			request.addEventListener(mx.rpc.events.ResultEvent.RESULT, this.onResult);
			request.addEventListener(mx.rpc.events.FaultEvent.FAULT, this.onFault);
		}
		
		public function send(mapID:int, projName:String):void
		{			

			var usm:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			if(usm.loggedIn()){
				FlexGlobals.topLevelApplication.rightSidePanel.chat.projectsSockHandler.nodeId=projName;

				request.send({uid:usm.uid,pass_hash:usm.passHash, map_id:mapID, category_id:projName});	
			}
		}
		
		protected function onResult(arg1:mx.rpc.events.ResultEvent):void
		{			

			AGORAController.getInstance().onMapAdded();
			dispatchEvent(new AGORAEvent(AGORAEvent.MAP_ADDED));//not sending, using direct calling to workaround
			// category sockets
			FlexGlobals.topLevelApplication.rightSidePanel.chat.projectsSockHandler.sendNodeInfoMessage();

		}
		
		protected function onFault(event:FaultEvent):void{
			Alert.show(Language.lookup('MapToProjError')); //To translate
		}
		
		internal var request:mx.rpc.http.HTTPService;
	}
}
