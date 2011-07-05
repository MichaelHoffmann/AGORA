package classes
{
	import flash.events.MouseEvent;
	
	import mx.containers.Panel;
	import mx.controls.Label;
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.VGroup;
	
	public class MenuPanel extends GridPanel
	{
		public var vgroup:VGroup;
		public var hgroup:HGroup;
		public var addReasonBtn:Button;
		public var changeSchemeBtn:Button;
		public var inference:Inference;
		
		public function MenuPanel()
		{
			super();
			minHeight = 20;
			width = 150;
			this.setStyle("chromeColor",uint("0xdddddd"));
		}
		override protected function createChildren():void
		{
			super.createChildren();
			vgroup = new VGroup;
			vgroup.gap = 0;
			addElement(vgroup);
			hgroup = new HGroup;
			vgroup.addElement(hgroup);
			addReasonBtn = new Button;
			addReasonBtn.label = "add..";
			hgroup.gap = 0;
			vgroup.percentWidth = 100;
			addReasonBtn.percentWidth = 100;
			
			changeSchemeBtn = new Button;
			changeSchemeBtn.label = "Scheme";
			changeSchemeBtn.percentWidth = 100;
			titleDisplay.setStyle("textAlign","center");
			title = "Therefore";
			vgroup.addElement(changeSchemeBtn);
			vgroup.addElement(addReasonBtn);
			this.titleDisplay.addEventListener(MouseEvent.MOUSE_DOWN,beginDrag);
			addEventListener(FlexEvent.PREINITIALIZE, menuPanelCreated);
		}
		
		private function menuPanelCreated(event:FlexEvent):void{
			try{
				gridX = inference._initXML.connection[0].@x;
				gridY = inference._initXML.connection[1].@y;
			}catch(e:Error){
				trace(e);
			}
		}
		
		public function beginDrag( mEvent:MouseEvent):void
		{
			try{
				var dInitiator:MenuPanel = mEvent.currentTarget.parent.parent.parent.parent.parent as MenuPanel;
				var ds:DragSource = new DragSource;
				ds.addData(dInitiator.mouseX,"x");
				ds.addData(dInitiator.mouseY,"y");
				ds.addData(dInitiator.gridX,"gx");
				ds.addData(dInitiator.gridY,"gy");
				DragManager.doDrag(dInitiator,ds,mEvent,null);
			}catch (e:Error){
				trace(e);
			}
		}
		
	}
}
