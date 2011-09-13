
package Controller.logic
{
	import Model.AGORAModel;
	import Model.ArgumentTypeModel;
	import Model.InferenceModel;
	import Model.SimpleStatementModel;
	import Model.StatementModel;
	
	import ValueObjects.AGORAParameters;
	
	import components.ArgSelector;
	import components.ArgumentPanel;
	import components.MenuPanel;
	import classes.Language;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;

	public class NotAllSyllogism extends ParentArg
	{
		private static var instance:NotAllSyllogism;
		public function NotAllSyllogism()
		{
			//myname = NOT_ALL_SYLL;
			//_dbType = "NotAllSyl";
			//langTypes = ["Not-all"]; 	// the sole language type here is expandable. always with And.
			//sLanguageExp = true;
			label = AGORAParameters.getInstance().NOT_ALL_SYLL;
		}
		
		public static function getInstance():NotAllSyllogism{
			if(instance==null){
				instance = new NotAllSyllogism;
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
			
			output = Language.lookup("ArgCannotBe");
			
			for(i=0; i<reasonModels.length; i++){
				reasonText = reasonText +  reasonModels[i].statement.text +
						Language.lookup("ArgAnd") + Language.lookup("ArgThat");
				argumentTypeModel.inferenceModel.statements[i+1].text = reasonModels[i].statement.text;
			}
			
			output = output + reasonText + claimModel.statement.positiveText;
			argumentTypeModel.inferenceModel.statements[0].text = claimModel.statement.text;
			argumentTypeModel.inferenceModel.statement.text = output;
		}
		
		override public function deleteLinks(argumentTypeModel:ArgumentTypeModel):void{
			
			
			var reasonModels:Vector.<StatementModel> = argumentTypeModel.reasonModels;
			var claimModel:StatementModel = argumentTypeModel.claimModel;
			var inferenceModel:StatementModel = argumentTypeModel.inferenceModel;
			
			//remove negativity from the inference
			inferenceModel.negated = false;
			
			//if first claim's argument, remove
			//negativity from the claim
			if(claimModel.firstClaim){
				claimModel.negated = false;
			}
			
			//remove links from claim to the inference's  statement
			var simpleStatement:SimpleStatementModel;
			var statementTobeUnLinked:SimpleStatementModel;
			
			simpleStatement = claimModel.statement;
			statementTobeUnLinked = inferenceModel.statements[0];
			removeDependence(simpleStatement, statementTobeUnLinked);
			
			if(reasonModels.length > 1){
				trace("NotAllSyllogism::deleteLinks: This should not be occuring.");
			}
			//remove links from reasons to the inference's statement
			simpleStatement = reasonModels[0].statement;
			statementTobeUnLinked = inferenceModel.statements[1];
			removeDependence(simpleStatement, statementTobeUnLinked);
			
			//delete the unnecessary statements in the infernece
			//but this is not required as the scheme could be changed
			//only when there is one reason. If there is only one reasons
			//the number of statements in the inference is going to be
			//only two, which is the default.
			
		}
		
		override public function link(argumentTypeModel:ArgumentTypeModel):void{
			var claimModel:StatementModel = argumentTypeModel.claimModel;
			var reasonModels:Vector.<StatementModel> = argumentTypeModel.reasonModels;
			var inferenceModel:StatementModel = argumentTypeModel.inferenceModel;
			
			//inference is a disjunction
			inferenceModel.connectingString = StatementModel.DISJUNCTION;
			
			//if first claim, change it to negative
			if(claimModel.firstClaim){
				claimModel.negated = true;
			}
			
			//connect the claim's statement to the finference's first statement
			claimModel.statement.forwardList.push(inferenceModel.statements[0]);
			
			//connect the reason's statement to the infernece's second statement
			reasonModels[0].statement.forwardList.push(inferenceModel.statements[1]);
		}
		
	
		/*
		override public function get dbType():String
		{
			return _dbType;
		}
		
		override public function getLanguageType(dbString:String):String{
			return _langTypes[0];
		}
		
		override public function createLinks():void
		{
			if(inference.claim.inference != null && !inference.claim.statementNegated)
			{
				Alert.show("Error: Statement cannot be positive");
			}

			
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
			
			
			for(i=0; i < inference.reasons.length; i++)
			{
				if(inference.reasons[i].statementNegated)
				{
					inference.reasons[i].statementNegated = false;	
				}
			}	
			inference.implies = false;
			
			super.createLinks();
			

		}
		
		override public function correctUsage():String {
			var output:String = "";
			var reasonStr:String;
			var i:int;
			
			output += "It cannot be the case, at the same time, that ";
			for(i=0;i<inference.reasons.length;i++)
			{
					output += inference.reasons[i].stmt + " and that ";
					//inference.inputs[i+1].text = inference.reasons[i].stmt;
					//inference.inputs[i+1].forwardUpdate();
			}
			output += inference.claim.positiveStmt;
			//inference.inputs[0].text = inference.claim.positiveStmt;
			//inference.inputs[0].forwardUpdate();
			return output;
		}
		*/
	}
}