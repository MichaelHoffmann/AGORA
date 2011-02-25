// ActionScript file
import classes.DynamicTextArea;

import events.StatementAcceptEvent;

import flash.events.MouseEvent;

import mx.binding.utils.BindingUtils;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.Label;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;


private var _reasonbox:DynamicTextArea;
private var _index:int;
private var _reasontext:String;
private var _claimIndex:int;
private var _userID:int;
private var _mapID:int;
private var _statementType:int;
 
[Bindable]
private var _xpos:int;
[Bindable]
private var _ypos:int;

private var _addx:int;
private var _addy:int;

private var _statementIndicator:Label;
private var _addButtonPosition:int;
private var _useButtonPosition:int;
private var _buttonPosition:int;
private var _addButton:Button;
private var _useButton:Button;

public function set buttonPosition(value:int):void{
	this._buttonPosition = value;
	done.y = this._buttonPosition+this._reasonbox.y;
}

public function set addButtonPosition(value:int):void{
	this._addButtonPosition = value;
	_addButton.y = this._addButtonPosition+this._reasonbox.y;
}

public function set useButtonPosition(value:int):void{
	this._useButtonPosition = value;
	_useButton.y = this._useButtonPosition+this._reasonbox.y;
}

public function get buttonPosition():int{
	return this._buttonPosition;
}

public function get addButtonPosition():int{
	return this._addButtonPosition;
}

public function get useButtonPosition():int{
	return this._useButtonPosition;
}

public function set claimIndex(value:int):void{
	this._claimIndex = value;
}

public function get claimIndex():int{
	return this._claimIndex;
}

public function set userID(value:int):void{
	this._userID = value;
}

public function get userID():int{
	return this._userID;
}

public function set mapID(value:int):void{
	this._mapID = value;
}

public function get mapID():int{
	return this.mapID;
}

public function set xpos(value:int):void{
	this._xpos = value;
	this.x = _xpos + _addx;
}

public function get xpos():int{
	return _xpos;
}

public function set ypos(value:int):void{
	this._ypos = value;
	this.y = _ypos + _addy;
}

public function set addy(value:int):void{
	this._addy = value;
}

public function get addy():int{
	return this._addy;
}

public function set addx(value:int):void{
	this._addx = value;
}

public function get addx():int{
	return this._addy;
}

public function set index(value:int):void{
	this._index = value;
}

public function get index():int{
	return this._index;
}

public function set reasontext(value:String):void{
	this._reasontext = value;
}

public function get reasontext():String{
	return this._reasontext;
}

public function get reasonbox():DynamicTextArea{
	return this._reasonbox;
}

public function init():void{
	_statementIndicator = new Label();
	_statementIndicator.x = 35;
	_statementIndicator.y = 0;
	addChild(_statementIndicator);
	_statementIndicator.text = "particular statement";
	_statementIndicator.toolTip = "Whether a statement is universal or particular determines what kind of objections are possible against it. A 'universal statement' is defined here as a statement that can be falsified by one counter-example. In this sense, laws, rules, and all statements that include 'ought' or 'should,' etc., are universal statements. Anything else is treated as a particular statement, including statements about possibilities.";
	_statementIndicator.addEventListener(MouseEvent.CLICK,changeType);
	_reasonbox = new DynamicTextArea();
	_index=0;
	_reasonbox.index = _index;
	_reasonbox.y = 25;
	setReasonBoxProperties(_reasonbox);
	addChild(_reasonbox);
	if(_reasontext==''){
		setReason("[Enter your reason]");
	}
	else{
		setReason(_reasontext);
	}
	BindingUtils.bindProperty(done,"x",_reasonbox,"x");
	BindingUtils.bindProperty(this,"buttonPosition",_reasonbox,"height");
	//done.addEventListener("click",callReasonAccept);
}


private function setReasonBoxProperties(reasonbox:DynamicTextArea):void{
	reasonbox.setStyle("borderThickness",2);
	reasonbox.setStyle("backgroundAlpha",0.6);
	reasonbox.wordWrap=true; 
	reasonbox.editable=true; 
	reasonbox.width=190;
	reasonbox.setStyle("textAlign","center");
	reasonbox.addEventListener("click",textBoxClicked);
	reasonbox.setStyle("fontWeight","normal"); 
	reasonbox.setStyle("fontSize","10"); 
	reasonbox.setStyle("fontFamily","Verdana"); 
	reasonbox.setStyle("backgroundColor","#D3D2D2"); 
	reasonbox.minHeight=65;
	reasonbox.height=65;
	_reasonbox.setStyle("paddingLeft","");
	_reasonbox.setStyle("paddingRight","");
	_reasonbox.setStyle("paddingTop","");
	reasonbox.setStyle("focusRoundedCorners","tr br tl bl");
	reasonbox.setStyle("cornerRadius","5");
	reasonbox.addEventListener("keyDown",checkForEnter);
	reasonbox.addEventListener("textInput",preventNewLine);
	reasonbox.setStyle("focusThickness",0);
}

private function setReasonBoxPropertiesUniversal():void{
	_reasonbox.setStyle("borderThickness",2);
	_reasonbox.setStyle("backgroundAlpha",0.6);
	_reasonbox.wordWrap=true; 
	_reasonbox.editable=true; 
	_reasonbox.width=190;
	_reasonbox.setStyle("textAlign","center");
	_reasonbox.addEventListener("click",textBoxClicked);
	_reasonbox.setStyle("fontWeight","normal"); 
	_reasonbox.setStyle("fontSize","10"); 
	_reasonbox.setStyle("fontFamily","Verdana"); 
	_reasonbox.setStyle("backgroundColor","#D3D2D2"); 
	_reasonbox.setStyle("paddingLeft","7");
	_reasonbox.setStyle("paddingRight","7");
	_reasonbox.setStyle("paddingTop","2");
	_reasonbox.minHeight=65;
	_reasonbox.setStyle("focusRoundedCorners","tr br tl bl");
	_reasonbox.setStyle("cornerRadius","75");
	_reasonbox.addEventListener("keyDown",checkForEnter);
	_reasonbox.addEventListener("textInput",preventNewLine);
	_reasonbox.setStyle("focusThickness",0);
}

private function acceptReason(event:ResultEvent):void{
	_addButton = new Button();
	
	removeChild(done);
	
	BindingUtils.bindProperty(_addButton,"x",_reasonbox,"x");
	BindingUtils.bindProperty(_addButton,"y",this,"buttonPosition");
	_addButton.setStyle("textRollOverColor","#0b333c");
	_addButton.setStyle("color","#B1B9BB");
	_addButton.setStyle("focusRoundedCorners","tr br tl bl");
   	_addButton.setStyle("cornerRadius",5);
	_addButton.label="add..." 
	_addButton.width=95;
	BindingUtils.bindProperty(this,"addButtonPosition",_reasonbox,"height");
	addChild(_addButton);
	
	_useButton = new Button();
	BindingUtils.bindProperty(_useButton,"x",_addButton,"width");
	BindingUtils.bindProperty(_useButton,"y",this,"buttonPosition");
	_useButton.setStyle("color","#B1B9BB");
	_useButton.setStyle("textRollOverColor","#0b333c") 
	_useButton.setStyle("focusRoundedCorners","tr br tl bl");
   	_useButton.setStyle("cornerRadius",5);
	_useButton.label="use as..." 
	_useButton.width=95;
	BindingUtils.bindProperty(this,"useButtonPosition",_reasonbox,"height");
	addChild(_useButton);
}

private function updateReason(event:ResultEvent):void{
	
}

private function displayReason(event:ResultEvent):void{
	
}

private function dispatchReasonEvent():void{
	var reasonAcceptEvent:StatementAcceptEvent = new StatementAcceptEvent("reasonAccepted",_reasontext,_claimIndex,_index);
	dispatchEvent(reasonAcceptEvent);
}
private function checkForEnter(event:KeyboardEvent):void{
	if(event.keyCode==Keyboard.ENTER){
		_reasontext = _reasonbox.text as String;
		dispatchReasonEvent();
	}
	if(_reasonbox.text=="[Enter your reason]"){
		_reasonbox.text="";
	}
}

/*				
private function addReason(event:MouseEvent):void{
	_reasontext= _reasonbox.text as String;
	reasonService.acceptReason(_reasontext,_index,_reasonbox.x,_reasonbox.y,1);	
	_index++;
	_reasonbox = new DynamicTextArea();
	_reasonbox.index = _index;
	_reasonbox.x = 0;
	_reasonbox[_index].y = _reasonbox[_index-1].y+_reasonbox[_index-1].height+25;
	setReasonBoxProperties(_reasonbox[_index]);
	addChild(_reasonbox[_index]);
	setReason("[Enter your reason]",_index);
	add.y = add.y+_reasonbox[_index].height+25;
	done.y = done.y+_reasonbox[_index].height+25;
}
*/
private function preventNewLine(event:TextEvent):void{
	if(event.text=="\n"){
		event.preventDefault();
	}
}
private function callReasonAccept(event:MouseEvent):void{
	_reasontext = _reasonbox.text;
	dispatchReasonEvent();
}
private function textBoxClicked(event:MouseEvent):void{
	if(_reasonbox.text == "[Enter your reason]"){
		this.setReason("");
	}
}


public function setReason(text:String):void{
	_reasonbox.text = text;
}

private function onFault(event:FaultEvent):void{
	Alert.show("Sorry, something went wrong. It's probably a bug in the code. Please notify me of the error.");
}

public function callReasonUpdate():void{
	reasonService.updateReason(this._reasontext,this._index,this._claimIndex,this._userID);
}

public function callAcceptReason():void{
	reasonService.acceptReason(_reasontext,_index,this.x,this.y,_userID,_claimIndex);
}

public function makeParticular():void{
	this._statementType = 0;
	this.setReasonBoxProperties(_reasonbox);
}

public function makeUniversal():void{
	this._statementType = 1;
	this.setReasonBoxPropertiesUniversal();
}

public function changeType(event:MouseEvent):void{
	if(this._statementType == 1){
		this.makeParticular();
		_statementIndicator.text = "particular statement";
	}
	else{
		this.makeUniversal();
		_statementIndicator.text = "universal statement";
	}
	
}