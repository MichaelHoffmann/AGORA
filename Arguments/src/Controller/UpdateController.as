package Controller
{
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	
	import components.LAMWorld;
	import components.MapName;
	
	import flash.display.DisplayObject;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	public class UpdateController
	{
		private static var instance:UpdateController;
		private var view:DisplayObject;
		
		public function UpdateController(singletonEnforcer:SingletonEnforcer)
		{
			instance = this;
			view = DisplayObject(FlexGlobals.topLevelApplication);
		}
		
		//----------------get Instance ----------------------------//
		public static function getInstance():UpdateController{
			if(!instance){
				instance = new UpdateController(new SingletonEnforcer);
				
			}
			return instance;
		}
		
		//-------------------------Create Map-------------------------//
		public function createMap(mapName:String):void{
			
		}
		
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
				Alert.show("Only registered users can created a map. If you had already registered, click Sign In.");
			}
		}
		
	}
}

class SingletonEnforcer{
	
}