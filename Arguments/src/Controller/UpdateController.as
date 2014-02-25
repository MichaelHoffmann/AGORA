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
	
	
	//Recording map meta data into the database.
	//For e.g., map title
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
		
		//---------------------- Updating Map info --------------//
		public function updateMapInfo(title:String):void{
			mapModel.updateMapInfo(title);
		}
		protected function onMapInfoUpdated(event:AGORAEvent):void{
			LoadController.getInstance().fetchMapData(true);		
		}
		protected function onMapInfoUpdateFailed(event:AGORAEvent):void{
			LoadController.getInstance().fetchMapData();
			Alert.show(AGORAParameters.getInstance().UPDATE_MAP_INFO_FAILED);
		}
	}
}

class SingletonEnforcer{
	
}