package Controller
{
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	
	import mx.core.FlexGlobals;

	public class LoadController
	{
		private static var instance:LoadController;
		private var model:AGORAModel;
		
		public function LoadController(singletonEnforcer:SingletonEnforcer)
		{
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
		
		protected function onMapDataFetched(event:AGORAEvent):void{
			FlexGlobals.topLevelApplication.map.agoraMap.timer.stop();
			FlexGlobals.topLevelApplication.map.agoraMap.timer.start();
			trace('onMapDataFetched called');
			
		}

	}
}


class SingletonEnforcer{
	
}