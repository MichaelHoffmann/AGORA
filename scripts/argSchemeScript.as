
import events.SchemeChangeEvent;

import flash.events.MouseEvent;
[Bindable]
private var _argText:String;
private var _inferenceIndex:int;
private var _addx:int;
private var _addy:int;
private var _xpos:int;
private var _ypos:int;


public function set xpos(value:int):void{
	this._xpos = value;
	this.x = _xpos+_addx;
}

public function get xpos():int{
	return this._xpos;
}

public function set ypos(value:int):void{
	this._ypos = value;
	this.y = _ypos+_addy;
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
	return addy;
}
public function init():void{
	argumentScheme.text = _argText;
}

public function set argText(argText:String):void{
	this._argText = argText;
}

public function get argText():String{
	return this._argText;
}

public function set inferenceIndex(inferenceIndex:int):void{
	this._inferenceIndex = inferenceIndex;
}

public function callChangeScheme(event:MouseEvent):void{
	var schemeChangeEvent:SchemeChangeEvent = new SchemeChangeEvent("changeScheme",_inferenceIndex);;
	dispatchEvent(schemeChangeEvent);
}

public function setArgumentText(argText:String):void{
	argumentScheme.text = argText;
}