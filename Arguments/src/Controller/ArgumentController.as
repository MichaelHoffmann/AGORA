package Controller
{
	import Events.AGORAEvent;
	
	import Model.AGORAMapModel;
	import Model.AGORAModel;
	import Model.MapMetaData;
	import Model.StatementModel;
	
	import ValueObjects.AGORAParameters;
	
	import components.ArgumentPanel;
	import components.LAMWorld;
	import components.Map;
	
	import flash.display.DisplayObject;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.CursorManager;
	import mx.managers.PopUpManager;
	
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
		public function addSupportingArgument(ID:int):void{
			
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
		}
		
		//------------------- configuration functions -----------------//
		public function setEventListeners(statementAddedEvent:AGORAEvent):void{
			//get the statement model
			var statementModel:StatementModel = statementAddedEvent.eventData as StatementModel;
			statementModel.addEventListener(AGORAEvent.STATEMENT_TYPE_TOGGLED,statementTypeToggled); 
			statementModel.addEventListener(AGORAEvent.TEXT_SAVED, textSaved);
			statementModel.addEventListener(AGORAEvent.FAULT, onFault);
		}
		
		
		//-------------------Generic Fault Handler---------------------//
		protected function onFault(event:AGORAEvent):void{
			Alert.show(AGORAParameters.getInstance().NETWORK_ERROR);
		}
		
	}
}

class SingletonEnforcer{}