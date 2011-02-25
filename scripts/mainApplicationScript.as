/**
 * This contains the functions that are used to run the application, and controls all the components that are part of the application.
 * The application starts with 4 options the user can choose from. Once the user chooses on of the options, the appropriate 
 * function is called, and the user is presented with the tools to create/edit an argument map.
 * 
 * @tag Tag text
*/
import components.SchemeSelector;

import events.SchemeChangeEvent;


include "claimHandlerScript.as";
include "reasonHandlerScript.as";
include "inferenceHandlerScript.as";
include "loginScript.as";
include "claimStartScript.as";
include "schemeStartScript.as";

private var _promptLabel:PromptLabel;
private var _allowAddReason:Boolean;
private var _reversePos:Array;

//The argument scheme indicator. Also held as an array with an element presen for each _claimBox array elent
private var _argScheme:Array;
//The Scheme Selector
private var _schemeSelector:SchemeSelector;
//Therefore
private var _therefore:Array;

private var _selectedLogic:Array;

private var _selectedFunction:Array;

private var _userID:int;
/**
 * This function initializes the main application. It creates instances of all the Array objects declared, sets the required values
 * and prepares the screen for user input 
 * 
 */
 
public function init():void{
	taskPrompt.labelText="Welcome. Please choose one of the following tasks to continue";
	argumentPaste.text="Paste a part of an argumentation from the clipboard (under construction)";
	conceptStart.text = "Click here if you want to divide a concept into sub-concepts or a claim into sub-claims so that arguments or objections\n can be developed for each case (under construction)";
	_reversePos = new Array();
}


public function changeSchemeEvent(event:SchemeChangeEvent):void{
	var schemeSelector:SchemeSelector = new SchemeSelector();
	schemeSelector.x = _schemeSelector.x;
	schemeSelector.y = _schemeSelector.y;
	schemeSelector.claimIndex = event.claimIndex;
	schemeSelector.addEventListener("schemeAccepted", schemeSelectEvent);
	_schemeSelector = schemeSelector;
	addChild(_schemeSelector);
}
