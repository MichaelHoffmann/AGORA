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
	import components.ChatWindow;
	import components.Map;
	import components.MapName;
	import components.MyMapName;
	import components.MyMapPanel;
	import components.ProjectName;
	import components.RightSidePanel;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.printing.*;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.controls.SWFLoader;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.core.FlexGlobals;
	import mx.formatters.DateFormatter;
	import mx.managers.CursorManager;
	import mx.managers.PopUpManager;
	import mx.printing.FlexPrintJob;
	import mx.printing.FlexPrintJobScaleType;
	import mx.states.State;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.NavigatorContent;
	import spark.components.VGroup;
	
	public class AGORAController
	{
		private static var instance:AGORAController;
		private var menu:AGORAMenu;
		private var map:Map;
		private var userSession:UserSessionModel;
		private var mapModel:AGORAMapModel;
		private var model:AGORAModel;
		private var project:Boolean;
		private var tempParentCategory:String;
		private var tempParentCategoryID:int;
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
			model.myProjectsModel.addEventListener(AGORAEvent.PROJECTS_LIST_FETCHED, onProjectsListFetched);
			model.myProjectsModel.addEventListener(AGORAEvent.PROJECTS_SUB_DETAILS, updateProjectSub);
			model.myProjectsModel.addEventListener(AGORAEvent.PROJECTS_MAP_DETAILS, updateProjectMap);
			model.myProjectsModel.addEventListener(AGORAEvent.PROJECTS_USER_DETAILS, updateProjectUser);
			model.selectAsAdmin.addEventListener(Events.AGORAEvent.ADMIN_CHANGED,onAdminChanged);
			model.editProject.addEventListener(Events.AGORAEvent.ADMIN_CHANGED,updateProject);
			model.myProjectsModel.addEventListener(AGORAEvent.FAULT, onFault);
			model.deleteProject.addEventListener(AGORAEvent.DELETED_PROJECT,onProjectDeleted);
			model.categoryModel.addEventListener(AGORAEvent.CATEGORY_FETCHED,onCategoryFetched);
			model.categoryModel.addEventListener(AGORAEvent.MAP_FETCHED,onChildMapFetched);
			model.categoryModel.addEventListener(AGORAEvent.PROJECT_FETCHED,onProjectFetched);
			model.editProject.addEventListener(AGORAEvent.EDITED_PROJECT,updateProject);
			model.editProject.addEventListener(AGORAEvent.EDITED_PROJECTRELOAD,updateProjectReload);
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
			model.chainModel.addEventListener(AGORAEvent.CHAIN_LOADED,onChainLoaded);



			menu = FlexGlobals.topLevelApplication.agoraMenu;
			map = FlexGlobals.topLevelApplication.map;
			userSession = AGORAModel.getInstance().userSessionModel;
			mapModel = AGORAModel.getInstance().agoraMapModel;
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
		public function loadProjectInCurrentWindow(e:Event):void{
			var usm:UserSessionModel=AGORAModel.getInstance().userSessionModel;
			var selectedTab:String=usm.selectedTab;
			if (selectedTab == Language.lookup("MainTab")){
				usm.selectedWoAProjID=parseInt((e.target as Button).name);
				updateWOA(e as MouseEvent);
			}else if (selectedTab== Language.lookup("MyPPProjects")){
				usm.selectedMyProjProjID=(e.target as Button).name;
				fetchDataMyProjects();
			}else if (selectedTab == Language.lookup("MyContributions")){
				usm.selectedMyContProjID=(e.target as Button).name;
				fetchDataMyProjects();
				//updateMyContributions(e as MouseEvent);
			}
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
		public function getChain(theID:int):void{
			this.model.chainModel.getChain(theID);
		}
		public function getMapChain(theID:int):void{
			this.model.chainModel.getChainMap(theID);
		}
		public function onChainLoaded(event:AGORAEvent):void{
			var usm =AGORAModel.getInstance().userSessionModel;
			var chain = FlexGlobals.topLevelApplication.rightSidePanel.categoryChain;
			chain.update();
			chain.visible=true;
		}
		public function fetchDataChildCategory(parentCategory:String,parentID:int,opt:int=0):void{
			menu.categories.loadingDisplay.text = Language.lookup("Loading");
			menu.categories.loadingDisplay.visible = true;
			//model.userSessionModel.selectedWoAProjectID=parentCategory;
			trace("Adding to the cc with category: " + parentCategory);
			getChain(parentID);
			var categoryM:CategoryModel = model.categoryModel;
			if(opt==0){
				categoryM.requestChildCategories(parentCategory,parentID);
			}else{
				categoryM.requestCatProjsMaps(parentCategory,parentID);
			}
		}
		public function fetchChildCategorycontributions(parentCategory:String,parentID:int):void{
			menu.contributions.loadingDisplay.text = Language.lookup("Loading");
			menu.contributions.loadingDisplay.visible = true;
			/*Adjust the category chain. Find the instantiation in AGORAController. cg is a legacy name*/
			trace("Adding to the cc with category: " + parentCategory);
			
			if (parentID!=-1){
				getChain(parentID );
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
			updateProject(event);
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
/*			if(model.userSessionModel.selectedMyProjProjID){
				menu.myProjects.setCurrentProject(model.userSessionModel.selectedMyProjProjID);
			}
	*/
			var usm:UserSessionModel=model.userSessionModel;
			var current=usm.selectedTab;			
			if(current == Language.lookup("MyContributions"))
			{
				model.myProjectsModel.listProjMaps(usm.selectedMyContProjID);
			}
			else if(current==Language.lookup("MyPPProjects"))
			{
				model.myProjectsModel.listProjMaps(usm.selectedMyProjProjID);

			}else if (current ==Language.lookup("MainTab"))
			{
				if(menu.categories.layerView)
					model.categoryModel.requestCatProjsMaps("",usm.selectedWoAProjID);
				else
				    model.myProjectsModel.listProjMaps(usm.selectedWoAProjID+"");
			}

			
		}
		public function publishMap(mapID:int, currCatID:int):void{
			model.publishMapModel.publishMap(mapID, currCatID);
		}
		public function renameProject(newName:String):void{
			model.editProject.rename(newName);
		}
		public function changeProjectType():void{
			model.editProject.changeType();
		}
		public function selectAsAdmin(userID:String):void{
			model.selectAsAdmin.sendRequest(userID);
		}
		public function deleteProject(projID:String):void{
			model.deleteProject.sendRequest(projID);
		}
		public function onProjectDeleted(e:Event):void{
			menu.myProjects.currentState="listOfProjects";
			//fetchDataMyProjects(1);			
			//fetchDataProjectList(); // changed 
			var cg = FlexGlobals.topLevelApplication.rightSidePanel.categoryChain;			
			var temp1:Number= AGORAModel.getInstance().agoraMapModel.projectID;
			var selectT:String = AGORAModel.getInstance().userSessionModel.selectedTab;
			if (selectT == Language.lookup("MainTab")){
				var backup:Array=cg.back();
				//if (backup[1]>-1){
				if(backup[2]==null || backup[2]=="0"){
					if(backup[1]>-1){
						var usm:UserSessionModel= AGORAModel.getInstance().userSessionModel;						
						usm.selectedWoAProjID=backup[1];
						Controller.AGORAController.getInstance().fetchDataChildCategory(backup[0],backup[1],1);
					}else{
						AGORAController.getInstance().fetchDataCategory();
						cg.topButton();
					}
				}
			}else if (selectT== Language.lookup("MyPPProjects")){
				menu.myProjects.currentState=("listOfProjects");
				Controller.AGORAController.getInstance().fetchDataMyProjects(1);
			}
		}
		public function onUsersChanged(e:Event):void{
			updateProject(e)
		}
		public function updateMyContributions(event:MouseEvent):void{
			fetchContributions();
		}
		public function updateMyMaps(event:MouseEvent):void{
			fetchDataMyMaps();
		}
		public function updateWOA(event:MouseEvent):void{
			updateMapProj();
			//AGORAController.getInstance().fetchDataChildCategory(usm.selectedWoAProjID.toString(),);

			var usm:UserSessionModel=AGORAModel.getInstance().userSessionModel;
			if(usm.selectedWoAProjID){
				getChain(usm.selectedWoAProjID);
			}else{
			}
			
		}
		public function createProj(e:Event){
			var usm:UserSessionModel=model.userSessionModel;
			var current=usm.selectedTab;
			if(usm.loggedIn()){
				Controller.AGORAController.getInstance().displayProjectInfoBox("newInProject");
			}
		}
		public function createMap(event:Event){
			var usm:UserSessionModel=model.userSessionModel;
			var current=usm.selectedTab;
			if(usm.loggedIn()){
				Controller.AGORAController.getInstance().displayMapInfoBox();
			}
		}
		public function updateProject(e:Event):void{
			var usm:UserSessionModel=model.userSessionModel;
			var current=usm.selectedTab;
			if( FlexGlobals.topLevelApplication.projectNameBox){
				FlexGlobals.topLevelApplication.projectNameBox.visible=false;
			}
			updateWOA(e as MouseEvent);
			//fetchDataProjectList();
			//model.myProjectsModel.sendRequest();
			fetchDataMyProjects();
		}
		public function updateProjectReload(e:Event):void{
			var usm:UserSessionModel=model.userSessionModel;
			var current=usm.selectedTab;
			if( FlexGlobals.topLevelApplication.projectNameBox){
				FlexGlobals.topLevelApplication.projectNameBox.visible=false;
			}
			updateWOA(e as MouseEvent);
			fetchDataMyProjects(1);
		}
		
		public function updateProjectOnce(e:Event):void{
			var usm:UserSessionModel=model.userSessionModel;
			var current=usm.selectedTab;
			if( FlexGlobals.topLevelApplication.projectNameBox){
				FlexGlobals.topLevelApplication.projectNameBox.visible=false;
			}
			updateWOA(e as MouseEvent);
			model.myProjectsModel.sendRequestOnce();
			fetchDataMyProjects();
		}
		
		public function onAdminChanged(e:Event):void{
			fetchDataMyProjects();
			menu.myProjects.currentState="listOfProjects";
		}
		public function updateProjectSub(e:Event):void{
			var usm:UserSessionModel=model.userSessionModel;
			var current=usm.selectedTab;
			if(usm.loggedIn()){
				if(current == Language.lookup("MyContributions"))
				{
					menu.contributions.pView.loadingDisplay.text = Language.lookup("Loading");
					menu.contributions.pView.populateSubProjects();

				}
				else if(current==Language.lookup("MyPPProjects"))
				{
					menu.myProjects.loadingDisplay.text = Language.lookup("Loading");
					menu.myProjects.populateSubProjects();
			
				}else if (current ==Language.lookup("MainTab"))
				{
					menu.categories.pView.loadingDisplay.text = Language.lookup("Loading");
					menu.categories.pView.loadingDisplay.visible=true;
					menu.categories.pView.populateSubProjects();
				}else if(current==Language.lookup("MyMaps"))
				{
					//do nothing.
					
				}
			}
		}
		public function updateProjectMap(e:Event):void{
			var usm:UserSessionModel=model.userSessionModel;
			var current=usm.selectedTab;
			if(usm.loggedIn()){
				if(current == Language.lookup("MyContributions"))
				{
					menu.contributions.loadingDisplay.text = Language.lookup("Loading");
					menu.contributions.pView.populateMap();
					
				}
				else if(current==Language.lookup("MyPPProjects"))
				{
					menu.myProjects.loadingDisplay.text = Language.lookup("Loading");
					menu.myProjects.populateMap();
					
				}else if (current ==Language.lookup("MainTab"))
				{
					menu.categories.pView.loadingDisplay.text = Language.lookup("Loading");
					menu.categories.pView.loadingDisplay.visible=true;
					menu.categories.pView.populateMap();
					
				}else if(current==Language.lookup("MyMaps"))
				{
					//do nothing.
					
				}
			}
		}
		public function updateProjectUser(e:Event):void{
			var usm:UserSessionModel=model.userSessionModel;
			var current=usm.selectedTab;
			if(usm.loggedIn()){
				if(current == Language.lookup("MyContributions"))
				{
					menu.contributions.loadingDisplay.text = Language.lookup("Loading");
					menu.contributions.pView.populateUser();
					
				}
				else if(current==Language.lookup("MyPPProjects"))
				{
					menu.myProjects.loadingDisplay.text = Language.lookup("Loading");
					menu.myProjects.populateUser();
					
				}else if (current ==Language.lookup("MainTab"))
				{
					menu.categories.pView.loadingDisplay.text = Language.lookup("Loading");
					menu.categories.pView.loadingDisplay.visible=true;
					menu.categories.pView.populateUser();
					
				}else if(current==Language.lookup("MyMaps"))
				{
					//do nothing.
					
				}
			}
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
		// chat new commenting ..
			//	var chatM:ChatModel = model.chatModel;
		//	chatM.requestChat();	
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
			//menu.myProjects.theProject.loadingDisplay.visible = false;
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

		public function verifyProjectMember(parentCategory:String,parentID:int):void{
			this.tempParentCategory = parentCategory;
			this.tempParentCategoryID = parentID;
			model.verifyProjModel.send();
		}
		
		protected function onProjectUserVerified(event:AGORAEvent):void{
			var usm:UserSessionModel=AGORAModel.getInstance().userSessionModel;
			var current:String=usm.selectedTab;
			var cg=FlexGlobals.topLevelApplication.rightSidePanel.categoryChain;
			if (cg.waitingForVerification){
				cg.verified();
			}else
			if(usm.loggedIn()){
				if(usm.hidemaptemp){
					AGORAController.getInstance().hideMap(1);
					usm.hidemaptemp=false;
				}
				
				menu.myProjects.loadingDisplay.text = Language.lookup("Loading");
				menu.myProjects.loadingDisplay.visible = true;
				model.myProjectsModel.sendRequest();
				if(current == Language.lookup("MyContributions"))
				{
					menu.contributions.showpView();
					usm.selectedMyContProjID=""+tempParentCategoryID;
				}
				else if(current==Language.lookup("MyPPProjects"))
				{
					usm.selectedMyProjProjID=""+tempParentCategoryID;	
				}else if (current ==Language.lookup("MainTab"))
				{
					menu.categories.showpView();

					usm.selectedWoAProjID=tempParentCategoryID;
				}else if(current==Language.lookup("MyMaps"))
				{
					//do nothing.					
				}
			}fetchDataMyProjects();
			
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
		
		// --------------------------- On Save and Move chain update -------------- //
		public function UpdateChainonMapSaveAs():void{
			var usm:UserSessionModel=model.userSessionModel;
			var current=usm.selectedTab;
			if(usm.loggedIn()){
				if(current == Language.lookup("MyContributions"))
				{
					if(usm.selectedMyContProjID){
						getChain(parseInt(usm.selectedMyContProjID));
					}
				}
				else if(current==Language.lookup("MyPPProjects"))
				{
					if(usm.selectedMyProjProjID){
						getChain(parseInt(usm.selectedMyProjProjID));
					}					
				}else if (current ==Language.lookup("MainTab"))
				{
					if(parseInt(""+usm.selectedWoAProjID)){
						getChain(usm.selectedWoAProjID);
					}
				}else if(current==Language.lookup("MyMaps"))
				{
				}
			}
		}
		//------------------Fetch my Projects ------------------------------//
		public function fetchDataMyProjects(opt:int=0):void{
			var usm:UserSessionModel=model.userSessionModel;
			var current=usm.selectedTab;
			if(usm.loggedIn()){
				if(current == Language.lookup("MyContributions"))
				{
					menu.myProjects.loadingDisplay.text = Language.lookup("Loading");

					if(usm.selectedMyContProjID){
						model.myProjectsModel.requestProjDetails(usm.selectedMyContProjID);
						model.myProjectsModel.requestChildCategories(usm.selectedMyContProjID);
						model.myProjectsModel.listProjMaps(usm.selectedMyContProjID);
						getChain(parseInt(usm.selectedMyContProjID));
					}
				}
				else if(current==Language.lookup("MyPPProjects"))
				{
					menu.myProjects.loadingDisplay.text = Language.lookup("Loading");
					if(menu.myProjects.theProject!=null){
					menu.myProjects.theProject.flushall();
					}
					if(usm.selectedMyProjProjID){
						model.myProjectsModel.requestProjDetails(usm.selectedMyProjProjID);
						model.myProjectsModel.requestChildCategories(usm.selectedMyProjProjID);
						model.myProjectsModel.listProjMaps(usm.selectedMyProjProjID);
						getChain(parseInt(usm.selectedMyProjProjID));
					}					
				}else if (current ==Language.lookup("MainTab"))
				{
					menu.categories.pView.loadingDisplay.text = Language.lookup("Loading");
					menu.categories.pView.loadingDisplay.visible=true;
					var cg:Button=FlexGlobals.topLevelApplication.rightSidePanel.categoryChain.getCategory();
					if(cg.label!=Language.lookup("CategoryTopLevel")){
//						model.categoryModel.requestChildCategories(cg.label,parseInt(cg.name));
					}
					if(parseInt(""+usm.selectedWoAProjID)){
						model.myProjectsModel.requestProjDetails(""+usm.selectedWoAProjID);
						model.myProjectsModel.requestChildCategories(""+usm.selectedWoAProjID);
						model.myProjectsModel.listProjMaps(""+usm.selectedWoAProjID);
						getChain(usm.selectedWoAProjID);
					}
				}else if(current==Language.lookup("MyMaps"))
				{
					//do nothing.
					
				}
			}
			
		//	model.myProjectsModel.sendRequest();
			if(opt==1){
			model.myProjectsModel.sendRequestOnce();
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
			//fetchDataProjectList();
			var usm:UserSessionModel=model.userSessionModel;
			var current=usm.selectedTab;
			if(current ==Language.lookup("MyPPProjects"))
				fetchDataMyProjects(1);	
				else
					fetchDataMyProjects();
			if (current ==Language.lookup("MainTab") && parseInt(""+usm.selectedWoAProjID) && menu.categories.layerView)
			{
				model.categoryModel.requestChildCategories("",usm.selectedWoAProjID);
			}			
		}
		protected function updateMapProj(){
			if( FlexGlobals.topLevelApplication.projectNameBox){
				FlexGlobals.topLevelApplication.projectNameBox.visible=false;
			}
			//fetchDataProjectList();
			fetchDataMyProjects();
			if(AGORAModel.getInstance().userSessionModel.selectedTab==Language.lookup("MyContributions"))
			{
	//			if(this.contributionsCategoryChain.length - 1>0){
//					fetchChildCategorycontributions(this.contributionsCategoryChain.getItemAt((this.contributionsCategoryChain.length - 1)).current,this.contributionsCategoryChain.getItemAt((this.contributionsCategoryChain.length - 1)).currentID);

//				}
			}
			/*else if(this.categoryChain.length - 1>0){
					fetchDataChildCategory(this.categoryChain.getItemAt((this.categoryChain.length - 1)).current,this.categoryChain.getItemAt((this.categoryChain.length - 1)).currentID,true);
				}*/
		}
		protected function onProjectMoved(event:AGORAEvent):void{
			fetchDataProjectList();
			fetchDataMyProjects(1);
			/*if(this.categoryChain.length - 1>0){
				fetchDataChildCategory(this.categoryChain.getItemAt((this.categoryChain.length - 1)).current,this.categoryChain.getItemAt((this.categoryChain.length - 1)).currentID,true);
			}*/
		}
		
		protected function onProjectsListFetched(event:AGORAEvent):void{
			menu.myProjects.populateProjects();
			menu.myProjects.populateProjects();
			//menu.myProjects.theProject.loadingDisplay.visible = false;
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
			var printIt:VGroup = new VGroup();
			var rsp:RightSidePanel= FlexGlobals.topLevelApplication.rightSidePanel;
			var flexPrintJob:FlexPrintJob = new FlexPrintJob();
			flexPrintJob.printAsBitmap = false;
			var created:Text=new Text();
			var author:Text=new Text();
			var agoraLogo=map.agoraLogo;
			var mapTitle=new Text();
			var agoraInfo:TextArea=new TextArea();
			agoraInfo.minWidth=300;
			agoraInfo.setStyle("borderVisible",false);
			agoraInfo.htmlText=Language.lookup("PrintFootNote");
			agoraLogo.visible=true;
			mapTitle.text = Language.lookup("Title") +rsp.mapTitle.text;
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "MMM DD,  YYYY LL:NN:SS A";
			created.text=Language.lookup("CreatedOn")+ dateFormatter.format(new Date());
			author.text=Language.lookup("FirstAuthor")+rsp.clickableMapOwnerInformation.label;
			author.percentWidth=100;
			mapTitle.percentWidth=100;
			agoraLogo.height=50;
			var logoAndInfo:HGroup=new HGroup;
			logoAndInfo.percentWidth==100;
			logoAndInfo.addElement(agoraLogo);
			logoAndInfo.addElement(agoraInfo);
			logoAndInfo.minWidth=600;
			printIt.minWidth=600;


			if(flexPrintJob.start()){
				printIt.addElement(logoAndInfo);
				printIt.addElement(mapTitle);
				printIt.addElement(author);
				printIt.addElement(created);
				printIt.gap=0;
				var tempZoom =map.zoomer.value;
				var printCanvas:Canvas = new Canvas;
				map.alerts.removeElement(map.agoraMap);
				FlexGlobals.topLevelApplication.addElement(printCanvas);
				printCanvas.width=map.agoraMap.width;
				printCanvas.height=map.agoraMap.height+200;

				printIt.width=printCanvas.width/map.zoomer.value;
				printIt.height = 100*map.zoomer.value;
				printCanvas.addElement(map.agoraMap);
				printCanvas.addElement(printIt);

				map.zoomerResize();
				map.zoomer.value=1;
				map.zoom();
				printCanvas.horizontalScrollPolicy="ScrollPolicy.OFF";
				printCanvas.verticalScrollPolicy="ScrollPolicy.OFF";
				printIt.scaleX=map.zoomer.value;
				printIt.scaleY=map.zoomer.value;
				//agoraLogo.scaleX=map.zoomer.value;
				//agoraLogo.scaleY=map.zoomer.value;

				map.agoraMap.top=printIt.height;
				map.agoraMap.left=0;
				map.agoraMap.top=100*map.zoomer.value;

				//printIt.addElement(map.agoraMap);
				flexPrintJob.printAsBitmap = false;
			    flexPrintJob.addObject(printCanvas,FlexPrintJobScaleType.SHOW_ALL);
				flexPrintJob.send();
				//printIt.removeElement(map.agoraMap);
				FlexGlobals.topLevelApplication.removeElement(printCanvas);
				map.alerts.addElementAt(map.agoraMap,0)
					map.zoomer.value=tempZoom;
					map.zoom();
					printCanvas.removeElement(printIt);
			}

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
			//menu.mapList.loadingDisplay.text = Language.lookup("NetworkError");
			///menu.myProjects.theProject.loadingDisplay.text = Language.lookup("NetworkError");
			if(userSession.uid){
//				menu.myMaps.loadingDisplay.text = Language.lookup("NetworkError");
			}
		}
		
		
		
		//----------- other public functions --------------------//
		public function hideMap(opt:int=0):void{
			//get the global chat on
			var chatbx:ChatWindow = FlexGlobals.topLevelApplication.rightSidePanel.chat;
			chatbx.init();
			FlexGlobals.topLevelApplication.rightSidePanel.invalidateDisplayList();
			//When we return to the category screen by clicking save and home or loading an illegal map,
			//find the current category and refresh it. Solved a problem with a created map not appearing
			//in the category panel upon returning home.
			/*if(categoryChain.length <= 0){
				fetchDataCategory();
			} else {
				fetchDataChildCategory((CategoryDataV0) (categoryChain.getItemAt(categoryChain.length-1)).current,this.categoryChain.getItemAt((this.categoryChain.length - 1)).currentID, false);
			}*/
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
			if(opt==0){
			AGORAController.getInstance().fetchDataMapList();
			AGORAController.getInstance().fetchDataMyMaps();
			AGORAController.getInstance().fetchDataChat();
			}
			if(model.rechain!=null && model.rechain){
				UpdateChainonMapSaveAs();
				model.rechain=false;
			}
			AGORAController.getInstance().mapModel.name = "null";
			//timers
			map.agoraMap.timer.reset();
			menu.timer.start();
		}
		
		public function showMap():void{
			map.setScrollers(0,0);
			map.zoomer.value=1;
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
		public function setSelectedTab(index:int):void{
			menu.tabNav.selectedIndex=index;
			//menu.setTab(((menu.tabNav.getChildAt(index)) as NavigatorContent).label);
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
				if(state == "addUsers")
				projectNameDialog.firstUserNameTextBox.setFocus();
				/*else
					projectNameDialog.firstUserNameTextBox.setFocus();*/	
			}
			else{
				Alert.show(Language.lookup("MustRegister"));
			}
		}





	}
}

class SingletonEnforcer{
	
}
