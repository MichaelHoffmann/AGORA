package classes
{
	import classes.Language;
	
	import components.ArgSelector;
	import components.Option;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import logic.ConditionalSyllogism;
	import logic.ParentArg;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.controls.Menu;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.EventListenerRequest;
	import mx.events.FlexEvent;
	import mx.events.MenuEvent;
	import mx.managers.DragManager;
	import mx.skins.Border;
	
	import org.osmf.events.GatewayChangeEvent;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Panel;
	import spark.components.TextArea;
	import spark.components.VGroup;
	import spark.effects.Resize;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	import spark.skins.spark.PanelSkin;
	
	public class ArgumentPanel extends GridPanel
	{
		//The text box in which the user enters the argument
		public var input1:DynamicTextArea;
		//Right now the requirement is for only two,
		//but this is extensible
		public var inputs:Vector.<DynamicTextArea>;
		
		public var topArea:UIComponent;
		//skin of the panel
		public var panelSkin:PanelSkin;
		//doneButton
		public var doneBtn:AButton;
		public var addBtn:AButton;
		public var deleteBtn:AButton;
		//A statment exists in two states: editable, and non-editable. When
		//the user clicks the done button, it goes to the non-editable state.
		//The input1 textbox is hidden and the below Text control is shown.
		public var displayTxt:Text;
		//label for displaying 'It is not the case that' for netaged
		//statements
		public var negatedLbl:Label;
		//A reference to the current map diplayed to the user
		public static var parentMap:AgoraMap;
		//The logical container that holds the text elements of the statement
		//that is, input1 and displayTxt
		public var group:Group;
		//multistatement group
		public var msVGroup:VGroup;
		//The enabler which makes this statements support a claim
		public var inference:Inference;
		//contains the add and the delete button
		public var bottomHG:HGroup;
		//the logical container that contains everything above the group container
		public var topHG:HGroup;
		//Within the topHG. It holds the author information and the type of statement
		public var stmtInfoVG:VGroup;
		//Container that holds the done button
		public var doneHG:HGroup;
		//contains the doneHG and bottomHG
		public var btnG:Group;
		//List of enablers which makes other statements support this statement
		public var rules:Vector.<Inference>;
		//state=0 -> universal statement and state=1 -> particular statement
		public var state:int;	
		//Type of Panel: this could be found by just using is operator
		public static const ARGUMENT_PANEL:int = 0;
		//Type of Panel
		public static const INFERENCE:int = 1;
		//Displays the type of this statment
		public var stmtTypeLbl:Label;
		//Displays the user id
		public var userIdLbl:Label;
		//Takes either INFERENCE or ARGUMENT_PANEL
		public var panelType:int;
		//Specifies whether the statement is negative or positive
		private var _statementNegated:Boolean;		
		//Before a user enters text into the statement, it is false
		public var userEntered:Boolean;
		//XML string holding the menu data for the add button
		public var addMenuData:XML;
		//XML string holding the menu data for the menu that pops up when user hits the done button
		public var constructArgData:XML;
		//claim added through start with claim
		public var firstClaim:Boolean;
		
		//multiple textboxes
		private var _multiStatement:Boolean;
		public var connectingStr:String;
		private var _implies:Boolean;
		
		public static var IF_THEN:String = "If-then";
		public static var IMPLIES:String = "Implies";
		
		public static var ARGUMENT_CONSTRUCTED:String = "Argument Constructed";
		public function ArgumentPanel()
		{
			super();
			firstClaim = false;
			addMenuData = <root><menuitem label="add an argument for this statement" type="TopLevel" /></root>;
			constructArgData = <root><menuitem label="add another reason" type="TopLevel"/><menuitem label="construct argument" type="TopLevel"/></root>;
			//addMenuData = new XML("<root><menuitem label=\"" + Language.lookup("add") + 
			//					Language.lookup("AddArg") + "\" type=\"TopLevel\" /></root>");
			//constructArgData = new XML("<root><menuitem label=\"" + Language.lookup("add") +
			//					Language.lookup("AddAnotherReason") + 
			//					"\" type=\"TopLevel\"/><menuitem label=\"construct argument\" type=\"TopLevel\"/></root>");
			userEntered = false;
			panelType = ArgumentPanel.ARGUMENT_PANEL;			
			this.addEventListener(FlexEvent.CREATION_COMPLETE,onArgumentPanelCreate);	
			this.addEventListener(UpdateEvent.UPDATE_EVENT,adjustHeight);
			this.addEventListener(KeyboardEvent.KEY_DOWN,keyEntered);
			
			this.addEventListener(ARGUMENT_CONSTRUCTED, argumentConstructed);
			
			//will be set by the object that creates this
			inference = null;
			
			//this should not use the set method
			//because the set method triggers actions on child elements
			//which are not created yet
			_statementNegated = false;
			
			rules = new Vector.<Inference>(0,false);
			inputs = new Vector.<DynamicTextArea>(0,false);
			
			width = 180;
			minHeight = 100;
			
		}
		
		public function get implies():Boolean
		{
			return _implies;
		}
		
		public function set implies(value:Boolean):void
		{
			if(_implies != value)
			{
				_implies = value;
			}
		}
		
		public function get multiStatement():Boolean
		{
			return _multiStatement;
		}
		
		public function set multiStatement(value:Boolean):void
		{
			var previous:Boolean = _multiStatement
			if(_multiStatement != value)
			{
				if(value == true){
					//group.removeElement(input1);
					input1.visible = false;
					group.addElement(msVGroup);
					if(!userEntered)
					{
						input1.text = "";
					}		
				}
				else
				{
					try{
						group.removeElement(msVGroup);
					}catch(error:Error)
					{
						trace(error);
					}
					//group.addElement(input1);
				}
				_multiStatement = value;
				userEntered = false;
			}
		}
		
		protected function argumentConstructed(event:Event):void
		{
			if(inference != null)
			{
				inference.setRuleState();
			}
		}
		
		public function get statementNegated():Boolean
		{
			return _statementNegated;
		}
		
		public function set statementNegated(value:Boolean):void
		{
			if(_statementNegated != value)
			{
				_statementNegated = value;
				if(value == true)
				{
					negatedLbl.visible = true;
				}
				else
				{
					negatedLbl.visible = false;
				}
			}
			makeUnEditable();
		}
		
		public function makeEditable():void
		{
			if(userEntered == false)
			{
				userEntered = true;
			}
			if(multiStatement){
				focusManager.setFocus(inputs[0]);
				msVGroup.visible = true;
			}
			else{
				focusManager.setFocus(input1);
				input1.visible = true;
			}
			displayTxt.visible = false;
			doneHG.visible = true;
			bottomHG.visible=false;
		}
		
		public function makeUnEditable():void
		{
			if(multiStatement)
			{
				//input1 is just used to calculate height
				input1.text = stmt;
				displayTxt.width = msVGroup.width;
				displayTxt.height = msVGroup.height;
			}
			else{
				displayTxt.width = input1.width;
				displayTxt.height = input1.height;
			}
			
			displayTxt.text = positiveStmt;
			
			//trace(displayTxt.text);
			displayTxt.visible = true;
			bottomHG.visible = true;
			doneHG.visible = false;
			if(multiStatement)
			{
				msVGroup.visible = false;
			}
			else
			{
				input1.visible = false;
			}
		}
		
		public function get stmt():String
		{
			
			var statement:String = "";
			if(multiStatement)
			{
				if(implies)
				{
					if(connectingStr == "If-then")
						statement = "If " + inputs[1].text + ", then " + inputs[0].text;
					else
						statement = inputs[1].text + " implies " + inputs[0].text;					
				}
				else
				{
					for(var i:int=0; i<inputs.length - 1; i++)
					{
						statement = statement + inputs[i].text + " and ";
					}
					statement = statement + inputs[i].text;
				}
			}
			else
			{
				statement = input1.text;
			}
			if(statementNegated == true)
			{
				return ("it is not the case that " + statement);
			}
			else
			{
				return statement;
			}
		}
		
		protected function lblClicked(event:MouseEvent):void
		{
			makeEditable();
		}
		
		public function get positiveStmt():String
		{
			return input1.text;
		}
		
		public function adjustHeight(e:Event):void
		{
			if(this is Inference)
			{
			}
			else if(this.inference != null)
			{
				parentMap.layoutManager.alignReasons(this, this.gridY);
			}
			return;
		}
		
		public function keyEntered(event: KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ENTER)	
			{
				statementEntered();	
			}
		}
		
		public function beginDrag( mouseEvent: MouseEvent ):void
		{
			try{
				var	dinitiator:UIComponent = UIComponent(mouseEvent.currentTarget);
				var dPInitiator:ArgumentPanel = this;
				var ds:DragSource = new DragSource();
				var tmpx:int = int(dPInitiator.mouseX);
				var tmpy:int = int(dPInitiator.mouseY);
				ds.addData(tmpx,"x");
				ds.addData(tmpy,"y");
				ds.addData(dPInitiator.gridX,"gx");
				ds.addData(dPInitiator.gridY,"gy");
				DragManager.doDrag(dPInitiator,ds,mouseEvent,null);
			}
			catch(error:Error)
			{
				Alert.show(error.toString());
			}
		}
		
		
		public function addArgument(event:MenuEvent):void
		{
			if(event.label == "add an argument for this statement")
			{
				
			}
		}
		
		protected function removeEventListeners():void
		{
			parentMap.option.removeEventListener(MouseEvent.CLICK,optionClicked);	
			rules[rules.length - 1].reasons[0].input1.removeEventListener(KeyboardEvent.KEY_DOWN,hideOption);
		}
		
		protected function optionClicked(event:MouseEvent):void
		{
			beginByArgument();
			parentMap.option.visible = false;
			removeEventListeners();
		}
		
		protected function hideOption(event:KeyboardEvent):void
		{
			parentMap.option.visible = false;	
			removeEventListeners();
		}
		
		public function addHandler(event:MouseEvent):void
		{
			addSupportingArgument();
			parentMap.option.visible = true;
			parentMap.option.addEventListener(MouseEvent.CLICK,optionClicked);
			rules[rules.length - 1].reasons[0].input1.addEventListener(KeyboardEvent.KEY_DOWN,hideOption);
			parentMap.option.x = rules[rules.length - 1].reasons[0].x + rules[rules.length - 1].reasons[0].width + 10;
			parentMap.option.y = rules[rules.length - 1].reasons[0].y;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		public function configureReason(event:FlexEvent):void
		{
			var reason:ArgumentPanel = ArgumentPanel(event.target);
			reason.makeUnEditable();
		}
		
		public function beginByArgument():void{
			rules[rules.length-1].visible = true; 
			rules[rules.length-1].chooseEnablerText();
			if(inference == null)
			{
				if(multiStatement){
				}
				else{
				}
			}
			makeUnEditable();
			//This is important if beginByArgument is called 
			//immediately after an argument is constructed
			//input1 of reason might not be created then.
			rules[rules.length-1].reasons[0].addEventListener(FlexEvent.CREATION_COMPLETE,configureReason);
			if(rules[rules.length-1].reasons[0].input1 != null)
			{
				rules[rules.length-1].reasons[0].makeUnEditable();
			}
			parentMap.invalidateDisplayList();
		}
		
		public function constructArgument(event:MenuEvent):void
		{
			if(event.label == "add another reason")
			{
				inference.addReason();
			}
			else if(event.label == "construct argument")
			{
				inference.chooseEnablerText();
				inference.visible = true;
				parentMap.invalidateDisplayList();
			}
		}
		
		public function showMenu():void
		{
			var menu:Menu = Menu.createMenu(null,constructArgData,false);
			menu.labelField = "@label";
			menu.addEventListener(MenuEvent.ITEM_CLICK, constructArgument);
			var globalPosition:Point = localToGlobal(new Point(0,this.height));
			menu.show(globalPosition.x,globalPosition.y);	
		}
		
		public function statementEntered():void
		{
			if(this.inference == null && this.rules.length == 0)
			{
				dispatchEvent(new Event("UserInteractionBegan",true,false));
				addSupportingArgument();
			}
			makeUnEditable();
			if(inference!=null && inference.selectedBool == false)
			{
				showMenu();		
			}
		}
		
		public function doneHandler(d:MouseEvent):void
		{
			statementEntered();
		}
		
		//reason must be registered before inference is
		//user must not change the inference rule. He creates the inference rule
		//through argument type, reasons and claim
		public function addSupportingArgument():void
		{
			
			var currInference:Inference = new Inference();
			currInference.myschemeSel = new ArgSelector;
			currInference.myschemeSel.addEventListener(FlexEvent.CREATION_COMPLETE, currInference.menuCreated);	
			//add the inference to map
			//trace(parentMap);
			parentMap.addElement(currInference);
			currInference.visible=false;
			//create the panel that displays connection information
			var infoPanel:MenuPanel = new MenuPanel;
			currInference.argType = infoPanel;
			currInference.argType.inference = currInference;
			parentMap.addElement(currInference.argType);
			
			//add inference to the list of inferences
			rules.push(currInference);
			//set the claim of the inference rule to this
			currInference.claim = this;
			currInference.inference = currInference;
			//create a reason node
			var reason:ArgumentPanel = new ArgumentPanel();
			reason.addEventListener( FlexEvent.CREATION_COMPLETE, currInference.reasonAdded);
			//add reason to the map
			parentMap.addElement(reason);
			//push reason to the list of reasons belonging to this particular class
			currInference.reasons.push(reason);
			//temporary, should be replaced by TID
			currInference.connectionIDs.push(Inference.connections++);
			//set the inference of the reason
			reason.inference = currInference;
			//type of reason
			//register the reason
			parentMap.layoutManager.registerPanel(reason);
			//create an invisible box for the inference rule corresponding to the claim
			var tmpInput:DynamicTextArea = new DynamicTextArea();
			//add it to the map
			parentMap.addElement(tmpInput);
			//set the input box as invisible
			tmpInput.visible = false;
			//logical
			//set the panel to which the input box belongs
			tmpInput.panelReference = currInference;
			//add a pointer to the input
			currInference.input.push(tmpInput);		
			//binding
			//tmpInput.forwardList.push(currInference.input1);
			//input1.forwardList.push(currInference.input[0]);
			tmpInput.aid = input1.aid;
			//create an invisible box for the reason
			var tmpInput2:DynamicTextArea = new DynamicTextArea();
			tmpInput2.aid = reason.input1.aid;
			parentMap.addElement(tmpInput2);
			tmpInput2.visible = false;
			tmpInput2.panelReference = currInference;
			currInference.input.push(tmpInput2);	
			//tmpInput2.forwardList.push(currInference.input1);
			//reason.input1.forwardList.push(tmpInput2);
			parentMap.layoutManager.registerPanel(currInference);
			//should be added towards the end
			//if there is only one possible scheme,
			//it is automatically selected
			parentMap.addChild(currInference.myschemeSel);
			currInference.myschemeSel.visible = false;
			dispatchEvent(new Event(ARGUMENT_CONSTRUCTED,true,false));
		}
		
		
		
		//create children must be overriden to create dynamically allocated children
		override protected function createChildren():void
		{
			
			//Elements are constructed, initialized with properties, and attached to display list		
			//create the children of MX Panel
			super.createChildren();		
			var uLayout:VerticalLayout = new VerticalLayout;
			uLayout.paddingBottom = 10;
			uLayout.paddingLeft = 10;
			uLayout.paddingRight = 10;
			uLayout.paddingTop = 10;
			this.layout = uLayout;
			
			
			userIdLbl = new Label;
			
			stmtTypeLbl = new Label;
			// default setting    	
			if(this is Inference)
			{
				stmtTypeLbl.text = "";
				state = 0;
			}
			else
			{
				//stmtTypeLbl.text = Language.lookup("Particular");
				stmtTypeLbl.text = "Particular";
				state = 1;
			}
			//stmtTypeLbl.toolTip = Language.lookup("ParticularUniversalClarification");
			//stmtTypeLbl.toolTip = "Please change it before commiting";
			stmtTypeLbl.toolTip = "'Universal statement' is defined as a statement that can be falsified by one counterexample. Thus, laws, rules, and all statements that include 'ought,' 'should,' or other forms indicating normativity, are universal statements. Anything else is treated as a 'particular statement' including statements about possibilities.  The distinction is important only with regard to the consequences of different forms of objections: If the premise of an argument is 'defeated,' then the conclusion and the entire chain of arguments that depends on this premise is defeated as well; but if a premise is only 'questioned' or criticized, then the conclusion and everything depending is only questioned, but not defeated. While universal statements can easily be defeated by a single counterexample, it depends on an agreement among deliberators whether a counterargument against a particular statement is sufficient to defeat it, even though it is always sufficient to question it and to shift, thus, the burden of proof.";
			stmtTypeLbl.addEventListener(MouseEvent.CLICK,toggle);
			
			bottomHG = new HGroup();
			doneHG = new HGroup;
			doneBtn = new AButton;
			doneBtn.label = "Done";
			doneHG.addElement(doneBtn);
			doneBtn.addEventListener(MouseEvent.CLICK,doneHandler);
			
			input1 = new DynamicTextArea();
			//this.input1.addEventListener(FocusEvent.FOCUS_OUT, makeUnEditable);
			input1.panelReference = this;
			input1.toolTip = "Otherwise, if you wish to start with Argument Scheme, click on the Add arg button below (do NOT press enter too)";
			//TODO: Translate
			displayTxt = new Text;
			this.displayTxt.addEventListener(MouseEvent.CLICK, lblClicked);
			//Create a UIComponent for clicking and dragging
			topArea = new UIComponent;
			
			topHG = new HGroup();
			addElement(topHG);
			
			//Draw on topArea UIComponent a rectangle
			//to be used for clicking and dragging
			
			topArea.addEventListener(MouseEvent.MOUSE_DOWN,beginDrag);
			topArea.width = 40;
			topHG.addElement(topArea);
			//add a vertical subgroup
			stmtInfoVG = new VGroup;
			stmtInfoVG.gap = 0;
			topHG.addElement(stmtInfoVG);
			
			
			stmtInfoVG.addElement(stmtTypeLbl);
			stmtInfoVG.addElement(userIdLbl);
			
			userIdLbl.text = "AU: " + UserData.userNameStr;
			var userInfoStr:String = "User Name: " + UserData.userNameStr + "\n" + "User ID: " + UserData.uid;
			userIdLbl.toolTip = userInfoStr;
			
			negatedLbl = new Label;
			negatedLbl.text = "It is not the case that";
			negatedLbl.visible = false;
			addElement(negatedLbl);
			
			
			group = new Group;
			addElement(group);
			group.addElement(input1);
			group.addElement(displayTxt);
			displayTxt.addEventListener(FlexEvent.CREATION_COMPLETE,setGuidingText);
			input1.visible=false;
			
			btnG = new Group;
			addElement(btnG);
			btnG.addElement(bottomHG);
			doneHG = new HGroup;
			doneHG.addElement(doneBtn);
			btnG.addElement(doneHG);
			btnG.addElement(bottomHG);
			addBtn = new AButton;
			addBtn.label = "add...";
			
			bottomHG.addElement(addBtn);
			deleteBtn = new AButton;
			deleteBtn.label = "delete...";
			deleteBtn.addEventListener(MouseEvent.CLICK,deleteThis);
			bottomHG.addElement(deleteBtn);
			addBtn.addEventListener(MouseEvent.CLICK,addHandler);
			bottomHG.visible = false;
			
			//presently, the requirement is only for two boxes
			msVGroup = new VGroup;
			//group.addElement(msVGroup);
			var dta:DynamicTextArea = new DynamicTextArea;
			dta.panelReference = this;
			inputs.push(dta);
			dta = new DynamicTextArea;
			dta.panelReference = this;
			inputs.push(dta);
			for(var i:int=0; i < inputs.length; i++)
			{
				msVGroup.addElement(inputs[i]);
			}
			
			invalidateProperties();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();	
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			topArea.graphics.beginFill(0xdddddd,1.0);
			topArea.graphics.drawRect(0,0,40,stmtInfoVG.height);
			userIdLbl.setActualSize(this.width - stmtInfoVG.x - 10, userIdLbl.height);		
		}
		
		public function onArgumentPanelCreate(e:FlexEvent):void
		{
			//remove the default title bar provided by mx
			panelSkin = this.skin as PanelSkin;
			panelSkin.topGroup.includeInLayout = false;
			panelSkin.topGroup.visible = false;
			if(!userEntered)
			{
				//displayTxt.text = "[Enter the claim]";
			}
		}
		
		protected function setGuidingText(event:FlexEvent):void
		{
			if(this.panelType==ARGUMENT_PANEL)
			{
				//input1.text = "[Enter your claim/reason]. Pressing Enter afterwards will prompt you for a reason";
			}
			else if(this.panelType==INFERENCE)
			{
			}
			displayTxt.text = input1.text;
			displayTxt.width = input1.width;
			displayTxt.height = input1.height;
		}
		
		public function toggle(m:MouseEvent):void
		{
			if(this.state==0) {
				if(this.panelType!=INFERENCE)
				{
					state = 1;
					stmtTypeLbl.text = "Particular Statement";
					this.setStyle("cornerRadius",0);
				}
				else {
					Alert.show("Inference can only be Universal Statement. Therefore, cannot change");
					stmtTypeLbl.text = "Universal Statement";
				}
			} 
			else {
				state = 0;
				stmtTypeLbl.text = "Universal Statement";
				this.setStyle("cornerRadius",30);
			} 
		}
		
		protected function deleteThis(event:MouseEvent):void
		{
			if(inference != null && inference.myArg is ConditionalSyllogism)
			{
				Alert.show("You cannot delete a reason of a conditional syllogism argument separately. To delete this argument, delete the enabler");
				return;
			}
			this.selfDestroy();
			if(inference != null)
			{
				if(inference.reasons.length == 0)
				{
					trace('No of reasons is zero, therefore deleting the inference panel');
					inference.selfDestroy();
				}
			}
		}
		
		public function selfDestroy():void
		{
			for(var i:int=rules.length-1; i >= 0; i--)
			{
				rules[i].selfDestroy();
			}
			if(inference != null)
			{
				inference.reasons.splice(inference.reasons.indexOf(this,0),1);
			}
			parentMap.layoutManager.panelList.splice(parentMap.layoutManager.panelList.indexOf(this,0),1);
			parentMap.removeChild(this);
			trace(this + ' destroyed');
			if(inference != null)
			{
				if(inference.reasons.length > 0)
				{
					parentMap.layoutManager.alignReasons(this,this.gridY);
					inference.displayStr = inference.myArg.correctUsage();
				}
			}
		}
	}
	
}
