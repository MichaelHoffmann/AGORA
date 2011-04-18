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
		public var typeBtn:Button;
		public var inference:Inference;
		//public var type:Label;
		
		public function DisplayArgType()
		{
			super();
		}
		override protected function createChildren():void
		{
			
			super.createChildren();
			//type = new Label;
			vgroup = new VGroup;
			addElement(vgroup);
			//vgroup.addElement(type);
			//type.text = "modus_ponens";
			hgroup = new HGroup;
			vgroup.addElement(hgroup);
			addReasonBtn = new Button;
			addReasonBtn.label = "+R";
			hgroup.addElement(addReasonBtn);
			typeBtn = new Button;
			typeBtn.label = "change..";
			hgroup.addElement(typeBtn);
			height = 20;
			width = 150;
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
			trace("hm..");
			trace(dInitiator);
			DragManager.doDrag(dInitiator,ds,mEvent,null);
			}catch (e:Error){
				trace(e);
			}
		}
		
	}
}