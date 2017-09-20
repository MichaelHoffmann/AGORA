package Controller
{
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	import Model.ArgumentTypeModel;
	import Model.StatementModel;
	
	import ValueObjects.AGORAParameters;
	
	import components.AgoraMap;
	import components.GridPanel;
	import components.StatusBar;
	
	import flash.utils.Dictionary;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import classes.SWFAddress;
	
	public class LoadController
	{
		private static var instance:LoadController;
		private var model:AGORAModel;
		private var agoraMap:AgoraMap;
		private var sbar:StatusBar;
		
		public function LoadController(singletonEnforcer:SingletonEnforcer)
		{	sbar = FlexGlobals.topLevelApplication.map.sBar;
			AGORAModel.getInstance().agoraMapModel.addEventListener(AGORAEvent.MAP_LOADED, onMapLoaded);
			AGORAModel.getInstance().agoraMapModel.addEventListener(AGORAEvent.MAP_LOADING_FAILED, onMapLoadingFailed);
			instance = this;
			model = AGORAModel.getInstance();
			agoraMap = FlexGlobals.topLevelApplication.map.agoraMap;
		}
		
		//----------------------Get Instance------------------------------//
		public static function getInstance():LoadController{
			if(!instance){
				instance = new LoadController(new SingletonEnforcer);
			}
			return instance;
		}
		
		//-----------------Update Map -----------------------------------//
		public function fetchMapData(tellCollab:Boolean=false):void{						
			if(!model.requested){
				sbar.displayLoading();
				model.requested = true;
				if(tellCollab){
					FlexGlobals.topLevelApplication.rightSidePanel.chat.collabHandler.sendCollabsMessage();
				}
				model.agoraMapModel.loadMapModel();
			}
		}
		
		protected function onMapLoaded(event:AGORAEvent):void{
			sbar.hideStatus();
			//get the vector of elements to be removed, and then remove
			//them from map
			var gridPanel:GridPanel;
			var labelDictionary:Dictionary;
			for each(var object:Object in model.agoraMapModel.deletedList){
				if(object is ArgumentTypeModel){
					var atm:ArgumentTypeModel = object as ArgumentTypeModel;
					gridPanel = agoraMap.menuPanelsHash[atm.ID];
					if(agoraMap.contains(agoraMap.menuPanelsHash[atm.ID]))
						agoraMap.removeChild(agoraMap.menuPanelsHash[atm.ID]);
				}
				else if(object is StatementModel){
					var sm:StatementModel = object as StatementModel;
					gridPanel = agoraMap.panelsHash[sm.ID];
					if(agoraMap.contains(agoraMap.panelsHash[sm.ID]))
						agoraMap.removeChild(agoraMap.panelsHash[sm.ID]);
				}
				if(gridPanel != null && agoraMap.contains(gridPanel))
				agoraMap.removeChild(gridPanel);
			}
			
			//empty the list
			model.agoraMapModel.deletedList.splice(0, model.agoraMapModel.deletedList.length);
			
			//set the title
			FlexGlobals.topLevelApplication.map.agoraMap.invalidateProperties();
			FlexGlobals.topLevelApplication.map.agoraMap.invalidateDisplayList();
			FlexGlobals.topLevelApplication.rightSidePanel.history.invalidateProperties();
			FlexGlobals.topLevelApplication.map.agoraMap.timer.reset();
			FlexGlobals.topLevelApplication.map.agoraMap.timer.start();
			SWFAddress.href('#map='+model.agoraMapModel.ID);
			
			
			//vinodh
			if(model.savedStatement!=null)
			{
				if(FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[model.savedStatement.ID])
				{
					ArgumentController.getInstance().textSavedTry(model.savedStatement);
					//	FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[model.savedStatement.ID].showMenu();
					
					model.savedStatement = null;
				}
				else
				{
					model.agoraMapModel.loadMapModel();
					//flash.events.EventDispatcher.dispatchEvent(new AGORAEvent(AGORAEvent.MAP_LOADED));
				}
				
			}
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