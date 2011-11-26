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
			var reasonText:String = reasonModels[0].statements[0].text;
			
			//remove Links normally
			//claim to first reason
			removeDependence(claimModel.statements[0], reasonModels[0].statements[0]);
			//claim to inference
			removeDependence(claimModel.statements[1], inferenceModel.statements[1]);
			
			//reasons
			for(i=0; i<reasonModels.length - 1; i++){
				removeDependence(reasonModels[i].statements[1], reasonModels[i+1].statements[0]);
			}
			
			//reason to inference
			removeDependence(reasonModels[reasonModels.length - 1].statements[1], inferenceModel.statements[0]);
			
			//remove temporary boxes
			//from claim
			for each(simpleStatement in claimModel.statements){
				if(simpleStatement.ID == SimpleStatementModel.TEMPORARY){
					simpleStatement.parent.statements.splice(simpleStatement.parent.statements.indexOf(simpleStatement),1);
				}
			}
			
			//from reason models
			//There should be only one reason
			//iterating is not required
			for(i=0; i<reasonModels.length; i++){
				for each(simpleStatement in reasonModels[i].statements){
					if(simpleStatement.ID == SimpleStatementModel.TEMPORARY){
						simpleStatement.parent.statements.splice(simpleStatement.parent.statements.indexOf(simpleStatement),1);
					}
				}
			}
			//So that changes get reflected in the statement
			claimModel.statements[0].updateStatementTexts();
			reasonModels[0].statements[0].updateStatementTexts();
			
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
					reasonModels[i].statements[1].text = "W" + i;
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
		
		
		
		/*		
		override public function addInitialReasons():void
		{
		if(inference == null)
		{
		//Help for programming. Translation not required. 
		Alert.show("Error: This logic class is not associated with an enabler");
		return;
		}
		var claim:ArgumentPanel = inference.claim;
		var reasons:Vector.<ArgumentPanel> = inference.reasons;
		if(!reasons[0].multiStatement)
		{
		reasons[0].multiStatement = true;
		reasons[0].implies = true;
		reasons[0].inputs[1].editable = false;
		reasons[0].connectingStr = inference.myschemeSel.selectedType;
		}
		}
		
		override public function createLinks():void
		{
		var i:int;
		var claim:ArgumentPanel = inference.claim;
		var reason:ArgumentPanel = inference.reasons[0];
		
		if(inference.claim.statementNegated)
		{
		inference.claim.statementNegated = false;
		}
		
		for(i=0; i < inference.reasons.length; i++)
		{
		if(inference.reasons[i].statementNegated)
		{
		inference.reasons[i].statementNegated = false;
		}
		}
		
		if(claim.inference == null && claim.rules.length == 1 && claim.userEntered == false && reason.userEntered == false && !(claim is Inference))
		{
		trace('user entered:' + claim.userEntered);
		claim.multiStatement = true;
		claim.implies = true;
		addInitialReasons();
		claim.inputs[0].text = "Q";
		claim.inputs[1].text = "P";
		claim.makeUnEditable();
		reason.inputs[0].text = "S";
		reason.inputs[1].text = "R";
		reason.makeUnEditable();
		}
		
		inference.claim.connectingStr = inference.myschemeSel.selectedType;
		inference.claim.makeUnEditable();
		inference.reasons[0].connectingStr = inference.myschemeSel.selectedType;
		inference.reasons[0].makeUnEditable();
		
		for(i=0; i < inference.reasons.length; i++)
		{
		if(!inference.reasons[i].multiStatement)
		{
		inference.reasons[i].multiStatement = true;
		inference.reasons[i].implies = true;
		inference.reasons[i].connectingStr = inference.claim.connectingStr;
		inference.reasons[i].makeUnEditable();
		inference.reasons[i].inputs[1].editable = false;
		//trace(inference.reasons[i].displayTxt.visible);
		}
		}
		
		
		if(inference.claim.multiStatement)
		{
		//link: claim's premise to first reason's premise
		link(inference.claim.inputs[1],inference.reasons[0].inputs[1]);
		for(i = 0; i < inference.reasons.length - 1; i++)
		{
		//a reson's conclusion is the next reasons premise
		//all of them are implies boxes
		link(inference.reasons[i].inputs[0],inference.reasons[i+1].inputs[1]);
		inference.reasons[i].inputs[0].forwardUpdate();	
		}
		//link(inference.reasons[i].inputs[0],inference.inputs[1]);
		link(inference.reasons[i].inputs[0],inference.input[0]);
		inference.reasons[i].inputs[0].forwardUpdate();	
		//claim's conclusion to enabler's conclusion
		link(inference.claim.inputs[0],inference.input[0]);
		link(inference.claim.inputs[1],inference.input[0]);
		link(inference.input[0],inference.input1);
		inference.claim.inputs[1].forwardUpdate();	
		inference.claim.inputs[0].forwardUpdate();
		
		}
		}
		
		override public function correctUsage():String {
		var output:String = "";
		var i:int;
		
		switch(inference.myschemeSel.selectedType)
		{
		case _langTypes[0]:
		inference.inputs[1].text = inference.reasons[inference.reasons.length - 1].inputs[0].text;
		if(inference.claim.multiStatement)
		{
		inference.inputs[0].text = inference.claim.inputs[0].text;
		}
		output = "If " + inference.inputs[1].text + ", then " +  inference.inputs[0].text;
		inference.inputs[1].forwardUpdate();
		inference.inputs[0].forwardUpdate();
		break;
		case _langTypes[1]:
		inference.inputs[1].text = inference.reasons[inference.reasons.length - 1].inputs[0].text;
		if(inference.claim.multiStatement)
		{
		inference.inputs[0].text = inference.claim.inputs[0].text;
		}
		output = inference.inputs[1].text + " implies " + inference.inputs[0].text;
		inference.inputs[1].forwardUpdate();
		inference.inputs[0].forwardUpdate();
		}
		return output;
		}
		*/
	}
}