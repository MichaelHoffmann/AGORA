package Controller
{
	import Controller.logic.ConditionalSyllogism;
	import Controller.logic.LogicFetcher;
	import Controller.logic.ParentArg;
	
	import Events.AGORAEvent;
	
	import Model.AGORAMapModel;
	import Model.AGORAModel;
	import Model.ArgumentTypeModel;
	import Model.MapMetaData;
	import Model.StatementModel;
	import Model.UserSessionModel;
	
	import ValueObjects.AGORAParameters;
	
	import classes.Language;
	
	import components.AGORAMenu;
	import components.AgoraMap;
	import components.ArgSelector;
	import components.ArgumentPanel;
	import components.ChatWindow;
	import components.GridPanel;
	import components.HelpText;
	import components.InfoBox;
	import components.Map;
	import components.MenuPanel;
	import components.Option;
	import components.RightSidePanel;
	import components.StatusBar;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import flashx.textLayout.formats.BackgroundColor;
	
	import mx.controls.Alert;
	import mx.controls.Menu;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.events.MenuEvent;
	import mx.managers.CursorManager;
	import mx.managers.PopUpManager;
	import mx.skins.spark.DefaultButtonSkin;
	import mx.states.State;
	
	//import org.osmf.layout.AbsoluteLayoutFacet;
	
	public class ArgumentController
	{
		private static var instance:ArgumentController;
		private var view:DisplayObject;
		private var model:AGORAModel;
		private var agoraParameters:AGORAParameters;
		private var map:Map;
		private var menu:AGORAMenu;
		private var sbar:StatusBar;
		
		public function ArgumentController(singletonEnforcer:SingletonEnforcer)
		{
			instance = this;	
			view = DisplayObject(FlexGlobals.topLevelApplication);
			model = AGORAModel.getInstance();
			map = FlexGlobals.topLevelApplication.map;
			menu = FlexGlobals.topLevelApplication.agoraMenu;
			
			agoraParameters = AGORAParameters.getInstance();	
			//Event handlers
			model.agoraMapModel.addEventListener(AGORAEvent.MAP_CREATED, onMapCreated);
			model.agoraMapModel.addEventListener(AGORAEvent.MAP_CREATION_FAILED, onMapCreatedFault);
			model.agoraMapModel.addEventListener(AGORAEvent.MAP_SAVEDAS, onMapSaveAsPass);
			model.agoraMapModel.addEventListener(AGORAEvent.MAP_SAVEDASFAULT, onMapSaveAsFault);
			model.agoraMapModel.addEventListener(AGORAEvent.FAULT, onFault);
			model.agoraMapModel.addEventListener(AGORAEvent.FIRST_CLAIM_ADDED, onFirstClaimAdded);
			model.agoraMapModel.addEventListener(AGORAEvent.STATEMENT_ADDED, setEventListeners);
			model.agoraMapModel.addEventListener(AGORAEvent.ARGUMENT_TYPE_ADDED, setArgumentTypeModelEventListeners);
			model.agoraMapModel.addEventListener(AGORAEvent.ARGUMENT_SCHEME_SET, onArgumentSchemeSet);
		}
		
		//---------------------Get Instance -----------------------------//
		public static function getInstance():ArgumentController{
			if(!instance){
				instance = new ArgumentController(new SingletonEnforcer);
			}
			return instance;
		}
		
		
		
		
		//--------------------- Other public function -------------------//
		public function removeOption(event:AGORAEvent):void{
			var argumentPanel:ArgumentPanel = event.eventData as ArgumentPanel;
			if(argumentPanel.branchControl != null){
				try{
					map.agoraMap.removeChild(argumentPanel.branchControl);
					//this will not be called again, and 
					//GC will clean the option component
					argumentPanel.branchControl = null;
				}catch(error:Error){
					//clicking on the Option component itself may remove 
					//it from map
					trace("Option component must have already been removed");
				}
			}
		}
		
		//-------------------- Load a saved Map --------------------------------//
		public function loadMapMain(id:String,historyClear:Boolean):void{
			if(model.userSessionModel.loggedIn()){
				if(historyClear){
					var thisMapInfo:UserSessionModel =  AGORAModel.getInstance().userSessionModel;
					((Vector.<Object>)(thisMapInfo.historyMapsVisited)).splice(0,((Vector.<Object>)(thisMapInfo.historyMapsVisited)).length);;
				}
				//initialize the model
				model.agoraMapModel.reinitializeModel();
				model.agoraMapModel.ID = int(id);
				//hide and show view components
				menu.visible = false;
				map.visible = true;
				// map specific chat
				var  chatbox:ChatWindow = FlexGlobals.topLevelApplication.rightSidePanel.chat;
				chatbox.mapId = id;
				chatbox.initMapChat(true);
				FlexGlobals.topLevelApplication.rightSidePanel.invalidateDisplayList();
				map.agora.visible = true;
				//reinitialize map view
				map.agoraMap.initializeMapStructures();
				//fetch data
				LoadController.getInstance().fetchMapData();
				// re on save and load
				if(model.rechain!=null && model.rechain){
					model.rechain=true;
				}else{
					model.rechain=false;
				}
			}else{
				Alert.show(Language.lookup("MustRegister"));
			}
		}
		//-------------------- Load a saved Map With History --------------------------------//
		public function loadMap(id:String):void{
			return loadMapMain(id,true);
		}
		
		//---------------------Creating a New Map-----------------------//
		public function createMap(mapName:String):void{
			model.agoraMapModel.reinitializeModel();
			model.agoraMapModel.createMap(mapName);	
			map.agoraMap.initializeMapStructures();
		}

		protected function onMapCreatedFault(event:AGORAEvent):void{
			Alert.show(Language.lookup("MapNameUnique"));
			var mapMetaData:MapMetaData = event.eventData as MapMetaData;
			AGORAController.getInstance().unfreeze();
			PopUpManager.removePopUp(FlexGlobals.topLevelApplication.mapNameBox);
			}
		protected function onMapCreated(event:AGORAEvent):void{
			var usm:UserSessionModel = AGORAModel.getInstance().userSessionModel;
			var rsp:RightSidePanel = FlexGlobals.topLevelApplication.rightSidePanel;
			var mapMetaData:MapMetaData = event.eventData as MapMetaData;
			AGORAController.getInstance().unfreeze();
			PopUpManager.removePopUp(FlexGlobals.topLevelApplication.mapNameBox);
			AGORAModel.getInstance().agoraMapModel.ID = mapMetaData.mapID;
			map.visible = true;
			var rsp:RightSidePanel = FlexGlobals.topLevelApplication.rightSidePanel;
			rsp.titleOfMap.text = this.model.agoraMapModel.name;
			rsp.clickableMapOwnerInformation.label = mapMetaData.mapCreator;
			rsp.clickableMapOwnerInformation.toolTip = 
				mapMetaData.url + '\n' + Language.lookup('MapOwnerURLWarning');
			rsp.clickableMapOwnerInformation.addEventListener(MouseEvent.CLICK, function event(e:Event):void{
				var urllink:String = mapMetaData.url;
				if(urllink!=null && urllink.indexOf("http://") ==-1)
					urllink = "http://"+urllink;							
				navigateToURL(new URLRequest(urllink), 'quote');
			},false, 0, false);
			rsp.mapTitle.text = this.model.agoraMapModel.name;
			rsp.invalidateDisplayList();
			startWithClaim();
			if(mapMetaData.mapCreator== usm.username){
				rsp.mapTitle.enabled=true;
				
			}else{
				rsp.mapTitle.enabled=false;
			}
			// update current view 
			var usm:UserSessionModel=model.userSessionModel;
			var current=usm.selectedTab;
				if(current == Language.lookup("MyContributions"))
				{
					if(usm.selectedMyContProjID){												
						model.myProjectsModel.listProjMaps(usm.selectedMyContProjID);
					}
				}
				else if(current==Language.lookup("MyPPProjects"))
				{
					if(usm.selectedMyProjProjID){
						model.myProjectsModel.listProjMaps(usm.selectedMyProjProjID);
					}					
				}else if (current ==Language.lookup("MainTab"))
				{
					if(parseInt(""+usm.selectedWoAProjID)){
						model.myProjectsModel.listProjMaps(""+usm.selectedWoAProjID);
					}
				}
			AGORAController.getInstance().getMapChain(mapMetaData.mapID);

		}
		
		
		//---------------------Save Map as-----------------------//
		public function saveMapAs(mapName:String):void{
//			model.agoraMapModel.reinitializeModel();
			var mapID= AGORAModel.getInstance().agoraMapModel.ID;
			model.agoraMapModel.saveAsMap(mapName,mapID);	
//			map.agoraMap.initializeMapStructures();
		}
		protected function onMapSaveAsFault(event:AGORAEvent):void{
			Alert.show(Language.lookup("MapNameUnique"));
			var mapMetaData:MapMetaData = event.eventData as MapMetaData;
			AGORAController.getInstance().unfreeze();
			PopUpManager.removePopUp(FlexGlobals.topLevelApplication.saveAsMapBox);
		}
		protected function onMapSaveAsPass(event:AGORAEvent):void{
			var mapObj = event.eventData;
			AGORAController.getInstance().unfreeze();
			PopUpManager.removePopUp(FlexGlobals.topLevelApplication.saveAsMapBox);
			Alert.show(Language.lookup("SaveAsMapSuccessMsg"),"Map saved",Alert.YES|Alert.NO, null, function(event:CloseEvent){
				if(event.detail == Alert.YES) {
					var rsp:RightSidePanel= FlexGlobals.topLevelApplication.rightSidePanel;
					rsp.clickableMapOwnerInformation.label = mapObj.username;
					rsp.mapTitle.text=mapObj.title;
					rsp.clickableMapOwnerInformation.toolTip = 
					 mapObj.url + '\n' + Language.lookup('MapOwnerURLWarning');
					rsp.clickableMapOwnerInformation.addEventListener(MouseEvent.CLICK, function event(e:Event):void{
						var urllink:String = mapObj.url;
						if(urllink!=null && urllink.indexOf("http://") ==-1)
							urllink = "http://"+urllink;			
						navigateToURL(new URLRequest(urllink), 'quote');
					},false, 0, false);
					rsp.invalidateDisplayList();
					model.rechain=true;
					ArgumentController.getInstance().loadMap(mapObj.ID);
				}
			});	
			}
		
		//-------------------Start with Claim----------------------------//
		public function startWithClaim():void{
			//remove Lam world

			//display map
			map.agora.visible = true;
			menu.visible= false;
			//ask controller to add the first claim
			addFirstClaim();
		}
		
		//-------------------Add First Claim------------------------------//
		public function addFirstClaim():void{
			if(!model.requested){
				//Set the coordinates of the help text
				map.agoraMap.firstClaimHelpText.visible = true;
				map.agoraMap.firstClaimHelpText.y = 2 * agoraParameters.gridWidth;
				map.agoraMap.firstClaimHelpText.x = 3 * agoraParameters.gridWidth + 300 + 25;
				//instruct the model to add a first claim to itself
				model.requested = true;
				model.agoraMapModel.addFirstClaim();
			}
		}
		
		protected function onFirstClaimAdded(event:AGORAEvent):void{
			var statementModel:StatementModel = event.eventData as StatementModel;
			model.requested = false;
			LoadController.getInstance().fetchMapData();
		}
		
		protected function onFirstClaimFailed(event:AGORAEvent):void{
			Alert.show(Language.lookup('FirstClaimFailed'));
			LoadController.getInstance().fetchMapData();
		}
		public function addComment(model:StatementModel):void{
			var obj:StatementModel;
			if(model.comments.length == 0)
				obj= LayoutController.getInstance().getBottomObjection(model);
			else
				obj= LayoutController.getInstance().getBottomComment(model);
			if(obj != null && map.agoraMap.panelsHash[obj.ID]){
				var bottomComment: ArgumentPanel = map.agoraMap.panelsHash[obj.ID];
				model.comment(obj.xgrid + bottomComment.height/agoraParameters.gridWidth + 3);	
			}
			else{
				var aPanel:ArgumentPanel = map.agoraMap.panelsHash[model.ID];
				model.comment(model.xgrid + aPanel.getExplicitOrMeasuredHeight()/agoraParameters.gridWidth + 1);
			}
		}
		public function addAmendment(model:StatementModel):void{
			var obj:StatementModel;
			if(model.comments.length == 0)
				obj= LayoutController.getInstance().getBottomObjection(model);
			else
				obj= LayoutController.getInstance().getBottomComment(model);
			if(obj != null && map.agoraMap.panelsHash[obj.ID]){
				var bottomComment: ArgumentPanel = map.agoraMap.panelsHash[obj.ID];
				model.amendment(obj.xgrid + bottomComment.height/agoraParameters.gridWidth + 3 );	
			}
			else{
				var aPanel:ArgumentPanel = map.agoraMap.panelsHash[model.ID];
				model.amendment(model.xgrid + aPanel.getExplicitOrMeasuredHeight()/agoraParameters.gridWidth + 1);
			}
		}
		public function addReference(model:StatementModel):void{
			var obj:StatementModel;
			obj= LayoutController.getInstance().getBottomObjection(model);
			for(var i:int = 0;i<model.comments.length;i++)
			{
				if(model.comments[i].statementFunction == StatementModel.LINKTORESOURCES)
					obj= model.comments[i];
			}
			if(obj != null && map.agoraMap.panelsHash[obj.ID]){
				var bottomComment: ArgumentPanel = map.agoraMap.panelsHash[obj.ID];
				model.reference(obj.xgrid + bottomComment.height/agoraParameters.gridWidth + 3 );	
			}
			else{
				var aPanel:ArgumentPanel = map.agoraMap.panelsHash[model.ID];
				model.reference(model.xgrid + aPanel.getExplicitOrMeasuredHeight()/agoraParameters.gridWidth + 1);
			}
		}
		public function addQuestion(model:StatementModel):void{
			var obj:StatementModel;
			if(model.comments.length == 0)
				obj= LayoutController.getInstance().getBottomObjection(model);
			else
				obj= LayoutController.getInstance().getBottomComment(model);
			if(obj != null && map.agoraMap.panelsHash[obj.ID]){
				var bottomComment: ArgumentPanel = map.agoraMap.panelsHash[obj.ID];
				model.question(obj.xgrid + bottomComment.height/agoraParameters.gridWidth + 3 );	
			}
			else{
				var aPanel:ArgumentPanel = map.agoraMap.panelsHash[model.ID];
				model.question(model.xgrid + aPanel.getExplicitOrMeasuredHeight()/agoraParameters.gridWidth + 1);
			}
		}
		public function addSupport(model:StatementModel):void{
			var obj:StatementModel = LayoutController.getInstance().getBottomComment(model);
			if(model.comments.length == 0)
				obj= LayoutController.getInstance().getBottomObjection(model);
			else
				obj= LayoutController.getInstance().getBottomComment(model);
			if(obj != null && map.agoraMap.panelsHash[obj.ID]){
				var bottomComment: ArgumentPanel = map.agoraMap.panelsHash[obj.ID];
				model.support(obj.xgrid + bottomComment.height/agoraParameters.gridWidth + 3 );	
			}
			else{
				var aPanel:ArgumentPanel = map.agoraMap.panelsHash[model.ID];
				model.support(model.xgrid + aPanel.getExplicitOrMeasuredHeight()/agoraParameters.gridWidth + 1);
			}
		}
		
		public function addReformulation(model:StatementModel):void{
			var obj:StatementModel;
			if(model.comments.length == 0)
				obj= LayoutController.getInstance().getBottomObjection(model);
			else
				obj= LayoutController.getInstance().getBottomComment(model);
			if(obj != null && map.agoraMap.panelsHash[obj.ID]){
				var bottomComment: ArgumentPanel = map.agoraMap.panelsHash[obj.ID];
				model.reformulation(obj.xgrid + bottomComment.height/agoraParameters.gridWidth + 3 );	
			}
			else{
				var aPanel:ArgumentPanel = map.agoraMap.panelsHash[model.ID];
				model.reformulation(model.xgrid + aPanel.getExplicitOrMeasuredHeight()/agoraParameters.gridWidth + 1);
			}
		}
		public function addLinkToMap(model:StatementModel):void{
			var obj:StatementModel;
			if(model.comments.length == 0)
				obj= LayoutController.getInstance().getBottomObjection(model);
			else
				obj= LayoutController.getInstance().getBottomComment(model);
			if(obj != null && map.agoraMap.panelsHash[obj.ID]){
				var bottomComment: ArgumentPanel = map.agoraMap.panelsHash[obj.ID];
				model.linktomap(obj.xgrid + bottomComment.height/agoraParameters.gridWidth + 3 );	
			}
			else{
				var aPanel:ArgumentPanel = map.agoraMap.panelsHash[model.ID];
				model.linktomap(model.xgrid + aPanel.getExplicitOrMeasuredHeight()/agoraParameters.gridWidth + 1);
			}
		}
		public function addLinkToResource(model:StatementModel):void{
			var obj:StatementModel;
			obj= LayoutController.getInstance().getBottomObjection(model);
		//	 for(var i:int = 0;i<model.comments.length;i++)
			// {
				// if(model.comments[i].statementFunction == StatementModel.LINKTORESOURCES)
					// obj= model.comments[i];
			 //}
			//if(model.comments.length == 0)
				
		//	else
			//	obj= LayoutController.getInstance().getBottomComment(model);
			if(obj != null && map.agoraMap.panelsHash[obj.ID]){
				var bottomComment: ArgumentPanel = map.agoraMap.panelsHash[obj.ID];
				model.linktoresource(obj.xgrid + bottomComment.height/agoraParameters.gridWidth + 3 );	
			}
			else{
				var aPanel:ArgumentPanel = map.agoraMap.panelsHash[model.ID];
				model.linktoresource(model.xgrid + aPanel.getExplicitOrMeasuredHeight()/agoraParameters.gridWidth + 1);
			}
		}
		public function addDefinition(model:StatementModel):void{
			var obj:StatementModel;
			if(model.comments.length == 0)
				obj= LayoutController.getInstance().getBottomObjection(model);
			else
				obj= LayoutController.getInstance().getBottomComment(model);
			if(obj != null && map.agoraMap.panelsHash[obj.ID]){
				var bottomComment: ArgumentPanel = map.agoraMap.panelsHash[obj.ID];
				model.definition(obj.xgrid + bottomComment.height/agoraParameters.gridWidth + 3 );	
			}
			else{
				var aPanel:ArgumentPanel = map.agoraMap.panelsHash[model.ID];
				model.definition(model.xgrid + aPanel.getExplicitOrMeasuredHeight()/agoraParameters.gridWidth + 1);
			}
		}
		//----------------- Adding an Argument -------------------------------//
		public function addSupportingArgument(statementModel:StatementModel):void{
			if(checkArgUnderConstruction()){
				return;
			}
			if(!AGORAModel.getInstance().requested){
				if(statementModel.firstClaim){//first claim
					if(statementModel.supportingArguments.length == 0){
						map.agoraMap.firstClaimHelpText.visible = false;
					}
				}
				//tell the statement to support itself with an argument. Supply the position.
				//figure out the position
				//find out the last menu panel
				if(statementModel.supportingArguments.length > 0){
					var argumentTypeModel:ArgumentTypeModel = statementModel.supportingArguments[statementModel.supportingArguments.length - 1];
					//Find the last grid
					//Find out the inference
					var inferenceModel:StatementModel = argumentTypeModel.inferenceModel;
					var inference:ArgumentPanel = FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[inferenceModel.ID];
					var xgridInference:int = (inference.y + inference.height) / AGORAParameters.getInstance().gridWidth + .10;
					//find out hte last reason
					var reasonModel:StatementModel = argumentTypeModel.reasonModels[argumentTypeModel.reasonModels.length - 1];
					var reason:ArgumentPanel = FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[reasonModel.ID];
					//find the last grid
					var xgridReason:int = (reason.y + reason.height ) / agoraParameters.gridWidth +10;
					//compare and figure out the max
					var nxgrid:int = xgridInference > xgridReason? xgridInference:xgridReason;
				}else{
					nxgrid = statementModel.xgrid;
				}
				//call the function
				AGORAModel.getInstance().requested = true;
				model.agoraMapModel.argUnderConstruction = true;
				statementModel.addSupportingArgument(nxgrid);
			}
		}
		
		protected function onArgumentCreated(event:AGORAEvent):void{
			model.requested = false;
			LoadController.getInstance().fetchMapData(); 
		}
		
		protected function onArgumentCreationFailed(event:AGORAEvent):void{
			Alert.show(Language.lookup( "ArgumentAdditionFailed"));
			model.agoraMapModel.argUnderConstruction = false;
			LoadController.getInstance().fetchMapData();
		}
		
		//------------------ Adding a Reason -------------------------------------//
		public function addReasonToExistingArgument(argumentTypeModel:ArgumentTypeModel):void{
			if(checkArgUnderConstruction()){
				return;
			}
			addReason(argumentTypeModel);
		}
		
		public function addReason(argumentTypeModel:ArgumentTypeModel):void{
			var x:int;
			var y:int;
			var flag:int = 0;
			if(!model.requested){
				if(argumentTypeModel.logicClass != null){
					var logicController:ParentArg = LogicFetcher.getInstance().logicHash[argumentTypeModel.logicClass];
					for each(var langType:String in logicController.expLangTypes){
						if(langType == argumentTypeModel.language){
							flag = 1;
							break;
						}
					}
				}{
					flag = 1;
				}
				if(argumentTypeModel.logicClass == AGORAParameters.getInstance().MOD_PON)
				{
					if(argumentTypeModel.language == (Language.lookup("Implies")) || argumentTypeModel.language == (Language.lookup("OnlyIf")) || argumentTypeModel.language == (Language.lookup("SufficientCond")) || argumentTypeModel.language == (Language.lookup("NecessaryCond")))
						flag = 0;
				}
				if(argumentTypeModel.logicClass == AGORAParameters.getInstance().MOD_TOL)
				{
					if(argumentTypeModel.language == (Language.lookup("OnlyIf")))
						flag = 1;
					else
						flag = 0;
				}
				if(argumentTypeModel.logicClass == AGORAParameters.getInstance().DIS_SYLL || argumentTypeModel.logicClass == AGORAParameters.getInstance().DIS_SYLL){
					flag = 1;
				}
				if(flag == 0){
					Alert.show(Language.lookup("CannotAddReason"));
					return;
				}
				var lastReason:ArgumentPanel = FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[LayoutController.getInstance().getBottomReason(argumentTypeModel).ID];
				x = (lastReason.y + lastReason.height)/AGORAParameters.getInstance().gridWidth + 3;
				y = argumentTypeModel.reasonModels[argumentTypeModel.reasonModels.length - 1].ygrid;
				AGORAModel.getInstance().requested = true;
				argumentTypeModel.addReason(x, y);
			}
			else{
				Alert.show(Language.lookup("ServerBusy"));
			}
		}
		
		protected function onReasonAdded(event:AGORAEvent):void{
			AGORAModel.getInstance().requested = false;
			LoadController.getInstance().fetchMapData();
		}
		
		//----------------- Construct Argument -----------------------------//
		public function initiateArgumentConstruction(argumentTypeModel:ArgumentTypeModel):void{
			if(checkArgUnderConstruction()){
				return;
			}
			model.agoraMapModel.argUnderConstruction = true;
			var helpText:HelpText = map.agoraMap.helpText;
			helpText.visible = false;
			helpText.parent.setChildIndex(helpText, map.agoraMap.numChildren -1);
			//get the first reason
			var firstReason:ArgumentPanel = AgoraMap(helpText.parent).panelsHash[ argumentTypeModel.reasonModels[0].ID];
			helpText.x = firstReason.x + firstReason.width + 30;
			helpText.y = firstReason.y;
			constructArgument(argumentTypeModel);
		} 
		
		public function constructArgument(argumentTypeModel:ArgumentTypeModel):void{
			if(!argumentTypeModel.reasonsCompleted){
				//make inference visible
				argumentTypeModel.reasonsCompleted = true;
			}
			//get the scheme selector
			var menuPanel:MenuPanel = FlexGlobals.topLevelApplication.map.agoraMap.menuPanelsHash[argumentTypeModel.ID];
			var schemeSelector:ArgSelector = menuPanel.schemeSelector;
			//Fill them up
			//if constrained
			if(argumentTypeModel.isTyped() && argumentTypeModel.logicClass != null){
				schemeSelector.scheme = ParentArg.getInstance().getConstrainedArray(argumentTypeModel);
			}
			else if(argumentTypeModel.logicClass == AGORAParameters.getInstance().COND_SYLL){
				schemeSelector.scheme = ParentArg.getInstance().getConstrainedArray(argumentTypeModel);
			}
			else if(argumentTypeModel.claimModel.firstClaim && argumentTypeModel.claimModel.statements.length == 1 && argumentTypeModel.claimModel.supportingArguments.length == 1){
				schemeSelector.scheme = ParentArg.getInstance().getFullArray();
			}
			else if(argumentTypeModel.claimModel.statements.length > 1){
				//Allowing for constructive dilemma. For constructive dilemma
				//a separate treatment is required
				//It's not yet incorporated
				
				//if positive implication
				if(argumentTypeModel.claimModel.connectingString == StatementModel.IMPLICATION){
					schemeSelector.scheme = ParentArg.getInstance().getImplicationArray();
				}
				
				//if positive disjunction -- This is conditional dilemma
				else if(argumentTypeModel.claimModel.connectingString == StatementModel.DISJUNCTION){
					schemeSelector.scheme = ParentArg.getInstance().getDisjunctionPositiveArray();
				}
				
			}
				//if simple positive statement
			else if(!argumentTypeModel.claimModel.negated){
				schemeSelector.scheme = ParentArg.getInstance().getPositiveArray();
			}
				//if simple negative statement
			else if(argumentTypeModel.claimModel.negated){
				schemeSelector.scheme = ParentArg.getInstance().getNegativeArray();
			}
			
			//show the menu
			//if(argumentTypeModel.logicClass != agoraParameters.DIS_SYLL && argumentTypeModel.logicClass != agoraParameters.NOT_ALL_SYLL){
			menuPanel.showArgSelector();
			//}
		}
		
		//----------------- After done button is clicked --------------------//
		public function onTextEntered(argumentPanel:ArgumentPanel):void{
			//if first claim
			var model:StatementModel = argumentPanel.model;
			if(model.firstClaim && model.supportingArguments.length == 0){
				//add an argument
				addSupportingArgument(model);
			}
				//if reasons Completed
				/*
				else if(!model.firstClaim && model.argumentTypeModel.reasonsCompleted){
				if(model.argumentTypeModel.reasonsCompleted){
				}
				}
				*/
			else if (!model.firstClaim && model.statementFunction == StatementModel.STATEMENT){
				if(!model.argumentTypeModel.reasonsCompleted){
					argumentPanel.showMenu();
				}
			}
		}
		
		//----------------- State Changes in a Statement --------------------//
		public function changeType(ID:int):void{
			try{
				//Busy Cursor
				if(!AGORAModel.getInstance().requested){
					CursorManager.setBusyCursor();
					//Find out the model class
					var sModel:StatementModel = model.agoraMapModel.panelListHash[ID];
					//Change the model
					AGORAModel.getInstance().requested = true;
					sModel.toggleType();
				}
			}catch(error:Error){
				Alert.show(AGORAParameters.getInstance().STATEMENT_TOGGLE_FAILED);
			}
		}
		
		protected function statementTypeToggled(event:AGORAEvent):void{
			AGORAModel.getInstance().requested = false;
			var sModel:StatementModel = AGORAModel.getInstance().agoraMapModel.panelListHash[event.eventData as int];
			var argumentPanel:ArgumentPanel = FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[event.eventData as int];
			CursorManager.removeBusyCursor();
		}
		
		protected function onStatementTogglingFailed(event:AGORAEvent):void{
			Alert.show(Language.lookup("StatementToggleFailed"));
		}
		
		//--------------------- delete Map -------------------------------//
		public function deleteNodes(gridPanel:GridPanel):void{

			if(!AGORAModel.getInstance().requested){
				var model:StatementModel = (gridPanel as ArgumentPanel).model;
				if(model.statementFunction == StatementModel.STATEMENT){
					if(model.supportingArguments.length == 0 && model.objections.length == 0 && (model.argumentTypeModel && model.argumentTypeModel.inferenceModel.supportingArguments.length == 0)){
						if(/*model.statement.text!="" &&*/ checkArgUnderConstruction()){
							return;
						}
						AGORAModel.getInstance().requested = true;
						/* for empty nodes
						var argumentPanel:ArgumentPanel = FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[model.ID];
						if(argumentPanel.branchControl != null){
							try{
								map.agoraMap.removeChild(argumentPanel.branchControl);
								argumentPanel.branchControl = null;
							}catch(error:Error){
								trace("Option component must have already been removed");
							}
						}
						*/
						map.sBar.displayLoading();
						model.deleteMe();
					}
					else{
						Alert.show(Language.lookup("DeleteFirstClaim"));
					}
					
				}
				else if(model.statementFunction == StatementModel.INFERENCE){
					if(model.supportingArguments.length > 0 || model.objections.length > 0){
						Alert.show(Language.lookup("DeleteSuppStmt"));
						return;
					}
					for each(var stmt:StatementModel in model.argumentTypeModel.reasonModels){
						if(stmt.supportingArguments.length > 0 || stmt.objections.length > 0){
							Alert.show(Language.lookup("DeleteSuppStmtExt"));
							return;
						}
					}
					if(checkArgUnderConstruction()){
						return;
					}
					AGORAModel.getInstance().requested = true;
					map.sBar.displayLoading();
					model.deleteMe();
				}
				else if(model.statementFunction == StatementModel.OBJECTION || model.statementFunction == StatementModel.COUNTER_EXAMPLE){
					if(model.supportingArguments.length > 0 || model.objections.length > 0){
						Alert.show(Language.lookup("DeleteSuppStmt"));
						return;
					}
					if(checkArgUnderConstruction()){
						return;
					}
					AGORAModel.getInstance().requested = true;
					map.sBar.displayLoading();
					model.deleteMe();
				}
				else if	(model.statementFunction == StatementModel.COMMENT ||model.statementFunction == StatementModel.REFERENCE || model.statementFunction == StatementModel.AMENDMENT || model.statementFunction == StatementModel.QUESTION || model.statementFunction == StatementModel.DEFINITION || model.statementFunction == StatementModel.REFORMULATION || model.statementFunction == StatementModel.LINKTOMAP || model.statementFunction == StatementModel.LINKTORESOURCES || model.statementFunction == StatementModel.SUPPORT){
					if(model.supportingArguments.length > 0 || model.comments.length > 0){
						Alert.show(Language.lookup("DeleteSuppStmt"));
						return;
					}
					if(checkArgUnderConstruction()){
						return;
					}
					AGORAModel.getInstance().requested = true;
					map.sBar.displayLoading();
					model.deleteMe();
				}
			}

			
		}
		
		public function onStatementDeleted(event:AGORAEvent):void{
			AGORAModel.getInstance().requested = false;
			map.sBar.hideStatus();
			LoadController.getInstance().fetchMapData();
		}
		
		protected function onArgumentDeleted(event:AGORAEvent):void{
			var argTM:ArgumentTypeModel = event.eventData as ArgumentTypeModel;
			
		}
		
		//------------------ Building by Argument Scheme ------------------//
		public function buildByArgumentScheme(option:Option):void{
			//remove option
			FlexGlobals.topLevelApplication.map.agoraMap.removeChild(option);
			//get the argumentTypeModel and set reasonsCompleted to be true
			//This automatically sets the inference visible through a bind
			//setter
			constructArgument(option.argumentTypeModel);
		}
		
		//------------------ Saving Text -----------------------------------//
		public function saveText(statementModel:StatementModel):void{
			if(!AGORAModel.getInstance().requested){
				//call the model's update text function
				AGORAModel.getInstance().requested = true;
				statementModel.saveTexts();
				map.sBar.displayLoading();
			}
		}
		protected function textSaved(event:AGORAEvent):void{
			AGORAModel.getInstance().requested = false;
			map.sBar.hideStatus();
			var statementModel:StatementModel = StatementModel(event.eventData);
			var argumentPanel:ArgumentPanel = FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[statementModel.ID];
			argumentPanel.state = ArgumentPanel.DISPLAY;
			CursorManager.removeAllCursors();
			onTextEntered(argumentPanel);
			LoadController.getInstance().fetchMapData();
		}
		
		//------------------- configuration functions -----------------//
		protected function setEventListeners(statementAddedEvent:AGORAEvent):void{
			//get the statement model
			var statementModel:StatementModel = statementAddedEvent.eventData as StatementModel;
			statementModel.addEventListener(AGORAEvent.STATEMENT_TYPE_TOGGLED,statementTypeToggled); 
			statementModel.addEventListener(AGORAEvent.TEXT_SAVED, textSaved);
			statementModel.addEventListener(AGORAEvent.ARGUMENT_CREATED, onArgumentCreated);
			statementModel.addEventListener(AGORAEvent.ARGUMENT_CREATION_FAILED, onArgumentCreationFailed);
			statementModel.addEventListener(AGORAEvent.FAULT, onFault);
			statementModel.addEventListener(AGORAEvent.STATEMENTS_DELETED, onStatementDeleted);
			statementModel.addEventListener(AGORAEvent.OBJECTION_CREATED, onObjectionCreated);
			statementModel.addEventListener(AGORAEvent.CREATING_OBJECTION_FAILED, onObjectionCreationFailed);
			statementModel.addEventListener(AGORAEvent.DEFEAT_CREATED, onDefeatCreated);
			statementModel.addEventListener(AGORAEvent.CREATING_DEFEAT_FAILED, onDefeatCreationFailed);
			statementModel.addEventListener(AGORAEvent.COMMENT_CREATED, onCommentCreated);
			statementModel.addEventListener(AGORAEvent.CREATING_COMMENT_FAILED, onCommentCreationFailed);
			statementModel.addEventListener(AGORAEvent.AMENDMENT_CREATED, onAmendmentCreated);
			statementModel.addEventListener(AGORAEvent.CREATING_AMENDMENT_FAILED, onAmendmentCreationFailed);
			statementModel.addEventListener(AGORAEvent.REFERENCE_CREATED, onAmendmentCreated);
			statementModel.addEventListener(AGORAEvent.CREATING_REFERENCE_FAILED, onAmendmentCreationFailed);
			statementModel.addEventListener(AGORAEvent.DEFINITION_CREATED, onAmendmentCreated);
			statementModel.addEventListener(AGORAEvent.CREATING_DEFINITION_FAILED, onAmendmentCreationFailed);
			statementModel.addEventListener(AGORAEvent.QUESTION_CREATED, onAmendmentCreated);
			statementModel.addEventListener(AGORAEvent.CREATING_QUESTION_FAILED, onAmendmentCreationFailed);
			statementModel.addEventListener(AGORAEvent.SUPPORT_CREATED, onAmendmentCreated);
			statementModel.addEventListener(AGORAEvent.CREATING_SUPPORT_FAILED, onAmendmentCreationFailed);
			statementModel.addEventListener(AGORAEvent.STATEMENT_TYPE_TOGGLE_FAILED, onStatementTogglingFailed);
		}
		
		protected function setArgumentTypeModelEventListeners(argumentTypeModelAddedEvent:AGORAEvent):void{
			var argumentTypeModel:ArgumentTypeModel = argumentTypeModelAddedEvent.eventData as ArgumentTypeModel;
			argumentTypeModel.addEventListener(AGORAEvent.REASON_ADDED, onReasonAdded);
			argumentTypeModel.addEventListener(AGORAEvent.ARGUMENT_SCHEME_SET, onArgumentSchemeSet);
			argumentTypeModel.addEventListener(AGORAEvent.ARGUMENT_SAVED, onArgumentSaved);
			argumentTypeModel.addEventListener(AGORAEvent.ARGUMENT_SAVE_FAILED, onArgumentSaveFailed);
			argumentTypeModel.addEventListener(AGORAEvent.REASON_ADDITION_NOT_ALLOWED, reasonAdditionNotAllowedFault);
		}
		
		//------------------ Objections -------------------------------//
		public function addAnObjection(model:StatementModel):void{
			var obj:StatementModel = LayoutController.getInstance().getBottomObjection(model);
			if(obj != null){
				var bottomObjection: ArgumentPanel = map.agoraMap.panelsHash[obj.ID];
				model.object(obj.xgrid + bottomObjection.height/agoraParameters.gridWidth + 3 );	
			}
			else{
				var aPanel:ArgumentPanel = map.agoraMap.panelsHash[model.ID];
				model.object(model.xgrid + aPanel.getExplicitOrMeasuredHeight()/agoraParameters.gridWidth + 1);
			}
		}
		public function addDefeatStatement(model:StatementModel):void{
			
			var obj:StatementModel = LayoutController.getInstance().getBottomObjection(model);
			if(obj != null){
				var bottomObjection: ArgumentPanel = map.agoraMap.panelsHash[obj.ID];
				model.defeat(obj.xgrid + bottomObjection.height/agoraParameters.gridWidth + 3 );	
			}
			else{
				var aPanel:ArgumentPanel = map.agoraMap.panelsHash[model.ID];
				model.defeat(model.xgrid + aPanel.getExplicitOrMeasuredHeight()/agoraParameters.gridWidth + 1);
			}
		}
		protected function onObjectionCreated(event:AGORAEvent):void{
			LoadController.getInstance().fetchMapData();
		}
		protected function onDefeatCreated(event:AGORAEvent):void{
			LoadController.getInstance().fetchMapData();
		}
		protected function onCommentCreated(event:AGORAEvent):void{
			LoadController.getInstance().fetchMapData();
		}
		protected function onAmendmentCreated(event:AGORAEvent):void{
			LoadController.getInstance().fetchMapData();
		}
		
		protected function onObjectionCreationFailed(event:AGORAEvent):void{
			Alert.show(Language.lookup('ObjectionFailed'));
		}
		protected function onDefeatCreationFailed(event:AGORAEvent):void{
			Alert.show(Language.lookup('ObjectionFailed'));
		}
		protected function onCommentCreationFailed(event:AGORAEvent):void{
			Alert.show(Language.lookup('ObjectionFailed'));
		}
		
		protected function onAmendmentCreationFailed(event:AGORAEvent):void{
			Alert.show(Language.lookup('ObjectionFailed'));
		}
		
		//------------------ Handling events from schemeSelector ------//
		public function displayLanguageType(argSchemeSelector:ArgSelector, scheme:String):void{
			var argumentTypeModel:ArgumentTypeModel = argSchemeSelector.argumentTypeModel;
			var logicClassController:ParentArg; 
			//unlink if there had been a class already
			if(argumentTypeModel.logicClass != null){
				logicClassController = LogicFetcher.getInstance().logicHash[argumentTypeModel.logicClass];
				logicClassController.deleteLinks(argumentTypeModel);
			}
			//set the model's logical class
			argumentTypeModel.logicClass = scheme;
			logicClassController = LogicFetcher.getInstance().logicHash[argumentTypeModel.logicClass];
			logicClassController.link(argumentTypeModel);
			//if(argSchemeSelector.mainSchemes.selectedItem||){
			//	argSchemeSelector.mainToolTip.text =argSchemeSelector.mainSchemes.selectedItem.Label;
			//}

			//show language options or display text
			if(logicClassController.hasLanguageOptions()){
				if(argumentTypeModel.reasonModels.length > 1){
					argSchemeSelector.typeSelector.dataProvider = logicClassController.expLangTypes;
				}
				else{
					argSchemeSelector.typeSelector.dataProvider = logicClassController.langTypes;
				}
				argSchemeSelector.typeSelector.x = argSchemeSelector.mainSchemes.width;
				argSchemeSelector.typeSelectorText.visible=true;
				argSchemeSelector.typeSelector.visible=true;
				
			}
			else{
				argSchemeSelector.typeSelectorText.visible = false;
				argSchemeSelector.typeSelector.visible = false;
				updateEnablerText(argSchemeSelector, null)
			}
		}
		
		public function updateEnablerText(argSchemeSelector:ArgSelector, language:String):void{
			var argumentTypeModel:ArgumentTypeModel = argSchemeSelector.argumentTypeModel;
			argumentTypeModel.language = language;
			if(argumentTypeModel.logicClass != null){
				var logicClassController:ParentArg = LogicFetcher.getInstance().logicHash[argumentTypeModel.logicClass];
				logicClassController.formText(argumentTypeModel);
			}
			else{
				trace("This shouldn't get executed... Problem!");
			}
		}
		
		public function updateEnablerTextWithConjunctions(argSchemeSelector:ArgSelector, option:String):void{
			var argumentTypeModel:ArgumentTypeModel = argSchemeSelector.argumentTypeModel;
			argumentTypeModel.lSubOption = option;
			var logicController:ParentArg = LogicFetcher.getInstance().logicHash[argumentTypeModel.logicClass];
			logicController.formText(argumentTypeModel);
		}
		
		public function setSchemeType(argSchemeSelector:ArgSelector, scheme:String):void{
			var argumentTypeModel:ArgumentTypeModel = argSchemeSelector.argumentTypeModel;
			if(!AGORAModel.getInstance().requested){
				switch(scheme){
					case AGORAParameters.getInstance().DIS_SYLL:
						AGORAModel.getInstance().requested = true;
						map.sBar.displayLoading();
						argumentTypeModel.updateConnection();
						FlexGlobals.topLevelApplication.map.agoraMap.helpText.visible = false;
						break;
					case AGORAParameters.getInstance().NOT_ALL_SYLL:
						AGORAModel.getInstance().requested = true;
						map.sBar.displayLoading();
						argumentTypeModel.updateConnection();
						FlexGlobals.topLevelApplication.map.agoraMap.helpText.visible = false;
						break;
				}
			}
		}
		
		public function setSchemeLanguageType(argSchemeSelector:ArgSelector, language:String):void{
			if(!AGORAModel.getInstance().requested){
				var argumentTypeModel:ArgumentTypeModel = argSchemeSelector.argumentTypeModel;
				if(argumentTypeModel.language != AGORAParameters.getInstance().ONLY_IF || argumentTypeModel.reasonModels.length == 1){
					AGORAModel.getInstance().requested = true;
					map.sBar.displayLoading();
					argumentTypeModel.updateConnection();
					FlexGlobals.topLevelApplication.map.agoraMap.helpText.visible = false;
				}
			}
		}
		
		public function setSchemeLanguageOptionType(argSchemeSelector:ArgSelector, option:String):void{
			if(!AGORAModel.getInstance().requested){
				var argumentTypeModel:ArgumentTypeModel = argSchemeSelector.argumentTypeModel;
				//make busy cursor
				CursorManager.setBusyCursor();
				AGORAModel.getInstance().requested = true;
				argumentTypeModel.updateConnection();
				FlexGlobals.topLevelApplication.map.agoraMap.helpText.visible = false;
			}
		}
		
		//------------------- Scheme Update Functions -----------------//
		protected function onArgumentSchemeSet(event:AGORAEvent):void{
			var argumentTypeModel:ArgumentTypeModel = event.eventData as ArgumentTypeModel;
			var logicController:ParentArg = LogicFetcher.getInstance().logicHash[argumentTypeModel.logicClass];
			if(logicController != null){
				logicController.link(argumentTypeModel);
			}	
		}
				
		protected function onArgumentSaved(event:AGORAEvent):void{
			var agoraMap:AgoraMap = FlexGlobals.topLevelApplication.map.agoraMap;
			AGORAModel.getInstance().requested=false;
			model.agoraMapModel.argUnderConstruction = false;
			map.sBar.hideStatus();
			var argumentTypeModel:ArgumentTypeModel = event.eventData as ArgumentTypeModel;
			var menuPanel:MenuPanel = agoraMap.menuPanelsHash[argumentTypeModel.ID]
			var argumentSelector:ArgSelector = agoraMap.menuPanelsHash[argumentTypeModel.ID].schemeSelector;
			menuPanel.hideArgSelector();
			if(argumentTypeModel.logicClass == AGORAParameters.getInstance().COND_SYLL){
				var logicController:ParentArg = LogicFetcher.getInstance().logicHash[argumentTypeModel.logicClass];
				logicController.deleteLinks(argumentTypeModel);
				AGORAModel.getInstance().agoraMapModel.loadMapModel();
			}
			
			//infobox beside enabler
			var inference:ArgumentPanel = agoraMap.panelsHash[argumentTypeModel.inferenceModel.ID];
			var addArgumentsInfo:InfoBox=new InfoBox();
			addArgumentsInfo.boxWidth=500;
			addArgumentsInfo.text = Language.lookup('ArgComplete');
			agoraMap.addEventListener(MouseEvent.CLICK,function(e:Event):void{
				addArgumentsInfo.visible=false;
				agoraMap.removeEventListener(MouseEvent.CLICK, arguments.callee);
			});
			FlexGlobals.topLevelApplication.map.alerts.addElement(addArgumentsInfo);
			addArgumentsInfo.y =  inference.y + inference.height + 20;
			addArgumentsInfo.x = inference.x;
			addArgumentsInfo.visible=true;
			//infobox on top of the claim and the reason
			var claim:ArgumentPanel = agoraMap.panelsHash[argumentTypeModel.claimModel.ID];
			if(claim.panelType != StatementModel.INFERENCE){
				claim.changeTypeInfo.x = claim.x;
				claim.changeTypeInfo.y = claim.y - claim.changeTypeInfo.getExplicitOrMeasuredHeight() - 10;
				claim.changeTypeInfo.depth = claim.parent.numChildren;
				//claim.changeTypeInfo.visible = true;
			}
			try{
				var reason:ArgumentPanel = agoraMap.panelsHash[argumentTypeModel.reasonModels[0].ID];
			}catch(typeError:TypeError){
				recover();
				return;
			}
			reason.changeTypeInfo.x = reason.x;
			reason.changeTypeInfo.y = reason.y - reason.changeTypeInfo.getExplicitOrMeasuredHeight() - 10;
			//reason.changeTypeInfo.visible = true;
			reason.changeTypeInfo.depth = reason.parent.numChildren;
		}
		
		protected function onArgumentSaveFailed(event:AGORAEvent):void{
			AGORAModel.getInstance().requested = false;
			model.agoraMapModel.argUnderConstruction = false;
			CursorManager.removeAllCursors();
			model.agoraMapModel.argUnderConstruction = false;
			var argumentTypeModel:ArgumentTypeModel = event.eventData as ArgumentTypeModel;
			var menuPanel:MenuPanel=FlexGlobals.topLevelApplication.map.agoraMap.menuPanelsHash[argumentTypeModel.ID];
			var argumentSelector:ArgSelector = FlexGlobals.topLevelApplication.map.agoraMap.menuPanelsHash[argumentTypeModel.ID].schemeSelector;
			menuPanel.hideArgSelector();
			if(argumentTypeModel.logicClass == AGORAParameters.getInstance().COND_SYLL){
				var logicController:ParentArg = LogicFetcher.getInstance().logicHash[argumentTypeModel.logicClass];
				logicController.deleteLinks(argumentTypeModel);
				AGORAModel.getInstance().agoraMapModel.loadMapModel();
			}
			Alert.show(Language.lookup("ArgumentSaveFailed"));
			recover();
		}
		
		//-------------------Event Handlers---------------------------//
		protected function reasonAdditionNotAllowedFault(event:AGORAEvent):void{
			Alert.show(Language.lookup("CannotModify"));
		}
		
		
		//------------------ other public functions ----------------------//
		public function showAddMenu(argumentPanel:ArgumentPanel):void{
			var addMenuData:XML = <root><menuitem label={agoraParameters.ADD_SUPPORTING_STATEMENT} type="TopLevel" /></root>;
			addMenuData.appendChild(<menuitem label={agoraParameters.ADD_OBJECTION} type="TopLevel"/>);
			var addMenu:Menu = Menu.createMenu(argumentPanel.parent, addMenuData, false);
			addMenu.labelField = "@label";
			var point:Point = new Point;
			point.x = 0;
			point.y = argumentPanel.height;
			point = argumentPanel.localToGlobal(point);
			addMenu.show(point.x, point.y);
			addMenu.addEventListener(MenuEvent.ITEM_CLICK, argumentPanel.addMenuClicked);
		}
		
		public function showAddHoverMenu(argumentPanel:ArgumentPanel):void{
			var addMenuData:XML;
			if(argumentPanel.panelType == StatementModel.STATEMENT || argumentPanel.panelType == StatementModel.INFERENCE)
			{
				if(argumentPanel.model.supportingArguments.length == 0)
				{
					addMenuData= <root><menuitem label={agoraParameters.ARGUMENT_FOR_CLAIM} type="TopLevel" contentBackgroundColor="#999999"/></root>;
					addMenuData.appendChild(<menuitem label={agoraParameters.SUPPORTING_STATEMENT} type="TopLevel" contentBackgroundColor="#999999"/>);
					addMenuData.appendChild(<menuitem label={agoraParameters.OBJECTION} type="TopLevel" contentBackgroundColor="#999999"/>);
					addMenuData.appendChild(<menuitem label={agoraParameters.DEFEAT_STATEMENT_BY_COUNTER_EXAMPLE} type="TopLevel" contentBackgroundColor="#999999"/>);
					//addMenuData.appendChild(<menuitem label={agoraParameters.EQUIVALENT_REFORMULATION} type="TopLevel"/>);
					addMenuData.appendChild(<menuitem label={agoraParameters.FRIENDLY_AMENDMENT} type="TopLevel" contentBackgroundColor="#999999"/>);
					addMenuData.appendChild(<menuitem label={agoraParameters.REFERENCE} type="TopLevel" contentBackgroundColor="#999999"/>);
					addMenuData.appendChild(<menuitem label={agoraParameters.DEFINITION} type="TopLevel" contentBackgroundColor="#999999"/>);
					addMenuData.appendChild(<menuitem label={agoraParameters.COMMENT} type="TopLevel" contentBackgroundColor="#999999"/>);
					addMenuData.appendChild(<menuitem label={agoraParameters.QUESTION} type="TopLevel" contentBackgroundColor="#999999"/>);
					addMenuData.appendChild(<menuitem label={agoraParameters.LINK_TO_RESOURCES} type="TopLevel" contentBackgroundColor="#999999"/>);
				}
				else
				{
					addMenuData= <root><menuitem label={agoraParameters.ARGUMENT_FOR_CLAIM} type="TopLevel" contentBackgroundColor="#999999"/></root>;
					addMenuData.appendChild(<menuitem label={agoraParameters.SUPPORTING_STATEMENT} type="TopLevel" contentBackgroundColor="#999999"/>);
					//addMenuData.appendChild(<menuitem label={agoraParameters.EQUIVALENT_REFORMULATION} type="TopLevel"/>);
					addMenuData.appendChild(<menuitem label={agoraParameters.FRIENDLY_AMENDMENT} type="TopLevel" contentBackgroundColor="#999999"/>);
					addMenuData.appendChild(<menuitem label={agoraParameters.REFERENCE} type="TopLevel" contentBackgroundColor="#999999"/>);
					addMenuData.appendChild(<menuitem label={agoraParameters.DEFINITION} type="TopLevel" contentBackgroundColor="#999999"/>);
					addMenuData.appendChild(<menuitem label={agoraParameters.COMMENT} type="TopLevel" contentBackgroundColor="#999999"/>);
					addMenuData.appendChild(<menuitem label={agoraParameters.QUESTION} type="TopLevel" contentBackgroundColor="#999999"/>);
					addMenuData.appendChild(<menuitem label={agoraParameters.LINK_TO_RESOURCES} type="TopLevel" contentBackgroundColor="#999999"/>);
				}
			}
			else if (argumentPanel.panelType == StatementModel.OBJECTION || argumentPanel.panelType == StatementModel.COUNTER_EXAMPLE)
			{
			addMenuData= <root><menuitem label={agoraParameters.ARGUMENT_FOR_CLAIM} type="TopLevel" contentBackgroundColor="#999999"/></root>;
			addMenuData.appendChild(<menuitem label={agoraParameters.SUPPORTING_STATEMENT} type="TopLevel" contentBackgroundColor="#999999"/>);
			addMenuData.appendChild(<menuitem label={agoraParameters.OBJECTION} type="TopLevel" contentBackgroundColor="#999999"/>);
			addMenuData.appendChild(<menuitem label={agoraParameters.DEFEAT_STATEMENT_BY_COUNTER_EXAMPLE} type="TopLevel" contentBackgroundColor="#999999"/>);
			//addMenuData.appendChild(<menuitem label={agoraParameters.EQUIVALENT_REFORMULATION} type="TopLevel"/>);
			addMenuData.appendChild(<menuitem label={agoraParameters.FRIENDLY_AMENDMENT} type="TopLevel" contentBackgroundColor="#999999"/>);
			addMenuData.appendChild(<menuitem label={agoraParameters.REFERENCE} type="TopLevel" contentBackgroundColor="#999999"/>);
			addMenuData.appendChild(<menuitem label={agoraParameters.DEFINITION} type="TopLevel" contentBackgroundColor="#999999"/>);
			addMenuData.appendChild(<menuitem label={agoraParameters.COMMENT} type="TopLevel" contentBackgroundColor="#999999"/>);
			addMenuData.appendChild(<menuitem label={agoraParameters.QUESTION} type="TopLevel" contentBackgroundColor="#999999"/>);
			addMenuData.appendChild(<menuitem label={agoraParameters.LINK_TO_RESOURCES} type="TopLevel" contentBackgroundColor="#999999"/>);
			
			}
			else
			{
				addMenuData= <root><menuitem label={agoraParameters.SUPPORTING_STATEMENT} type="TopLevel" contentBackgroundColor="#999999"/></root>;
				//addMenuData.appendChild(<menuitem label={agoraParameters.EQUIVALENT_REFORMULATION} type="TopLevel"/>);
				addMenuData.appendChild(<menuitem label={agoraParameters.FRIENDLY_AMENDMENT} type="TopLevel" contentBackgroundColor="#999999"/>);
				addMenuData.appendChild(<menuitem label={agoraParameters.REFERENCE} type="TopLevel" contentBackgroundColor="#999999"/>);
				addMenuData.appendChild(<menuitem label={agoraParameters.DEFINITION} type="TopLevel" contentBackgroundColor="#999999"/>);
				addMenuData.appendChild(<menuitem label={agoraParameters.COMMENT} type="TopLevel" contentBackgroundColor="#999999"/>);
				addMenuData.appendChild(<menuitem label={agoraParameters.QUESTION} type="TopLevel" contentBackgroundColor="#999999"/>);
				addMenuData.appendChild(<menuitem label={agoraParameters.LINK_TO_RESOURCES} type="TopLevel" contentBackgroundColor="#999999"/>);
			}
			var addMenu:Menu = Menu.createMenu(argumentPanel.parent, addMenuData, false);
			var addMenu1:Menu = Menu.createMenu(argumentPanel.parent, addMenuData, false);
			addMenu.labelField = "@label"; 
			var color:String = addMenu.dataProvider[0].menuitem[0].@contentBackgroundColor;

		//	addMenu.get.setStyle("contentBackgroundColor","#999999");
					
			var point:Point = new Point;
			point.x = 0;
			point.y = argumentPanel.height;
			point = argumentPanel.localToGlobal(point);
			point.y = point.y - 250;
			addMenu.show(point.x, point.y);
			addMenu.addEventListener(MenuEvent.ITEM_CLICK, argumentPanel.addHoverMenuClicked);
		}
		
		//-------------------Generic Fault Handler---------------------//
		protected function onFault(event:AGORAEvent):void{
			CursorManager.removeAllCursors();
			model.requested = false;
			map.sBar.displayError();
		}
		
		//----------------- Utility Functions -----------------//
		protected function checkArgUnderConstruction():Boolean{
			if(model.agoraMapModel.argUnderConstruction){
				Alert.show(Language.lookup("ArgUnderConstruction"));
				return true;
			}else{
				return false;
			}
		}
		
		private function fetchCompleteMap():void{
			model.agoraMapModel.timestamp = "0";
			LoadController.getInstance().fetchMapData();
		}
		
		protected function recover():void{
			//reinitialize the map model
			//reinitialize the map view
			//load the map
			model.agoraMapModel.reinitializeModel();
			map.agoraMap.initializeMapStructures();
			LoadController.getInstance().fetchMapData();
		}
		
		// Projects 
			protected function onProjectAddFailed(event:AGORAEvent):void{
			Alert.show(Language.lookup("ProjectNameUnique"));
		}
	}
}

class SingletonEnforcer{}