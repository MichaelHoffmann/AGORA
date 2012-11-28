package Model
{
	import Events.AGORAEvent;
	
	import ValueObjects.AGORAParameters;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class MyMapsModel extends EventDispatcher
	{
		private var myMapsXML:XML;
		private var requestMapsService:HTTPService;
		private var removeMapsService:HTTPService;
		
		public function MyMapsModel(target:IEventDispatcher=null)
		{
			
			super(target);
			
			//request maps http service
			requestMapsService = new HTTPService;
			requestMapsService.resultFormat = "e4x";
			requestMapsService.url = AGORAParameters.getInstance().myMapsURL;
			requestMapsService.addEventListener(ResultEvent.RESULT, onRequestMapsServiceResult);
			requestMapsService.addEventListener(FaultEvent.FAULT, onServiceFault);
			
			//remove Maps Service
			removeMapsService = new HTTPService;
			removeMapsService.resultFormat ="e4x";
			removeMapsService.url = AGORAParameters.getInstance().mapRemoveURL;
			removeMapsService.addEventListener(ResultEvent.RESULT, onRemoveMapsServiceResult);
			removeMapsService.addEventListener(FaultEvent.FAULT, onServiceFault);
		}
		
		
		//-----------------------Requesting Map List--------------------------------//
		public function requestMapList():void{
			

			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			if(userSessionModel.loggedIn()){
				
				
				

				requestMapsService.send({uid:userSessionModel.uid, pass_hash:userSessionModel.passHash});
				

			}else{
				Alert.show("Attempting to fetch my maps when the user is not logged in... Please report this error...");
				//TODO: Translate above error
			}
		}
	
		protected function onRequestMapsServiceResult(event:ResultEvent):void{
			myMapsXML = event.result as XML;
			

			dispatchEvent(new AGORAEvent(AGORAEvent.MY_MAPS_LIST_FETCHED, myMapsXML));
		}	
		
		//------------------------Requesting to remove maps-------------------------//
		public function removeMaps(xmlIn:XML):void{
			var userSessionModel:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			trace(xmlIn.toXMLString());
			removeMapsService.send({uid:userSessionModel.uid, pass_hash:userSessionModel.passHash, xml:xmlIn})	;
		}
		
		protected function onRemoveMapsServiceResult(event:ResultEvent):void{
			trace(event.result.toXMLString());
			dispatchEvent(new AGORAEvent(AGORAEvent.MAPS_DELETED));
		}

		//------------------------Fault---------------------------------------------//
		protected function onServiceFault(event:FaultEvent):void{
			dispatchEvent(new AGORAEvent(AGORAEvent.FAULT));
		}
		
		
	}
}