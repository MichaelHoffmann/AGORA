package components
{

	/**
	 AGORA - an interactive and web-based argument mapping tool that stimulates reasoning, 
	 reflection, critique, deliberation, and creativity in individual argument construction 
	 and in collaborative or adversarial settings. 
	 Copyright (C) 2011 Georgia Institute of Technology
	 
	 This program is free software: you can redistribute it and/or modify
	 it under the terms of the GNU Affero General Public License as
	 published by the Free Software Foundation, either version 3 of the
	 License, or (at your option) any later version.
	 
	 This program is distributed in the hope that it will be useful,
	 but WITHOUT ANY WARRANTY; without even the implied warranty of
	 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	 GNU Affero General Public License for more details.
	 
	 You should have received a copy of the GNU Affero General Public License
	 along with this program.  If not, see <http://www.gnu.org/licenses/>.
	 
	 */
	import Controller.ArgumentController;
	
	import Model.ArgumentTypeModel;
	
	import Model.ArgumentTypeModel;

	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.containers.Panel;
	import mx.controls.Label;
	import mx.core.DragSource;
	import mx.core.FlexBitmap;
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
			BindingUtils.bindSetter(this.setSchemeText, model, "logicClass");
			
		}
		
		//------------------ Bind Setters --------------------------//
		//Buttons must not be enabled when the user is still constructing
		//the argument
		protected function enableAddReason(value:Boolean):void{
			//if(value && schemeSelector.visible == false){
				addReasonBtn.enabled = value;	
			//}
		}
		
		protected function enableChangeScheme(value:Boolean):void{
			changeSchemeBtn.enabled = value;	
		}
		
		protected function setSchemeText(value:String):void{
			//This should happen only after changeSchemeBtn is created
			if(changeSchemeBtn){
				if(value == null){
					changeSchemeBtn.label = "Scheme";
				}else{
					changeSchemeBtn.label = value;
				}
			}
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
			changeSchemeBtn.label =  (model != null)?(model.logicClass != null? model.logicClass: 'Scheme') : 'Scheme';
			changeSchemeBtn.percentWidth = 100;
			titleDisplay.setStyle("textAlign","center");
			//title = Language.lookup("Therefore");
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
				var dInitiator:MenuPanel = this;//mEvent.currentTarget.parent.parent.parent.parent.parent as MenuPanel;
				var ds:DragSource = new DragSource;
				ds.addData(dInitiator.mouseX,"x");
				ds.addData(dInitiator.mouseY,"y");
				ds.addData(dInitiator.model.xgrid,"gx");
				ds.addData(dInitiator.model.ygrid,"gy");
				DragManager.doDrag(dInitiator,ds,mEvent,null);
			}catch (e:Error){
				trace(e);
			}
		}
		
	}
}
