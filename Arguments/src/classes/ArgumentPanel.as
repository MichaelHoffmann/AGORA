package classes
{
	import components.ArgSelector;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import logic.ParentArg;
	
	import mx.binding.utils.BindingUtils;
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.controls.Menu;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
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
		//the hit area for dragging the box
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
		//A reference to the current map diplayed to the user
		public static var parentMap:AgoraMap;
		//The logical container that holds the text elements of the statement
		//that is, input1 and displayTxt
		public var group:Group;
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
		//The string that is displayed
		public var _displayStr:String;
		
		public static var ARGUMENT_CONSTRUCTED:String = "Argument Constructed";
		public function ArgumentPanel()
		{
			super();
			addMenuData = <root><menuitem label="add an argument for this statement" type="TopLevel" /></root>;
			constructArgData = <root><menuitem label="add another reason" type="TopLevel"/><menuitem label="construct argument" type="TopLevel"/></root>;
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
			
			width = 180;
			minHeight = 100;
			
		}
		
		protected function argumentConstructed(event:Event):void
		{
			if(inference != null)
			{
				trace("Argument Constructed");
				inference.setRuleState();
			}
		}
		
		public function set displayStr(value:String):void
		{
			_displayStr = value;
			input1.text = _displayStr;
			displayTxt.text = _displayStr;
			displayTxt.height = input1.height;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		public function get displayStr():String
		{
			return _displayStr;
		}
		public function get statementNegated():Boolean
		{
			return _statementNegated;
		}
		
		public function set statementNegated(value:Boolean):void
		{
			_statementNegated = value;
			makeUnEditable();
		}
	
		public function makeEditable():void
		{
			if(userEntered == false)
			{
				input1.text="";
				userEntered = true;
			}
			
			focusManager.setFocus(input1);
			input1.visible = true;
			displayTxt.visible = false;
			doneHG.visible = true;
			bottomHG.visible=false;
		}
	
		public function makeUnEditable():void
		{
			displayTxt.width = input1.width;
			displayTxt.height = input1.height;
			displayTxt.text = stmt;
			displayTxt.visible = true;
			input1.visible = false;
			bottomHG.visible = true;
			doneHG.visible = false;
		}
		
		public function get stmt():String
		{
			
			if(statementNegated == true)
			{
				return ("it is not the case that " + input1.text);
			}
			else
			{
				return input1.text;
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
		
		public function addHandler(event:MouseEvent):void
		{
			addSupportingArgument();
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
			input1.forwardUpdate();
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
			//add reason to the map
			parentMap.addElement(reason);
			//push reason to the list of reasons belonging to this particular class
			currInference.reasons.push(reason);
			//temporary, should be replaced by TID
			currInference.connectionIDs.push(Inference.connections++);
			//set the inference of the reason
			reason.inference = currInference;
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
			tmpInput.forwardList.push(currInference.input1);
			input1.forwardList.push(currInference.input[0]);
			tmpInput.aid = input1.aid;
			//create an invisible box for the reason
			var tmpInput2:DynamicTextArea = new DynamicTextArea();
			tmpInput2.aid = reason.input1.aid;
			parentMap.addElement(tmpInput2);
			tmpInput2.visible = false;
			tmpInput2.panelReference = currInference;
			currInference.input.push(tmpInput2);	
			tmpInput2.forwardList.push(currInference.input1);
			reason.input1.forwardList.push(tmpInput2);
			parentMap.layoutManager.registerPanel(currInference);
			dispatchEvent(new Event(ARGUMENT_CONSTRUCTED,true,false));
		}
		
		
		public function textBoxClicked(event:MouseEvent):void{
			if(this.inference==null)
				event.target.text = "";
		}
		
		public function movedAway(event:MouseEvent):void{
			if(event.target.text == ""){
				event.target.text = "[Enter your claim/reason]. Pressing Enter afterwards will prompt you for a reason";
			}
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
				stmtTypeLbl.text = "Particular Statement";
				state = 1;
			}
			stmtTypeLbl.toolTip = "Whether a statement is universal or particular determines what kind of objections are possible against it. " +
				"A 'universal statement' is defined here as a statement that can be falsified by one counter-example. " +
				"In this sense, laws, rules, and all statements that include 'ought' or 'should,' etc., are universal statements." +
				" Anything else is treated as a particular statement, including statements about possibilities. CLICK TO CHANGE";
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
			bottomHG.addElement(deleteBtn);
			addBtn.addEventListener(MouseEvent.CLICK,addHandler);
			bottomHG.visible = false;
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
		}
		
		protected function setGuidingText(event:FlexEvent):void
		{
			if(this.panelType==ARGUMENT_PANEL)
			{
				input1.text = "[Enter your claim/reason]. Pressing Enter afterwards will prompt you for a reason";
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
		
	}
}