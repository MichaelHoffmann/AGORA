// ActionScript file
[Bindable]
private var _labelText:String;
[Bindable]
private var _xpos:int;
[Bindable]
private var _ypos:int;

private var _addx:int;
private var _addy:int;

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

public function set labelText(text:String):void{
	this._labelText = text;
}

