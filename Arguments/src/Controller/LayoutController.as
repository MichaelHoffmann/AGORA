package Controller
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
	
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	import Model.ArgumentTypeModel;
	import Model.InferenceModel;
	import Model.StatementModel;
	
	import components.ArgumentPanel;
	import components.GridPanel;
	import components.Inference;
	import components.Map;
	import components.MenuPanel;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Menu;
	import mx.controls.Text;
	import mx.core.FlexGlobals;
	import mx.core.INavigatorContent;
	import mx.core.LayoutContainer;
	import mx.core.UIComponent;
	import mx.managers.CursorManager;
	import mx.managers.LayoutManager;
	import mx.messaging.messages.ErrorMessage;
	
	import spark.components.VGroup;
	import spark.layouts.VerticalLayout;
	
	public class LayoutController
	{
		//public var listOfPanels:Vector.<ArgumentPanel>;
		
		private static var instance: LayoutController
		private var _model:AGORAModel;
		
		public var panelList:Vector.<GridPanel>;
		public var uwidth:int;
		public var yPadding:int;
		public var yArgDistances:int;
		public var yArgDisplay:int;
		
		public function LayoutController()
		{
			uwidth = 25;
			yPadding = 0;
			yArgDistances = 10;
			yArgDisplay  = 7;
			
			model = AGORAModel.getInstance();
			
			model.agoraMapModel.addEventListener(AGORAEvent.POSITIONS_UPDATED, onPositionsUpdated);
			
		}
		
		//-------------------------- get instance ----------------------//

		public function get model():AGORAModel
		{
			return _model;
		}

		public function set model(value:AGORAModel):void
		{
			_model = value;
		}

		public static function getInstance():LayoutController{
			if(instance == null){
				instance = new LayoutController;
			}
			return instance;
		}
		
		//------------------------- Moving Panels around -----------------------//
		public function movePanel(gridPanel:GridPanel, diffx:int, diffy:int):void{
			if(gridPanel is MenuPanel){
				AGORAModel.getInstance().agoraMapModel.moveStatement(MenuPanel(gridPanel).model, diffx, diffy);
			}
			else if(gridPanel is ArgumentPanel){
				AGORAModel.getInstance().agoraMapModel.moveStatement(ArgumentPanel(gridPanel).model, diffx, diffy);
			}
		}
		
		protected function onPositionsUpdated(event:AGORAEvent):void{
			LoadController.getInstance().fetchMapData();
		}
		
		//------------------------- other public functions --------------------//
		public function setApplicationLayoutProperties():void{
			FlexGlobals.topLevelApplication.map.agora.height =  FlexGlobals.topLevelApplication.map.stage.stageHeight - FlexGlobals.topLevelApplication.map.topPanel.height - FlexGlobals.topLevelApplication.map.container.gap - 30;
			FlexGlobals.topLevelApplication.map.agora.width = FlexGlobals.topLevelApplication.map.stage.stageWidth - 30;
			FlexGlobals.topLevelApplication.map.stage.addEventListener(Event.RESIZE, FlexGlobals.topLevelApplication.map.setWidth);
		}
		
		public function getBottomReason(atm:ArgumentTypeModel):StatementModel{
			var reason:StatementModel;
			var lastReason:StatementModel;
			lastReason = atm.reasonModels[0];
			for each(reason in atm.reasonModels){
				if(reason.xgrid > lastReason.xgrid){
					lastReason = reason;
				}
			}
			return lastReason;
		}
		
		public function getBottomArgument(sm:StatementModel):ArgumentTypeModel{
			var atm:ArgumentTypeModel;
			var lastATM:ArgumentTypeModel = sm.supportingArguments[0];
			for each(atm in sm.supportingArguments){
				if(atm.xgrid > lastATM.xgrid){
					lastATM = atm;
				}
			}
			return lastATM;
		}	
		
		
		public function addSavedPanel(panel:GridPanel):void
		{
			panelList.push(panel);
		}
		
		public function getGridPositionX(tmpY :int):int
		{
				return (Math.floor(tmpY/uwidth));
		}
		
		public function getGridPositionY(tmpX:int):int
		{	
			return (Math.floor(tmpX/uwidth));
		}
		
		public function tempArrange(panel1:ArgumentPanel):void {
			var currReason:ArgumentPanel = panel1 as ArgumentPanel;
			
			var currClaim:ArgumentPanel = currReason.inference.claim;
			
			currReason.gridY = currClaim.gridY + Math.ceil(currClaim.width / uwidth ) + 2;
			
			currReason.gridX = currClaim.gridX;	
			
		}
		
		
		public function registerPanel(panel1:GridPanel):void
		{
			try{
				if(panel1 is Inference)
				{
					//registerPanel(Inference(panel1).argType);
				}
			//This module is for a reason added to an existing argument
				else if(panel1 is ArgumentPanel)
				{
					
				}
			}
			catch(e:Error)
			{
				Alert.show(e.toString());
			}
			panelList.push(panel1);
			//components.Map(ArgumentPanel.parentMap.parent.parent.parent.parent.parent).update();
		}
		
		public function getGridSpan(pixels:int):int
		{
			return Math.ceil(pixels/uwidth);
		}		
	}	
}