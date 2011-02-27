import classes.DynamicTextArea;

import events.StatementAcceptEvent;

import flash.events.MouseEvent;

import mx.binding.utils.BindingUtils;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.Label;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

/**
 * The variable that holds the claimbox 
 */
private var _claimbox:DynamicTextArea;
/**
 * The variable that holds the claimtext 
 */
private var _claimtext:String;
private var _userID:int;
private var _mapID:int;
private var _claimIndex:int;
private var _statementType:int;
private var _statementIndicator:Label;
private var _addButtonPosition:int;
private var _useButtonPosition:int;
[Bindable]
private var _buttonPosition:int;
[Bindable]
private var _addButton:Button;
[Bindable]
private var _useButton:Button;
private var _claimAccepted:Boolean;

public function get claimbox():DynamicTextArea{
	return this._claimbox;
}
public function set buttonPosition(value:int):void{
	this._buttonPosition = value;
	done.y = this._buttonPosition+this._claimbox.y;
}

public function set addButtonPosition(value:int):void{
	this._addButtonPosition = value;
	_addButton.y = this._addButtonPosition+this._claimbox.y;
}

public function set useButtonPosition(value:int):void{
	this._useButtonPosition = value;
	_useButton.y = this._useButtonPosition+this._claimbox.y;
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


public function set claimtext(value:String):void{
	this._claimtext = value;
}

public function get claimtext():String{
	return this._claimtext;
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

public function set claimIndex(value:int):void{
	this._claimIndex = value;
}

public function get claimIndex():int{
	return this._claimIndex;
}

/**
 * This is the initialization function that creates a new instance of DynamicTextArea and places the claimbox on the Canvas 
 * 
 */ 
public function init():void{
	/*var prompt:DynamicTextArea = new DynamicTextArea();
	prompt.x = 30;
	prompt.y = 0;
	addChild(prompt);
	prompt.text = "particular statement";
	prompt.setStyle("borderThickness",0);
	prompt.height = 10;
	prompt.addEventListener("click",changeType);*/
	this._claimAccepted = false;
	_statementIndicator = new Label();
	_statementIndicator.x = 30;
	_statementIndicator.y = 0;
	addChild(_statementIndicator);
	_statementIndicator.text = "particular statement";
	_statementIndicator.toolTip = "Whether a statement is universal or particular determines what kind of objections are possible against it. A 'universal statement' is defined here as a statement that can be falsified by one counter-example. In this sense, laws, rules, and all statements that include 'ought' or 'should,' etc., are universal statements. Anything else is treated as a particular statement, including statements about possibilities.";
	_statementIndicator.addEventListener(MouseEvent.CLICK,changeType);
	
	_claimtext = new String;
	_claimbox=new DynamicTextArea();
	_claimbox.x = 0;
	_claimbox.y = 25;
	setClaimBoxProperties(_claimbox);
	addChild(_claimbox);
	if(_claimtext==''){
		setClaim("[Enter your Claim]");
	}
	else{
		setClaim(_claimtext);
	}
	BindingUtils.bindProperty(this,"buttonPosition",_claimbox,"height"); //to automatically get where to place button from where the claimbox is rendered.
	//instead, the buttons can be included in the custom component structure and placed relatively
	
}

/**
 * This function sets all the properties of the claimbox, so that it becomes visually appealing, and also to 
 * set the event handlers for the click and enter events
 * @param claimbox The claimbox to set the properties for
 * 
 */
private function setClaimBoxProperties(claimbox:DynamicTextArea):void{
	claimbox.setStyle("borderThickness",2);
	claimbox.setStyle("backgroundAlpha",0.6);
	claimbox.wordWrap=true; 
	claimbox.editable=true; 
	claimbox.width=190;
	claimbox.setStyle("textAlign","center");
	claimbox.addEventListener("click",textBoxClicked);
	claimbox.setStyle("fontWeight","normal"); 
	claimbox.setStyle("fontSize","10"); 
	claimbox.setStyle("fontFamily","Verdana"); 
	claimbox.setStyle("backgroundColor","#D3D2D2"); 
	claimbox.minHeight=65;
	claimbox.height=65;
	claimbox.setStyle("paddingLeft","");
	claimbox.setStyle("paddingRight","");
	claimbox.setStyle("paddingTop","");
	claimbox.setStyle("focusRoundedCorners","tr br tl bl");
	claimbox.setStyle("cornerRadius","5");
	claimbox.addEventListener("keyDown",checkForEnter);
	claimbox.addEventListener("textInput",preventNewLine);
	claimbox.setStyle("focusThickness",0);
}

private function setClaimBoxPropertiesUniversal():void{
	_claimbox.setStyle("borderThickness",2);
	_claimbox.setStyle("backgroundAlpha",0.6);
	_claimbox.wordWrap=true; 
	_claimbox.editable=true; 
	_claimbox.width=190;
	_claimbox.setStyle("textAlign","center");
	_claimbox.addEventListener("click",textBoxClicked);
	_claimbox.setStyle("fontWeight","normal"); 
	_claimbox.setStyle("fontSize","10"); 
	_claimbox.setStyle("fontFamily","Verdana"); 
	_claimbox.setStyle("backgroundColor","#D3D2D2"); 
	_claimbox.setStyle("paddingLeft","7");
	_claimbox.setStyle("paddingRight","7");
	_claimbox.setStyle("paddingTop","");
	_claimbox.minHeight=65;
	_claimbox.setStyle("focusRoundedCorners","tr br tl bl");
	_claimbox.setStyle("cornerRadius","75");
	_claimbox.addEventListener("keyDown",checkForEnter);
	_claimbox.addEventListener("textInput",preventNewLine);
	_claimbox.setStyle("focusThickness",0);
}

/**
 * Respoonds to the button click event on "Done" and calls acceptClaim 
 * @param event The Click event
 * 
 */
public function callClaimAccept(event:MouseEvent):void{
	_claimtext = _claimbox.text;
	Alert.show("1.inside callClaimAccept");
	dispatchClaimEvent();
}

/**
 * This function is set as the event handler for the ResultEvent that is fired when the RemoteObject call is executed.
 * It adds two new buttons, "add" and "use as" to the claimbox, and removes the "Done" button 
 * @param event The ResultEvent
 * 
 */
private function acceptClaim(event:ResultEvent):void{
	Alert.show("5.inside acceptClaim finally");
	_addButton = new Button();
	
	removeChild(done);
	this._claimAccepted = true;
	
	BindingUtils.bindProperty(_addButton,"x",claimbox,"x");
	BindingUtils.bindProperty(_addButton,"y",this,"buttonPosition");
	_addButton.setStyle("textRollOverColor","#0b333c");
	_addButton.setStyle("color","#B1B9BB");
	_addButton.setStyle("focusRoundedCorners","tr br tl bl");
   	_addButton.setStyle("cornerRadius",5);
	_addButton.label="add reason" 
	_addButton.width=95;
	BindingUtils.bindProperty(this,"addButtonPosition",_claimbox,"height");
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
	BindingUtils.bindProperty(this,"useButtonPosition",_claimbox,"height");
	addChild(_useButton);
}

/**
 * This function is fired when a claim is already present, but is updated at a later point of time by the user 
 * @param event ResultEvent
 * 
 */
public function updateClaim(event:ResultEvent):void{
	if(!(this._claimAccepted)){
		_addButton = new Button();
		
		removeChild(done);
		this._claimAccepted = true;
		BindingUtils.bindProperty(_addButton,"x",_claimbox,"x");
		BindingUtils.bindProperty(_addButton,"y",this,"buttonPosition");
		_addButton.setStyle("textRollOverColor","#0b333c");
		_addButton.setStyle("color","#B1B9BB");
		_addButton.setStyle("focusRoundedCorners","tr br tl bl");
	   	_addButton.setStyle("cornerRadius",5);
		_addButton.label="add reason" 
		_addButton.width=95;
		BindingUtils.bindProperty(this,"addButtonPosition",_claimbox,"height");
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
		BindingUtils.bindProperty(this,"useButtonPosition",_claimbox,"height");
		addChild(_useButton);
	}
}

/**
 * This function is fired when the argument map is loading, and the saved claim has to be displayed  
 * @param event
 * 
 */
public function displayClaim(event:ResultEvent):void{
	
}

/**
 * This function dispatches the "claimAccepted" event to the main application, so that the application can respond accordingly. *  
 * 
 */
public function dispatchClaimEvent():void{
	var claimAcceptEvent:StatementAcceptEvent = new StatementAcceptEvent("claimAccepted",_claimtext,_claimIndex);
	Alert.show("2.inside dispatchClaimEvent");
	dispatchEvent(claimAcceptEvent);
}
/**
 * This function is fired when the user presses "Enter" on the keyboard. 
 * @param event
 * 
 */
public function checkForEnter(event:KeyboardEvent):void{
	if(event.keyCode==Keyboard.ENTER){
		_claimtext= _claimbox.text as String;
		dispatchClaimEvent();
	}
	if(_claimbox.text=="[Enter your Claim]"){
		_claimbox.text="";
	}
}
/*				
public function addClaim(event:MouseEvent):void{
	_claimtext[_index] = _claimbox[_index].text as String;
	claimService.acceptClaim(_claimtext[_index],_index,_claimbox[_index].x,_claimbox[_index].y,1);	
	_index++;
	_claimbox[_index] = new DynamicTextArea();
	_claimbox[_index].index = _index;
	_claimbox[_index].x = 0;
	_claimbox[_index].y = _claimbox[_index-1].y+_claimbox[_index-1].height+25;
	setClaimBoxProperties(_claimbox[_index]);
	addChild(_claimbox[_index]);
	setClaim("[Enter your Claim]",_index);
	add.y = add.y+_claimbox[_index].height+25;
	done.y = done.y+_claimbox[_index].height+25;
	boxHeight = _claimbox[_index].y+_claimbox[_index].height;
}
*/

/**
 * This function prevents a new line from occuring in the claim box 
 * @param event
 * 
 */
public function preventNewLine(event:TextEvent):void{
	if(event.text=="\n"){
		event.preventDefault();
	}
}

/**
 * This function clears the text box if the string "[Enter your claim"] is present. 
 * @param event
 * 
 */
public function textBoxClicked(event:MouseEvent):void{
	if(this._claimAccepted){
		removeChild(_addButton);
		removeChild(_useButton);
		addChild(done);
		this._claimAccepted = false;
	}
	if(_claimbox.text == "[Enter your Claim]"){
		this.setClaim("");
	}
}


/**
 * This function sets the claimbox's text 
 * @param text The text that needs to be set
 * 
 */
public function setClaim(text:String):void{
	_claimbox.text = text;
}

/**
 * This function is fired in case a fault occurs in the RemoteObject calls 
 * @param event
 * 
 */
public function onFault(event:FaultEvent):void{
	Alert.show("Sorry, something went wrong. It's probably a bug in the code. Please notify me of what went wrong.");
}

public function callClaimUpdate():void{
	claimService.updateClaim(this._claimtext,this._claimIndex,this._userID);
}

public function callAcceptClaim():void{
	Alert.show("4.inside callAcceptClaim - goes to claimService");
	claimService.acceptClaim(_claimtext,_claimIndex,this.x,this.y,_userID);
}

public function makeParticular():void{
	this._statementType = 0;
	this.setClaimBoxProperties(_claimbox);
}

public function makeUniversal():void{
	this._statementType = 1;
	this.setClaimBoxPropertiesUniversal();
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