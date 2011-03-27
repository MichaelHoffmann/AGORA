// ActionScript file
import classes.DynamicTextArea;

import components.Node1;

import events.AddReasonEvent;

import flash.events.MouseEvent;

import mx.binding.utils.BindingUtils;
import mx.controls.Alert;
import mx.controls.Button;
import mx.core.UIComponent;

[Bindable]
private var _node:DynamicTextArea;
private var _nodeType:String; //"claim","reason" or "argument"
private var _nodeText:String;
private var _userID:int;
private var _mapID:int;
private var _nodeIndex:int;
//private var _addButtonPosition:int;
//private var _useButtonPosition:int;
[Bindable]
private var _buttonPosition:int;
[Bindable]
private var _xpos:int;
[Bindable]
private var _ypos:int;
private var _addx:int;
private var _addy:int;
private var temp:UIComponent;
private var _button:Button;

public function get node():DynamicTextArea{
	//var tempnode:DynamicTextArea = new DynamicTextArea();
	//return tempnode;
	return this._node;
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

public function get ypos():int{
	return _ypos;
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

public function set nodeText(value:String):void{
	this._nodeText=value;
}

public function get nodeText():String{
	return this._nodeText;
}

public function init():void
{
	_node = new DynamicTextArea();
	//_node = new Array();
	//_node = new Node1();
	_node.x=0;
	_node.y=30;
	_nodeText = new String;
	_node.width = 200;
	addElement(_node);
	if(_nodeText=='')
		setNodeText("[Enter your claim/reasoning]");
	else
		setNodeText(_nodeText);
	_node.addEventListener("click",textBoxClicked);

}

public function setNodeText(mytext:String):void
{
	_node.text =  mytext;
}

public function textBoxClicked(event:MouseEvent):void{
	if(_node.text == "[Enter your claim/reasoning]"){
		this.setNodeText("");
	}
}

public function addReason_clickHandler(event:MouseEvent):void
{
	/*temp = new UIComponent;
	temp.graphics.beginFill(0x000000);
	temp.drawRoundRect(100,100,200,200);
	temp.graphics.endFill();
	addElement(temp);*/
	
	var eventObject:AddReasonEvent = new AddReasonEvent("addReason");
	dispatchEvent(eventObject);
	
}

public function addClaim_clickHandler(event:MouseEvent):void
{
	Alert.show("Adding claim");
	init();
	//addReason.visible=true;
}

public function addArg_clickHandler(event:MouseEvent):void
{
	Alert.show('To add an argument');
}