package classes
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.binding.utils.BindingUtils;
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.TextInput;
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
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
		public var input1:DynamicTextArea;
		public var topArea:UIComponent;
		public var panelSkin:PanelSkin;
		public var panelSkin1:PanelSkin;
		public var doneButton:spark.components.Button;
		public var argschemeButton:spark.components.Button;
		public var savedText:String;
		public static var parentMap:AgoraMap;
		public var inference:Inference;		//back reference
		public var bottomH:HGroup;
		public var topH:HGroup;
		public var rules:Vector.<Inference>;	//forward reference
		public var binders:Vector.<Binder>;
		public var state:int;	//state=0 -> universal statement and state=1 -> particular statement
		
		public static const ARGUMENT_PANEL:int = 0;
		public static const INFERENCE:int = 1;
		public var MODE:int = 1;	// mode:0 means construct by reason, mode:1 means construct by argument scheme
		
		public var lab:Label;
		public var panelType:int;
		public var thereforeLine:UIComponent;
		public var thereforeText:Label;
		public var negated:Boolean;		// negated = 0 means no - it is positive. negated = 1 means yes - it is negative. Useful for Modus Tollens and Disjunctive Syllogism
		
		public function ArgumentPanel()
		{
			super();
			
			var uLayout:VerticalLayout = new VerticalLayout;
			uLayout.paddingBottom = 10;
			uLayout.paddingLeft = 10;
			uLayout.paddingRight = 10;
			uLayout.paddingTop = 10;
			width = 180;
			minHeight = 100;
			this.layout = uLayout;
			panelType = ArgumentPanel.ARGUMENT_PANEL;			
			this.addEventListener(FlexEvent.CREATION_COMPLETE,onArgumentPanelCreate);	
			this.addEventListener(UpdateEvent.UPDATE_EVENT,adjustHeight);
			inference = null;
			rules = new Vector.<Inference>(0,false);

			lab = new Label;
			// default setting
			if(this is Inference) lab.text = "Universal Statement";
			else lab.text = "Particular Statement";
			lab.toolTip = "Whether a statement is universal or particular determines what kind of objections are possible against it. " +
				"A 'universal statement' is defined here as a statement that can be falsified by one counter-example. " +
				"In this sense, laws, rules, and all statements that include 'ought' or 'should,' etc., are universal statements." +
				" Anything else is treated as a particular statement, including statements about possibilities. CLICK TO CHANGE";
			lab.addEventListener(MouseEvent.CLICK,toggle);
			
			bottomH = new HGroup();
			doneButton = new spark.components.Button;
			doneButton.label = "Done";
			bottomH.addElement(doneButton);
			doneButton.addEventListener(MouseEvent.CLICK,doneHandler);
			
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
				parentMap.layoutManager.alignReasons(this, this.gridY);
		}
		
		public function beginDrag( mouseEvent: MouseEvent ):void
		{
			try{
				var	dinitiator:UIComponent = UIComponent(mouseEvent.currentTarget);
				var dPInitiator:ArgumentPanel = ArgumentPanel(dinitiator.parent.parent.parent.parent.parent.parent);
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
		public function addArgSchemeHandler(event:MouseEvent):void
		{
			//create an inference
			var currInference:Inference = new Inference();
			//add the inference to map
			parentMap.addElement(currInference);
			//add inference to the list of inferences
			rules.push(currInference);
			//set the claim of the inference rule to this
			currInference.claim = this;
			//set the class of the reason
			//currInference.argumentClass = Inference.MODUS_PONENS;
			//if(MODE==0) { currInference.visible = false;
			//	currInference.argType.visible = false; }
			
			//create a reason node
			var reason:ArgumentPanel = new ArgumentPanel();
			//add reason to the map
			parentMap.addElement(reason);
			//push reason to the list of reasons belonging to this particular class
			currInference.reasons.push(reason);
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
			
			for each (var dta:DynamicTextArea in input1.forwardList)
			{
				trace(dta);
			}
			
			//create an invisible box for the reason
			var tmpInput2:DynamicTextArea = new DynamicTextArea();
			parentMap.addElement(tmpInput2);
			tmpInput2.visible = false;
			tmpInput2.panelReference = currInference;
			currInference.input.push(tmpInput2);	
			
			tmpInput2.forwardList.push(currInference.input1);
			reason.input1.forwardList.push(tmpInput2);
			
			input1.forwardUpdate();		//claim	
			reason.input1.forwardUpdate();		//reason

			parentMap.layoutManager.registerPanel(currInference);	
		}
		
		public function checkForEnter(event:KeyboardEvent):void{
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
				
				//create an invisible box for the reason
				var tmpInput2:DynamicTextArea = new DynamicTextArea();
				parentMap.addElement(tmpInput2);
				tmpInput2.visible = false;
				tmpInput2.panelReference = currInference;
				currInference.input.push(tmpInput2);	
				
				tmpInput2.forwardList.push(currInference.input1);
				reason.input1.forwardList.push(tmpInput2);
				input1.forwardUpdate();		//claim	
				reason.input1.forwardUpdate();		//reason
				
				
				// deactive the DONE button to avoid duplicate action
				doneButton.removeEventListener(MouseEvent.CLICK,doneHandler);
			}
		}
		
		public function doneHandler(d:MouseEvent):void{
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
		override protected function createChildren():void{
			//create the children of MX Panel
			super.createChildren();		
			
			//create children of Agora Panel
			//create the Dynamic Text Area
			//input1 = new TextInput();
			input1 = new DynamicTextArea();
			input1.panelReference = this;
			input1.toolTip = "Otherwise, if you wish to start with Argument Scheme, click on the Add arg button below (do NOT press enter too)";
			if(this.panelType==ARGUMENT_PANEL) {
			input1.addEventListener(MouseEvent.CLICK,textBoxClicked);
			input1.addEventListener(MouseEvent.MOUSE_OUT,movedAway);
			input1.addEventListener(KeyboardEvent.KEY_DOWN,checkForEnter); }
			//Create a UIComponent for clicking and dragging
			topArea = new UIComponent;
			
			topH = new HGroup();
			addElement(topH);
			
			//Draw on topArea UIComponent a rectangle
			//to be used for clicking and dragging
			topArea.graphics.beginFill(0xdddddd,1.0);
			topArea.graphics.drawRect(0,0,40,20);
			topArea.width = 40;
			topArea.height = 20;
			topArea.addEventListener(MouseEvent.MOUSE_DOWN,beginDrag);
			topH.addElement(topArea);
			topH.addElement(lab);
			
			//Register event handlers
			//Creation Complete event handlers
			//this.input1.addEventListener(FlexEvent.CREATION_COMPLETE,onArgumentPanelChildrenCreate);
			//this.input2.addEventListener(FlexEvent.CREATION_COMPLETE,onArgumentPanelChildrenCreate);
			//this.topArea.addEventListener(FlexEvent.CREATION_COMPLETE,onArgumentPanelChildrenCreate);
			
			
			//add the elements to the display list
			//of the application. 
			//addChild --> Halo
			//addElement --> Spark
			//addElement(topArea);
			addElement(input1);	
			addElement(bottomH);
			
			argschemeButton = new spark.components.Button;
			argschemeButton.label = "Add arg";
			bottomH.addElement(argschemeButton);
			argschemeButton.addEventListener(MouseEvent.CLICK,addArgSchemeHandler);
			
		}
		
		public function onArgumentPanelCreate(e:FlexEvent):void
		{
			//remove the default title bar provided by mx
			panelSkin = this.skin as PanelSkin;
			panelSkin.topGroup.includeInLayout = false;
			panelSkin.topGroup.visible = false;
			
			//panelSkin1 = this.buttonArea.skin as PanelSkin;
			//panelSkin1.topGroup.includeInLayout = false;
			//panelSkin1.topGroup.visible = false;
			if(this.panelType==ARGUMENT_PANEL)
			input1.text = "[Enter your claim/reason]. Pressing Enter afterwards will prompt you for a reason";

		}
		
		public function toggle(m:MouseEvent):void
		{
			if(this.state==0) {
				if(this.panelType!=INFERENCE){
				//Alert.show("Toggling to particular statement");
				state = 1;
				lab.text = "Particular Statement";
				this.setStyle("cornerRadius",0);}
				else {
	 			Alert.show("Inference can only be Universal Statement. Therefore, cannot change");
				lab.text = "Universal Statement"; }
			} 
			else {
				state = 0;
				//Alert.show("Toggling to universal statement");
				lab.text = "Universal Statement";
				this.setStyle("cornerRadius",30);
			} 
		}
		
	}
}