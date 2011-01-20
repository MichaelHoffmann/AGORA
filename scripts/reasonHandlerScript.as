// ActionScript file
import classes.InferenceProvider;

import components.CustomLine;
import components.ReasonBox;

import events.StatementAcceptEvent;

import mx.utils.ObjectUtil;

//An array of ReasonBoxes
private var _reasonBox:Array;

//The index of the current reason
private var _reasonIndex:int;
//The array that holds the reason texts
private var _reasonTextArray:Array;

public function reasonInit():void{
	_reasonBox= new Array();
	_reasonTextArray = new Array();
	_reasonIndex = 0;
	_reasonTextArray[_claimIndex] = new Array();
}

private function reasonAcceptEvent(event:StatementAcceptEvent):void{
	var claimIndex:int = event.claimIndex;
	var reasonIndex:int = event.reasonIndex;
	if(!(_inferencePresent[claimIndex])){
		_reasonBox[claimIndex][reasonIndex].callAcceptReason();
		_reasonTextArray[claimIndex][reasonIndex] = event.statement;
		_schemeSelector.x = _reasonBox[claimIndex][reasonIndex].x + 20;
		_schemeSelector.y = _reasonBox[claimIndex][reasonIndex].y + 140;
		_schemeSelector.addEventListener("schemeAccepted",schemeSelectEvent);
		addChild(_schemeSelector);
		focusManager.setFocus(_schemeSelector.mainSchemes);
		_promptLabel.x = _schemeSelector.x+10;
		_promptLabel.y = _schemeSelector.y-20;
		_promptLabel.labelText = "Choose your argument scheme";
	}
	else{
		var newReasonText:Array = event.statement.split("It is not the case that ");
		
		if(newReasonText[0]!=''){
			_reasonTextArray[claimIndex][reasonIndex] = event.statement;
		}
		else{
			_reasonTextArray[claimIndex][reasonIndex] = newReasonText[1];
		}
		_reasonBox[claimIndex][reasonIndex].reasontext = _reasonTextArray[claimIndex][reasonIndex];
		_reasonBox[claimIndex][reasonIndex].callReasonUpdate();
		
		var inferenceProviderInstance:InferenceProvider = new InferenceProvider(_claimTextArray[claimIndex],_reasonTextArray[claimIndex],_reversePos[claimIndex]);
		_inferenceTextArray[claimIndex]  = inferenceProviderInstance.getInferenceText(_selectedLogic[claimIndex],_selectedFunction[claimIndex]);
		_claimBox[claimIndex].setClaim(inferenceProviderInstance.claimText);
		var reasonTextArray:Array = new Array();
		reasonTextArray = ObjectUtil.copy(inferenceProviderInstance.reasonText) as Array;
		
		for(var i:int = 0;i<_reasonBox[claimIndex].length;i++){
			_reasonBox[claimIndex][i].setReason(reasonTextArray[i]);
		}
		
		setInferenceBoxText(claimIndex,_inferenceTextArray[claimIndex]);
		setInferenceText(claimIndex,_inferenceTextArray[claimIndex]);
		updateInferenceText(claimIndex)
	}
}

public function createNewReasonBox(claimIndex:int,leftLine:CustomLine,reasonText:String=""):void{
	//The following lines of code create a new reason box
	_reasonBox[claimIndex] = new Array();
	_reasonBox[claimIndex][_reasonIndex] = new ReasonBox();
	_reasonBox[claimIndex][_reasonIndex].addx = leftLine.x + 77;
	_reasonBox[claimIndex][_reasonIndex].addy = 0;
	BindingUtils.bindProperty(_reasonBox[claimIndex][_reasonIndex],"xpos",_claimBox[claimIndex],"x");
	BindingUtils.bindProperty(_reasonBox[claimIndex][_reasonIndex],"ypos",_claimBox[claimIndex],"y");
	_reasonBox[claimIndex][_reasonIndex].addEventListener("reasonAccepted",reasonAcceptEvent);
	_reasonBox[claimIndex][_reasonIndex].index = _reasonIndex;
	_reasonBox[claimIndex][_reasonIndex].userID = 	_userID;
	_reasonBox[claimIndex][_reasonIndex].claimIndex = claimIndex;
	_reasonBox[claimIndex][_reasonIndex].reasontext = reasonText;
	addChild(_reasonBox[claimIndex][_reasonIndex]);
	_promptLabel.x = _reasonBox[claimIndex][_reasonIndex].x + 25;
	_promptLabel.y = _reasonBox[claimIndex][_reasonIndex].y - 20;
	_promptLabel.labelText = "What is your reason?";
	_reasonBox[claimIndex][_reasonIndex].init();
	_reasonBox[claimIndex][_reasonIndex].reasonbox.setFocus();
	return;
}

public function setReasonBoxText(claimIndex:int,reasonTextArray:Array):void{
	for(var i:int = 0;i<_reasonBox[claimIndex].length;i++){
		_reasonBox[claimIndex][i].setReason(reasonTextArray[i]);
	}
}

public function setReasonTextArray(claimIndex:int,reasonTextArray:Array):void{
	_reasonTextArray[claimIndex] = ObjectUtil.copy(reasonTextArray) as Array;
	for(var i:int = 0;i<_reasonBox[claimIndex].length;i++){
		_reasonBox[claimIndex][i].reasontext = _reasonTextArray[i];
	}
}
public function setReasonText(claimIndex:int,reasonIndex:int,reasonText:String):void{
	_reasonTextArray[claimIndex][reasonIndex] = reasonText;
}
public function clearReasonIndex():void{
	_reasonIndex = 0;
}

public function updateReasonText(claimIndex:int,reasonIndex:int):void{
	_reasonBox[claimIndex][reasonIndex].callReasonUpdate();
}