// ActionScript file
import components.PromptLabel;
import components.SchemeSelector;
import components.StatementPrompt;

import events.SchemeSelectedEvent;

import mx.events.FlexEvent;

public var _schemeComplete:Boolean = false;
public function startWithScheme():void{
	claimStart.visible = false;
	conceptStart.visible = false;
	schemeStart.visible = false;
	argumentPaste.visible = false;
	taskPrompt.visible = false;
	
	_promptLabel = new PromptLabel();
	
	statementPromptInstance = new StatementPrompt();
	_claimIndex = 0;
	_therefore = new Array;
	_selectedLogic = new Array;
	_selectedFunction = new Array;
	_argScheme = new Array;
	_userID=1;
	_schemeSelector = new SchemeSelector();
	_schemeSelector.x = 450;
	_schemeSelector.y = 210;
	_schemeSelector.claimStart = false;
	_schemeSelector.claimIndex = _claimIndex;
	_schemeSelector.addEventListener("schemeRollOver",rollOverSchemeEvent);
	_schemeSelector.addEventListener("schemeAccepted",acceptScheme);
	addChild(_schemeSelector);
	
	
	this.claimInit();
	
	_claimBox[_claimIndex].addEventListener(FlexEvent.CREATION_COMPLETE,completeArgument);
	
	
}

public function completeArgument(event:FlexEvent):void{
	var leftArrow:CustomImage = new CustomImage();
	leftArrow.imageSource = "images/left-arrow.png";
	leftArrow.addx = _claimBox[_claimIndex].width;
	leftArrow.addy = (_claimBox[_claimIndex].height/2) - 10;
	BindingUtils.bindProperty(leftArrow,"xpos",_claimBox[_claimIndex],"x");
	BindingUtils.bindProperty(leftArrow,"ypos",_claimBox[_claimIndex],"y");
	addChild(leftArrow);
	
	_therefore[_claimIndex] = new PromptLabel();
	_therefore[_claimIndex].addx = 85;
	_therefore[_claimIndex].addy = 2;
	_therefore[_claimIndex].labelText = "therefore";
	
	BindingUtils.bindProperty(_therefore[_claimIndex],"xpos",leftArrow,"x");
	BindingUtils.bindProperty(_therefore[_claimIndex],"ypos",leftArrow,"y");
	addChild(_therefore[_claimIndex]);

	//The following lines of code create the leftline and bind it to therefore's position
	var leftLine:CustomLine = new CustomLine();
	leftLine.addx = 72;
	leftLine.addy = 8;
	leftLine.linex = 85;
	leftLine.liney = 0;
	BindingUtils.bindProperty(leftLine,"xpos",_therefore[_claimIndex],"x");
	BindingUtils.bindProperty(leftLine,"ypos",_therefore[_claimIndex],"y");
	leftLine.init();
	addChild(leftLine);
	
	this.reasonInit();
	clearReasonIndex();
	this.inferenceInit();

	createNewReasonBox(_claimIndex,leftLine);
	
	_argScheme[_claimIndex] = new ArgScheme();
	_argScheme[_claimIndex].inferenceIndex = _claimIndex;
	_argScheme[_claimIndex].argText = "ArgScheme:\n";
	_argScheme[_claimIndex].addx = -45;
	_argScheme[_claimIndex].addy = 15;
	_argScheme[_claimIndex].addEventListener("changeScheme",changeSchemeEvent);
	BindingUtils.bindProperty(_argScheme[_claimIndex],"xpos",_therefore[_claimIndex],"x");
	BindingUtils.bindProperty(_argScheme[_claimIndex],"ypos",_therefore[_claimIndex],"y");
	addChild(_argScheme[_claimIndex]);
	
	var downLine:CustomLine = new CustomLine();
	downLine.addx = _claimBox[_claimIndex].width+120;
	downLine.addy = _claimBox[_claimIndex].height/2 + 40;
	downLine.linex = 0;
	downLine.liney = 85;
	BindingUtils.bindProperty(downLine,"xpos",_claimBox[_claimIndex],"x");
	BindingUtils.bindProperty(downLine,"ypos",_claimBox[_claimIndex],"y");
	addChild(downLine);
	
	createNewInferenceBox(_claimIndex,downLine,_selectedLogic[_claimIndex],_selectedFunction[_claimIndex],false);
	_promptLabel.labelText = "Roll over the schemes and select a language form. It is usually best to start with the formulation of the inference rule\n" + "(in the text box at the bottom) by overwriting the \"P\" and \"Q\" with your own propositions. You can change the argument\n scheme any time by clicking on \"ArgScheme\"";
	_promptLabel.y = 150;
	_promptLabel.x = _promptLabel.x - 20;
	

}
public function rollOverSchemeEvent(event:SchemeSelectedEvent):void{
	
	var claimIndex:int = _claimIndex;
	_selectedLogic[claimIndex] = event.logicType;
	_selectedFunction[claimIndex] = event.languageType;

	_argScheme[_claimIndex].setArgumentText("ArgScheme:\n"+event.logicType);
		
	var inferenceProviderInstance:InferenceProvider = new InferenceProvider(_claimTextArray[_claimIndex],_reasonTextArray[_claimIndex],false,event.languageForm,true);
	_inferenceTextArray[_claimIndex]  = inferenceProviderInstance.getInferenceText(_selectedLogic[_claimIndex],_selectedFunction[_claimIndex]);
	setInferenceBoxText(claimIndex,_inferenceTextArray[_claimIndex]);
	var newClaimTextArray:Array = inferenceProviderInstance.claimText.split("It is not the case that ");
	if(newClaimTextArray[0]!=""){
		setClaimText(claimIndex,inferenceProviderInstance.claimText);
		_claimTextArray[claimIndex ] = inferenceProviderInstance.claimText
	}
	else{
		setClaimText(claimIndex,newClaimTextArray[1]);
		_claimTextArray[claimIndex ] = newClaimTextArray[1];
	}
	
	var reasonTextArray:Array = ObjectUtil.copy(inferenceProviderInstance.reasonText) as Array;
	
	setClaimBoxText(claimIndex,inferenceProviderInstance.claimText);
	setReasonBoxText(claimIndex,reasonTextArray);
	for(var i:int =0;i<_reasonBox[claimIndex].length;i++){
		//_reasonBox[claimIndex][i].setReason(reasonTextArray[i]);
		var newReasonText:Array = reasonTextArray[i].split("It is not the case that ");
		if(newReasonText[0]!=""){
			setReasonText(claimIndex,i,reasonTextArray[i]);
			_reasonTextArray[claimIndex][i] = reasonTextArray[i];
		}
		else{
			setReasonText(claimIndex,i,newReasonText[1]);
			_reasonTextArray[claimIndex][i] = newReasonText[1];
		}
	}
}

public function acceptScheme(event:SchemeSelectedEvent):void{
	
	var claimIndex:int = event.claimIndex;
	_selectedLogic[claimIndex] = event.logicType;
	_selectedFunction[claimIndex] = event.languageType;
		
	//The following lines of code create the therefore label and bind it to the left arrow's position
	
	
		
	var inferenceProviderInstance:InferenceProvider = new InferenceProvider(_claimTextArray[_claimIndex],_reasonTextArray[_claimIndex],false,event.languageForm,true);
	_inferenceTextArray[_claimIndex]  = inferenceProviderInstance.getInferenceText(_selectedLogic[_claimIndex],_selectedFunction[_claimIndex]);
	setInferenceBoxText(claimIndex,_inferenceTextArray[_claimIndex]);
	var newClaimTextArray:Array = inferenceProviderInstance.claimText.split("It is not the case that ");
	if(newClaimTextArray[0]!=""){
		setClaimText(claimIndex,inferenceProviderInstance.claimText);
		_claimTextArray[claimIndex ] = inferenceProviderInstance.claimText
		
	}
	else{
		setClaimText(claimIndex,newClaimTextArray[1]);
		_claimTextArray[claimIndex ] = newClaimTextArray[1];
	}
	
	var reasonTextArray:Array = ObjectUtil.copy(inferenceProviderInstance.reasonText) as Array;
	
	setClaimBoxText(claimIndex,inferenceProviderInstance.claimText);
	setReasonBoxText(claimIndex,reasonTextArray);
	for(var i:int =0;i<_reasonBox[claimIndex].length;i++){
		var newReasonText:Array = reasonTextArray[i].split("It is not the case that ");
		if(newReasonText[0]!=""){
			setReasonText(claimIndex,i,reasonTextArray[i]);
			_reasonTextArray[claimIndex][i] = reasonTextArray[i];
		}
		else{
			setReasonText(claimIndex,i,newReasonText[1]);
			_reasonTextArray[claimIndex][i] = newReasonText[1];
		}
	}
	_promptLabel.visible = false;
	_inferenceBox[claimIndex].claimIndex = claimIndex;
	_inferenceBox[claimIndex].logicType = event.logicType;
	_inferenceBox[claimIndex].languageType = event.languageType;
	_inferenceBox[claimIndex].userID = this._userID;
	this._reversePos[claimIndex] = inferenceProviderInstance.reversePos;
	_schemeSelector.removeEventListener("schemeAccepted",acceptScheme);
	_schemeSelector.removeEventListener("schemeRollOver",rollOverSchemeEvent);
	_schemeSelector.addEventListener("schemeAccepted", schemeSelectEvent);
	removeChild(_schemeSelector);

	
	_claimBox[claimIndex].callAcceptClaim();
	_reasonBox[claimIndex][0].callAcceptReason();
	_inferenceBox[claimIndex].callStoreInference();
}
