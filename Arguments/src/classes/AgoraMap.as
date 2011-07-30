//This class is the canvas on which everything will be drawn
package classes
{
	import Controller.ArgumentController;
	import Controller.LoadController;
	
	import Model.AGORAModel;
	import Model.ArgumentTypeModel;
	import Model.InferenceModel;
	import Model.StatementModel;
	
	import components.ArgSelector;
	import components.HelpText;
	import components.Option;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import logic.ConditionalSyllogism;
	import logic.DisjunctiveSyllogism;
	import logic.ModusPonens;
	import logic.ModusTollens;
	import logic.NotAllSyllogism;
	import logic.ParentArg;
	
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
		public var layoutManager:ALayoutManager = null;
		public var drawUtility:UIComponent = null;
		public var ID:int;
		public var option:Option;
		public var helpText:HelpText;
		private static var _tempID:int;
		public var initXML:XML;
		public static var dbTypes:Array = ["MP","MT","DisjSyl","NotAllSyl","CS", "CD"];
		public var timer:Timer;
		
		public var panelsHash:Dictionary;
		
		
		public function AgoraMap()
		{
			layoutManager = new ALayoutManager;	
			addEventListener(DragEvent.DRAG_ENTER,acceptDrop);
			addEventListener(DragEvent.DRAG_DROP,handleDrop );
			addEventListener(FlexEvent.CREATION_COMPLETE, mapCreated);
			timer = new Timer(30000);
			timer.addEventListener(TimerEvent.TIMER, onMapTimer);
			panelsHash = new Dictionary;
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
		/*
		public function getConnection( claim:ArgumentPanel):XML
		{
			
			var coordinate:Coordinate = new Coordinate;
			var argTypeCoordinate:Coordinate = new Coordinate;
			var reasonCoordinate:Coordinate = new Coordinate;
			
			coordinate.gridX = claim.gridX;
			coordinate.gridY = claim.gridY;
			
			//First rule
			//if(claim.rules.length == 0)
			{
				coordinate.gridX += Math.ceil(claim.height / layoutManager.uwidth ) + 2;
				coordinate.gridY +=  Math.ceil(claim.width / layoutManager.uwidth ) + 2;
			}
				//Not First Rule
			//else
			{
			//	var lastInference:Inference = claim.rules[claim.rules.length - 1];
			//	var lastInferenceGridX:int  = lastInference.gridX + layoutManager.getGridSpan(lastInference.height);
			//	var lastReason:ArgumentPanel = lastInference.reasons[lastInference.reasons.length - 1];
				var lastReasonGridX:int = lastReason.gridX + layoutManager.getGridSpan(lastReason.height);
				var max:int;
				
				if(lastInferenceGridX <= lastReasonGridX){
					max = lastReasonGridX;
				}
				else{
					max = lastInferenceGridX;
				}
				max = max + layoutManager.yArgDistances;
				coordinate.gridY = coordinate.gridY + layoutManager.getGridSpan(claim.width) + 2;
				coordinate.gridX = max;
			}
			
			if(claim.rules.length == 0){
				argTypeCoordinate.gridX = claim.gridX;
				argTypeCoordinate.gridY = coordinate.gridY;
			}
			else{
				argTypeCoordinate.gridX = coordinate.gridX - layoutManager.yArgDisplay;
				argTypeCoordinate.gridY = coordinate.gridY;
			}
			
			reasonCoordinate.gridX = argTypeCoordinate.gridX;
			reasonCoordinate.gridY = coordinate.gridY + Math.ceil(claim.width/layoutManager.uwidth) + 1;
			
			var xml:XML = <map>
							<textbox text=""/>
							<textbox text=""/>
							<textbox text=""/>
							<node Type="Standard" typed="0" is_positive="1" x={reasonCoordinate.gridX} y={reasonCoordinate.gridY}>
								<nodetext/><nodetext/><nodetext/>
							</node>
							<node Type="Inference" typed="0" is_positive="1" x={coordinate.gridX} y={coordinate.gridY}>
							</node>
							<connection type="Unset" x={argTypeCoordinate.gridX} y={argTypeCoordinate.gridY} />
						 </map>
			
			//setting the ID of the map
			xml.@ID = ID;
			
			//temporary IDs for the three new textboxes
			var textboxesList:XMLList = xml.textbox;
			for each(var textbox:XML in textboxesList)
			{
				textbox.@TID = tempID;
			}
			var nodeList:XMLList = xml.node;
			for each(var node:XML in nodeList)
			{
				node.@TID = tempID;
			}
			//set the node text for the reason box (standard)
			var reasonNode:XML = nodeList[0];
			var nodetextList:XMLList = reasonNode.nodetext;
			for each(var nodetext:XML in nodetextList)
			{
				nodetext.@TID = tempID;
			}
			for(var i:int = 0; i < nodetextList.length(); i++)
			{
				nodetextList[i].@textboxTID = textboxesList[i].@TID;
			}
			
			//add a connection
			var newConnXML:XML = xml.connection[0];
			newConnXML.@TID = tempID;
			//newConnXML.@targetnodeID = claim.ID;
			for(i=0; i<nodeList.length(); i++)
			{
				var sourcenodeXML:XML = <sourcenode />;
				sourcenodeXML.@TID = tempID;
				sourcenodeXML.@nodeTID = nodeList[i].@TID;
				newConnXML.appendChild(sourcenodeXML);
			}
			return xml;
		}
		*/
		
		public function getAddReason(inference:Inference):XML
		{
			//cannot be the first reason
			//get the recently added reason
			var reason:ArgumentPanel = inference.reasons[inference.reasons.length - 1];
			var coordinate:Coordinate = new Coordinate;
			coordinate.gridX = reason.gridX + layoutManager.getGridSpan(reason.height) + 1;
			coordinate.gridY = reason.gridY;
			
			var xml:XML=<map>
						<textbox text=""/>
						<textbox text=""/>
						<textbox text=""/>
						<node Type="Standard" typed="0" is_positive="1" x={coordinate.gridX} y={coordinate.gridY}>
							<nodetext/>
							<nodetext/>
							<nodetext/>
						</node>
						<connection></connection>
						</map>;
		
			xml.@ID = ID;
			var textboxesList:XMLList = xml.textbox;
			for each(var textbox:XML in textboxesList)
			{
				textbox.@TID = tempID;
			}
			var nodeList:XMLList = xml.node;
			
			for each(var node:XML in nodeList)
			{
				node.@TID = tempID;
			}
			var reasonNode:XML = nodeList[0];
			var nodetextList:XMLList = reasonNode.nodetext;
			for(var i:int = 0; i < nodetextList.length(); i++)
			{
				nodetextList[i].@textboxTID = textboxesList[i].@TID;
			}
			//add connection
			var connection:XML = xml.connection[0];
			connection.@ID = inference.connID;
			connection.@type = inference.myArg.dbType;
			connection.@x = inference.argType.gridX;
			connection.@y = inference.argType.gridY;
			//connection.@targetnode = inference.claim.ID;
			//add a sourcenode to the connection
			var sourcenode:XML = <sourcenode />;
			sourcenode.@TID = tempID;
			sourcenode.@nodeTID = reasonNode.@TID;
			connection.appendChild(sourcenode);
			return xml;
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
			/*
			try{
				
				var currentStage:Canvas = Canvas(dragEvent.currentTarget);
				var akcdragInitiator1:GridPanel =  dragEvent.dragInitiator as GridPanel;
				var dragSource:DragSource = dragEvent.dragSource;
				var tmpx:int = int(dragSource.dataForFormat("x"));
				var tmpy:int = int(dragSource.dataForFormat("y"));
				tmpx = currentStage.mouseX -  tmpx;
				tmpy = currentStage.mouseY - tmpy;
				
				var tmpGridX:int = layoutManager.getGridPositionX(tmpy);//In the logical co ordinates x and y are along different axes
				var tmpGridY:int = layoutManager.getGridPositionY(tmpx);//Got to change this though ;-)
				
				var diffX:int = tmpGridX - int(dragSource.dataForFormat("gx"));
				var diffY:int = tmpGridY - int(dragSource.dataForFormat("gy"));
				
				if(akcdragInitiator1 is Inference)
				{
					var akcdragInitiator:ArgumentPanel = ArgumentPanel(dragEvent.dragInitiator);
					//figure out if it's allowed
					var currInference:Inference = Inference(akcdragInitiator);
					var lLimit:int = currInference.claim.gridY + layoutManager.getGridSpan(currInference.width);
					var uLimit:int = currInference.reasons[0].gridY - layoutManager.getGridSpan(currInference.width) - 1; 
					if(tmpGridY >= lLimit && tmpGridY <= uLimit)
					{
						currInference.gridX = tmpGridX;
						if(currInference.rules.length > 0 )
						{
							layoutManager.moveConnectedPanels(currInference, diffX, 0);
						}
					}
				}
					
				else if(akcdragInitiator1 is ArgumentPanel)
				{
					akcdragInitiator = akcdragInitiator1 as ArgumentPanel;
					akcdragInitiator.gridY = tmpGridY;
					if(akcdragInitiator.inference == null)
					{
						akcdragInitiator.gridX = tmpGridX;
					}
					else
					{
						layoutManager.alignReasons(akcdragInitiator,tmpGridY);
					}
					for(var i:int=0; i < akcdragInitiator.rules.length; i++)
					{
						akcdragInitiator.rules[i].gridY = akcdragInitiator.rules[i].gridY + diffY;
						
						akcdragInitiator.rules[i].argType.gridY = akcdragInitiator.rules[i].argType.gridY + diffY;
						if(akcdragInitiator.inference == null)
						{
							akcdragInitiator.rules[i].argType.gridX=akcdragInitiator.rules[i].argType.gridX + diffX;
							akcdragInitiator.rules[i].gridX = akcdragInitiator.rules[i].gridX + diffX;
							layoutManager.moveConnectedPanels(akcdragInitiator.rules[i],diffX,diffY);
						}
						else
						{
							layoutManager.moveConnectedPanels(akcdragInitiator.rules[i], 0, diffY);
						}
						
					}
				}
				else if(akcdragInitiator1 is MenuPanel)
				{
					var argdisplay:MenuPanel = akcdragInitiator1 as MenuPanel;
					if(argdisplay.inference != argdisplay.inference.claim.rules[0]){
						argdisplay.gridX = argdisplay.gridX + diffX;
						argdisplay.inference.gridX = argdisplay.inference.gridX + diffX;
						layoutManager.moveConnectedPanels(argdisplay.inference,diffX,0);
					}
				}
		
				
			}catch(error:Error)
			{
				Alert.show(error.message.toString());
			}
			layoutManager.layoutComponents();
			*/
		}
		
		override protected function commitProperties():void{
			var newPanels:ArrayCollection = AGORAModel.getInstance().agoraMapModel.newPanels; 
			for(var i:int=0; i< newPanels.length; i++){
				if(newPanels[i] is InferenceModel){
					var inference:Inference = new Inference;
					inference.model = newPanels[i];
					panelsHash[inference.model.ID] = inference;
					var xWatcherSetter:ChangeWatcher = BindingUtils.bindSetter(inference.setX, inference.model, "xgrid", true);
					var yWatcherSetter:ChangeWatcher = BindingUtils.bindSetter(inference.setY, inference.model, "ygrid", true);
					addChild(inference);
				}
				else if(newPanels[i] is StatementModel){
					var argumentPanel:ArgumentPanel = new ArgumentPanel;
					argumentPanel.statementModel = newPanels[i];
					var xWatcherSetter:ChangeWatcher = BindingUtils.bindSetter(argumentPanel.setX, argumentPanel.statementModel, "xgrid", true);
					var yWatcherSetter:ChangeWatcher = BindingUtils.bindSetter(argumentPanel.setY, argumentPanel.statementModel, "ygrid", true);
					addChild(argumentPanel);
				}
			}
			var newMenuPanels:ArrayCollection = AGORAModel.getInstance().agoraMapModel.newConnections;
			for each(var argumentTypeModel:ArgumentTypeModel in newMenuPanels){
				var menuPanel:MenuPanel = new MenuPanel;
				menuPanel.model = argumentTypeModel;
				var xWatcherSetterMenuPanel:ChangeWatcher = BindingUtils.bindSetter(menuPanel.setX, menuPanel.model, "xgrid", true);
				var yWatcherSetterMenuPanel:ChangeWatcher = BindingUtils.bindSetter(menuPanel.setY, menuPanel.model, "ygrid", true);
				addChild(menuPanel);
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
