package Controller
{
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	import Model.ArgumentTypeModel;
	import Model.StatementModel;
	
	import ValueObjects.AGORAParameters;
	
	import components.AgoraMap;
	import components.GridPanel;
	
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
			if(!model.requested){
				model.requested = true;
				model.agoraMapModel.loadMapModel();
			}
		}
		
		protected function onMapLoaded(event:AGORAEvent):void{
			
			var agoraMap:AgoraMap = FlexGlobals.topLevelApplication.map.agoraMap;
			//get the vector of elements to be removed, and then remove
			//them from map
			var gridPanel:GridPanel;
			for each(var object:Object in model.agoraMapModel.deletedList){
				if(object is ArgumentTypeModel){
					var atm:ArgumentTypeModel = object as ArgumentTypeModel;
					gridPanel = agoraMap.menuPanelsHash[atm.ID];
				}
				else if(object is StatementModel){
					var sm:StatementModel = object as StatementModel;
					gridPanel = agoraMap.panelsHash[sm.ID];
				}
				agoraMap.removeChild(gridPanel);
			}
			
			//empty the list
			model.agoraMapModel.deletedList.splice(0, model.agoraMapModel.deletedList.length);
			
			//set the title
			
			//FlexGlobals.topLevelApplication.map.title.title = model.agoraMapModel.name;
			//trace(model.agoraMapModel.name);
			FlexGlobals.topLevelApplication.map.agoraMap.invalidateProperties();
			FlexGlobals.topLevelApplication.map.agoraMap.invalidateDisplayList();
			FlexGlobals.topLevelApplication.map.agoraMap.timer.stop();
			FlexGlobals.topLevelApplication.map.agoraMap.timer.start();
			
			model.requested = false;
		}
		
		protected function onMapLoadingFailed(event:AGORAEvent):void{
			model.requested = false;
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