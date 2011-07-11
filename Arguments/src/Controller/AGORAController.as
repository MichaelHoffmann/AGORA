package Controller
{
	import Events.NetworkEvent;
	
	import Model.AGORAModel;
	import Model.MapListModel;
	
	import ValueObjects.UserDataVO;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	
	public class AGORAController extends EventDispatcher
	{
		public function AGORAController(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function fetchDataMapList():void{
			var mapListModel:MapListModel = AGORAModel.getInstance().mapListModel;
			mapListModel.addEventListener(NetworkEvent.MAP_LIST_FETCHED, onMapListFetched);
			mapListModel.addEventListener(NetworkEvent.FAULT, onFault);
			mapListModel.requestMapList();
		}
		
		public function fetchDataMyMaps():void{
			if(AGORAModel.getInstance().userSessionModel.uid){
				AGORAModel.getInstance().myMapsModel.requestMapList();
			}
		}
		
		protected function onMapListFetched(event : NetworkEvent):void{
			trace("Map List Fetched");
			var mapListModel:MapListModel = AGORAModel.getInstance().mapListModel;
			mapListModel.removeEventListener(NetworkEvent.MAP_LIST_FETCHED, onMapListFetched);
			mapListModel.removeEventListener(NetworkEvent.FAULT, onFault);
			FlexGlobals.topLevelApplication.agoraMenu.mapList.invalidateSkinState();
			FlexGlobals.topLevelApplication.agoraMenu.mapList.invalidateProperties();
			FlexGlobals.topLevelApplication.agoraMenu.mapList.invalidateDisplayList();
		}
		
		protected function onFault(event:NetworkEvent):void{
			Alert.show("Network error occurred when fetching map list. Please make sure you are connected to the internet");
		}
		
		
	}
}