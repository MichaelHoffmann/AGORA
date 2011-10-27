package Controller
{
	import Events.AGORAEvent;
	
	import Model.AGORAMapModel;
	import Model.AGORAModel;
	import Model.MapListModel;
	
	import ValueObjects.UserDataVO;
	
	import components.MyMapName;
	import components.MyMapsPanel;
	
	import classes.Language;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.CursorManager;
	
	import spark.components.Group;
	
	public class AGORAController
	{
		private static var instance:AGORAController;
			
		//-------------------------Constructor-----------------------------//
		public function AGORAController(singletonEnforcer:SingletonEnforcer)
		{
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
				trace(AGORAModel.getInstance().userSessionModel.uid);
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
		
		//--------------------Freeze the app--------------//
		public function freeze():void{
			CursorManager.setBusyCursor();
		}
		
		public function unfreeze():void{
			CursorManager.removeBusyCursor();
		}
		
		//--------------------Generic Fault Event ----------------------//
		protected function onFault(event:AGORAEvent):void{
			Alert.show(Language.lookup("NetworkError"));
		}
		
		//--------------------Application Complete---------------------//
		
		
		
		public function hideMap():void{
			AGORAModel.getInstance().state = AGORAModel.MENU;
			FlexGlobals.topLevelApplication.map.visible = false;
			FlexGlobals.topLevelApplication.agoraMenu.visible = true;
			
			AGORAController.getInstance().fetchDataMapList();
			AGORAController.getInstance().fetchDataMyMaps();
		}
	}
}

class SingletonEnforcer{
	
}