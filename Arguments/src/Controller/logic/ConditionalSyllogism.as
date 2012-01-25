package Controller.logic
{
	import Model.AGORAModel;
	import Model.ArgumentTypeModel;
	import Model.SimpleStatementModel;
	import Model.StatementModel;
	
	import ValueObjects.AGORAParameters;
	
	import components.ArgumentPanel;
	import components.DynamicTextArea;
	
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	
	import classes.Language;
	
	public class ConditionalSyllogism extends ParentArg
	{		
		private static var instance:ConditionalSyllogism;
		public var built:Boolean;	
		
		public function ConditionalSyllogism()
		{
			var agoraParameters:AGORAParameters = AGORAParameters.getInstance();
			langTypes = [agoraParameters.IF_THEN,agoraParameters.IMPLIES];
			expLangTypes = [agoraParameters.IF_THEN,agoraParameters.IMPLIES];
			label = AGORAParameters.getInstance().COND_SYLL;
		}
		
		public static function getInstance():ConditionalSyllogism{
			if(instance == null){
				instance = new ConditionalSyllogism;
			}
			return instance;
		}
		
		override public function getLabel():String{
			return AGORAParameters.getInstance().COND_SYLL;
		}
		
		override public function formText(argumentTypeModel:ArgumentTypeModel):void{
			var output:String = "";
			var reasonText:String = "";
			var reasonModels:Vector.<StatementModel> = argumentTypeModel.reasonModels;
			var claimModel:StatementModel = argumentTypeModel.claimModel;
			var inferenceModel:StatementModel = argumentTypeModel.inferenceModel;
			
			inferenceModel.statements[0].text = reasonModels[reasonModels.length-1].statements[1].text;
			inferenceModel.statements[1].text = claimModel.statements[1].text;
			
			switch(argumentTypeModel.language){
				case langTypes[0]:
					inferenceModel.statement.text = Language.lookup("ArgIfCap") + inferenceModel.statements[0].text + 
					Language.lookup("ArgThen") + inferenceModel.statements[1].text;
					break;
				case langTypes[1]:
					inferenceModel.statement.text = inferenceModel.statements[0].text + Language.lookup("ArgImplies") +
					inferenceModel.statements[1].text;
			}
		}
		
		override public function deleteLinks(argumentTypeModel:ArgumentTypeModel):void{
			var reasonModels:Vector.<StatementModel> = argumentTypeModel.reasonModels;
			var claimModel:StatementModel = argumentTypeModel.claimModel;
			var inferenceModel:StatementModel = argumentTypeModel.inferenceModel;
			var simpleStatement:SimpleStatementModel;
			var stmtToBeUnlinked:SimpleStatementModel;
			var i:int;
			
			var claimText:String = claimModel.statements[0].text;
			if(reasonModels.length > 0){
				var reasonText:String = reasonModels[0].statements[0].text;
				removeDependence(claimModel.statements[0], reasonModels[0].statements[0]);
				for(i=0; i<reasonModels.length - 1; i++){
					removeDependence(reasonModels[i].statements[1], reasonModels[i+1].statements[0]);
				}
				//reason to inference
				removeDependence(reasonModels[reasonModels.length - 1].statements[1], inferenceModel.statements[0]);
			}
			
			//claim to inference
			removeDependence(claimModel.statements[1], inferenceModel.statements[1]);
			
			//remove temporary boxes
			//from claim
			for each(simpleStatement in claimModel.statements){
				if(simpleStatement.ID == SimpleStatementModel.TEMPORARY){
					simpleStatement.parent.statements.splice(simpleStatement.parent.statements.indexOf(simpleStatement),1);
				}
			}
			
			for(i=0; i<reasonModels.length; i++){
				for each(simpleStatement in reasonModels[i].statements){
					if(simpleStatement.ID == SimpleStatementModel.TEMPORARY){
						simpleStatement.parent.statements.splice(simpleStatement.parent.statements.indexOf(simpleStatement),1);
					}
				}
			}
			
			//So that changes get reflected in the statement
			claimModel.statements[0].updateStatementTexts();
			if(reasonModels.length > 0){
				reasonModels[0].statements[0].updateStatementTexts();
			}
		}
		
		override public function link(argumentTypeModel:ArgumentTypeModel):void{
			var reasonModels:Vector.<StatementModel> = argumentTypeModel.reasonModels;
			var claimModel:StatementModel = argumentTypeModel.claimModel;
			var inferenceModel:StatementModel = argumentTypeModel.inferenceModel;
			var hashMap:Dictionary = FlexGlobals.topLevelApplication.map.agoraMap.panelsHash;
			var i:int;
			
			var argumentPanel:ArgumentPanel;
			inferenceModel.connectingString = StatementModel.IMPLICATION;
			claimModel.connectingString = StatementModel.IMPLICATION;
			//reasonModels[i].connectingString = StatementModel.IMPLICATION;
			
			
			if(claimModel.firstClaim && claimModel.statements.length < 2){
				claimModel.addTemporaryStatement();
				claimModel.statements[1].text = "T";
			}
			
			for(i = 0; i<reasonModels.length; i++){
				if(reasonModels[i].statements.length < 2){
					reasonModels[i].addTemporaryStatement();
					reasonModels[i].statements[1].text = (reasonModels[i].statements[0].text == "" || reasonModels[i].statements[0].text==null)? "W"+i.toString() : reasonModels[i].statements[0].text;
					reasonModels[i].connectingString = StatementModel.IMPLICATION;
				}
			}
			
			//connect the conclusion of the claim
			//to the conclusion of the inference
			claimModel.statements[1].addDependentStatement(inferenceModel.statements[1]);
			//connect the first reason's premise to the
			//claim's premise
			claimModel.statements[0].addDependentStatement(reasonModels[0].statements[0]);
			
			//connect subsequent reasons
			for(i=0; i<reasonModels.length -1; i++){
				reasonModels[i].statements[1].addDependentStatement(reasonModels[i+1].statements[0]);
			}
			//connect last reason's conclusion to the 
			//inference's premise
			reasonModels[reasonModels.length - 1].statements[1].addDependentStatement(inferenceModel.statements[0]);
			
			
			
			//update linked texts
			claimModel.statements[0].updateStatementTexts();
			claimModel.statements[1].updateStatementTexts();
			for each(var reasonModel:StatementModel in reasonModels){
				reasonModel.statements[0].updateStatementTexts();
				reasonModel.statements[1].updateStatementTexts();
				reasonModel.connectingString = StatementModel.IMPLICATION;
			}
			
		}
		
	}
}