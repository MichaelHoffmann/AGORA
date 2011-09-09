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
					output = "If " + claimModel.statement.positiveText + ", then " + reasonText;
					break;
				case langTypes[1]:
					output = claimModel.statement.positiveText + " implies " + reasonModels[0].statement.positiveText;
					break;
				case langTypes[2]:
					reasonText = reasonModels[0].statement.positiveText;
					output = "Whenever " + claimModel.statement.positiveText + ", " + reasonText;
					break;
				case langTypes[3]:
					//if many reasons
					if(argumentTypeModel.reasonModels.length > 1){
						output = "Select how you want to connect the reasons";
						argSelector.andor.x = argSelector.typeSelector.x + argSelector.typeSelector.width;
						argSelector.andor.visible = true;
						//if one reason
					}else if(argumentTypeModel.reasonModels.length == 1){
						reasonText = reasonModels[0].statement.positiveText;
						output = claimModel.statement.positiveText + " only if ";
						output = output + reasonText;
					}else{
						output = claimModel.statement.positiveText + " only if ";	
						for(i=0; i<reasonModels.length - 1; i++){
							reasonText = reasonText + reasonModels[i].statement.positiveText + " " + argumentTypeModel.lSubOption + " ";
						}
						reasonText = reasonText + reasonModels[reasonModels.length - 1].statement.positiveText;
						output = output + reasonText;
					}
					break;
				case langTypes[4]:
					//provided that
					reasonText = reasonModels[0].statement.positiveText ;
					output = reasonText + " provided that " + claimModel.statement.positiveText;
					break;
				case langTypes[5]:
					//sufficient condition
					reasonText = reasonModels[0].statement.positiveText;
					output = claimModel.statement.positiveText + " is a sufficient condition for " + reasonText;
					break;
				case langTypes[6]:
					//necessary condition
					reasonText = reasonModels[0].statement.positiveText  
					output = reasonText + " is a necessary condition for " + claimModel.statement.positiveText;
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
				output = claimModel.statement.positiveText + " only if " + reasonModels[0].statement.positiveText;
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
			
			claimModel.statement.forwardList.push(inferenceModel.statements[0]);
		
			for each(var reason:StatementModel in reasonModels){
				reason.negated = true;
				reason.statement.forwardList.push(inferenceModel.statements[1]);
			}
		}
		
		/*
		
		override public function getOption(dbString:String):String{
		if(dbString.indexOf("or") >= 0)
		{
		return "or";
		}
		else if(dbString.indexOf("and") >= 0)
		{
		return "and"  ;
		}
		else
		{
		return "";
		}
		}
		
		override public function get dbType():String
		{
		
		for(var i:int=0; i<_langTypes.length; i++)
		{
		if(inference.myschemeSel.selectedType == _langTypes[i]){
		if(_langTypes[i] == "Only if" && inference.hasMultipleReasons){
		
		return _dbType+dbLangTypeNames[i]+andOr;
		}
		else 
		{
		return _dbType+dbLangTypeNames[i];
		
		}
		}
		}
		return "Unset";
		}
		
		override public function createLinks():void
		{
		//Negate the claim if it is the first claim of the argument
		if(inference.claim.inference != null && !inference.claim.statementNegated)
		{
		Alert.show("Error: The claim should not have been a non-negative statement");
		}
		
		//change claim and reason from multistatement to normal
		//statement type
		if(inference.claim.multiStatement)
		{
		inference.claim.multiStatement = false;
		}
		for(var i:int=0; i < inference.reasons.length; i++)
		{
		if(inference.reasons[i].multiStatement)
		{
		inference.reasons[i].multiStatement = false;
		}
		}
		
		if(inference.claim.userEntered == false && inference.claim.inference == null && inference.claim.rules.length < 2)
		{
		inference.claim.input1.text = "P";
		inference.claim.makeUnEditable();
		inference.reasons[0].input1.text = "Q";
		inference.reasons[0].makeUnEditable();
		}
		
		
		if(!inference.claim.statementNegated)
		{
		inference.claim.statementNegated = true;	
		}
		
		for(i = 0; i < inference.reasons.length; i++)
		{
		if(!inference.reasons[i].statementNegated)
		{
		inference.reasons[i].statementNegated = true;
		}	
		}
		
		inference.implies = true;
		
		var	claim:ArgumentPanel = inference.claim;
		var reasons:Vector.<ArgumentPanel> = inference.reasons;
		claim.input1.forwardList.push(inference.input[0]);
		inference.input[0].forwardList.push(inference.inputs[1]);
		for(i=0; i < reasons.length; i++)
		{
		reasons[i].input1.forwardList.push(inference.input[i+1]);
		inference.input[i+1].forwardList.push(inference.inputs[0]);
		}
		inference.implies = true;
		}
		
		override public function correctUsage():String {
		var output:String = "";
		var reason:Vector.<ArgumentPanel> = inference.reasons;
		var claim:ArgumentPanel = inference.claim;
		var i:int;
		
		
		//Negate the reason. The reason will not be supported by other
		//arguments. If it were, the argument woud have had 'typed' true,
		//and myArg would not be pointing to a Modus Tollens Object
		
		switch(inference.myschemeSel.selectedType) {
		//negate reason				
		case _langTypes[0]: //If-then. If both claim and reason negated
		//output += "If " + claim.positiveStmt + ", then "+ reason[0].positiveStmt;
		inference.inputs[0].text = reason[0].positiveStmt;
		
		inference.inputs[1].text = claim.positiveStmt;
		
		output = "If " + inference.inputs[1].text + ", then " + inference.inputs[0].text;
		inference.inputs[0].forwardUpdate();
		inference.inputs[1].forwardUpdate();
		break;
		case _langTypes[1]: // Implies
		output +=  claim.positiveStmt + " implies " + reason[0].positiveStmt;
		inference.inputs[0].text = reason[0].positiveStmt;
		inference.inputs[1].text = claim.positiveStmt;
		inference.inputs[0].forwardUpdate();
		inference.inputs[1].forwardUpdate();
		break;
		case _langTypes[2]: //Whenever
		output += "Whenever " + claim.positiveStmt + ", " + reason[0].positiveStmt;
		inference.inputs[0].text = reason[0].positiveStmt;
		inference.inputs[1].text = claim.positiveStmt;
		inference.inputs[0].forwardUpdate();
		inference.inputs[1].forwardUpdate();
		break;
		case _langTypes[3]: // Only if
		var reasonStr:String = "";
		output += claim.positiveStmt + " only if ";
		for(i=0;i<reason.length-1;i++)
		{
		output += reason[i].positiveStmt + " " + andOr + " ";
		reasonStr = reasonStr + reason[i].positiveStmt + " " + andOr + " ";
		}
		reasonStr = reasonStr + reason[i].positiveStmt;
		output += reason[reason.length-1].positiveStmt;
		inference.inputs[0].text = reasonStr;
		inference.inputs[1].text = claim.positiveStmt;
		inference.inputs[0].forwardUpdate();
		inference.inputs[1].forwardUpdate();
		break;
		case _langTypes[4]: // Provided that
		output += reason[0].positiveStmt + " provided that " + claim.positiveStmt;
		inference.inputs[0].text = reason[0].positiveStmt;
		inference.inputs[1].text = claim.positiveStmt;
		inference.inputs[0].forwardUpdate();
		inference.inputs[1].forwardUpdate();
		break;
		
		case _langTypes[5]: // Sufficient condition
		output += claim.positiveStmt + " is a sufficient condition for " + reason[0].positiveStmt;
		inference.inputs[0].text = reason[0].positiveStmt;
		inference.inputs[1].text = claim.positiveStmt;
		inference.inputs[0].forwardUpdate();
		inference.inputs[1].forwardUpdate();
		break;
		case _langTypes[6]: // Necessary condition
		output += reason[0].positiveStmt + " is a necessary condition for " + claim.positiveStmt;
		inference.inputs[0].text = reason[0].positiveStmt;
		inference.inputs[1].text = claim.positiveStmt;
		inference.inputs[0].forwardUpdate();
		inference.inputs[1].forwardUpdate();
		break;	
		}
		return output;
		}
		*/
	}
}