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
		public var layoutManager:LayoutController = null;
		public var drawUtility:UIComponent = null;
		public var ID:int;
		public var option:Option;
		public var helpText:HelpText;
		private static var _tempID:int;
		public var initXML:XML;
		public static var dbTypes:Array = ["MP","MT","DisjSyl","NotAllSyl","CS", "CD"];
		public var timer:Timer;
		
		public var panelsHash:Dictionary;
		public var menuPanelsHash:Dictionary;
		
		public function AgoraMap()
		{
			layoutManager = new LayoutController;	
			addEventListener(DragEvent.DRAG_ENTER,acceptDrop);
			addEventListener(DragEvent.DRAG_DROP,handleDrop );
			addEventListener(FlexEvent.CREATION_COMPLETE, mapCreated);
			timer = new Timer(30000);
			timer.addEventListener(TimerEvent.TIMER, onMapTimer);
			panelsHash = new Dictionary;
			menuPanelsHash = new Dictionary;
		}
		
		
		protected function onMapTimer(event:TimerEvent):void{
			LoadController.getInstance().fetchMapData();
		}
		
		private function mapCreated(event:FlexEvent):void
		{
		}
		
		public function getAP():XML
		{
			var xml:XML=<map><textbox text=""/><textbox text=""/><textbox text=""/><node TID="1" Type="Standard" typed="0" is_positive="1"  x="2" y="3"  ><nodetext/><nodetext /><nodetext /></node></map>;
			xml.@ID = ID;
			var textboxesList:XMLList = xml.textbox;
			for each(var textbox:XML in textboxesList)
			{
				textbox.@TID = tempID;
			}
			xml.node.@TID = tempID;
			var nodetextlist:XMLList = xml.node.nodetext;
			for each(var nodetext:XML in nodetextlist)
			{
				nodetext.@TID = tempID;
			}
			for(var i:int = 0; i < nodetextlist.length(); i++)
			{
				nodetextlist[i].@textboxTID = textboxesList[i].@TID;
			}
			return xml;
		}
		
		public function getAddReason(inference:Inference):XML
		{
			
			return new XML;
			
		}
		
		public static function get tempID():int
		{
			_tempID = _tempID + 1;
			return 	_tempID - 1;
		}
		
		public function panelCreated(event:FlexEvent):void{
			var panel:ArgumentPanel = event.target as ArgumentPanel;
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
			
			var panelList:Vector.<GridPanel> = layoutManager.panelList;
			drawUtility.depth = this.numChildren;
			drawUtility.graphics.clear();
			drawUtility.graphics.lineStyle(2,0,1);
			
			/*
			for(var i:int=0; i<panelList.length; i++)
			{
			//Drawing an arrow. Arrows are always pointing towards the left on the claim.
			var tmp1:GridPanel = panelList[i];
			if(tmp1 is ArgumentPanel){
			var tmp:ArgumentPanel = tmp1 as ArgumentPanel;
			var m:int;
			for(m = 0; m < tmp.rules.length; m++)
			{
			//for each  rule
			var gridy:int = tmp.rules[0].claim.gridY +  layoutManager.getGridSpan(tmp.rules[0].claim.width) + 1;
			//horizontal lines to argType box
			drawUtility.graphics.moveTo(gridy * layoutManager.uwidth, tmp.rules[m].argType.y + 30);
			drawUtility.graphics.lineTo(tmp.rules[m].argType.x, tmp.rules[m].argType.y + 30);
			//vertical line from argtype to inference box
			if(tmp.rules[m].visible == true)
			{
			drawUtility.graphics.moveTo(tmp.rules[m].argType.x + tmp.rules[m].argType.width/2, tmp.rules[m].argType.y + tmp.rules[m].argType.height);
			drawUtility.graphics.lineTo(tmp.rules[m].argType.x + tmp.rules[m].argType.width/2, tmp.rules[m].y);
			}
			//an inference always has reasons
			var gridyreasons:int = tmp.rules[m].reasons[0].gridY - 1;
			for(var n:int = 0; n < tmp.rules[m].reasons.length; n++){
			//draw a line from the prev grid to the current reason
			drawUtility.graphics.moveTo(gridyreasons * layoutManager.uwidth, tmp.rules[m].reasons[n].y + 30);
			drawUtility.graphics.lineTo(tmp.rules[m].reasons[n].x, tmp.rules[m].reasons[n].y + 30);
			}
			
			drawUtility.graphics.moveTo(gridyreasons * layoutManager.uwidth, tmp.rules[m].reasons[0].y + 30);
			drawUtility.graphics.lineTo(gridyreasons * layoutManager.uwidth, tmp.rules[m].reasons[n-1].y + 30);
			
			drawUtility.graphics.moveTo(tmp.rules[m].argType.x  + tmp.rules[m].argType.width, tmp.rules[m].argType.y + 30);
			drawUtility.graphics.lineTo(gridyreasons * layoutManager.uwidth, tmp.rules[m].reasons[0].y + 30);
			
			}
			if(tmp.rules.length > 0){
			gridy = tmp.rules[0].claim.gridY +  layoutManager.getGridSpan(tmp.rules[0].claim.width) + 1;
			//vert line
			drawUtility.graphics.moveTo(gridy * layoutManager.uwidth, tmp.rules[0].argType.y+30);
			drawUtility.graphics.lineTo(gridy * layoutManager.uwidth, tmp.rules[m-1].argType.y + 30);
			
			//first horizontal line
			drawUtility.graphics.moveTo(tmp.x + tmp.width, tmp.y + 30);
			drawUtility.graphics.lineTo(gridy * layoutManager.uwidth, tmp.rules[0].argType.y + 30);
			//draw an arrow
			drawUtility.graphics.moveTo(tmp.x + tmp.width, tmp.y + 30);
			drawUtility.graphics.lineTo(tmp.x + tmp.width + 5, tmp.y + 30 - 5);
			drawUtility.graphics.moveTo(tmp.x + tmp.width, tmp.y + 30);
			drawUtility.graphics.lineTo(tmp.x + tmp.width + 5, tmp.y + 30 + 5);
			}	
			}
			
			}
			*/
		}		
	}
}
