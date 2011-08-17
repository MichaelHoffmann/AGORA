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
		
		//-------------------------- panel moved -----------------------//
		public function movePanel(panel:GridPanel, xgridDiff:int, ygridDiff:int):void{
			if(panel is Inference){
				var inferenceModel:InferenceModel = Inference(panel).inferenceModel;
				model.agoraMapModel.updatePosition(inferenceModel, xgridDiff, ygridDiff);
			}
			else if(panel is ArgumentPanel){
				var statementModel:StatementModel = ArgumentPanel(panel).model;
				model.agoraMapModel.updatePosition(statementModel, xgridDiff, ygridDiff);
			}
			else if(panel is MenuPanel){
				var argumentTypeModel:ArgumentTypeModel = MenuPanel(panel).model;
				model.agoraMapModel.updatePosition(argumentTypeModel, xgridDiff, ygridDiff);
			}
		}
		
		protected function onPositionsUpdated(event:AGORAEvent):void{
			CursorManager.removeAllCursors();
			LoadController.getInstance().fetchMapData();
		}
		
		//------------------------- other public functions --------------------//
		public function setApplicationLayoutProperties():void{
			FlexGlobals.topLevelApplication.map.agora.height =  FlexGlobals.topLevelApplication.map.stage.stageHeight - FlexGlobals.topLevelApplication.map.topPanel.height - FlexGlobals.topLevelApplication.map.container.gap - 30;
			FlexGlobals.topLevelApplication.map.agora.width = FlexGlobals.topLevelApplication.map.stage.stageWidth - 30;
			FlexGlobals.topLevelApplication.map.stage.addEventListener(Event.RESIZE, FlexGlobals.topLevelApplication.map.setWidth);
		}
		
		
		
		/*
		public function alignReasons(reason:ArgumentPanel,tmpY:int):void
		{
			//two conditions
			var i:int;
			var claim:ArgumentPanel = reason.inference.claim;
			var inference:Inference = reason.inference;
			var currX:int = inference.argType.gridX;
			
			for(i=0;i< inference.reasons.length;i++)
			{
				
				var currReason:ArgumentPanel = inference.reasons[i];
				var oldGridX:int = currReason.gridX;
				var oldGridY:int = currReason.gridY;
				currReason.gridY = tmpY;
				currReason.gridX = currX;
				currX = currX + getGridSpan(currReason.height) + 1;
				if(currReason.rules.length > 0)
					moveConnectedPanels(currReason,currReason.gridX - oldGridX, currReason.gridY - oldGridY);
			}
			layoutComponents();
		}
		*/
		
		public function unregister(panel:ArgumentPanel):void
		{
			var ind:int = panelList.indexOf(panel);
			panelList.splice(ind,1);
		}
		
		public function moveConnectedPanels(claim:ArgumentPanel,diffX:int, diffY:int):void
		{
			/*
			if(claim is Inference){
				var inference:Inference = claim as Inference;
				alignReasons(inference.reasons[0],inference.reasons[0].gridY + diffY);

				for( var n:int =0; n < inference.rules.length; n++)
				{
					var currInference:Inference = inference.rules[n];
					currInference.gridX = currInference.gridX + diffX;
					currInference.gridY = currInference.gridY + diffY;
					currInference.argType.gridX = currInference.argType.gridX + diffX;
					currInference.argType.gridY = currInference.argType.gridY + diffY;
					moveConnectedPanels(currInference,diffX,diffY);
				}
	
			}
			else{
				for(var m:int=0; m<claim.rules.length;m++){		
					inference = claim.rules[m];	
					inference.gridX = inference.gridX + diffX;
					inference.gridY = inference.gridY + diffY;	
					inference.argType.gridX = inference.argType.gridX + diffX;
					inference.argType.gridY = inference.argType.gridY + diffY;
						moveConnectedPanels(inference,diffX,diffY);
						
						
				}
			}

			layoutComponents();
			*/
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