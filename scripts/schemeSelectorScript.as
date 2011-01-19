import events.SchemeSelectedEvent;

import mx.controls.Alert;
import mx.events.ListEvent;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
			
private var _selectedLogicName:String;
private var _selectedLogic:String;
private var _selectedLanguageForm:String;	
private var _claimIndex:int;
private var _selectedLanguageType:String;
private var _hover:Boolean;
[Bindable]
private var _schemeHolder:Object;	
			
[Bindable]
private var _languageTypeHolder:Object;

private var _claimStart:Boolean;			

public function set claimStart(value:Boolean):void{
	this._claimStart = value;
}					

public function get claimStart():Boolean{
	return this._claimStart;
}

public function init():void{
	schemeService.getSchemes(this._claimStart);
}
public function onFault(event:FaultEvent):void{
	Alert.show("I'm sorry, something went wrong. It's probably a bug in the code, so please notify me of what went wrong","SchemeSelector",Alert.OK);
}
			
public function showSchemes(event:ResultEvent):void{
	_schemeHolder = event.result;
}

public function set claimIndex(value:int):void{
	this._claimIndex = value;
}

public function get claimIndex():int{
	return this._claimIndex;
}
			
public function showLanguageType(event:ResultEvent):void{
	_languageTypeHolder = event.result;
	argumentSelector.dataProvider = _languageTypeHolder;
	argumentSelector.labelField = "language_forms";
	argumentSelector.visible=true;
	schemeService.getSchemeClasses(_selectedLogicName);
}
		
public function setSchemeClass(event:ResultEvent):void{
	_selectedLogic = event.result[0].class_name.toString();
}
/*
Shows the language types for the selected logic type
*/
public function getSchemeLanguages(event:ListEvent):void{
	
	_selectedLogicName = event.itemRenderer.data.name.toString();			
	schemeService.getLanguageTypes(_selectedLogicName);
}
		
/*
Dispatches the schemeAccepted custom event to the main application. The event holds the logic type and the language type
*/
		
public function sendScheme(event:ResultEvent):void{
	_selectedLanguageType = event.result[0].function_id;
	var schemeSelectedEvent:SchemeSelectedEvent;
	schemeSelectedEvent = new SchemeSelectedEvent("schemeAccepted",_selectedLogic,_selectedLanguageType,_selectedLanguageForm,_claimIndex);
	dispatchEvent(schemeSelectedEvent);
}

public function rollOverScheme(event:ResultEvent):void{
	_selectedLanguageType = event.result[0].function_id;
	var schemeSelectedEvent:SchemeSelectedEvent;
	schemeSelectedEvent = new SchemeSelectedEvent("schemeRollOver",_selectedLogic,_selectedLanguageType,_selectedLanguageForm,_claimIndex);
	dispatchEvent(schemeSelectedEvent);
}

public function rollOverLanguageType(event:ListEvent):void{
	_selectedLanguageForm = event.itemRenderer.data.language_forms.toString();
	schemeService.rollOverLanguageFunction(_selectedLanguageForm,_selectedLogic);
}
public function acceptLanguageType(event:ListEvent):void{
	//selectedLanguageForm= logic.category.(@name==selectedLogicName).SubCategory.(@data==argumentSelector.selectedItem);
	_selectedLanguageForm = event.itemRenderer.data.language_forms.toString();
	schemeService.getLanguageFunction(_selectedLanguageForm,_selectedLogic);
}