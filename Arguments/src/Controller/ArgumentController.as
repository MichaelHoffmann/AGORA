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
	import mx.states.State;
	
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
		}
		
		//---------------------Get Instance -----------------------------//
		public static function getInstance():ArgumentController{
			if(!instance){
				instance = new ArgumentController(new SingletonEnforcer);
			}
			return instance;
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
				var inference:ArgumentPanel = this.model.agoraMapModel.panelListHash[inferenceModel.ID];
				var xgridInference:int = (inference.x + inference.height) / AGORAParameters.getInstance().gridWidth + 1;
				//find out hte last reason
				var reasonModel:StatementModel = argumentTypeModel.reasonModels[argumentTypeModel.reasonModels.length - 1];
				var reason:ArgumentPanel = this.model.agoraMapModel.panelListHash[reasonModel.ID];
				//find the last grid
				var xgridReason:int = (reason.x + reason.height ) / AGORAParameters.getInstance().gridWidth + 1;
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
			
		}
		
		//----------------- Construct Argument -----------------------------//
		public function constructArgument(argumentTypeModel:ArgumentTypeModel):void{
			//make inference visible
			argumentTypeModel.reasonsCompleted = true;
			//get the scheme selector
			var menuPanel:MenuPanel = FlexGlobals.topLevelApplication.map.agoraMap.menuPanelsHash[argumentTypeModel.ID];
			var schemeSelector:ArgSelector = menuPanel.schemeSelector;
			//Fill them up
			//if constrained
			if(argumentTypeModel.isLanguageTyped()){
				schemeSelector.scheme = ParentArg.getInstance().getConstrainedArray(argumentTypeModel);
			}
			//if constructed by argument and first claim is being supported
			else if(AGORAModel.getInstance().agoraMapModel.mapConstructedFromArgument && argumentTypeModel.claimModel.firstClaim){
				schemeSelector.scheme = ParentArg.getInstance().getFullArray();
			}
			
			else if(argumentTypeModel.claimModel.firstClaim){
				schemeSelector.scheme = ParentArg.getInstance().getFullArray();
			}
			
			//if simple positive statement
			else if(!argumentTypeModel.claimModel.negated){
				schemeSelector.scheme = ParentArg.getInstance().getPositiveArray();
			}
			//if simple negative statement
			else if(argumentTypeModel.claimModel.negated){
				schemeSelector.scheme = ParentArg.getInstance().getNegativeArray();
			}
			//if positive implication
			else if(argumentTypeModel.claimModel.connectingString == StatementModel.IMPLICATION){
				schemeSelector.scheme = ParentArg.getInstance().getImplicationArray();
			}
			//if positive disjunction
			else if(argumentTypeModel.claimModel.connectingString == StatementModel.DISJUNCTION){
				schemeSelector.scheme = ParentArg.getInstance().getDisjunctionPositiveArray();
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
		public function setEventListeners(statementAddedEvent:AGORAEvent):void{
			//get the statement model
			var statementModel:StatementModel = statementAddedEvent.eventData as StatementModel;
			statementModel.addEventListener(AGORAEvent.STATEMENT_TYPE_TOGGLED,statementTypeToggled); 
			statementModel.addEventListener(AGORAEvent.TEXT_SAVED, textSaved);
			statementModel.addEventListener(AGORAEvent.ARGUMENT_CREATED, onArgumentCreated);
			statementModel.addEventListener(AGORAEvent.FAULT, onFault);
		}
		
		//------------------ Handling events from schemeSelector ------//
		public function displayLanguageType(argSchemeSelector:ArgSelector, scheme:String):void{
			var argumentTypeModel:ArgumentTypeModel = argSchemeSelector.argumentTypeModel;
			//set the model's logical class
			argumentTypeModel.logicClass = LogicFetcher.getInstance().logicHash[scheme];
			//show language options or display text
			if(argumentTypeModel.logicClass.hasLanguageTypeOptions){
				if(argumentTypeModel.reasonModels.length > 1){
					argSchemeSelector.typeSelector.dataProvider = argumentTypeModel.logicClass.expLangTypes;
				}
				else{
					argSchemeSelector.typeSelector.dataProvider = argumentTypeModel.logicClass.langTypes;
				}
				argSchemeSelector.typeSelector.x = argSchemeSelector.mainSchemes.width;
				argSchemeSelector.typeSelector.visible=true;
			}
			else{
				updateEnablerText(argSchemeSelector, null)
			}
		}
		
		public function updateEnablerText(argSchemeSelector:ArgSelector, language:String):void{
			var argumentTypeModel:ArgumentTypeModel = argSchemeSelector.argumentTypeModel;
			if(language == null){
				//get inference
				
			}else{
			
				
			}
		}
		
		public function setSchemeType(argSchemeSelector:ArgSelector):void{
			
		}
		
		public function setSchemeLanguageType(argumentTypeModel:ArgumentTypeModel):void{
			
		}
		
		//-------------------Generic Fault Handler---------------------//
		protected function onFault(event:AGORAEvent):void{
			Alert.show(AGORAParameters.getInstance().NETWORK_ERROR);
		}
		
	}
}

class SingletonEnforcer{}