package components
{
	import Controller.ArgumentController;
	
	import Model.ArgumentTypeModel;
	
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
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
		private var _model:ArgumentTypeModel;
		public var vgroup:VGroup;
		public var hgroup:HGroup;
		public var addReasonBtn:Button;
		public var changeSchemeBtn:Button;
		
		
		private var _schemeSelector:ArgSelector;
		
		public function MenuPanel()
		{
			super();
			minHeight = 20;
			width = 150;
			this.setStyle("chromeColor",uint("0xdddddd"));
		}


		public function get schemeSelector():ArgSelector
		{
			return _schemeSelector;
		}

		public function set schemeSelector(value:ArgSelector):void
		{
			_schemeSelector = value;
		}

		public function get model():ArgumentTypeModel
		{
			return _model;
		}

		public function set model(value:ArgumentTypeModel):void
		{
			_model = value;
			BindingUtils.bindSetter(this.setX, model, "xgrid");
			BindingUtils.bindSetter(this.setY, model, "ygrid");
		}
		
		//------------------ Bind Setters --------------------------//
		//Buttons must not be enabled when the user is still constructing
		//the argument
		protected function enableAddReason(value:Boolean):void{
			addReasonBtn.enabled = value;
		}
		
		protected function enableChangeScheme(value:Boolean):void{
			changeSchemeBtn.enabled = value;	
		}

		//---------- Event Handlers ---------------------------------//
		protected function onAddReasonClicked(event:MouseEvent):void{
			ArgumentController.getInstance().addReason(model);
		}
		protected function onChangeSchemeClicked(event:MouseEvent):void{
			ArgumentController.getInstance().constructArgument(model);
		}
		
		//------------------- Framework methods---------------------//
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
			
			
			addReasonBtn.addEventListener(MouseEvent.CLICK, onAddReasonClicked);
			changeSchemeBtn.addEventListener(MouseEvent.CLICK, onChangeSchemeClicked);
			
			//set bind setters
			BindingUtils.bindSetter(enableAddReason, model, "reasonsCompleted");
			BindingUtils.bindSetter(enableChangeScheme, model, "reasonsCompleted");
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
