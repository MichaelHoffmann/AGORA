// ActionScript file
import flash.display.Shape;


[Bindable]
private var _xpos:int;
[Bindable]
private var _ypos:int;

private var _addx:int;
private var _addy:int;

private var _linex:int;
private var _liney:int;

private var _leftLine:Shape;
public function set xpos(value:int):void{
	this._xpos = value;
	this.x = _xpos+_addx;
	drawLine();
}

public function get xpos():int {
	return this._xpos;
}

public function set ypos(value:int):void{
	this._ypos = value;
	this.y = _ypos+_addy;
	drawLine(); 
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

public function set linex(value:int):void{
	this._linex = value;
}

public function get linex():int{
	return this._linex;
}

public function set liney(value:int):void{
	this._liney = value;
}

public function get liney():int{
	return this._addy;
}

public function init():void{
	_leftLine = new Shape();
	_leftLine.graphics.lineStyle(2,734012,0.4);
	_leftLine.graphics.moveTo(0,0);
	_leftLine.graphics.lineTo(_linex,_liney);
	this.rawChildren.addChild(_leftLine);
}

public function drawLine():void{
	//_leftLine.graphics.lineTo(_addx,_addy);
}