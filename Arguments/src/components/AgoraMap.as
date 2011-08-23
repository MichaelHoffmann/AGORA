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
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	
	public class AgoraMap extends Canvas
	{
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
		}
		
		
		protected function onMapTimer(event:TimerEvent):void{
			LoadController.getInstance().fetchMapData();
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
			//code for the connecting arrows
		}		
	}
}
