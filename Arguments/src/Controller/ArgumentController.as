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
	
	import ValueObjects.AGORAParameters;
	
	import components.ArgSelector;
	import components.ArgumentPanel;
	import components.Inference;
	import components.LAMWorld;
	import components.Map;
	import components.MenuPanel;
	import components.Option;
	
	import flash.display.DisplayObject;
	
	import mx.controls.Alert;
	import mx.controls.Menu;
	import mx.core.FlexGlobals;
	import mx.events.MenuEvent;
	import mx.managers.CursorManager;
	import mx.managers.PopUpManager;
	import mx.skins.spark.DefaultButtonSkin;
	import mx.states.State;
	
	import org.osmf.layout.AbsoluteLayoutFacet;
	
	public class ArgumentController
	{
		private static var instance:ArgumentController;
		private var view:DisplayObject;
		private var model:AGORAModel;
		
		public function ArgumentController(singletonEnforcer:SingletonEnforcer)
		{
			instance = this;	
			view = DisplayObject(FlexGlobals.topLevelApplication);
			model = AGORAModel.getInstance();
			
			//Event handlers
			model.agoraMapModel.addEventListener(AGORAEvent.MAP_CREATED, onMapCreated);
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
					FlexGlobals.topLevelApplication.map.agoraMap.removeChild(argumentPanel.branchControl);
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
		
		//-------------------- Load Map --------------------------------//
		public function loadMap(id:String):void{
			if(AGORAModel.getInstance().userSessionModel.loggedIn()){
				AGORAModel.getInstance().agoraMapModel.ID = int(id);
				FlexGlobals.topLevelApplication.agoraMenu.visible = false;
				FlexGlobals.topLevelApplication.map.visible = true;
				FlexGlobals.topLevelApplication.map.agoraMap.initializeMapStructures();
				LoadController.getInstance().fetchMapData();
			}else{
				Alert.show("Please sign in into AGORA before loading a map.");
			}
		}
		
		//---------------------Creating a New Map-----------------------//
		public function createMap(mapName:String):void{
			model.agoraMapModel.createMap(mapName);	
		}
		
		protected function onMapCreated(event:AGORAEvent):void{
			var map:MapMetaData = event.eventData as MapMetaData;
			AGORAController.getInstance().unfreeze();
			PopUpManager.removePopUp(FlexGlobals.topLevelApplication.mapNameBox);
			AGORAModel.getInstance().agoraMapModel.ID = map.mapID;
			FlexGlobals.topLevelApplication.lamWorld.visible = true;
			FlexGlobals.topLevelApplication.agoraMenu.visible = false;
		}
		
		//-------------------Start with Claim----------------------------//
		public function startWithClaim():void{
			//remove Lam world
			FlexGlobals.topLevelApplication.lamWorld.visible = false;
			
			//display map
			FlexGlobals.topLevelApplication.map.visible = true;
			
			//ask controller to add the first claim
			addFirstClaim();
		}
		
		//-------------------Add First Claim------------------------------//
		public function addFirstClaim():void{
			//instruct the model to add a first claim to itself
			model.agoraMapModel.addFirstClaim();
		}
		
		protected function onFirstClaimAdded(event:AGORAEvent):void{
			var statementModel:StatementModel = event.eventData as StatementModel;
			LoadController.getInstance().fetchMapData();
			//Edit: Delay the below invalidation until next update
			//invalidate component, so that they get updated during the validation  cycle of the Flex architecture
			//FlexGlobals.topLevelApplication.map.agoraMap.invalidateProperties();
			//FlexGlobals.topLevelApplication.map.agoraMap.invalidateDisplayList();
		}
		
		//----------------- Adding an Argument -------------------------------//
		public function addSupportingArgument(model:StatementModel):void{
			//tell the statement to support itself with an argument. Supply the position.
			//figure out the position
			//find out the last menu panel
			if(model.supportingArguments.length > 0){
				var argumentTypeModel:ArgumentTypeModel = model.supportingArguments[model.supportingArguments.length - 1];
				//Find the last grid
				//Find out the inference
				var inferenceModel:StatementModel = argumentTypeModel.inferenceModel;
				var inference:ArgumentPanel = FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[inferenceModel.ID];
				var xgridInference:int = (inference.y + inference.height) / AGORAParameters.getInstance().gridWidth + 2;
				//find out hte last reason
				var reasonModel:StatementModel = argumentTypeModel.reasonModels[argumentTypeModel.reasonModels.length - 1];
				var reason:ArgumentPanel = FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[reasonModel.ID];
				//find the last grid
				var xgridReason:int = (reason.y + reason.height ) / AGORAParameters.getInstance().gridWidth + 2;
				//compare and figure out the max
				var nxgrid:int = xgridInference > xgridReason? xgridInference:xgridReason;
			}else{
				nxgrid = model.xgrid;
			}
			//call the function
			model.addSupportingArgument(nxgrid);
		}
		
		
		protected function onArgumentCreated(event:AGORAEvent):void{
			LoadController.getInstance().fetchMapData(); 
		}
		
		//------------------ Adding a Reason -------------------------------------//
		public function addReason(argumentTypeModel:ArgumentTypeModel):void{
			var x:int;
			var y:int;
			var flag:int = 0;
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
			if(argumentTypeModel.logicClass == AGORAParameters.getInstance().DIS_SYLL || argumentTypeModel.logicClass == AGORAParameters.getInstance().DIS_SYLL){
				flag = 1;
			}
			if(flag == 0){
				Alert.show("The language type you have chosen is not expandable with multiple reasons. Please choose an expandable language type before adding reasons");
				return;
			}
			var lastReason:ArgumentPanel = FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[LayoutController.getInstance().getBottomReason(argumentTypeModel).ID];
			x = (lastReason.y + lastReason.height)/AGORAParameters.getInstance().gridWidth + 3;
			y = argumentTypeModel.reasonModels[argumentTypeModel.reasonModels.length - 1].ygrid;
			argumentTypeModel.addReason(x, y);
		}
		
		protected function onReasonAdded(event:AGORAEvent):void{
			LoadController.getInstance().fetchMapData();
		}
		
		//----------------- Construct Argument -----------------------------//
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
				//Allowing for constructive dilemma. Even for constructive dilemma
				//a separate treatment is required
				//It's not yet incorporated
				//if positive implication
				if(argumentTypeModel.claimModel.connectingString == StatementModel.IMPLICATION){
					schemeSelector.scheme = ParentArg.getInstance().getImplicationArray();
				}
					//if positive disjunction
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
			schemeSelector.visible = true;
		}
		
		//----------------- After done button is clicked --------------------//
		public function onTextEntered(argumentPanel:ArgumentPanel):void{
			//if first claim
			var model:StatementModel = argumentPanel.model;
			if(model.firstClaim){
			}
				//if reasons Completed
			else if(model.argumentTypeModel.reasonsCompleted){
			}
			else{
				argumentPanel.showMenu();
			}
		}
		
		//----------------- State Changes in a Statement --------------------//
		public function changeType(ID:int):void{
			try{
				//Busy Cursor
				CursorManager.setBusyCursor();
				//Find out the model class
				var sModel:StatementModel = model.agoraMapModel.panelListHash[ID];
				//Change the model
				sModel.toggleType();
			}catch(error:Error){
				Alert.show(AGORAParameters.getInstance().STATEMENT_TOGGLE_FAILED);
			}
		}
		
		protected function statementTypeToggled(event:AGORAEvent):void{
			var sModel:StatementModel = AGORAModel.getInstance().agoraMapModel.panelListHash[event.eventData as int];
			var argumentPanel:ArgumentPanel = FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[event.eventData as int];
			CursorManager.removeBusyCursor();
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
			//call the model's update text function
			statementModel.saveTexts();
			CursorManager.setBusyCursor();
		}
		
		
		protected function textSaved(event:AGORAEvent):void{
			var statementModel:StatementModel = StatementModel(event.eventData);
			var argumentPanel:ArgumentPanel = FlexGlobals.topLevelApplication.map.agoraMap.panelsHash[statementModel.ID];
			argumentPanel.state = ArgumentPanel.DISPLAY;
			CursorManager.removeAllCursors();
			onTextEntered(argumentPanel);
		}
		
		//------------------- configuration functions -----------------//
		protected function setEventListeners(statementAddedEvent:AGORAEvent):void{
			//get the statement model
			var statementModel:StatementModel = statementAddedEvent.eventData as StatementModel;
			statementModel.addEventListener(AGORAEvent.STATEMENT_TYPE_TOGGLED,statementTypeToggled); 
			statementModel.addEventListener(AGORAEvent.TEXT_SAVED, textSaved);
			statementModel.addEventListener(AGORAEvent.ARGUMENT_CREATED, onArgumentCreated);
			statementModel.addEventListener(AGORAEvent.FAULT, onFault);
		}
		
		protected function setArgumentTypeModelEventListeners(argumentTypeModelAddedEvent:AGORAEvent):void{
			var argumentTypeModel:ArgumentTypeModel = argumentTypeModelAddedEvent.eventData as ArgumentTypeModel;
			argumentTypeModel.addEventListener(AGORAEvent.REASON_ADDED, onReasonAdded);
			argumentTypeModel.addEventListener(AGORAEvent.ARGUMENT_SCHEME_SET, onArgumentSchemeSet);
			argumentTypeModel.addEventListener(AGORAEvent.ARGUMENT_SAVED, onArgumentSaved);
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
			
			//show language options or display text
			if(logicClassController.hasLanguageOptions()){
				if(argumentTypeModel.reasonModels.length > 1){
					argSchemeSelector.typeSelector.dataProvider = logicClassController.expLangTypes;
				}
				else{
					argSchemeSelector.typeSelector.dataProvider = logicClassController.langTypes;
				}
				argSchemeSelector.typeSelector.x = argSchemeSelector.mainSchemes.width;
				argSchemeSelector.typeSelector.visible=true;
			}
			else{
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
			switch(scheme){
				case AGORAParameters.getInstance().DIS_SYLL:
					CursorManager.setBusyCursor();
					argumentTypeModel.updateConnection();
					break;
				case AGORAParameters.getInstance().NOT_ALL_SYLL:
					//make cursor busy
					CursorManager.setBusyCursor();
					argumentTypeModel.updateConnection();
					break;
			}
		}
		
		public function setSchemeLanguageType(argSchemeSelector:ArgSelector, language:String):void{
			var argumentTypeModel:ArgumentTypeModel = argSchemeSelector.argumentTypeModel;
			if(argumentTypeModel.language != AGORAParameters.getInstance().ONLY_IF || argumentTypeModel.reasonModels.length == 1){
				CursorManager.setBusyCursor();
				argumentTypeModel.updateConnection();
			}
		}
		
		public function setSchemeLanguageOptionType(argSchemeSelector:ArgSelector, option:String):void{
			var argumentTypeModel:ArgumentTypeModel = argSchemeSelector.argumentTypeModel;
			//make busy cursor
			CursorManager.setBusyCursor();
			argumentTypeModel.updateConnection();
		}
		
		//------------------- Scheme Update Functions -----------------//
		protected function onArgumentSchemeSet(event:AGORAEvent):void{
			CursorManager.removeAllCursors();
			var argumentTypeModel:ArgumentTypeModel = event.eventData as ArgumentTypeModel;
			var logicController:ParentArg = LogicFetcher.getInstance().logicHash[argumentTypeModel.logicClass];
			if(logicController != null){
				logicController.link(argumentTypeModel);
			}
			
			
		}
		
		protected function onArgumentSaved(event:AGORAEvent):void{
			CursorManager.removeAllCursors();
			var argumentTypeModel:ArgumentTypeModel = event.eventData as ArgumentTypeModel;
			var argumentSelector:ArgSelector = FlexGlobals.topLevelApplication.map.agoraMap.menuPanelsHash[argumentTypeModel.ID].schemeSelector;
			argumentSelector.hide();
			if(argumentTypeModel.logicClass == AGORAParameters.getInstance().COND_SYLL){
				var logicController:ParentArg = LogicFetcher.getInstance().logicHash[argumentTypeModel.logicClass];
				logicController.deleteLinks(argumentTypeModel);
				AGORAModel.getInstance().agoraMapModel.loadMapModel();
			}
			
		}
		
		//-------------------Generic Fault Handler---------------------//
		protected function onFault(event:AGORAEvent):void{
			CursorManager.removeAllCursors();
			Alert.show(AGORAParameters.getInstance().NETWORK_ERROR);
		}
		
	}
}

class SingletonEnforcer{}