import events.StatementAcceptEvent;

import flash.events.MouseEvent;

import mx.binding.utils.BindingUtils;
import mx.controls.Alert;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;


[Bindable]
/*
Publicly exposed variable that can be used to pass the inference text to the component
*/
private var _inferenceText:String;

private var _claimIndex:int;
private var _userID:int;
private var _mapID:int;
private var _logicType:String;
private var _languageType:String;

[Bindable]
private var _xpos:int;
[Bindable]
private var _ypos:int;
private var _addx:int;
private var _addy:int;


public function set claimIndex(value:int):void{
	this._claimIndex = value;
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

public function set logicType(value:String):void{
	this._logicType = value;
}

public function get logicType():String{
	return this._logicType;
}

public function set languageType(value:String):void{
	this._languageType = value;
}

public function get languageType():String{
	return this._languageType;
}

public function set xpos(value:int):void{
	this._xpos = value;
	this.x = this._xpos+this._addx;
}

public function get xpos():int {
	return this._xpos;
}

public function set ypos(value:int):void{
	this._ypos = value;
	this.y = this._ypos+this._addy; 
}

public function get ypos():int{
	return this._ypos;
}

public function set addx(value:int):void{
	this._addx = value;
}

public function get addx():int{
	return this._addx;
}

public function set addy(value:int):void{
	this._addy = value;
}

public function get addy():int{
	return this._addy;
}

/*
Accepts user input on pressing enter
*/
public function init():void{
	this.setInference(_inferenceText);
    BindingUtils.bindProperty(done,"y",inference,"height");
}

public function checkForEnter(event:KeyboardEvent):void{
	if(event.keyCode==Keyboard.ENTER){
			_inferenceText = inference.text as String;
			var inferenceAcceptEvent:StatementAcceptEvent = new StatementAcceptEvent("inferenceAccepted",_inferenceText,_claimIndex);
			dispatchEvent(inferenceAcceptEvent);
	}
}

public function inferenceDone(event:MouseEvent):void{
		_inferenceText = inference.text as String;
		var inferenceAcceptEvent:StatementAcceptEvent = new StatementAcceptEvent("inferenceAccepted",_inferenceText,_claimIndex);
		dispatchEvent(inferenceAcceptEvent);
}
/*
Suppresses the default action of enter
*/
public function preventNewLine(event:TextEvent):void{
		if(event.text=="\n"){
			event.preventDefault();
		}
		
}
public function set inferenceText(inferenceText:String):void{
	this._inferenceText = inferenceText;
}
/*
Sets the inference
*/
public function setInference(inferenceText:String):void{
	inference.text = inferenceText;
}

public function onFault(event:FaultEvent):void{
	Alert.show("I am sorry, something went wrong. It's probably a bug in the code. Please notify me of the mistake so that it can be corrected","InferenceBox",Alert.OK);
}

public function storeInference(event:ResultEvent):void{
	
}

public function callInferenceUpdate():void{
	inferenceService.updateInference(this._inferenceText,this._claimIndex,	this._claimIndex,this._userID);
}

public function updateInference(event:ResultEvent):void{
	
}

public function callStoreInference():void{
	inferenceService.storeInference(this._inferenceText,this._claimIndex,this._logicType,this._languageType,this.x,this.y,this._claimIndex,this._userID);
}