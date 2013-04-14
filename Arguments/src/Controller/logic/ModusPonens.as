package Controller.logic
{	
	import Model.AGORAModel;
	import Model.ArgumentTypeModel;
	import Model.SimpleStatementModel;
	import Model.StatementModel;
	
	import ValueObjects.AGORAParameters;
	
	import classes.Language;
	
	import components.ArgSelector;
	import components.ArgumentPanel;
	import components.MenuPanel;
	
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.messaging.channels.StreamingAMFChannel;
	
	public class ModusPonens extends ParentArg
	{
		
		private static var instance:ModusPonens;
		private var agoraLiterals:AGORAParameters;
		
		public function ModusPonens()
		{
			agoraLiterals = AGORAParameters.getInstance();
			langTypes = [agoraLiterals.IF_THEN,agoraLiterals.IMPLIES,agoraLiterals.WHENEVER, agoraLiterals.ONLY_IF, agoraLiterals.PROVIDED_THAT,agoraLiterals.SUFFICIENT_CONDITION, agoraLiterals.NECESSARY_CONDITION ];
			expLangTypes = [agoraLiterals.IF_THEN, agoraLiterals.WHENEVER, agoraLiterals.PROVIDED_THAT];	
			label = AGORAParameters.getInstance().MOD_PON;
		}
		
		public static function getInstance():ModusPonens{
			if(instance==null){
				instance = new ModusPonens;
			}
			return instance;
		}
		
		//------------------- public functions -------------------------//
		override public function getLabel():String{
			return AGORAParameters.getInstance().MOD_PON;
		}
		
		override public function formText(argumentTypeModel:ArgumentTypeModel):void{
			var output:String = "";
			var reasonText:String = "";
			var reasonModels:Vector.<StatementModel> = argumentTypeModel.reasonModels;
			var claimModel:StatementModel = argumentTypeModel.claimModel;
			var i:int;
			var hash:Dictionary = FlexGlobals.topLevelApplication.map.agoraMap.menuPanelsHash;
			var argSelector:ArgSelector = null;
			if(hash.hasOwnProperty(argumentTypeModel.ID)){
				argSelector = MenuPanel(hash[argumentTypeModel.ID]).schemeSelector;
			}
			if(argSelector != null)
				argSelector.andor.visible = false;
			if(reasonModels.length == 0){
				return;
			}
			
			switch(argumentTypeModel.language){
				case langTypes[0]:
					reasonText = reasonModels[0].statement.text;
					for(i=1; i<reasonModels.length; i++){
						reasonText = reasonText + " " + Language.lookup("ArgAndIf") + " "+ reasonModels[i].statement.text;
					}
					
					output = Language.lookup("ArgIf") + reasonText; 
					output = output + Language.lookup("ArgThen") + claimModel.statement.text;
					break;
				case langTypes[1]:
					reasonText =  reasonModels[0].statement.text;
					output = reasonText + Language.lookup("ArgImplies") + claimModel.statement.text;
					break;
				case langTypes[2]:
					
					output = Language.lookup("ArgWhenever");
					reasonText = reasonModels[0].statement.text;
					for(i=1; i<reasonModels.length; i++){
						reasonText = reasonText + Language.lookup("ArgAnd") + reasonModels[i].statement.text;
					}
					output = output + reasonText + ", " + claimModel.statement.text;
					break;
				case langTypes[3]:
					reasonText =  reasonModels[0].statement.text ; 
					output = reasonText + Language.lookup("ArgOnlyIf") + claimModel.statement.text;
					break;
				case langTypes[4]:
					output = claimModel.statement.text + Language.lookup("ArgProvidedThat");
					reasonText = reasonModels[0].statement.text;
					for(i=1; i < reasonModels.length; i++){
						reasonText = reasonText + Language.lookup("ArgAnd") + reasonModels[i].statement.text;
					}
					output = output + reasonText;
					break;
				case langTypes[5]:
					reasonText = reasonModels[0].statement.text; 
					output =  reasonText + Language.lookup("ArgSufficientCond") + claimModel.statement.text;
					break;
				case langTypes[6]:
					reasonText = reasonModels[0].statement.text;
					output = claimModel.statement.text + Language.lookup("ArgNecessaryCond") + reasonText;
					break;
			}
			argumentTypeModel.inferenceModel.statements[0].text = reasonText;
			argumentTypeModel.inferenceModel.statements[1].text = argumentTypeModel.claimModel.statement.text;
			argumentTypeModel.inferenceModel.statement.text = output;
		}
		
		override public function link(argumentTypeModel:ArgumentTypeModel):void{
			var claimModel:StatementModel = argumentTypeModel.claimModel;
			var reasonModels:Vector.<StatementModel> = argumentTypeModel.reasonModels;
			var inferenceModel:StatementModel = argumentTypeModel.inferenceModel;
			//the inference is an implication
			inferenceModel.connectingString = StatementModel.IMPLICATION;
			//push inference into claim's statement
			var inferenceStatement:SimpleStatementModel = argumentTypeModel.inferenceModel.statements[1];
			claimModel.statement.addDependentStatement(inferenceStatement);
			//push inference into reasons statement
			for(var i:int=0; i<reasonModels.length; i++){
				var reason:StatementModel = reasonModels[i];
				reason.statement.addDependentStatement(inferenceModel.statements[0]);
			}
		}
		
		override public function deleteLinks(argumentTypeModel:ArgumentTypeModel):void{
			//remove inference's dependence on claim
			var statement:SimpleStatementModel = argumentTypeModel.claimModel.statement;
			var modelToBeRemoved:SimpleStatementModel = argumentTypeModel.inferenceModel.statements[1];
			try{
				removeDependence(statement, modelToBeRemoved);
			}catch(error:Error){
				trace("ModusPonens::deleteLinks:");
				trace(error.message);
			}
			try{
				for(var i:int = 0; i < argumentTypeModel.reasonModels.length; i++){
					statement =  argumentTypeModel.reasonModels[i].statement;
					modelToBeRemoved = argumentTypeModel.inferenceModel.statements[0];
					removeDependence(statement, modelToBeRemoved);	
				}
			}catch(error:Error){
				trace(error.message);
			}
		}
	}	
}