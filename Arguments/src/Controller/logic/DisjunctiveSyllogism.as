
package Controller.logic
{
	import Model.AGORAModel;
	import Model.ArgumentTypeModel;
	import Model.SimpleStatementModel;
	import Model.StatementModel;
	
	import ValueObjects.AGORAParameters;
	
	import components.ArgumentPanel;
	import classes.Language;
		
	import mx.controls.Alert;
	
	public class DisjunctiveSyllogism extends ParentArg
	{
		private static var instance:DisjunctiveSyllogism;
		
		public function DisjunctiveSyllogism()
		{
			//langTypes = ["Either-or"];
			//expLangTypes =  ["Either-or"];
			//myname = DIS_SYLL;
			//_dbType = "DisjSyl";
			label = AGORAParameters.getInstance().DIS_SYLL;
		}
		
		public static function getInstance():DisjunctiveSyllogism{
			if(instance == null){
				instance = new DisjunctiveSyllogism;
			}
			return instance;
		}
		
		override public function formText(argumentTypeModel:ArgumentTypeModel):void{
			var output:String = "";
			var reasonText:String = "";
			var reasonModels:Vector.<StatementModel> = argumentTypeModel.reasonModels;
			var claimModel:StatementModel = argumentTypeModel.claimModel;
			var inferenceModel:StatementModel = argumentTypeModel.inferenceModel;
			var i:int;
			
			output = Language.lookup("ArgEitherCap");
			for(i=0; i<reasonModels.length; i++){
				inferenceModel.statements[i+1].text = reasonModels[i].statement.positiveText;
				reasonText = reasonText + reasonModels[i].statement.positiveText + Language.lookup("ArgOr"); 
			}
			
			inferenceModel.statements[0].text = claimModel.statement.text;
			output = output + reasonText + claimModel.statement.text;
			
			inferenceModel.statement.text = output;	
		}
		
		override public function deleteLinks(argumentTypeModel:ArgumentTypeModel):void{
			var reasonModels:Vector.<StatementModel> = argumentTypeModel.reasonModels;
			var claimModel:StatementModel = argumentTypeModel.claimModel;
			var inferenceModel:StatementModel = argumentTypeModel.inferenceModel;
			
			//remove negativity of the reason
			reasonModels[0].negated = false;
			
			//There is only one reason
			//claim is already positive
			
			//remove links from reason to inference
			var simpleStatement:SimpleStatementModel;
			var stmtToBeUnlinked:SimpleStatementModel;
			
			simpleStatement = reasonModels[0].statement;
			stmtToBeUnlinked = inferenceModel.statements[1];
			removeDependence(simpleStatement, stmtToBeUnlinked);
			
			simpleStatement = claimModel.statement;
			stmtToBeUnlinked = inferenceModel.statements[0];
			removeDependence(simpleStatement, stmtToBeUnlinked);	
		}
		
		override public function link(argumentTypeModel:ArgumentTypeModel):void{
			var reasonModels:Vector.<StatementModel> = argumentTypeModel.reasonModels;
			var claimModel:StatementModel = argumentTypeModel.claimModel;
			var inferenceModel:StatementModel = argumentTypeModel.inferenceModel;
			
			//make reason negative
			reasonModels[0].negated = true;
			
			
			claimModel.statement.forwardList.push(inferenceModel.statements[0]);
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
			trace("creating links");

			if(inference.claim.inference != null && inference.claim.statementNegated)
			{
				Alert.show("Error: Statement cannot be negative");
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
				inference.reasons[0].input1.text = "Q";
				inference.claim.makeUnEditable();
				inference.reasons[0].makeUnEditable();
			}
			
			if(inference.claim.statementNegated)
				inference.claim.statementNegated = false;
			
			for(i=0; i < inference.reasons.length; i++)
			{
				if(!inference.reasons[i].statementNegated)
				{
					inference.reasons[i].statementNegated = true;
				}
			}
			inference.implies = false;
			super.createLinks();
		}
		
		override public function correctUsage():String {
			
			var i:int;
			var output:String = "";
			switch(inference.myschemeSel.selectedType) 
			{
				case _langTypes[0]: 
					output += "Either ";
					for(i=0;i<inference.reasons.length;i++)
					{
						output += inference.reasons[i].positiveStmt + " or ";
						//Required for constructive dillemma
						//inference.inputs[i+1].text = inference.reasons[i].positiveStmt;
						//inference.inputs[i+1].forwardUpdate();
					}
					output += inference.claim.stmt;
					//inference.inputs[0].text = inference.claim.stmt;
					//inference.inputs[0].forwardUpdate();	
					break;
			}
			return output;
		}
		*/
	}
}