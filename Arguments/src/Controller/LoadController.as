package Controller
{
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	
	import ValueObjects.AGORAParameters;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;

	public class LoadController
	{
		private static var instance:LoadController;
		private var model:AGORAModel;
		
		public function LoadController(singletonEnforcer:SingletonEnforcer)
		{
			AGORAModel.getInstance().agoraMapModel.addEventListener(AGORAEvent.MAP_LOADED, onMapLoaded);
			AGORAModel.getInstance().agoraMapModel.addEventListener(AGORAEvent.MAP_LOADING_FAILED, onMapLoadingFailed);
			
			instance = this;
			model = AGORAModel.getInstance();
		}
		
		//----------------------Get Instance------------------------------//
		public static function getInstance():LoadController{
			if(!instance){
				instance = new LoadController(new SingletonEnforcer);
			}
			return instance;
		}
		
		//-----------------Update Map -----------------------------------//
		public function fetchMapData():void{
			model.agoraMapModel.loadMapModel();
		}
		
		protected function onMapLoaded(event:AGORAEvent):void{
			trace("map loaded");
			FlexGlobals.topLevelApplication.map.agoraMap.invalidateProperties();
			FlexGlobals.topLevelApplication.map.agoraMap.invalidateDisplayList();
			FlexGlobals.topLevelApplication.map.agoraMap.timer.stop();
			FlexGlobals.topLevelApplication.map.agoraMap.timer.start();
		}
		
		protected function onMapLoadingFailed(event:AGORAEvent):void{
			Alert.show(AGORAParameters.getInstance().MAP_LOADING_FAILED);
		}
	
		public function mapUpdateCleanUp():void{
			//####### Should be modified
			//model should be asked to do this
			var newPanels:ArrayCollection = model.agoraMapModel.newPanels;
			newPanels.removeAll();
			var newConnections:ArrayCollection = model.agoraMapModel.newConnections;
			newConnections.removeAll();
		}

	}
}


class SingletonEnforcer{
	
}