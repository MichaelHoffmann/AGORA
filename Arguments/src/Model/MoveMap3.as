package Model
{
	import Controller.AGORAController;
	import Controller.ArgumentController;
	import Controller.UserSessionController;
	import Events.AGORAEvent;
	import ValueObjects.AGORAParameters;
	import classes.Language;
	import Events.*;
	import ValueObjects.*;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.rpc.events.*;
	import mx.rpc.http.*;
	import flash.events.*;

	
	/**
	 * This class moves a map to a project by taking a map's ID and a project's name
	 * and using the project's ID from the project's name and moving them over to
	 * the map's project ID field.
	 *
	 */
	public class MoveMap3 extends EventDispatcher
	{
		private var request: HTTPService;
		
		/**
		 * Constructor that sets up the request that eventually sends the data off to the database
		 */
		public function MoveMap3()
		{
			
			super();
			request = new HTTPService;
			request.url = AGORAParameters.getInstance().moveMapToProjectURL;
			request.resultFormat="e4x";
			request.addEventListener(ResultEvent.RESULT, onSuccessfulJoin);
			request.addEventListener(FaultEvent.FAULT, onFault);
		}
		
		/**
		 * The method that sends the request off to the database loaded with the correct info
		 */
		public function send(mapID:int, projName:String):void{
			var usm:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			if(usm.loggedIn()){
				request.send({uid:usm.uid,pass_hash:usm.passHash, map_id:mapID, category_id:projName});	
			}
		}

		/**
		 * When we do not return with an error enters here
		 */
		protected function onSuccessfulJoin(event:ResultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.MAP_ADDED));

		}
		
		/**
		 * When we return from the DB with an error, enters here
		 */
		protected function onFault(event:FaultEvent):void{
			Alert.show(Language.lookup('MapToProjError')); //To translate
		}
	}
}