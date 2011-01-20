// ActionScript file
import events.StatementClassifierEvent;

import flash.events.MouseEvent;

import mx.controls.Alert;


private var _type:int;
private var _promptText:String;
private var _claimIndex:int;
private var _reasonIndex:int;

public function init():void{
	prompt.text = this._promptText;
}
public function set type(value:int):void{
	this._type = value;
}

public function get type():int{
	return this._type;
}

public function set promptText(value:String):void{
	this._promptText = value;
}

public function get promptText():String{
	return this._promptText;
}

public function set claimIndex(value:int):void{
	this._claimIndex = value;
}

public function get claimIndex():int{
	return this._claimIndex;
}

public function set reasonIndex(value:int):void{
	this._reasonIndex = value;
}

public function get reasonIndex():int{
	return this._reasonIndex;
}
public function selectUniversal(event:MouseEvent):void{
	this._type = 0;
	var statementClassifiedEvent:StatementClassifierEvent = new StatementClassifierEvent("statementClassified",this._type,this._claimIndex, this._reasonIndex);
	dispatchEvent(statementClassifiedEvent);
}

public function selectParticular(event:MouseEvent):void{
	this._type = 1;
	var statementClassifiedEvent:StatementClassifierEvent = new StatementClassifierEvent("statementClassified",this._type,this._claimIndex,this._reasonIndex);
	dispatchEvent(statementClassifiedEvent);
}

public function selectHelp(event:MouseEvent):void{
	Alert.show("Whether a statement is universal or particular determines what kind of objections are possible against it. A 'universal statement' is defined here as a statement that can be falsified by one counter-example. In this sense, laws, rules, and all statements that include 'ought' or 'should,' etc., are universal statements. Anything else is treated as a particular statement, including statements about possibilities.");
}

public function setPrompt():void{
	prompt.text = this._promptText;
}