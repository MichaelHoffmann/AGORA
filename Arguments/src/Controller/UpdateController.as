package Controller
{
	import Events.AGORAEvent;
	
	import Model.AGORAMapModel;
	import Model.AGORAModel;
	import Model.StatementModel;
	
	import ValueObjects.AGORAParameters;
	
	import components.ArgumentPanel;
	import components.GridPanel;
	import components.LAMWorld;
	import components.Map;
	import components.MapName;
	import components.TitleDisplay;
	
	import flash.display.DisplayObject;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	public class UpdateController
	{
		private static var instance:UpdateController;
		private var view:DisplayObject;
		private var mapModel:AGORAMapModel;
		
		
		
		public function UpdateController(singletonEnforcer:SingletonEnforcer)
		{
			instance = this;
			view = DisplayObject(FlexGlobals.topLevelApplication);
			mapModel = AGORAModel.getInstance().agoraMapModel;
			mapModel.addEventListener(AGORAEvent.MAP_INFO_UPDATE_FAILED, onMapInfoUpdateFailed);
			mapModel.addEventListener(AGORAEvent.MAP_INFO_UPDATED, onMapInfoUpdated);
			
			
		}
		
		
		//----------------get Instance ----------------------------//
		public static function getInstance():UpdateController{
			if(!instance){
				instance = new UpdateController(new SingletonEnforcer);
				
			}
			return instance;
		}
		
		//check if this function is called to create a map.
		//------------------------Creating a Map---------------//
		public function displayMapInfoBox():void{
			var agoraModel:AGORAModel = AGORAModel.getInstance();
			if(agoraModel.userSessionModel.loggedIn()){
				FlexGlobals.topLevelApplication.mapNameBox = new MapName;
				var mapNameDialog:MapName = FlexGlobals.topLevelApplication.mapNameBox;
				PopUpManager.addPopUp(mapNameDialog,DisplayObject(FlexGlobals.topLevelApplication),true);
				PopUpManager.centerPopUp(mapNameDialog);
			}
			else{
				Alert.show("Only registered users can create a map. If you had already registered, click Sign In.");
			}
		}
		
		//---------------------- Updating Map info --------------//
		public function updateMapInfo(title:String):void{
			mapModel.updateMapInfo(title);
		}
		protected function onMapInfoUpdated(event:AGORAEvent):void{
			LoadController.getInstance().fetchMapData();		
		}
		protected function onMapInfoUpdateFailed(event:AGORAEvent):void{
			LoadController.getInstance().fetchMapData();
			Alert.show(AGORAParameters.getInstance().UPDATE_MAP_INFO_FAILED);
		}
	}
}

class SingletonEnforcer{
	
}