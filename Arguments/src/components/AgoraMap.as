//This class is the canvas on which everything will be drawn
package components
{
	import Controller.ArgumentController;
	import Controller.LayoutController;
	import Controller.LoadController;
	import Controller.logic.ConditionalSyllogism;
	import Controller.logic.DisjunctiveSyllogism;
	import Controller.logic.ModusPonens;
	import Controller.logic.ModusTollens;
	import Controller.logic.NotAllSyllogism;
	import Controller.logic.ParentArg;
	
	import Events.AGORAEvent;
	
	import Model.AGORAModel;
	import Model.ArgumentTypeModel;
	import Model.InferenceModel;
	import Model.StatementModel;
	
	import ValueObjects.AGORAParameters;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Menu;
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	
	public class AgoraMap extends Canvas
	{
		public static const BY_ARGUMENT:String = "ByArgument";
		public static const BY_CLAIM:String = "ByClaim";
		
		public var beganBy:String;
		public var drawUtility:UIComponent = null;
		public var ID:int;
		public var option:Option;
		public var helpText:HelpText;
		private static var _tempID:int;
		public var timer:Timer;
		
		public var panelsHash:Dictionary;
		public var menuPanelsHash:Dictionary;
		
		public function AgoraMap()
		{	
			addEventListener(DragEvent.DRAG_ENTER,acceptDrop);
			addEventListener(DragEvent.DRAG_DROP,handleDrop );
			timer = new Timer(30000);
			timer.addEventListener(TimerEvent.TIMER, onMapTimer);
			panelsHash = new Dictionary;
			menuPanelsHash = new Dictionary;
			//default
			beganBy = BY_CLAIM;
		}
		
		
		protected function onMapTimer(event:TimerEvent):void{
			//LoadController.getInstance().fetchMapData();
		}
		
		public function getGlobalCoordinates(point:Point):Point
		{
			return localToGlobal(point);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			drawUtility = new UIComponent();
			this.parent.addChild(drawUtility);
			option = new Option;
			addChild(option);
			option.visible = false;
			
			helpText = new HelpText;
			addChild(helpText);
			helpText.visible = false;
		}
		public function acceptDrop(d:DragEvent):void
		{
			DragManager.acceptDragDrop(Canvas(d.currentTarget));
		}
		
		public function handleDrop(dragEvent:DragEvent):void
		{	
			var currentStage:Canvas = Canvas(dragEvent.currentTarget);
			var gridPanel:GridPanel = dragEvent.dragInitiator as GridPanel;
			var dragSource:DragSource = dragEvent.dragSource;
			var tmpx:int = int(dragSource.dataForFormat("x"));
			var tmpy:int = int(dragSource.dataForFormat("y"));
			tmpx = currentStage.mouseX - tmpx;
			tmpy = currentStage.mouseY - tmpy;
			var toxgrid:int = Math.floor(tmpy/AGORAParameters.getInstance().gridWidth);
			var toygrid:int = Math.floor(tmpx/AGORAParameters.getInstance().gridWidth);
			var diffx:int = toxgrid - int(dragSource.dataForFormat("gx"));
			var diffy:int = toygrid - int(dragSource.dataForFormat("gy"));
			
			LayoutController.getInstance().movePanel(gridPanel,diffx, diffy);
			
		}
		
		override protected function commitProperties():void{
			super.commitProperties();
			var newPanels:ArrayCollection = AGORAModel.getInstance().agoraMapModel.newPanels; 
			for(var i:int=0; i< newPanels.length; i++){
				if(StatementModel(newPanels[i]).statementFunction == StatementModel.INFERENCE){
					var inference:ArgumentPanel = new ArgumentPanel;
					inference.model = newPanels[i];
					panelsHash[inference.model.ID] = inference;
					addChild(inference);
				}
				else if(newPanels[i] is StatementModel){
					if(newPanels[i] is StatementModel){
						var model:StatementModel = newPanels[i];
						var argumentPanel:ArgumentPanel = new ArgumentPanel;
						argumentPanel.model = model;
						panelsHash[model.ID] = argumentPanel;
						argumentPanel.addEventListener(AGORAEvent.STATEMENT_STATE_TO_EDIT, ArgumentController.getInstance().removeOption);
						if(model.argumentTypeModel){
							if(!model.argumentTypeModel.reasonsCompleted)
							{
								if(model.argumentTypeModel.reasonModels.length == 1){
									argumentPanel.branchControl = new Option;
									argumentPanel.branchControl.x = argumentPanel.x + AGORAParameters.getInstance().gridWidth * 9;
									argumentPanel.branchControl.y = argumentPanel.y;
									argumentPanel.branchControl.argumentTypeModel = model.argumentTypeModel;
									addChild(argumentPanel.branchControl);
								}
							}
						}
						addChild(argumentPanel);
					}
				}
			}
			var newMenuPanels:ArrayCollection = AGORAModel.getInstance().agoraMapModel.newConnections;
			for each(var argumentTypeModel:ArgumentTypeModel in newMenuPanels){
				var menuPanel:MenuPanel = new MenuPanel;
				menuPanel.model = argumentTypeModel;
				menuPanel.schemeSelector = new ArgSelector;
				menuPanel.schemeSelector.visible = false;
				menuPanel.schemeSelector.argumentTypeModel = argumentTypeModel;
				menuPanelsHash[menuPanel.model.ID] =  menuPanel;
				addChild(menuPanel);
				addChild(menuPanel.schemeSelector);
			}
			
			LoadController.getInstance().mapUpdateCleanUp();
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			connectRelatedPanels();
		}
		
		public function addable():Boolean
		{
			if(option.visible == true)
				return false;
			else
				return true;
		}
		
		public function connectRelatedPanels():void
		{
			var panelList:Dictionary = panelsHash;			
			drawUtility.depth = this.numChildren;
			drawUtility.graphics.clear();
			drawUtility.graphics.lineStyle(2,0,1);
			var gridWidth:int = AGORAParameters.getInstance().gridWidth;
			var layoutController:LayoutController = LayoutController.getInstance();
			var statementModel:StatementModel;
			var argumentTypeModel:ArgumentTypeModel;
			//code for the connecting arrows
			
			for each(var model:StatementModel in AGORAModel.getInstance().agoraMapModel.panelListHash){
				if(model.supportingArguments.length > 0){
					//First Vertical Line Starting Point
					var argumentPanel:ArgumentPanel = panelsHash[model.ID]; 
					var fvlspx:int = ((argumentPanel.x + argumentPanel.width)/gridWidth + 2) * gridWidth;
					var fvlspy:int = argumentPanel.y + 30;
					//First Vertical Line Finishing Point
					var lastMenuPanel:MenuPanel = menuPanelsHash[layoutController.getBottomArgument(model).ID];
					var fvlfpy:int = (lastMenuPanel.y + 30);
					//draw a line
					drawUtility.graphics.moveTo(fvlspx, fvlspy);
					drawUtility.graphics.lineTo(fvlspx, fvlfpy);
					
					//Line from claim to vertical line starting point
					var firstMenuPanel:MenuPanel = menuPanelsHash[model.supportingArguments[0].ID];
					drawUtility.graphics.moveTo(argumentPanel.x + argumentPanel.width, argumentPanel.y + 30);
					drawUtility.graphics.lineTo(fvlspx, firstMenuPanel.y + 30);
					
					//for each argument
					for each(argumentTypeModel in model.supportingArguments){
						//get the point one grid before the first reason horizontally.
						var rspx:int = (argumentTypeModel.reasonModels[0].ygrid - 1) * gridWidth;
						var rspy:int = argumentTypeModel.reasonModels[0].xgrid * gridWidth + 30;
						//get the point in front of the last reason
						var rfpy:int = layoutController.getBottomReason(argumentTypeModel).xgrid * gridWidth + 30;
						
						//draw a line
						drawUtility.graphics.moveTo(rspx, rspy);
						drawUtility.graphics.lineTo(rspx, rfpy);
						
						var menuPanel:MenuPanel = menuPanelsHash[argumentTypeModel.ID];
						//Line from menu Panel to the starting point of reason vertical line
						drawUtility.graphics.moveTo(menuPanel.x + menuPanel.width, menuPanel.y + 30);
						drawUtility.graphics.lineTo(rspx, menuPanel.y + 30);
						
						//Line from first vertical line to menu Panel
						drawUtility.graphics.moveTo(fvlspx, menuPanel.y + 30);
						drawUtility.graphics.lineTo(menuPanel.x, menuPanel.y + 30);
						
						//Line from menuPanel to Inference
						var inferencePanel:ArgumentPanel = panelsHash[argumentTypeModel.inferenceModel.ID];
						if(inferencePanel.visible){
							drawUtility.graphics.moveTo(menuPanel.x + menuPanel.width/2, menuPanel.y+menuPanel.height);
							drawUtility.graphics.lineTo(menuPanel.x + menuPanel.width/2, inferencePanel.y);
						}
						for each(statementModel in argumentTypeModel.reasonModels){
							//hline
							var poReason:int = statementModel.xgrid * gridWidth + 30;
							drawUtility.graphics.moveTo(rspx, poReason);
							drawUtility.graphics.lineTo(statementModel.ygrid * gridWidth, poReason);
						}
					}
					
				} 
			}
		}		
	}
}
