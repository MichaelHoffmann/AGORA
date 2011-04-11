package classes
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
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
	import spark.components.VGroup;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	import spark.skins.spark.PanelSkin;
	
	public class ArgumentPanel extends Panel
	{
		public var input1:DynamicTextArea;
		public var topArea:UIComponent;
		public var buttonArea:Panel;
		public var panelSkin:PanelSkin;
		public var panelSkin1:PanelSkin;
		public var gridX:int;
		public var gridY:int;
		public var reasonButton:spark.components.Button;
		public var argschemeButton:spark.components.Button;
		public static var parentMap:AgoraMap;
		//public var reasons:Vector.<ArgumentPanel>;
		public var inference:Inference;
		//public var rule:Inference;
		public var logicalContainer:HGroup;
		public var rules:Vector.<Inference>;
		public var binders:Vector.<Binder>;
		
		public static const ARGUMENT_PANEL:int = 0;
		public static const INFERENCE:int = 1;
		
		
		public var panelType:int;
		
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
			//binders = new Vector.<Binder>(0,false);
			inference = null;
			rules = new Vector.<Inference>(0,false);
			
		}
		
		
		public function adjustHeight(e:Event):void
		{
			
			if(this is Inference)
			{
				//do nothing
			}
			else if(this.inference != null)
				parentMap.layoutManager.alignReasons(this, this.gridY);
		}
		
		public function beginDrag( mouseEvent: MouseEvent ):void
		{
			try{
				var	dinitiator:UIComponent = UIComponent(mouseEvent.currentTarget);
				var dPInitiator:ArgumentPanel = ArgumentPanel(dinitiator.parent.parent.parent.parent.parent);
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
		
		
		/*
		public function deleteChildren(claim:ArgumentPanel):void
		{
			if(claim.rule != null)
			{
				while(claim.reasons.length > 0)
				{
					var currReason:ArgumentPanel = claim.reasons.pop();
					deleteNode(currReason);
				}
				deleteNode(claim.rule);
			}
			
			
		}
		
		
		public function deleteNode(claim:ArgumentPanel):void
		{
			if(claim.rule != null)
			{
				while(claim.reasons.length > 0)
				{
					var currReason:ArgumentPanel = claim.reasons.pop();
					deleteNode(currReason);
					//ArgumentPanel.parentMap.removeChild(claim.claim.reasons[claim.reasons.length-1]);
				}
				deleteNode(claim.rule);
				claim.rule = null;
				ArgumentPanel.parentMap.removeChild(claim);
			}
			else if(claim.rule == null)
			{
				ArgumentPanel.parentMap.removeChild(claim);
				ArgumentPanel.parentMap.layoutManager.unregister(claim);
			}
			
		}

		*/
		//reason must be registered before inference is
		//user must not change the inference rule. He creates the inference rule
		//through argument type, reasons and claim
		public function addArgSchemeHandler(event:MouseEvent):void
		{
			//create an inference
			var currInference:Inference = new Inference;
			//add the inference to map
			parentMap.addElement(currInference);
			//add inference to the list of inferences
			rules.push(currInference);
			//set the claim of the inference rule to this
			currInference.claim = this;
			//set the class of the reason
			currInference.argumentClass = Inference.MODUS_PONENS;
			
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
			this.input1.forwardList.push(currInference.input[0]);
			
			//create an invisible box for the reason
			tmpInput = new DynamicTextArea();
			parentMap.addElement(tmpInput);
			tmpInput.visible = false;
			tmpInput.panelReference = currInference;
			currInference.input.push(tmpInput);	
			
			tmpInput.forwardList.push(currInference.input1);
			reason.input1.forwardList.push(tmpInput);
				
			input1.forwardUpdate();
			reason.input1.forwardUpdate();
			
			try{
				
			}catch(e:Error)
			{
				Alert.show(e.toString());
			}

			parentMap.layoutManager.registerPanel(currInference);	
		}	
		
		public function linkBoxes(a:ArgumentPanel,b:ArgumentPanel,g:Group):void
		{
			var drawUtility:UIComponent = new UIComponent;
			g.addElement(drawUtility);
			try{
				drawUtility.graphics.clear();
				drawUtility.graphics.lineStyle(2.0,0x000000,1.0);
				drawUtility.graphics.moveTo(a.x + 100, a.y + 40);
				drawUtility.graphics.lineTo(b.x, b.y + 40);
			}catch(problem:Error)
			{
				Alert.show(problem.toString());
			}
		}
		
		public function getString():String{
			return input1.text;
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
			//Create a UIComponent for clicking and dragging
			topArea = new UIComponent;
			
			logicalContainer = new HGroup();
			//Register event handlers
			//Creation Complete event handlers
			//this.input1.addEventListener(FlexEvent.CREATION_COMPLETE,onArgumentPanelChildrenCreate);
			//this.input2.addEventListener(FlexEvent.CREATION_COMPLETE,onArgumentPanelChildrenCreate);
			//this.topArea.addEventListener(FlexEvent.CREATION_COMPLETE,onArgumentPanelChildrenCreate);
			
			//Draw on topArea UIComponent a rectangle
			//to be used for clicking and dragging
			topArea.graphics.beginFill(0xdddddd,1.0);
			topArea.graphics.drawRect(0,0,20,20);
			topArea.width = 20;
			topArea.height = 20;
			topArea.addEventListener(MouseEvent.MOUSE_DOWN,beginDrag);
			
			//add the elements to the display list
			//of the application. 
			//addChild --> Halo
			//addElement --> Spark
			addElement(topArea);
			addElement(input1);	
			addElement(logicalContainer);
			
			//Bottom Panel
			/*
			var bLayout:HorizontalLayout = new HorizontalLayout;
			buttonArea = new Panel;
			buttonArea.layout = bLayout;
			reasonButton = new spark.components.Button;
			argschemeButton = new spark.components.Button;
			//buttonArea.addElement(reasonButton);
			buttonArea.addElement(argschemeButton);
			buttonArea.height = 20;
			addElement(buttonArea);
			this.reasonButton.label="+reason";
			//this.reasonButton.addEventListener(MouseEvent.CLICK,addReasonHandler);
			this.argschemeButton.label="argScheme";
			this.argschemeButton.addEventListener(MouseEvent.CLICK,addArgSchemeHandler);	
			*/
			argschemeButton = new spark.components.Button;
			argschemeButton.label = "+ Args";
			logicalContainer.addElement(argschemeButton);
			argschemeButton.addEventListener(MouseEvent.CLICK,addArgSchemeHandler);
		}
		
		public function onArgumentPanelCreate( e:FlexEvent):void
		{
			//remove the default title bar provided by mx
			panelSkin = this.skin as PanelSkin;
			panelSkin.topGroup.includeInLayout = false;
			panelSkin.topGroup.visible = false;
			
			//panelSkin1 = this.buttonArea.skin as PanelSkin;
			//panelSkin1.topGroup.includeInLayout = false;
			//panelSkin1.topGroup.visible = false;
		}
	}
}