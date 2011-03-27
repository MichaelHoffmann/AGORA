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
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Panel;
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
		public var reasons:Vector.<ArgumentPanel>;
		public var claim:ArgumentPanel;
		public var rule:Inference;
		
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
			
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE,onArgumentPanelCreate);	
			this.addEventListener(UpdateEvent.UPDATE_EVENT,adjustHeight);
			
			reasons = new Vector.<ArgumentPanel>(0,false);
			claim = null;
			
		}
		
		
		public function adjustHeight(e:Event):void
		{
		
			if(this.claim != null)
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
		
		public function addReasonHandler(event:MouseEvent):void
		{
			if(this.rule != null){
			var tmp:ArgumentPanel = new ArgumentPanel();
			parentMap.addElement(tmp);
			try{
				reasons.push(tmp);
				tmp.claim = this;
				parentMap.layoutManager.registerPanel(tmp);
			}catch (e:Error)
			{
				Alert.show(e.toString());
			}
			}
			else{
				Alert.show("Reason cannont be added without an argument scheme");
			}
			
		}	
		
		//reason must be registered before inference is
		public function addArgSchemeHandler(event:MouseEvent):void
		{
			//rule = null; //necessary, in case argument scheme is changed
			
			while(reasons.length > 0)
			{
				var	tmp:ArgumentPanel = reasons.pop();
				parentMap.removeChild(tmp);
				tmp = null;
			}
			
			var reason:ArgumentPanel = new ArgumentPanel();
			parentMap.addElement(reason);
			reasons.push(reason);
			reason.claim = this;	
			parentMap.layoutManager.registerPanel(reason);

			
			var inferenceRule:Inference = new Inference;
			inferenceRule.argumentClass = Inference.MODUS_PONENS;
			parentMap.addElement(inferenceRule);
			rule = inferenceRule;
			inferenceRule.claim = this;
			try{
			
			}catch(e:Error)
			{
				Alert.show(e.toString());
			}
			parentMap.layoutManager.registerPanel(inferenceRule);	
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
		
		//create children must be overriden to create dynamically allocated children
		override protected function createChildren():void{
			//create the children of MX Panel
			super.createChildren();		
			
			//create children of Agora Panel
			//create the Dynamic Text Area
			//input1 = new TextInput();
		    input1 = new DynamicTextArea();
			//Create a UIComponent for clicking and dragging
			topArea = new UIComponent;
		
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
			
			//Bottom Panel
			var bLayout:HorizontalLayout = new HorizontalLayout;
			buttonArea = new Panel;
			buttonArea.layout = bLayout;
			reasonButton = new spark.components.Button;
			argschemeButton = new spark.components.Button;
			buttonArea.addElement(reasonButton);
			buttonArea.addElement(argschemeButton);
			buttonArea.height = 20;
			addElement(buttonArea);
			this.reasonButton.label="+reason";
			this.reasonButton.addEventListener(MouseEvent.CLICK,addReasonHandler);
			this.argschemeButton.label="argScheme";
			this.argschemeButton.addEventListener(MouseEvent.CLICK,addArgSchemeHandler);	
		}
		
		public function onArgumentPanelCreate( e:FlexEvent):void
		{
			//remove the default title bar provided by mx
			panelSkin = this.skin as PanelSkin;
			panelSkin.topGroup.includeInLayout = false;
			panelSkin.topGroup.visible = false;
			panelSkin1 = this.buttonArea.skin as PanelSkin;
			panelSkin1.topGroup.includeInLayout = false;
			panelSkin1.topGroup.visible = false;
		}
	}
}