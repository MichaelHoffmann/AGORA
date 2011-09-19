
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

			output = "Either "; //TODO: Need a translation for this
			if(reasonModels.length < inferenceModel.statements.length){
				for(i=0; i<reasonModels.length; i++){
					inferenceModel.statements[i+1].text = reasonModels[i].statement.positiveText;
					reasonText = reasonText + reasonModels[i].statement.positiveText + Language.lookup("ArgOr"); 
				}
				inferenceModel.statements[0].text = claimModel.statement.text;
				output = output + reasonText + claimModel.statement.text;
				inferenceModel.statement.text = output;	
			}
		}
		
		override public function deleteLinks(argumentTypeModel:ArgumentTypeModel):void{
			var reasonModels:Vector.<StatementModel> = argumentTypeModel.reasonModels;
			var claimModel:StatementModel = argumentTypeModel.claimModel;
			var inferenceModel:StatementModel = argumentTypeModel.inferenceModel;
			
			//remove negativity of the reason
			reasonModels[0].negated = false;
			
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
			
			
			claimModel.statement.forwardList.push(inferenceModel.statements[0]);
			for(var i:int=0; i<reasonModels.length; i++){
				reasonModels[i].statement.forwardList.push(inferenceModel.statements[i+1]);
				reasonModels[i].negated = true;
			}	
			inferenceModel.connectingString = StatementModel.DISJUNCTION;
		}
	}
}