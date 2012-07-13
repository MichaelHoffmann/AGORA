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
	
	import Model.AGORAModel;
	import Model.ArgumentTypeModel;
	
	import Skins.AddButtonSkin;
	import Skins.MenuPanelSkin;
	import Skins.SchemeButtonSkin;
	import Skins.ToggleButtonSkin;
	
	import ValueObjects.AGORAParameters;
	
	import classes.Language;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.containers.Panel;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.core.DragSource;
	import mx.core.FlexBitmap;
	import mx.core.FlexGlobals;
	import mx.core.IUIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.primitives.Ellipse;

	import classes.Language;

	public class MenuPanel extends GridPanel
	{
		private var _model:ArgumentTypeModel;
		private var _agoraConstants:AGORAParameters;
		public var vgroup:HGroup;
		public var hgroup:HGroup;
		public var addReasonBtn:Button;
		public var changeSchemeBtn:Button;
		public var changeButton:Button;
		
		
		
		private var _schemeSelector:ArgSelector;
		
		public function MenuPanel()
		{
			super();
			setStyle("skinClass", MenuPanelSkin);
			setStyle("borderVisible", false);
			minHeight = 20;
			agoraConstants = AGORAParameters.getInstance();
			this.title = agoraConstants.THEREFORE;
		}
		
		public function showArgSelector():void{
			schemeSelector.visible= true;
			PopUpManager.addPopUp(schemeSelector,parent,true);
			schemeSelector.x= this.x+schemeSelector.width;
			schemeSelector.y=this.y+200;
		}
		public function hideArgSelector():void{
			PopUpManager.removePopUp(schemeSelector);
		}
		public function get agoraConstants():AGORAParameters
		{
			return _agoraConstants;
		}

		public function set agoraConstants(value:AGORAParameters):void
		{
			_agoraConstants = value;
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
					changeSchemeBtn.label = Language.lookup("Scheme");
				}else{
					changeSchemeBtn.label = "("+value;
				}
			}
		}
		
		//---------- Event Handlers ---------------------------------//
		protected function onAddReasonClicked(event:MouseEvent):void{
			if(!(AGORAModel.getInstance().userSessionModel.username == "Guest")){
				ArgumentController.getInstance().addReasonToExistingArgument(model);
			} else { 
				Alert.show(Language.lookup("GuestEditMapError"));
			}
		}
		protected function onChangeSchemeClicked(event:MouseEvent):void{
			if(!(AGORAModel.getInstance().userSessionModel.username == "Guest")){
				ArgumentController.getInstance().initiateArgumentConstruction(model);
			} else { 
				Alert.show(Language.lookup("GuestEditMapError"));
			}
		}
		
		//------------------- Framework methods---------------------//
		override protected function createChildren():void
		{
			super.createChildren();
			vgroup = new HGroup;
			vgroup.top=-10;
			vgroup.gap = 0;
			addElement(vgroup);
			addReasonBtn = new Button;
			vgroup.percentWidth = 100;
			vgroup.verticalAlign = "middle";
			addReasonBtn.setStyle("skinClass",AddButtonSkin);
			addReasonBtn.toolTip=Language.lookup('AnotherReasonHelp2');
			changeButton = new Button;
			changeSchemeBtn = new Button;
			changeButton.toolTip=changeButton.toolTip=Language.lookup("ArgSchemeChange");
			changeSchemeBtn.toolTip=changeButton.toolTip=Language.lookup("ArgSchemeChange");
			changeButton.setStyle("skinClass",ToggleButtonSkin);
			var endParen:Label=new Label();
			
			endParen.text=")";
			changeSchemeBtn.width=140;
			changeSchemeBtn.label = "("+( (model != null)?(model.logicClass != null? model.logicClass: Language.lookup("Scheme")) : Language.lookup("Scheme"));
			//titleDisplay.setStyle("textAlign","center");
			changeSchemeBtn.setStyle("skinClass",SchemeButtonSkin);
			addReasonBtn.top = -23;
			addReasonBtn.scaleX=.8;
			addReasonBtn.scaleY=.8;
			addReasonBtn.right = -20;
			
			this.addElement(addReasonBtn);
			vgroup.addElement(changeSchemeBtn);
			vgroup.addElement(changeButton);
			vgroup.addElement(endParen);
			
			addReasonBtn.addEventListener(MouseEvent.CLICK, onAddReasonClicked);
			changeSchemeBtn.addEventListener(MouseEvent.CLICK, onChangeSchemeClicked);
			changeButton.addEventListener(MouseEvent.CLICK, onChangeSchemeClicked);
			changeButton.verticalCenter=0;
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
