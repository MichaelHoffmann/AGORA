package classes
{
	import flash.events.MouseEvent;
	
	import mx.containers.Panel;
	import mx.controls.Label;
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.VGroup;

	public class DisplayArgType extends GridPanel
	{
		public var vgroup:VGroup;
		public var hgroup:HGroup;
		public var addReasonBtn:Button;
		public var changeSchemeBtn:Button;
		public var inference:Inference;
		public var schemeText:String;
		public var schemeTextIndex:int;
		public var connText:String;
		
		public function DisplayArgType()
		{
			super();
			minHeight = 20;
			this.setStyle("chromeColor",uint("0xdddddd"));
		}
		override protected function createChildren():void
		{
			super.createChildren();
			vgroup = new VGroup;
			addElement(vgroup);
			hgroup = new HGroup;
			vgroup.addElement(hgroup);
			addReasonBtn = new Button;
			addReasonBtn.label = "+R";
			hgroup.gap = 0;
			hgroup.addElement(addReasonBtn);
			changeSchemeBtn = new Button;
			changeSchemeBtn.label = "Change Scheme";
			hgroup.addElement(changeSchemeBtn);
			this.titleDisplay.addEventListener(MouseEvent.MOUSE_DOWN,beginDrag);
		}
		public function beginDrag( mEvent:MouseEvent):void
		{
			try{
			var dInitiator:DisplayArgType = mEvent.currentTarget.parent.parent.parent.parent.parent as DisplayArgType;
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