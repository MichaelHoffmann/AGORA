package Controller.logic
{	
	import Model.AGORAModel;
	import Model.ArgumentTypeModel;
	import Model.SimpleStatementModel;
	import Model.StatementModel;
	
	import ValueObjects.AGORAParameters;
	
	import components.ArgSelector;
	import components.ArgumentPanel;
	
	import mx.controls.Alert;
	import mx.messaging.channels.StreamingAMFChannel;
	
	public class ModusPonens extends ParentArg
	{
		
		private static var instance:ModusPonens;
		
		
		public function ModusPonens()
		{			
			langTypes = ["If-then","Implies","Whenever","Only if","Provided that","Sufficient condition","Necessary condition"];
			//dbLangTypeNames = ["ifthen","implies","whenever","onlyif","providedthat","sufficient","necessary"];
			expLangTypes = ["If-then","Whenever","Provided that"];	
			label = AGORAParameters.getInstance().MOD_PON;
			//_dbType = "MP";
			
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
			
			switch(argumentTypeModel.language){
				case langTypes[0]:
					reasonText = reasonModels[i].statement.text;
					for(i=1; i<reasonModels.length; i++){
						reasonText = reasonText + " and "  + reasonModels[i].statement.text;
					}
					output = "If " + reasonText; 
					output = output + ", then " + claimModel.statement.text;
					break;
				case langTypes[1]:
					reasonText =  reasonModels[0].statement.text;
					output = reasonText + " implies " + claimModel.statement.text;
					break;
				case langTypes[2]:
					output = "Whenever ";
					reasonText = reasonModels[0].statement.text;
					for(i=1; i<reasonModels.length; i++){
						reasonText = reasonText + " and " + reasonModels[i].statement.text;
					}
					output = output + reasonText + ", " + claimModel.statement.text; 
					break;
				case langTypes[3]:
					reasonText =  reasonModels[0].statement.text ; 
					output = reasonText + " only if " + claimModel.statement.text;
					break;
				case langTypes[4]:
					output = claimModel.statement.text + " provided that ";
					reasonText = reasonModels[0].statement.text;
					for(i=1; i < reasonModels.length; i++){
						reasonText = reasonText + " and " + reasonModels[i].statement.text;
					}
					output = output + reasonText;
					break;
				case langTypes[5]:
					reasonText = reasonModels[0].statement.text; 
					output =  reasonText + " is a sufficient condition for " + claimModel.statement.text;
					break;
				case langTypes[6]:
					reasonText = reasonModels[0].statement.text;
					output = claimModel.statement.text + " is a necessary condition for " + reasonText;
					break;
			}
			//trace(reasonText);
			argumentTypeModel.inferenceModel.statements[0].text = reasonText;
			argumentTypeModel.inferenceModel.statements[1].text = argumentTypeModel.claimModel.statement.text;
			if(argumentTypeModel.inferenceModel.statement.forwardList.length > 0){
				trace("Very good observation");
				trace(argumentTypeModel.inferenceModel.statement.forwardList[0] == argumentTypeModel.inferenceModel.statements[0]);
				trace(argumentTypeModel.inferenceModel.statement.forwardList[0].ID == argumentTypeModel.inferenceModel.statements[0].ID);
				trace(argumentTypeModel.inferenceModel.statement.forwardList[0].ID);
				trace(argumentTypeModel.inferenceModel.statement.parent.ID);
				trace('-----');
				for(i=0; i < argumentTypeModel.inferenceModel.nodeTextIDs.length; i++){
					trace(argumentTypeModel.inferenceModel.nodeTextIDs[i]);
					trace(argumentTypeModel.inferenceModel.statements[i].ID);
					
				}
			}
			
			else{
				trace('did not');
			}
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
			
			for(var i:int = 0; i < argumentTypeModel.reasonModels.length; i++){
				statement =  argumentTypeModel.reasonModels[i].statement;
				modelToBeRemoved = argumentTypeModel.inferenceModel.statements[0];
				removeDependence(statement, modelToBeRemoved);	
			}
		}
		
		
		
	}
	
}