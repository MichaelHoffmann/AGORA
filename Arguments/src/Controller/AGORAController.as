package Controller
{
	import Events.AGORAEvent;
	
	import Model.AGORAMapModel;
	import Model.AGORAModel;
	import Model.CategoryModel;
	import Model.ChatModel;
	import Model.MapListModel;
	import Model.MoveMap;
	import Model.MyContributionsModel;
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
	import flash.events.MouseEvent;
	
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
		private var _contributionsCategoryChain:ArrayList;
		private var tempParentCategory:String;
		private var tempParentCategoryID:String;
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
			model.myProjectsModel.addEventListener(AGORAEvent.MY_PROJECTS_SUB_DETAILS, updateProjectSub);
			model.myProjectsModel.addEventListener(AGORAEvent.MY_PROJECTS_MAP_DETAILS, updateProjectMap);
			model.myProjectsModel.addEventListener(AGORAEvent.MY_PROJECTS_USER_DETAILS, updateProjectUser);
			model.selectAsAdmin.addEventListener(Events.AGORAEvent.ADMIN_CHANGED,onAdminChanged);
			model.editProject.addEventListener(Events.AGORAEvent.ADMIN_CHANGED,updateProject);
			model.myProjectsModel.addEventListener(AGORAEvent.FAULT, onFault);
			model.deleteProject.addEventListener(AGORAEvent.DELETED_PROJECT,onProjectDeleted);
			model.categoryModel.addEventListener(AGORAEvent.CATEGORY_FETCHED,onCategoryFetched);
			model.categoryModel.addEventListener(AGORAEvent.MAP_FETCHED,onChildMapFetched);
			model.categoryModel.addEventListener(AGORAEvent.PROJECT_FETCHED,onProjectFetched);
			model.editProject.addEventListener(AGORAEvent.EDITED_PROJECT,updateProject);
			model.categoryModel.addEventListener(AGORAEvent.FAULT, onFault);
			model.mycontributionsModel.addEventListener(AGORAEvent.CONTRIBUTIONS_FETCHED,onContributionsFetched);
			model.mycontributionsModel.addEventListener(AGORAEvent.CHILD_PROJECT_FETCHED,onProjectFetchedContributions);
			model.mycontributionsModel.addEventListener(AGORAEvent.CHILD_MAP_FETCHED,onChildMapFetchedContributions);
			model.chatModel.addEventListener(AGORAEvent.CHAT_FETCHED,onChatFetched);
			model.chatModel.addEventListener(AGORAEvent.FAULT, onFault);
			model.verifyProjModel.addEventListener(AGORAEvent.PROJECT_USER_VERIFIED, onProjectUserVerified);
			model.publishMapModel.addEventListener(AGORAEvent.CATEGORY_FETCHED_FOR_PUBLISH, onCategoryFetchedForPublish);
			model.publishMapModel.addEventListener(AGORAEvent.MAP_PUBLISHED, onMapPublished);
			model.moveProjectModel.addEventListener(AGORAEvent.CATEGORY_FETCHED_FOR_MOVEPROJECT, onCategoryFetchedForMoveProject);
			//model.moveProjectModel.addEventListener(AGORAEvent.MAP_PUBLISHED, onProjectPublished);
			model.pushprojects.addEventListener(AGORAEvent.PROJECT_PUSHED,onProjectPush);
			model.moveProjectModel.addEventListener(AGORAEvent.PROJECT_MOVED,onProjectMoved);
			model.pushprojects.addEventListener(AGORAEvent.PROJECT_PUSH_FAILED,onProjectPushFail);
			model.addUsers.addEventListener(AGORAEvent.ADDED_USERS,onUsersChanged);
			model.removeUsers.addEventListener(AGORAEvent.REMOVED_USERS,onUsersChanged);
			model.moveMap.addEventListener(AGORAEvent.MAP_ADDED,onMapAdded);
			


			menu = FlexGlobals.topLevelApplication.agoraMenu;
			map = FlexGlobals.topLevelApplication.map;
			userSession = AGORAModel.getInstance().userSessionModel;
			mapModel = AGORAModel.getInstance().agoraMapModel;
			categoryChain = new ArrayList();
			contributionsCategoryChain = new ArrayList();
		}
		
		//----------------------Get Instance------------------------------//
		public function get contributionsCategoryChain():ArrayList
		{
			return _contributionsCategoryChain;
		}
		public function set contributionsCategoryChain(value:ArrayList):void
		{
			_contributionsCategoryChain = value;
		}
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
			categoryM.requestChildCategories(parentCategory,parentID);
		}
		public function fetchChildCategorycontributions(parentCategory:String,parentID:String, addOne:Boolean):void{
			menu.contributions.loadingDisplay.text = Language.lookup("Loading");
			menu.contributions.loadingDisplay.visible = true;
			/*Adjust the category chain. Find the instantiation in AGORAController. cg is a legacy name*/
			trace("Adding to the cc with category: " + parentCategory);
			if(addOne){
				if(contributionsCategoryChain.length == 0){
					contributionsCategoryChain.addItem(new CategoryDataV0(parentCategory,parentID,null, null));
				}else{	
					trace("Adding pair" + (CategoryDataV0)(contributionsCategoryChain.getItemAt(contributionsCategoryChain.length-1)).current + "-->" + parentCategory);
					contributionsCategoryChain.addItem(new CategoryDataV0(parentCategory,parentID, (CategoryDataV0)(contributionsCategoryChain.getItemAt(contributionsCategoryChain.length-1)).current, (CategoryDataV0)(contributionsCategoryChain.getItemAt(contributionsCategoryChain.length-1)).currentID));	
				}
				FlexGlobals.topLevelApplication.rightSidePanel.contributionscategoryChain.addCategory(parentCategory);
			}
			var contributionsM:MyContributionsModel = model.mycontributionsModel;
			contributionsM.requestChildCategories(parentCategory,parentID);
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
			menu.myProjects.populateProjects();
		}
		
		protected function onChildMapFetchedContributions(event:AGORAEvent):void{
			menu.contributions.loadingDisplay.visible = false;
			menu.contributions.invalidateProperties();
			menu.contributions.invalidateDisplayList();
			menu.myProjects.populateProjects();
		}
		
		protected function onProjectFetchedContributions(event:AGORAEvent):void{
			menu.contributions.loadingDisplay.visible = false;
			menu.contributions.invalidateProperties();
			menu.contributions.invalidateDisplayList();
		}
		
		protected function onContributionsFetched(event:AGORAEvent):void{
			menu.contributions.loadingDisplay.visible = false;
			menu.contributions.invalidateProperties();
			menu.contributions.invalidateDisplayList();
			
		}
		public function fetchDataChildCategoryForPublish(parentCategory:String,parentCategoryID:String):void{
			model.publishMapModel.sendForChildren(parentCategory,parentCategoryID);
		}
		public function fetchDataChildCategoryForMoveProject(parentCategory:String,parentCategoryID:String):void{
			model.moveProjectModel.sendForChildren(parentCategory,parentCategoryID);
		}
		public function onMapAdded():void{
			if(model.userSessionModel.selectedMyProjProjID){
				menu.myProjects.setCurrentProject(model.userSessionModel.selectedMyProjProjID);
			}
		}
		public function publishMap(mapID:int, currCatID:int):void{
			model.publishMapModel.publishMap(mapID, currCatID);
		}
		public function renameProject(newName:String):void{
			model.editProject.rename(newName);
		}
		public function selectAsAdmin(userID:String):void{
			model.selectAsAdmin.sendRequest(userID);
		}
		public function deleteProject(projID:String):void{
			model.deleteProject.sendRequest(projID);
		}
		public function onProjectDeleted(e:Event):void{
			menu.createMapinProjectBtn.visible=false;
			menu.ProjBtn.visible=false;
			menu.myProjects.currentState="listOfProjects";
			fetchDataMyProjects();
			fetchDataProjectList();
		}
		public function onUsersChanged(e:Event):void{
			fetchDataMyProjects();
		}
		public function updateMyContributions(event:MouseEvent):void{
			if(this.contributionsCategoryChain.length - 1>-1){
			fetchChildCategorycontributions(this.contributionsCategoryChain.getItemAt((this.contributionsCategoryChain.length - 1)).current,this.contributionsCategoryChain.getItemAt((this.contributionsCategoryChain.length - 1)).currentID,true);
			}else{
				mx.controls.Alert.show(""+(this.contributionsCategoryChain.length - 1));
				fetchContributions();
			}
		}
		public function updateWOA(event:MouseEvent):void{
			updateMapProj();
		}
		public function updateProject(e:Event):void{
			if(FlexGlobals.topLevelApplication.projectNameBox){
				FlexGlobals.topLevelApplication.projectNameBox.visible=false;
			}
			if(menu.myProjects.currentState=="projectsInfo"){
				menu.myProjects.updateProject();
			}
			fetchDataProjectList();
			fetchDataMyProjects();
			
			
		}
		public function onAdminChanged(e:Event):void{
			fetchDataMyProjects();
			menu.myProjects.currentState="listOfProjects";
		}
		public function updateProjectSub(e:Event):void{
			menu.myProjects.populateSubProjects();
		}
		public function updateProjectMap(e:Event):void{
			menu.myProjects.populateMap();
		}
		public function updateProjectUser(e:Event):void{
			menu.myProjects.populateUser();
		}
		public function moveProject(catID:int, parentCatID:int):void{
			model.moveProjectModel.moveProject(catID, parentCatID);
			
		}
		protected function onCategoryFetchedForPublish(event:AGORAEvent):void{
			FlexGlobals.topLevelApplication.publishMap.invalidateProperties();
			FlexGlobals.topLevelApplication.publishMap.invalidateDisplayList();
		}
		
		protected function onCategoryFetchedForMoveProject(event:AGORAEvent):void{
			FlexGlobals.topLevelApplication.moveProject.invalidateProperties();
			FlexGlobals.topLevelApplication.moveProject.invalidateDisplayList();
		}
		protected function onMapPublished(event:AGORAEvent):void{
			fetchDataMyMaps();
			var usm:UserSessionModel=AGORAModel.getInstance().userSessionModel;
			menu.myProjects.setCurrentProject(usm.selectedMyProjProjID);	

		}
		protected function onProjectPublished(event:AGORAEvent):void{
		/*	fetchDataMyMaps();
			var usm:UserSessionModel=AGORAModel.getInstance().userSessionModel;
			menu.myProjects.setCurrentProject(usm.selectedMyProjProjID);	*/
			fetchDataProjectList();

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
		public function fetchContributions():void{
			var myContributionsM:MyContributionsModel = model.mycontributionsModel;
			myContributionsM.requestMyContributions();
		}
		protected function onProjectListFetched(event:AGORAEvent):void{
			menu.myProjects.loadingDisplay.visible = false;
			menu.projects.invalidateProperties();
			menu.projects.invalidateDisplayList();
			menu.myProjects.populateProjects();

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
		public function verifyProjectMember(parentCategory:String,parentID:String):void{
			this.tempParentCategory = parentCategory;
			this.tempParentCategoryID = parentID;
			model.verifyProjModel.send();
		}
		
		protected function onProjectUserVerified(event:AGORAEvent):void{
			if(AGORAModel.getInstance().userSessionModel.selectedTab!=Language.lookup("MyContributions"))
			fetchDataChildCategory(tempParentCategory,tempParentCategoryID, true);
			else
				AGORAController.getInstance().fetchChildCategorycontributions(tempParentCategory,tempParentCategoryID, true);
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
			var usm:UserSessionModel=model.userSessionModel;
			if(usm.loggedIn()){
				menu.myProjects.loadingDisplay.text = Language.lookup("Loading");
				menu.myProjects.loadingDisplay.visible = true;
				model.myProjectsModel.sendRequest();
				if(usm.selectedMyProjProjID){
					model.myProjectsModel.requestProjDetails(usm.selectedMyProjProjID);
					model.myProjectsModel.requestChildCategories(usm.selectedMyProjProjID);
					model.myProjectsModel.listProjMaps(usm.selectedMyProjProjID);
				}
			}
		}
		
		protected function onProjectPushFail(event:AGORAEvent):void{
			Alert.show(Language.lookup("ProjectNameUnique"));
		}
		
		protected function onProjectPush(event:AGORAEvent):void{
			Alert.show(Language.lookup("ProjectCreated"));
			if( FlexGlobals.topLevelApplication.projectNameBox){
				FlexGlobals.topLevelApplication.projectNameBox.visible=false;
			}
			fetchDataProjectList();
			fetchDataMyProjects();
			if(AGORAModel.getInstance().userSessionModel.selectedTab==Language.lookup("MyContributions"))
			{
				fetchChildCategorycontributions(this.contributionsCategoryChain.getItemAt((this.contributionsCategoryChain.length - 1)).current,this.contributionsCategoryChain.getItemAt((this.contributionsCategoryChain.length - 1)).currentID,true);
			}
			else
			if(this.categoryChain.length - 1>0){
				fetchDataChildCategory(this.categoryChain.getItemAt((this.categoryChain.length - 1)).current,this.categoryChain.getItemAt((this.categoryChain.length - 1)).currentID,true);
			}
		}
		protected function updateMapProj(){
			if( FlexGlobals.topLevelApplication.projectNameBox){
				FlexGlobals.topLevelApplication.projectNameBox.visible=false;
			}
			fetchDataProjectList();
			fetchDataMyProjects();
			if(AGORAModel.getInstance().userSessionModel.selectedTab==Language.lookup("MyContributions"))
			{
				if(this.contributionsCategoryChain.length - 1>0){
					fetchChildCategorycontributions(this.contributionsCategoryChain.getItemAt((this.contributionsCategoryChain.length - 1)).current,this.contributionsCategoryChain.getItemAt((this.contributionsCategoryChain.length - 1)).currentID,true);

				}
			}
			else
				if(this.categoryChain.length - 1>0){
					fetchDataChildCategory(this.categoryChain.getItemAt((this.categoryChain.length - 1)).current,this.categoryChain.getItemAt((this.categoryChain.length - 1)).currentID,true);
				}
		}
		protected function onProjectMoved(event:AGORAEvent):void{
			fetchDataProjectList();
			fetchDataMyProjects();
			if(this.categoryChain.length - 1>0){
				fetchDataChildCategory(this.categoryChain.getItemAt((this.categoryChain.length - 1)).current,this.categoryChain.getItemAt((this.categoryChain.length - 1)).currentID,true);
			}
		}
		
		protected function onMyProjectsListFetched(event:AGORAEvent):void{
			menu.myProjects.populateProjects();
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
