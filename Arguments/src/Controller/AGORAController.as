package Controller
{
	import Events.AGORAEvent;
	
	import Model.AGORAMapModel;
	import Model.AGORAModel;
	import Model.CategoryModel;
	import Model.ChatModel;
	import Model.MapListModel;
	import Model.MoveMap;
	import Model.ProjectListModel;
	import Model.ProjectsModel;
	import Model.PublishMapModel;
	import Model.PushProject;
	import Model.UserSessionModel;
	import Model.VerifyProjectMemberModel;
	
	import ValueObjects.CategoryDataV0;
	import ValueObjects.ChatDataVO;
	import ValueObjects.UserDataVO;
	
	import classes.Language;
	
	import components.AGORAMenu;
	import components.Map;
	import components.MapName;
	import components.MyMapName;
	import components.MyMapPanel;
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
	import spark.components.HGroup;
	
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
		private var tempParentCategory:String;
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
			model.categoryModel.addEventListener(AGORAEvent.MAP_FETCHED,onChildMapFetched);
			model.categoryModel.addEventListener(AGORAEvent.PROJECT_FETCHED,onProjectFetched);
			model.categoryModel.addEventListener(AGORAEvent.FAULT, onFault);
			model.chatModel.addEventListener(AGORAEvent.CHAT_FETCHED,onChatFetched);
			model.chatModel.addEventListener(AGORAEvent.FAULT, onFault);
			model.verifyProjModel.addEventListener(AGORAEvent.PROJECT_USER_VERIFIED, onProjectUserVerified);
			model.publishMapModel.addEventListener(AGORAEvent.CATEGORY_FETCHED_FOR_PUBLISH, onCategoryFetchedForPublish);
			model.publishMapModel.addEventListener(AGORAEvent.MAP_PUBLISHED, onMapPublished);
			model.pushprojects.addEventListener(AGORAEvent.PROJECT_PUSHED,onProjectPush);
			model.pushprojects.addEventListener(AGORAEvent.PROJECT_PUSH_FAILED,onProjectPushFail);
			model.addUsers.addEventListener(AGORAEvent.ADDED_USERS,onMapCreated);
			model.removeUsers.addEventListener(AGORAEvent.REMOVED_USERS,onMapCreated);
			model.moveMap.addEventListener(AGORAEvent.MAP_ADDED,onMapCreated);
			


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
		
		public function addUsers():void
		{
			this.model.addUsers.sendRequest();
			return;
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
		
		public function fetchDataChildCategory(parentCategory:String,parentID, addOne:Boolean):void{
			menu.categories.loadingDisplay.text = Language.lookup("Loading");
			menu.categories.loadingDisplay.visible = true;
			//model.userSessionModel.selectedWoAProjectID=parentCategory;
				/*Adjust the category chain. Find the instantiation in AGORAController. cg is a legacy name*/
			trace("Adding to the cc with category: " + parentCategory);
			if(addOne){
				if(categoryChain.length == 0){
					categoryChain.addItem(new CategoryDataV0(parentCategory,parentID,null, null));
				}else{	
					trace("Adding pair" + (CategoryDataV0)(categoryChain.getItemAt(categoryChain.length-1)).current + "-->" + parentCategory);
					categoryChain.addItem(new CategoryDataV0(parentCategory,parentID,(CategoryDataV0)(categoryChain.getItemAt(categoryChain.length-1)).current, (CategoryDataV0)(categoryChain.getItemAt(categoryChain.length-1)).currentID));	
				}
				FlexGlobals.topLevelApplication.rightSidePanel.categoryChain.addCategory(parentCategory);
			}
			var categoryM:CategoryModel = model.categoryModel;
			categoryM.requestChildCategories(parentCategory);
		}
		protected function onChildCategoryFetched(event:AGORAEvent):void{
			trace (" child category fetched");
			menu.categories.loadingDisplay.visible = false;
			menu.categories.invalidateProperties();
			menu.categories.invalidateDisplayList();
		}
		
		protected function onChildMapFetched(event:AGORAEvent):void{
			menu.categories.loadingDisplay.visible = false;
			menu.categories.invalidateProperties();
			menu.categories.invalidateDisplayList();
		}
		
		protected function onProjectFetched(event:AGORAEvent):void{
			menu.categories.loadingDisplay.visible = false;
			menu.categories.invalidateProperties();
			menu.categories.invalidateDisplayList();
		}
		public function fetchDataChildCategoryForPublish(parentCategory:String):void{
			model.publishMapModel.sendForChildren(parentCategory);
		}
		public function onMapCreated(event:AGORAEvent):void{
			
			menu.myProjects.setCurrentProject(model.userSessionModel.selectedMyProjProjID);
		}
		public function publishMap(mapID:int, currCatID:int):void{
			model.publishMapModel.publishMap(mapID, currCatID);
		}
		protected function onCategoryFetchedForPublish(event:AGORAEvent):void{
			FlexGlobals.topLevelApplication.publishMap.invalidateProperties();
			FlexGlobals.topLevelApplication.publishMap.invalidateDisplayList();
		}
		
		protected function onMapPublished(event:AGORAEvent):void{
			fetchDataMyMaps();
			var usm:UserSessionModel=AGORAModel.getInstance().userSessionModel;
			menu.myProjects.setCurrentProject(usm.selectedMyProjProjID);	

		}
		
		
		//------------------Fetch Chat--------------------------------//
		public function fetchDataChat():void{
			var chatM:ChatModel = model.chatModel;
			chatM.requestChat();	
		}
		protected function onChatFetched(event:AGORAEvent):void{
			FlexGlobals.topLevelApplication.rightSidePanel.chat.invalidateProperties();
			FlexGlobals.topLevelApplication.rightSidePanel.chat.invalidateDisplayList();
		}
		//------------------Fetch Project List----------------------------//
		public function fetchDataProjectList():void{
			menu.projects.loadingDisplay.text = Language.lookup("Loading");
			menu.projects.loadingDisplay.visible = true;
			var projectListM:ProjectListModel = model.projectListModel;
			projectListM.requestProjectList();	
		}
		protected function onProjectListFetched(event:AGORAEvent):void{
			mx.controls.Alert.show("butt");
			menu.myProjects.loadingDisplay.visible = false;
			menu.projects.invalidateProperties();
			menu.projects.invalidateDisplayList();
		}
		
		public function pushNewProject():void{
			//var pp:PushProject = new PushProject;
			model.pushprojects.sendRequest();
		}
		public function removeMembers():void
		{
			this.model.removeUsers.sendRequest();
			return;
		}

		public function addProjectToWoM():void
		{
			this.model.pushprojects.inWoA();
			return;
		}
		public function addProjectToMyProjects():*
		{
			this.model.pushprojects.inProjectsList();
			return;
		}
		public function verifyProjectMember(parentCategory:String):void{
			this.tempParentCategory = parentCategory;
			model.verifyProjModel.send();
		}
		
		protected function onProjectUserVerified(event:AGORAEvent):void{
			fetchDataChildCategory(tempParentCategory,null, true);
		}
		
		/**
		 * This sends an HTTPRequest. Todo... check which function is calling it to determine
		 * where to send the open call...
		 */
		public function moveMap(mapID:int, projName:String):void{
			var mapToProject:MoveMap = new MoveMap;
			mapToProject.send(mapID, projName);
		}
		
		//-------------------Fetch My Maps Data---------------------------//
		public function fetchDataMyMaps():void{

			if(AGORAModel.getInstance().userSessionModel.loggedIn()){
				var statusNE:String = Language.lookup("NetworkError");;
//				if(menu.myMaps.loadingDisplay.text == statusNE){
//
//					menu.myMaps.loadingDisplay.text = Language.lookup("Loading");
//				}
				//FlexGlobals.topLevelApplication.agoraMenu.myMaps.loadingDisplay.visible = true;
				

				AGORAModel.getInstance().myMapsModel.requestMapList();
			}
		}
		

		protected function onMyMapsListFetched(event:AGORAEvent):void{
//			FlexGlobals.topLevelApplication.agoraMenu.myMaps.loadingDisplay.visible = false;
			FlexGlobals.topLevelApplication.agoraMenu.myMaps.mapListXML = event.xmlData;
			FlexGlobals.topLevelApplication.agoraMenu.myMaps.invalidateProperties();
			FlexGlobals.topLevelApplication.agoraMenu.myMaps.invalidateDisplayList();
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
		
		protected function onProjectPushFail(event:AGORAEvent):void{
			Alert.show(Language.lookup("ProjectNameUnique"));
		}
		
		protected function onProjectPush(event:AGORAEvent):void{
			Alert.show(Language.lookup("ProjectCreated"));
			FlexGlobals.topLevelApplication.projectNameBox.visible=false;
			if(this.categoryChain.length - 1>0){
				fetchDataChildCategory(this.categoryChain.getItemAt((this.categoryChain.length - 1)).current,this.categoryChain.getItemAt((this.categoryChain.length - 1)).currentID,true);
			}
			fetchDataProjectList();
			fetchDataMyProjects();
		}
		
		protected function onMyProjectsListFetched(event:AGORAEvent):void{
			menu.myProjects.populateProjects();
			menu.myProjects.loadingDisplay.visible = false;

		}
		
		protected function onProjectVerified(event:AGORAEvent):void{
			trace("Loading the projects within the category");
			//FlexGlobals.topLevelApplication.agoraMenu.categories.loadProjectCategories();
		}
		
		//-------------------------Delete Maps-----------------------------//
		public function deleteSelectedMaps():void{
			var myMapListPanel:MyMapPanel = FlexGlobals.topLevelApplication.agoraMenu.myMaps;
			var mapsGroup:Group = myMapListPanel.listMyMaps;
			
			//get the map id's to be deleted and form XML
			var xml:XML = <remove></remove>;
			for(var i:int=0; i < mapsGroup.numElements; i++)
			{
				var horizMapGroup:HGroup = (HGroup)(mapsGroup.getElementAt(i));
				var myMapName:MyMapName = MyMapName(horizMapGroup.getElementAt(0));
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
//				menu.myMaps.loadingDisplay.text = Language.lookup("NetworkError");
			}
		}
		
		
		
		//----------- other public functions --------------------//
		public function hideMap():void{
			FlexGlobals.topLevelApplication.rightSidePanel.invalidateDisplayList();
			//When we return to the category screen by clicking save and home or loading an illegal map,
			//find the current category and refresh it. Solved a problem with a created map not appearing
			//in the category panel upon returning home.
			if(categoryChain.length <= 0){
				fetchDataCategory();
			} else {
				fetchDataChildCategory((CategoryDataV0) (categoryChain.getItemAt(categoryChain.length-1)).current,this.categoryChain.getItemAt((this.categoryChain.length - 1)).currentID, false);
			}
			//reinitializes the map model
			mapModel.reinitializeModel();
			//initlizes the children hash map, and 
			//sets the flag to delete all children
			map.agoraMap.initializeMapStructures();
			map.visible = false;
			FlexGlobals.topLevelApplication.agoraMenu.visible = true;
			FlexGlobals.topLevelApplication.map.agoraMap.firstClaimHelpText.visible = false;
			map.agoraMap.helpText.visible = false;
			mapModel.ID = 0;
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
		
		public function displayProjectInfoBox(state:String):void{
			var agoraModel:AGORAModel = AGORAModel.getInstance();
			if(agoraModel.userSessionModel.loggedIn()){
				FlexGlobals.topLevelApplication.projectNameBox = new ProjectName;
				var projectNameDialog:ProjectName = FlexGlobals.topLevelApplication.projectNameBox;
				projectNameDialog.currentState=state;
				PopUpManager.addPopUp(projectNameDialog,DisplayObject(FlexGlobals.topLevelApplication),true);
				PopUpManager.centerPopUp(projectNameDialog);
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
