package Controller
{
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	import Model.MapMetaData;
	
	import flash.display.DisplayObject;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;

	public class ArgumentController
	{
		private static var instance:ArgumentController;
		private var view:DisplayObject;
		private var model:AGORAModel;
		
		public function ArgumentController(singletonEnforcer:SingletonEnforcer)
		{
			instance = this;	
			view = DisplayObject(FlexGlobals.topLevelApplication);
			model = AGORAModel.getInstance();
			
			//---------------- Event Handlers ---------------------------//
			model.agoraMapModel.addEventListener(AGORAEvent.MAP_CREATED, onMapCreated);
			model.agoraMapModel.addEventListener(AGORAEvent.FAULT, onFault);
			
		}
		
		//---------------------Get Instance -----------------------------//
		public static function getInstance():ArgumentController{
			if(!instance){
				instance = new ArgumentController(new SingletonEnforcer);
			}
			return instance;
		}
		
		//---------------------Creating a New Map-----------------------//
		public function createMap(mapName:String):void{
			model.agoraMapModel.createMap(mapName);	
		}
		
		protected function onMapCreated(event:AGORAEvent):void{
			var map:MapMetaData = event.eventData as MapMetaData;
			AGORAController.getInstance().unfreeze();
			PopUpManager.removePopUp(FlexGlobals.topLevelApplication.mapNameBox);
			AGORAModel.getInstance().agoraMapModel.ID = map.mapID;
		}
		
		//-------------------Generic Fault Handler---------------------//
		protected function onFault(event:AGORAEvent):void{
			Alert.show("Error occurred. Please make sure you are connected to the internet");
		}
		
	}
}

class SingletonEnforcer{}