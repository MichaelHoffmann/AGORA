package classes
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
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
	import spark.layouts.HorizontalAlign;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	import spark.skins.spark.PanelSkin;
	
	
	public class ArgumentPanel extends GridPanel
	{
		//The text box
		public var input1:DynamicTextArea;
		//the hit area for dragging the box
		public var topArea:UIComponent;
		//skin of the panel
		public var panelSkin:PanelSkin;
		//another skin
		public var panelSkin1:PanelSkin;
		//doneButton
		
		public var doneBtn:AButton;
		public var addBtn:AButton;
		public var deleteBtn:AButton;
		public var savedTextStr:String;
		//public var displayLbl:Label;
		public var displayTxt:Text;
		public static var parentMap:AgoraMap;
		public var group:Group;
		//The enabler which makes these statements support a claim
		public var inference:Inference;		
		public var bottomHG:HGroup;
		public var topHG:HGroup;
		public var stmtInfoVG:VGroup;
		public var doneHG:HGroup;
		public var btnG:Group;
		//List of enablers which support this statement
		public var rules:Vector.<Inference>;
		public var binders:Vector.<Binder>;
		public var state:int;	//state=0 -> universal statement and state=1 -> particular statement
		
		public static const ARGUMENT_PANEL:int = 0;
		public static const INFERENCE:int = 1;
		public var MODE:int = 0;	// mode:0 means construct by reason, mode:1 means construct by argument scheme
		
		public var stmtTypeLbl:Label;
		public var panelType:int;
		public var thereforeLine:UIComponent;
		public var thereforeText:Label;
		public var negated:Boolean;		// negated = 0 means no - it is positive. negated = 1 means yes - it is negative. Useful for Modus Tollens and Disjunctive Syllogism
		public var userEntered:Boolean;
		public var addMenuData:XML;
		public var constructArgData:XML;
		
		
		public function makeEditable(event:MouseEvent):void
		{
			if(userEntered == false)
			{
					input1.text="";
					userEntered = true;
			}
			//trace("should make it editable");
			if( !( event.target is mx.controls.Button) )
			{
				input1.visible = true;
				//displayLbl.visible = false;
				displayTxt.visible = false;
				doneHG.visible = true;
				bottomHG.visible=false;
			}
		}
		
		public function makeUnEditable():void
		{
			displayTxt.width = input1.width;
			displayTxt.height = input1.height;
			displayTxt.text = input1.text;
			displayTxt.visible = true;
			input1.visible = false;
			bottomHG.visible = true;
			doneHG.visible = false;
		}
		
		public function ArgumentPanel()
		{
			super();
			addMenuData = <root><menuitem label="add an argument for this statement" type="TopLevel" /></root>;
			constructArgData = <root><menuitem label="add another reason" type="TopLevel"/><menuitem label="construct argument" type="TopLevel"/></root>;
			userEntered = false;
			panelType = ArgumentPanel.ARGUMENT_PANEL;			
			this.addEventListener(FlexEvent.CREATION_COMPLETE,onArgumentPanelCreate);	
			this.addEventListener(UpdateEvent.UPDATE_EVENT,adjustHeight);
		
			//will be set by the object that creates this
			inference = null;
			
			rules = new Vector.<Inference>(0,false);
			
			width = 180;
			minHeight = 100;
			
			thereforeLine = new UIComponent();
			thereforeLine.graphics.clear();
			thereforeLine.graphics.lineStyle(2,0,1);
			addElement(thereforeLine);			
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
			}catch(error:Error)
			{
				Alert.show(error.toString());
			}
		}
		//reason must be registered before inference is
		//user must not change the inference rule. He creates the inference rule
		//through argument type, reasons and claim
		public function addArgument(event:MenuEvent):void
		{
				if(event.label == "add an argument for this statement")
				{
					//create an inference
					var currInference:Inference = new Inference();
					//add the inference to map
					parentMap.addElement(currInference);
					currInference.visible=false;
					//create the panel that displays connection information
					var infoPanel:DisplayArgType = new DisplayArgType;
					currInference.argType = infoPanel;
					currInference.argType.inference = currInference;
					parentMap.addElement(currInference.argType);
					//add inference to the list of inferences
					rules.push(currInference);
					//set the claim of the inference rule to this
					currInference.claim = this;
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
				}
		}
		
		public function addHandler(event:MouseEvent):void
		{
			var menu:Menu = Menu.createMenu(null,addMenuData,false);
			menu.labelField = "@label";
			menu.addEventListener(MenuEvent.ITEM_CLICK, addArgument);
			var globalPosition:Point = localToGlobal(new Point(0,this.height));
			menu.show(globalPosition.x,globalPosition.y);		
		}
		
		
		public function checkForEnter(event:KeyboardEvent):void{
			/*
			if(event.keyCode==Keyboard.ENTER){
				MODE=0;
				// add Reason only
				var reason:ArgumentPanel = new ArgumentPanel();
				reason.x = this.gridY*25 + this.width + 100;
				reason.y = this.gridX*25;	
				//add reason to the map
				parentMap.addElement(reason);
				
				Alert.show("Select reason to be Universal or Particular statement, by clicking on its label on top");
				
				//line saying "therefore" joining claim and reason temporarily
				thereforeLine.graphics.moveTo(this.width-10,this.height/2);
				thereforeLine.graphics.lineTo(this.width+100,this.height/2);
				thereforeText = new Label;
				thereforeText.x = this.gridY*25+this.width + 10; thereforeText.y = this.gridX*25+50;
				parentMap.addElement(thereforeText);
				thereforeText.text = "<== Therefore";
				
				var currInference:Inference = new Inference();
				parentMap.addElement(currInference);
				currInference.visible = false; currInference.argType.visible = false;
				currInference.claim = this;
				currInference.reasons.push(reason);
				
				currInference.connectionIDs.push(Inference.connections++);
				
				reason.inference = currInference;
	
				//create an invisible box for the inference rule corresponding to the claim
				var tmpInput:DynamicTextArea = new DynamicTextArea();
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
				
				//set the id of the new text box to the id of the one in the reason
				tmpInput.aid = input1.aid;
				
				
				//create an invisible box for the reason
				var tmpInput2:DynamicTextArea = new DynamicTextArea();
				//set its id to the DTA's id present in the reason
				tmpInput2.aid = reason.input1.aid;
				parentMap.addElement(tmpInput2);
				tmpInput2.visible = false;
				tmpInput2.panelReference = currInference;
				currInference.input.push(tmpInput2);	
				
				tmpInput2.forwardList.push(currInference.input1);
				reason.input1.forwardList.push(tmpInput2);
				input1.forwardUpdate();		//claim	
				reason.input1.forwardUpdate();		//reason
				
				
				// deactive the DONE button to avoid duplicate action
				doneBtn.removeEventListener(MouseEvent.CLICK,doneHandler);
		
			}
			*/
		}
		
		public function constructArgument(event:MenuEvent):void
		{
			if(event.label == "add another reason")
			{
				inference.addReason();
			}
			else if(event.label == "construct argument")
			{
				inference.buildInference();
				inference.formedBool = true;
				inference.visible = true;
			}
		}
		
		public function doneHandler(d:MouseEvent):void{
			makeUnEditable();
			input1.forwardUpdate();
			if(inference!=null && inference.formedBool == false)
			{
				var menu:Menu = Menu.createMenu(null,constructArgData,false);
				menu.labelField = "@label";
				menu.addEventListener(MenuEvent.ITEM_CLICK, constructArgument);
				var globalPosition:Point = localToGlobal(new Point(0,this.height));
				menu.show(globalPosition.x,globalPosition.y);
			}
			/*
			if(MODE==1){ //only reason has been added, inference is invisible and not pushed to claim.rules
				var correspClaim:ArgumentPanel = this.inference.claim;
				correspClaim.rules.push(this.inference);
				parentMap.layoutManager.registerPanel(this);	
				parentMap.layoutManager.registerPanel(this.inference);	
				this.inference.makeVisible();
				parentMap.removeElement(correspClaim.thereforeText);
				correspClaim.thereforeLine.graphics.clear();
				
				Alert.show("Select Argument Scheme from the list");
				var simulatedClick:MouseEvent = new MouseEvent(MouseEvent.CLICK);
				this.inference.scheme.dispatchEvent(simulatedClick);

			}
			else { //this is also a claim. so "done" should not do anything special. here done should be equivalent to hitting 'enter'
				if(this.rules.length==0) {//open ended claim. Enter has not been hit yet
					var simulatedEnter:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
					simulatedEnter.keyCode = Keyboard.ENTER;
					input1.dispatchEvent(simulatedEnter);
				}
			}
			*/
		}
	
		public function getString():String{
			return input1.text;
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
			//create the children of MX Panel
			super.createChildren();		
			var uLayout:VerticalLayout = new VerticalLayout;
			uLayout.paddingBottom = 10;
			uLayout.paddingLeft = 10;
			uLayout.paddingRight = 10;
			uLayout.paddingTop = 10;
			this.layout = uLayout;
			
			
			stmtTypeLbl = new Label;
			// default setting    	
			if(this is Inference) stmtTypeLbl.text = "Universal Statement";
			else stmtTypeLbl.text = "Particular Statement";
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
			if(this.panelType==ARGUMENT_PANEL) {
			//input1.addEventListener(MouseEvent.CLICK,textBoxClicked);
			//input1.addEventListener(MouseEvent.MOUSE_OUT,movedAway);
			input1.addEventListener(KeyboardEvent.KEY_DOWN,checkForEnter); }
			
			//Create the label for displaying the statement
			//displayLbl = new Label;
			displayTxt = new Text;
			this.displayTxt.addEventListener(MouseEvent.CLICK, makeEditable);
			//Create a UIComponent for clicking and dragging
			topArea = new UIComponent;
			
			topHG = new HGroup();
			addElement(topHG);
			
			//Draw on topArea UIComponent a rectangle
			//to be used for clicking and dragging
			topArea.graphics.beginFill(0xdddddd,1.0);
			topArea.graphics.drawRect(0,0,40,20);
			topArea.width = 40;
			topArea.height = 20;
			topArea.addEventListener(MouseEvent.MOUSE_DOWN,beginDrag);
			topHG.addElement(topArea);
			//add a vertical subgroup
			stmtInfoVG = new VGroup;
			topHG.addElement(stmtInfoVG);
			stmtInfoVG.addElement(stmtTypeLbl);
			
			group = new Group;
			addElement(group);
			group.addElement(input1);
			//displayLbl.width = 100;
			group.addElement(displayTxt);
			//set the text as soon as its created
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
				//bottomHG.visible = true;
				//doneHG.visible = false;
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
					//Alert.show("Toggling to particular statement");
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
				//Alert.show("Toggling to universal statement");
				stmtTypeLbl.text = "Universal Statement";
				this.setStyle("cornerRadius",30);
			} 
		}
		
	}
}