package Controller
{
	import Events.AGORAEvent;
	
	import Model.AGORAMapModel;
	import Model.AGORAModel;
	import Model.CategoryModel;
	import Model.ChatModel;
	import Model.MapListModel;
	import Model.MoveMapToProjectModel;
	import Model.ProjectListModel;
	import Model.ProjectsModel;
	import Model.PushProject;
	import Model.UserSessionModel;
	import Model.VerifyProjectPasswordModel;
	
	import ValueObjects.ChatDataVO;
	import ValueObjects.UserDataVO;
	
	import classes.Language;
	
	import components.AGORAMenu;
	import components.Map;
	import components.MapName;
	import components.MyMapName;
	import components.MyMapsPanel;
	import components.ProjectName;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.CursorManager;
	import mx.managers.PopUpManager;
	import mx.printing.FlexPrintJob;
	import mx.printing.FlexPrintJobScaleType;
	import mx.states.State;
	
	import spark.components.Group;
	
	public class AGORAController
	{
		private static var instance:AGORAController;
		private var menu:AGORAMenu;
		private var map:Map;
		private var userSession:UserSessionModel;
		private var mapModel:AGORAMapModel;
		private var model:AGORAModel;
		private var project:Boolean;
		private var _categoryChain:ArrayList;
		//-------------------------Constructor-----------------------------//
		public function AGORAController(singletonEnforcer:SingletonEnforcer)
		{
			instance = this;
			project=false;
			model = AGORAModel.getInstance();
			AGORAModel.getInstance().mapListModel.addEventListener(AGORAEvent.MAP_LIST_FETCHED, onMapListFetched);
			AGORAModel.getInstance().myMapsModel.addEventListener(AGORAEvent.MY_MAPS_LIST_FETCHED, onMyMapsListFetched);
			AGORAModel.getInstance().myMapsModel.addEventListener(AGORAEvent.MAPS_DELETED, onMyMapsDeleted);
			AGORAModel.getInstance().myMapsModel.addEventListener(AGORAEvent.MAPS_DELETION_FAILED, onMyMapsDeletionFailed);
			AGORAModel.getInstance().mapListModel.addEventListener(AGORAEvent.FAULT, onFault);
			AGORAModel.getInstance().agoraMapModel.addEventListener(AGORAEvent.ILLEGAL_MAP, handleIllegalMap);
			model.projectListModel.addEventListener(AGORAEvent.PROJECT_LIST_FETCHED, onProjectListFetched);
			model.projectListModel.addEventListener(AGORAEvent.FAULT, onFault);
			model.myProjectsModel.addEventListener(AGORAEvent.MY_PROJECTS_LIST_FETCHED, onMyProjectsListFetched);
			model.myProjectsModel.addEventListener(AGORAEvent.FAULT, onFault);
			model.categoryModel.addEventListener(AGORAEvent.CATEGORY_FETCHED,onCategoryFetched);
			model.categoryModel.addEventListener(AGORAEvent.FAULT, onFault);
			model.chatModel.addEventListener(AGORAEvent.CHAT_FETCHED,onChatFetched);
			model.chatModel.addEventListener(AGORAEvent.FAULT, onFault);
			
			menu = FlexGlobals.topLevelApplication.agoraMenu;
			map = FlexGlobals.topLevelApplication.map;
			userSession = AGORAModel.getInstance().userSessionModel;
			mapModel = AGORAModel.getInstance().agoraMapModel;
			categoryChain = new ArrayList();
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

			var statusNE:String = Language.lookup("NetworkError");
			if(statusNE == menu.mapList.loadingDisplay.text){
				
				menu.mapList.loadingDisplay.text = Language.lookup("Loading");
			}
			menu.mapList.loadingDisplay.visible = true;
			var mapListModel:MapListModel = AGORAModel.getInstance().mapListModel;
			mapListModel.requestMapList();			
		}
		
		protected function onMapListFetched(event : AGORAEvent):void{
			menu.mapList.loadingDisplay.visible = false;
			menu.mapList.invalidateSkinState();
			menu.mapList.invalidateProperties();
			menu.mapList.invalidateSize();
			menu.mapList.invalidateDisplayList();
		}
		//------------------Fetch Category--------------------------------//
		public function fetchDataCategory():void{
			menu.categories.loadingDisplay.text = Language.lookup("Loading");
			menu.categories.loadingDisplay.visible = true;
			var categoryM:CategoryModel = model.categoryModel;
			categoryM.requestCategory();
			
		}
		protected function onCategoryFetched(event:AGORAEvent):void{
			menu.categories.loadingDisplay.visible = false;
			menu.categories.invalidateProperties();
			menu.categories.invalidateDisplayList();
		}
		
		public function fetchDataChildCategory(parentCategory:String):void{
			menu.categories.loadingDisplay.text = Language.lookup("Loading");
			menu.categories.loadingDisplay.visible = true;
			var categoryM:CategoryModel = model.categoryModel;
			categoryM.requestChildCategories(parentCategory);
		}
		protected function onChildCategoryFetched(event:AGORAEvent):void{
			menu.categories.loadingDisplay.visible = false;
			menu.categories.invalidateProperties();
			menu.categories.invalidateDisplayList();
		}
		public function fetchDataChildMap(parentCategory:String):void{
			menu.categories.loadingDisplay.text = Language.lookup("Loading");
			menu.categories.loadingDisplay.visible = true;
			var categoryM:CategoryModel = model.categoryModel;
			categoryM.onrequestChildMap(parentCategory);
		}
		protected function onChildMapFetched(event:AGORAEvent):void{
			menu.categories.loadingDisplay.visible = false;
			menu.categories.invalidateProperties();
			menu.categories.invalidateDisplayList();
		}
		
		
		//------------------Fetch Chat--------------------------------//
		public function fetchDataChat():void{
			var chatM:ChatModel = model.chatModel;
			chatM.requestChat();	
		}
		protected function onChatFetched(event:AGORAEvent):void{
			menu.chat.invalidateProperties();
			menu.chat.invalidateDisplayList();
			FlexGlobals.topLevelApplication.Map.chat.invalidateProperties();
			FlexGlobals.topLevelApplication.Map.chat.invalidateDisplayList();
		}
		//------------------Fetch Project List----------------------------//
		public function fetchDataProjectList():void{
			menu.projects.loadingDisplay.text = Language.lookup("Loading");
			menu.projects.loadingDisplay.visible = true;
			var projectListM:ProjectListModel = model.projectListModel;
			projectListM.requestProjectList();	
		}
		protected function onProjectListFetched(event:AGORAEvent):void{
			menu.projects.loadingDisplay.visible = false;
			menu.projects.invalidateProperties();
			menu.projects.invalidateDisplayList();
		}
		
		public function pushNewProject():void{
			var pp:PushProject = new PushProject;
			pp.sendRequest();
		}
		
		public function verifyProjectPassword():void{
			var verifyPassword:VerifyProjectPasswordModel = new VerifyProjectPasswordModel;
			verifyPassword.send();
		}
		
		/**
		 * This sends an HTTPRequest. Todo... check which function is calling it to determine
		 * where to send the open call...
		 */
		public function addMapToProject(mapID:int, projID:int):void{
			var mapToProject:MoveMapToProjectModel = new MoveMapToProjectModel;
			mapToProject.send(mapID,projID);
		}
		
		//-------------------Fetch My Maps Data---------------------------//
		public function fetchDataMyMaps():void{

			if(AGORAModel.getInstance().userSessionModel.loggedIn()){
				var statusNE:String = Language.lookup("NetworkError");;
				if(menu.myMaps.loadingDisplay.text == statusNE){

					menu.myMaps.loadingDisplay.text = Language.lookup("Loading");
				}
				FlexGlobals.topLevelApplication.agoraMenu.myMaps.loadingDisplay.visible = true;
				

				AGORAModel.getInstance().myMapsModel.requestMapList();
			}
		}
		

		protected function onMyMapsListFetched(event:AGORAEvent):void{
			FlexGlobals.topLevelApplication.agoraMenu.myMaps.loadingDisplay.visible = false;
			FlexGlobals.topLevelApplication.agoraMenu.myMaps.mapListXML = event.xmlData;
			FlexGlobals.topLevelApplication.agoraMenu.myMaps.invalidateSkinState();
			FlexGlobals.topLevelApplication.invalidateProperties();
			FlexGlobals.topLevelApplication.invalidateDisplayList();
		}
		
		//------------------Fetch my Projects ------------------------------//
		public function fetchDataMyProjects():void{
			if(model.userSessionModel.loggedIn()){
				menu.myProjects.loadingDisplay.text = Language.lookup("Loading");
				menu.myProjects.loadingDisplay.visible = true;
				model.myProjectsModel.sendRequest();
			}
		}
		
		protected function onMyProjectsListFetched(event:AGORAEvent):void{
			menu.myProjects.loadingDisplay.visible = false;
			menu.myProjects.invalidateProperties();
			menu.myProjects.invalidateDisplayList();
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
			Alert.show(Language.lookup("MapsDeleted"));
			fetchDataMyMaps();
			fetchDataMapList();
		}
		
		protected function onMyMapsDeletionFailed(event:AGORAEvent):void{
		}
		
		public function printMap():void{
			var flexPrintJob:FlexPrintJob = new FlexPrintJob;
			flexPrintJob.start();
			flexPrintJob.printAsBitmap = false;
			flexPrintJob.addObject(map.agoraMap, FlexPrintJobScaleType.SHOW_ALL);
			flexPrintJob.send();
		}
		
		
		//-------------------On timer-------------------//
		public function onTimer():void{
			//fetchDataMapList();
			if(AGORAModel.getInstance().userSessionModel.loggedIn()){
				fetchDataMyMaps();
			}
			//fetchDataProjectList();
			fetchDataChat();
		}
		
		//--------------------Freeze the app--------------//
		public function freeze():void{
			CursorManager.setBusyCursor();
		}
		
		public function unfreeze():void{
			CursorManager.removeBusyCursor();
		}
		
		//-------------------- Illegal Map--------------------------------//
		protected function handleIllegalMap(event:AGORAEvent):void{
			Alert.show(Language.lookup("IllegalMap"));
			hideMap();
		}
		
		//--------------------Generic Fault Event ----------------------//
		protected function onFault(event:AGORAEvent):void{
			//If loading had been displayed, remove it
			//For the Map List box
			menu.mapList.loadingDisplay.text = Language.lookup("NetworkError");
			menu.myProjects.loadingDisplay.text = Language.lookup("NetworkError");
			if(userSession.uid){
				menu.myMaps.loadingDisplay.text = Language.lookup("NetworkError");
			}
		}
		
		
		
		//----------- other public functions --------------------//
		public function hideMap():void{
			FlexGlobals.topLevelApplication.map.lamWorld.visible = false;
			//reinitializes the map model
			mapModel.reinitializeModel();
			//initlizes the children hash map, and 
			//sets the flag to delete all children
			map.agoraMap.initializeMapStructures();
			map.visible = false;
			FlexGlobals.topLevelApplication.agoraMenu.visible = true;
			FlexGlobals.topLevelApplication.map.agoraMap.firstClaimHelpText.visible = false;
			map.agoraMap.helpText.visible = false;
			AGORAController.getInstance().fetchDataMapList();
			AGORAController.getInstance().fetchDataMyMaps();
			AGORAController.getInstance().mapModel.name = "null";
			AGORAController.getInstance().fetchDataChat();
			
			//timers
			map.agoraMap.timer.reset();
			menu.timer.start();
		}
		
		public function showMap():void{
			model.agoraMapModel.reinitializeModel();
			//hide and show view components
			menu.visible = false;
			map.visible = true;
			map.agora.visible = true;
			//reinitialize map view
			map.agoraMap.initializeMapStructures();
			//fetch data
			LoadController.getInstance().fetchMapData();
			//timers
			map.agoraMap.timer.start();
			menu.timer.reset();
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
				Alert.show(Language.lookup("MustRegister"));
			}
		}
		
		public function displayProjectInfoBox():void{
			var agoraModel:AGORAModel = AGORAModel.getInstance();
			if(agoraModel.userSessionModel.loggedIn()){
				FlexGlobals.topLevelApplication.projectNameBox = new ProjectName;
				var pojectNameDialog:ProjectName = FlexGlobals.topLevelApplication.projectNameBox;
				PopUpManager.addPopUp(pojectNameDialog,DisplayObject(FlexGlobals.topLevelApplication),true);
				PopUpManager.centerPopUp(pojectNameDialog);
			}
			else{
				Alert.show(Language.lookup("MustRegister"));
			}
		}

		public function get categoryChain():ArrayList
		{
			return _categoryChain;
		}

		public function set categoryChain(value:ArrayList):void
		{
			_categoryChain = value;
		}

	}
}

class SingletonEnforcer{
	
}
