// ActionScript file


import classes.InferenceProvider;

import components.ArgScheme;
import components.CustomLine;
import components.PromptLabel;
import components.SchemeSelector;
import components.StatementPrompt;

import events.SchemeSelectedEvent;
import events.StatementClassifierEvent;

import mx.binding.utils.BindingUtils;
import mx.controls.Alert;
import mx.rpc.events.FaultEvent;
import mx.utils.ObjectUtil;

private var statementPromptInstance:StatementPrompt = new StatementPrompt();

public function startWithClaim():void{
	claimStart.visible = false;
	conceptStart.visible = false;
	schemeStart.visible = false;
	argumentPaste.visible = false;
	taskPrompt.visible = false;
	
	_userID=1;
	
	this.claimInit();
	this.reasonInit();
	this.inferenceInit();
	
	_argScheme = new Array();
	_schemeSelector = new SchemeSelector();
	_schemeSelector.claimStart = true;
	_therefore = new Array;
	_selectedLogic = new Array;
	_selectedFunction = new Array;
	
	_therefore[_claimIndex] = new PromptLabel();
	_therefore[_claimIndex].labelText = "therefore";
	_schemeComplete = true;
}

private function schemeSelectEvent(event:SchemeSelectedEvent):void{
	var claimIndex:int = event.claimIndex;
	if(!(_inferencePresent[claimIndex])){
		var inferenceProviderInstance:InferenceProvider = new InferenceProvider(_claimTextArray[_claimIndex],_reasonTextArray[_claimIndex]);
		_selectedLogic[_claimIndex]=event.logicType;
		_selectedFunction[_claimIndex]=event.languageType;
		_inferenceTextArray[_claimIndex]  = inferenceProviderInstance.getInferenceText(event.logicType,event.languageType);
		
		setClaimBoxText(_claimIndex,inferenceProviderInstance.claimText);
		setReasonBoxText(_claimIndex,inferenceProviderInstance.reasonText);

		_argScheme[_claimIndex] = new ArgScheme();
		_argScheme[_claimIndex].inferenceIndex = _claimIndex;
		_argScheme[_claimIndex].argText = "ArgScheme:\n" + event.logicType;
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
		
		createNewInferenceBox(_claimIndex,downLine,event.logicType,event.languageType);
		
		this._reversePos[_claimIndex] = inferenceProviderInstance.reversePos;
		removeChild(_schemeSelector);				
		removeChild(_promptLabel);
	}
	else{
		inferenceProviderInstance = new InferenceProvider(_claimTextArray[claimIndex],_reasonTextArray[claimIndex],_reversePos[claimIndex]);
		_selectedLogic[claimIndex] = event.logicType;
		_selectedFunction[claimIndex] = event.languageType;
		_inferenceTextArray[claimIndex]  = inferenceProviderInstance.getInferenceText(event.logicType,event.languageType);
		
		setClaimBoxText(claimIndex,inferenceProviderInstance.claimText);
		setReasonBoxText(claimIndex, ObjectUtil.copy(inferenceProviderInstance.reasonText) as Array);
		
		for(var reasonIndex:int=0;reasonIndex<inferenceProviderInstance.reasonText.length;reasonIndex++){
			var newReasonText:Array = inferenceProviderInstance.reasonText[reasonIndex].split("It is not the case that ");
			
			if(newReasonText[0]!=''){
				_reasonTextArray[claimIndex][reasonIndex] = inferenceProviderInstance.reasonText;
			}
			else{
				_reasonTextArray[claimIndex][reasonIndex] = newReasonText[1];
			}
			
			_reasonBox[claimIndex][reasonIndex].reasontext = _reasonTextArray[claimIndex][reasonIndex];
			_reasonBox[claimIndex][reasonIndex].callReasonUpdate();
		}
		
		var claimText:String = inferenceProviderInstance.claimText;
		var newClaimText:Array = claimText.split("It is not the case that ");
		if(newClaimText[0]!=""){
			_claimTextArray[claimIndex] = inferenceProviderInstance.claimText;
		}
		else{
			_claimTextArray[claimIndex] = newClaimText[1];
		}
		_claimBox[claimIndex].claimtext = _claimTextArray[claimIndex];
		_claimBox[claimIndex].callClaimUpdate();
		_argScheme[claimIndex].argText = "ArgScheme:\n" + event.logicType;
		_argScheme[claimIndex].setArgumentText("ArgScheme:\n" + event.logicType);
		
		setInferenceBoxText(claimIndex,_inferenceTextArray[claimIndex]);
		setInferenceText(claimIndex,_inferenceTextArray[claimIndex]);
		this._reversePos[claimIndex] = inferenceProviderInstance.reversePos;
		updateInferenceText(claimIndex);
		
		removeChild(_schemeSelector);
		
	}
}

public function onFault(event:FaultEvent):void{
	Alert.show("I am sorry, something went wrong. It's probably a bug in the code, so please notify me of what the error was, and what induced it","Error!",Alert.OK);
}

public function classifyClaim(event:StatementClassifierEvent):void{
	if(event.statementType==1){
		_claimBox[event.claimIndex].makeParticular();
	}
	else{
		_claimBox[event.claimIndex].makeUniversal();
	}
	
	statementPromptInstance.promptText = "Is your reason a particular statement or a universal statement?";
	statementPromptInstance.setPrompt();
	statementPromptInstance.removeEventListener("statementClassified",classifyClaim);
	statementPromptInstance.addEventListener("statementClassified",classifyReason);
}

public function classifyReason(event:StatementClassifierEvent):void{
	if(event.statementType==0){
		_reasonBox[_claimIndex][_reasonIndex].makeUniversal();
	}
	else{
		_reasonBox[_claimIndex][_reasonIndex].makeParticular();
	}
	removeChild(statementPromptInstance);
}