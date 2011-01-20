// ActionScript file
import components.ClaimBox;
import components.CustomImage;

import events.StatementAcceptEvent;
//An array of ClaimBoxes
private var _claimBox:Array;
//The array that holds the claim texts
private var _claimTextArray:Array;
//The index of the current claim
private var _claimIndex:int;


public function claimInit():void{
	_claimBox = new Array();
	_claimTextArray = new Array();
	_claimIndex = 0;
	_promptLabel = new PromptLabel();
	_promptLabel.labelText = "What is your claim?";
	_promptLabel.x = 35;
	_promptLabel.y = 5;
	addChild(_promptLabel);
	_claimBox[_claimIndex] = new ClaimBox();
	_claimBox[_claimIndex].claimIndex = _claimIndex;
	_claimBox[_claimIndex].x = 10;
	_claimBox[_claimIndex].y = 25;
	_claimBox[_claimIndex].userID = _userID;
	_claimBox[_claimIndex].addEventListener("claimAccepted",claimAcceptEvent);
	addChild(_claimBox[_claimIndex]);
	_claimBox[_claimIndex].init();
}

private function claimAcceptEvent(event:StatementAcceptEvent):void{
	var claimIndex:int = event.claimIndex;
	if(!(_inferencePresent[claimIndex])){
		_claimBox[claimIndex].callAcceptClaim();
		_claimTextArray[claimIndex] = event.statement;
		
		//The following lines of code create the left arrow and bind it to the claimbox position
		var leftArrow:CustomImage = new CustomImage();
		leftArrow.imageSource = "images/left-arrow.png";
		leftArrow.addx = _claimBox[claimIndex].width;
		leftArrow.addy = (_claimBox[claimIndex].height/2) - 10;
		BindingUtils.bindProperty(leftArrow,"xpos",_claimBox[claimIndex],"x");
		BindingUtils.bindProperty(leftArrow,"ypos",_claimBox[claimIndex],"y");
		addChild(leftArrow);
		
		//The following lines of code create the therefore label and bind it to the left arrow's position
		_therefore[claimIndex].addx = 85;
		_therefore[claimIndex].addy = 2;
		BindingUtils.bindProperty(_therefore[claimIndex],"xpos",leftArrow,"x");
		BindingUtils.bindProperty(_therefore[claimIndex],"ypos",leftArrow,"y");
		addChild(_therefore[claimIndex]);
		
		//The following lines of code create the leftline and bind it to therefore's position
		var leftLine:CustomLine = new CustomLine();
		leftLine.addx = 72;
		leftLine.addy = 8;
		leftLine.linex = 85;
		leftLine.liney = 0;
		BindingUtils.bindProperty(leftLine,"xpos",_therefore[claimIndex],"x");
		BindingUtils.bindProperty(leftLine,"ypos",_therefore[claimIndex],"y");
		addChild(leftLine);
		clearReasonIndex();
		createNewReasonBox(claimIndex,leftLine);
	}
	else{
		var claimText:String = event.statement;
		var newClaimText:Array = claimText.split("It is not the case that ");
		if(newClaimText[0]!=""){
			_claimTextArray[claimIndex] = event.statement;
		}
		else{
			_claimTextArray[claimIndex] = newClaimText[1];
		}
		_claimBox[claimIndex].claimtext = _claimTextArray[claimIndex];
		_claimBox[claimIndex].callClaimUpdate();
		
		var inferenceProviderInstance:InferenceProvider = new InferenceProvider(_claimTextArray[claimIndex],_reasonTextArray[claimIndex],_reversePos[claimIndex]);
		_inferenceTextArray[claimIndex]  = inferenceProviderInstance.getInferenceText(_selectedLogic[claimIndex],_selectedFunction[claimIndex]);
		
		_claimBox[claimIndex].setClaim(inferenceProviderInstance.claimText);
		
		setReasonBoxText(claimIndex,inferenceProviderInstance.reasonText);
		
		
		setInferenceBoxText(claimIndex,_inferenceTextArray[claimIndex]);
		setInferenceText(claimIndex,_inferenceTextArray[claimIndex]);
		updateInferenceText(claimIndex);
	}	
}

public function setClaimBoxText(claimIndex:int,claimText:String):void{
	_claimBox[claimIndex].setClaim(claimText);
}

public function updateClaimText(claimIndex:int):void{
	_claimBox[claimIndex].callClaimUpdate();
}

public function setClaimText(claimIndex:int,claimText:String):void{
	_claimTextArray[claimIndex] = claimText;
	_claimBox[claimIndex].claimtext = claimText;
}