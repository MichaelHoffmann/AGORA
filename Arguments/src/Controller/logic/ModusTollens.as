package Controller.logic
{
	import Controller.ArgumentController;
	
	import Model.AGORAModel;
	import Model.ArgumentTypeModel;
	import Model.StatementModel;
	
	import ValueObjects.AGORAParameters;
	
	import components.ArgSelector;
	import components.ArgumentPanel;
	import components.MenuPanel;
	
	import classes.Language;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	
	public class ModusTollens extends ParentArg
	{ 
		public var andOr:String;
		private var _isExp:Boolean;
		private static var instance:ModusTollens;
		
		
		public function ModusTollens()
		{
			langTypes = ["If-then","Implies","Whenever","Only if","Provided that","Sufficient condition","Necessary condition"];
			//dbLangTypeNames = ["ifthen","implies","whenever","onlyif","providedthat","sufficient","necessary"];
			expLangTypes = ["Only if"];	// Expandable with both And and Or
			label = AGORAParameters.getInstance().MOD_TOL;
			
		}
		
		public static function getInstance():ModusTollens{
			if(instance == null){
				instance = new ModusTollens;
			}
			return instance;
		}
		
		override public function getLabel():String{
			return label;
		}
		
		override public function formText(argumentTypeModel:ArgumentTypeModel):void{
			var output:String = "";
			var reasonText:String = "";
			var reasonModels:Vector.<StatementModel> = argumentTypeModel.reasonModels;
			var claimModel:StatementModel = argumentTypeModel.claimModel;
			var argSelector:ArgSelector = MenuPanel(FlexGlobals.topLevelApplication.map.agoraMap.menuPanelsHash[argumentTypeModel.ID]).schemeSelector;
			var i:int;
			
			switch(argumentTypeModel.language){
				case langTypes[0]:
					reasonText = reasonModels[0].statement.positiveText;
					output = Language.lookup("ArgIf") + claimModel.statement.positiveText + 
						Language.lookup("ArgThen") + reasonText;
					break;
				case langTypes[1]:
					output = claimModel.statement.positiveText + Language.lookup("ArgImplies") + reasonModels[0].statement.positiveText;
					break;
				case langTypes[2]:
					reasonText = reasonModels[0].statement.positiveText;
					output = Language.lookup("ArgWhenever") + claimModel.statement.positiveText + ", " + reasonText;
					break;
				case langTypes[3]:
					//if many reasons
					var params:AGORAParameters = AGORAParameters.getInstance();
					if(argumentTypeModel.reasonModels.length > 1 && argumentTypeModel.lSubOption == null){
						output = "Select how you want to connect the reasons";
						argSelector.andor.x = argSelector.typeSelector.x + argSelector.typeSelector.width;
						argSelector.andor.dataProvider = [params.AND, params.OR];
						argSelector.andor.visible = argSelector.typeSelector.visible;
						//if one reason
					}else if(argumentTypeModel.reasonModels.length == 1){
						reasonText = reasonModels[0].statement.positiveText;
						output = claimModel.statement.positiveText + Language.lookup("ArgOnlyIf");
						output = output + reasonText;
					}else{
						output = claimModel.statement.positiveText + Language.lookup("ArgOnlyIf");	
						for(i=0; i<reasonModels.length - 1; i++){
							reasonText = reasonText + reasonModels[i].statement.positiveText + " " + argumentTypeModel.lSubOption + " ";
						}
						reasonText = reasonText + reasonModels[reasonModels.length - 1].statement.positiveText;
						output = output + reasonText;
						argSelector.andor.x = argSelector.typeSelector.x + argSelector.typeSelector.width;
						argSelector.andor.dataProvider = [params.AND, params.OR];
						argSelector.andor.visible = argSelector.typeSelector.visible;
					}
					break;
				case langTypes[4]:
					//provided that
					reasonText = reasonModels[0].statement.positiveText ;
					output = reasonText + Language.lookup("ArgProvidedThat") + claimModel.statement.positiveText;
					break;
				case langTypes[5]:
					//sufficient condition
					reasonText = reasonModels[0].statement.positiveText;
					output = claimModel.statement.positiveText + Language.lookup("ArgSufficientCond") + reasonText;
					break;
				case langTypes[6]:
					//necessary condition
					reasonText = reasonModels[0].statement.positiveText  
					output = reasonText + Language.lookup("ArgNecessaryCond") + claimModel.statement.positiveText;
					break;
			}
		
			argumentTypeModel.inferenceModel.statements[0].text = claimModel.statement.text;
			argumentTypeModel.inferenceModel.statements[1].text = reasonText;
			argumentTypeModel.inferenceModel.statement.text = output;
		}
		
		override public function formTextWithSubOption(argumentTypeModel:ArgumentTypeModel):void{
			//must be only if:
			var output:String = "";
			var reasonModels:Vector.<StatementModel> = argumentTypeModel.reasonModels;
			var claimModel:StatementModel = argumentTypeModel.claimModel;
			var argSelector:ArgSelector = MenuPanel(FlexGlobals.topLevelApplication.map.agoraMap.menuPanelsHash[argumentTypeModel.ID]).schemeSelector;
			var i:int;
			
			if(argumentTypeModel.language == langTypes[4]){
				output = claimModel.statement.positiveText + Language.lookup("ArgOnlyIf") + reasonModels[0].statement.positiveText;
				for(i=1; i < reasonModels.length; i++){
					output = " " + argumentTypeModel.lSubOption + " " + reasonModels[i].statement.positiveText;
				}
			}
			else{
				trace("ModusTollens::formTextWithSubOption: Should not be any other language type other than only if");	
			}
			
			argumentTypeModel.inferenceModel.statement.text = output;
		}
		
		override public function deleteLinks(argumentTypeModel:ArgumentTypeModel):void{
			var reasonModels:Vector.<StatementModel> = argumentTypeModel.reasonModels;
			var claimModel:StatementModel = argumentTypeModel.claimModel;
			//var inferenceModel:StatementModel = argumentTypeModel.inferenceModel;
			//if first claim's argument, then make it non-negative
			if(claimModel.firstClaim){
				claimModel.negated = false;
				//the first inference statement is the one to be removed
			}
			removeDependence(claimModel.statement, argumentTypeModel.inferenceModel.statements[0]);
			//make reason models non-negative
			for each(var reason:StatementModel in reasonModels){
				reason.negated = false;
				removeDependence(reason.statement, argumentTypeModel.inferenceModel.statements[1]);
			}
		}
		
		override public function link(argumentTypeModel:ArgumentTypeModel):void{
			var reasonModels:Vector.<StatementModel> = argumentTypeModel.reasonModels;
			var claimModel:StatementModel = argumentTypeModel.claimModel;
			var inferenceModel:StatementModel = argumentTypeModel.inferenceModel;
			
			if(claimModel.firstClaim){
				claimModel.negated = true;
			}
			
			inferenceModel.connectingString = StatementModel.IMPLICATION;
			
			//claimModel.statement.forwardList.push(inferenceModel.statements[0]);
			claimModel.statement.addDependentStatement(inferenceModel.statements[0]);
		
			for each(var reason:StatementModel in reasonModels){
				reason.negated = true;
				//reason.statement.forwardList.push(inferenceModel.statements[1]);
				reason.statement.addDependentStatement(inferenceModel.statements[1]);
			}
		}
	}
}