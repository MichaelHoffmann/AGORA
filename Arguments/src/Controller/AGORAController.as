package Controller
{
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	import Model.MapListModel;
	
	import ValueObjects.UserDataVO;
	
	import components.MyMapName;
	import components.MyMapsPanel;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	
	import spark.components.Group;
	
	public class AGORAController extends EventDispatcher
	{
		private static var instance:AGORAController;
			
		//-------------------------Constructor-----------------------------//
		public function AGORAController(singletonEnforcer:SingletonEnforcer, target:IEventDispatcher=null)
		{
			super(target);
			instance = this;
			AGORAModel.getInstance().mapListModel.addEventListener(AGORAEvent.MAP_LIST_FETCHED, onMapListFetched);
			AGORAModel.getInstance().myMapsModel.addEventListener(AGORAEvent.MY_MAPS_LIST_FETCHED, onMyMapsListFetched);
			AGORAModel.getInstance().myMapsModel.addEventListener(AGORAEvent.MAPS_DELETED, onMyMapsDeleted);
			AGORAModel.getInstance().myMapsModel.addEventListener(AGORAEvent.MAPS_DELETION_FAILED, onMyMapsDeletionFailed);
			AGORAModel.getInstance().addEventListener(AGORAEvent.APP_STATE_SET, onAppStateSet);
			AGORAModel.getInstance().mapListModel.addEventListener(AGORAEvent.FAULT, onFault);
			AGORAModel.getInstance().myMapsModel.addEventListener(AGORAEvent.FAULT, onFault);
		}
		
		//----------------------Get Instance------------------------------//
		public static function getInstance():AGORAController{
			if(!instance){
				instance = new AGORAController(new SingletonEnforcer);
			}
			return instance;
		}
		
		//--------------------Fetch Map List------------------------------//
		public function fetchDataMapList():void{
			var mapListModel:MapListModel = AGORAModel.getInstance().mapListModel;
			mapListModel.requestMapList();
		}
		
		protected function onMapListFetched(event : AGORAEvent):void{
			trace("Map List Fetched");
			FlexGlobals.topLevelApplication.agoraMenu.mapList.invalidateSkinState();
			FlexGlobals.topLevelApplication.agoraMenu.mapList.invalidateProperties();
			FlexGlobals.topLevelApplication.agoraMenu.mapList.invalidateDisplayList();
		}
		
		
		
		//-------------------Fetch My Maps Data---------------------------//
		public function fetchDataMyMaps():void{
			if(AGORAModel.getInstance().userSessionModel.uid){
				AGORAModel.getInstance().myMapsModel.requestMapList();
			}
			else{
				Alert.show("The user has not signed in yet...");
			}
		}
		
		protected function onMyMapsListFetched(event:AGORAEvent):void{
			trace("My Maps List Fetched");
			FlexGlobals.topLevelApplication.agoraMenu.myMaps.mapListXML = event.xmlData;
			FlexGlobals.topLevelApplication.agoraMenu.myMaps.invalidateSkinState();
			FlexGlobals.topLevelApplication.invalidateProperties();
			FlexGlobals.topLevelApplication.invalidateDisplayList();
		}
		
		
		
		//-------------------------Delete Maps-----------------------------//
		public function deleteSelectedMaps():void{
			var myMapListPanel: MyMapsPanel = FlexGlobals.topLevelApplication.agoraMenu.myMaps;
			var mapsGroup:Group = myMapListPanel.mapsGroup;
			
			//get the map id's to be deleted and form XML
			var xml:XML = <remove></remove>;
			for(var i:int=0; i < mapsGroup.numElements; i++)
			{
				var myMapName:MyMapName = MyMapName(mapsGroup.getElementAt(i));
				if(myMapName.thisMap.selected == true){
					xml.appendChild(<map id={myMapName.mapId} />);	
				}
			}
			AGORAModel.getInstance().myMapsModel.removeMaps(xml);
		}
		
		protected function onMyMapsDeleted(event:AGORAEvent):void{
			Alert.show("Maps Deleted");
			fetchDataMyMaps();
			fetchDataMapList();
		}
		
		protected function onMyMapsDeletionFailed(event:AGORAEvent):void{
			
		}
		
		//--------------------On App State Set--------------------------//
		protected function onAppStateSet(event:AGORAEvent):void{
			//stop timer for AGORA Menu
			if(AGORAModel.getInstance().state == AGORAModel.MAP){
				FlexGlobals.topLevelApplication.agoraMenu.timer.stop();
			}
			else{
				FlexGlobals.topLevelApplication.agoraMenu.timer.start();
			}
		}
		
		//-------------------On timer-------------------//
		public function onTimer():void{
			fetchDataMapList();
			if(AGORAModel.getInstance().userSessionModel.loggedIn()){
				fetchDataMyMaps();
			}
		}
		
		//--------------------Generic Fault Event ----------------------//
		protected function onFault(event:AGORAEvent):void{
			Alert.show("Network error occurred. Please make sure you are connected to the internet");
		}
		
	}
}

class SingletonEnforcer{
	
}