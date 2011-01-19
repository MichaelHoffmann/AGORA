// ActionScript file
import components.CustomLine;
import components.InferenceBox;

//An array of InferenceBoxes
private var _inferenceBox:Array;
//The array that holds the inference texts
private var _inferenceTextArray:Array;
//There exists an _inferencePresent array element for reach _claimBox array element. Indicates whether an inference is present or not
private var _inferencePresent:Array;

public function inferenceInit():void{
	_inferenceBox = new Array();
	_inferencePresent = new Array();
	_inferenceTextArray = new Array();
	_inferencePresent[_claimIndex] = false;
}

public function createNewInferenceBox(claimIndex:int,downLine:CustomLine,logicType:String,languageType:String,store:Boolean=true):void{
	_inferenceBox[claimIndex] = new InferenceBox();
	_inferenceBox[claimIndex].inferenceText = _inferenceTextArray[claimIndex];
	_inferenceBox[claimIndex].addx = -115;
	_inferenceBox[claimIndex].addy = downLine.height + 90;
	BindingUtils.bindProperty(_inferenceBox[claimIndex],"xpos",downLine,"x");
	BindingUtils.bindProperty(_inferenceBox[claimIndex],"ypos",downLine,"y");
	_inferenceBox[claimIndex].logicType = logicType;
	_inferenceBox[claimIndex].languageType = languageType;
	_inferenceBox[claimIndex].claimIndex = claimIndex;
	_inferenceBox[claimIndex].userID = _userID;
	this._inferencePresent[claimIndex] = true;	
	_inferenceBox[claimIndex].addEventListener("inferenceAccepted",inferenceAcceptEvent);
	if(store){
		_inferenceBox[claimIndex].callStoreInference();
	}	
	addChild(_inferenceBox[claimIndex]);
}

public function inferenceAcceptEvent(event:StatementAcceptEvent):void{
	var claimIndex:int = event.claimIndex;
	_inferenceTextArray[claimIndex]=event.statement;
	_inferenceBox[claimIndex].callInferenceUpdate();
	
	var inferenceProviderInstance:InferenceProvider = new InferenceProvider(_claimTextArray[claimIndex],_reasonTextArray[claimIndex],false,event.statement,true);
	
	_inferenceTextArray[claimIndex] = inferenceProviderInstance.getInferenceText(_selectedLogic[claimIndex],_selectedFunction[claimIndex]);
	var newClaimTextArray:Array = inferenceProviderInstance.claimText.split("It is not the case that ");
	if(newClaimTextArray[0]!=""){
		setClaimText(claimIndex,inferenceProviderInstance.claimText);
	}
	else{
		setClaimText(claimIndex,newClaimTextArray[1]);
	}
	
	var reasonTextArray:Array = ObjectUtil.copy(inferenceProviderInstance.reasonText) as Array;
	
	setClaimBoxText(claimIndex,inferenceProviderInstance.claimText);
	updateClaimText(claimIndex);
	
	for(var i:int =0;i<_reasonBox[claimIndex].length;i++){
		_reasonBox[claimIndex][i].setReason(reasonTextArray[i]);
		var newReasonText:Array = reasonTextArray[i].split("It is not the case that ");
		if(newReasonText[0]!=""){
			setReasonText(claimIndex,i,reasonTextArray[i]);
		}
		else{
			setReasonText(claimIndex,i,newReasonText[1]);
		}
		updateReasonText(claimIndex,i);
	}
}

public function setInferenceBoxText(claimIndex:int,inferenceText:String):void{
	_inferenceBox[claimIndex].setInference(_inferenceTextArray[claimIndex]);
}

public function setInferenceText(claimIndex:int,inferenceText:String):void{
	_inferenceBox[claimIndex].inferenceText = _inferenceTextArray[claimIndex];
}

public function setArgumentType(claimIndex:int,logicType:String,languageType:String):void{
	_inferenceBox[claimIndex].logicType = logicType;
	_inferenceBox[claimIndex].languageType = languageType;
}

public function updateInferenceText(claimIndex:int):void{
	_inferenceBox[claimIndex].callInferenceUpdate();
}