//This class is the canvas on which everything will be drawn
package classes
{
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
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
		public function AgoraMap()
		{
			layoutManager = new ALayoutManager;	
			addEventListener(DragEvent.DRAG_ENTER,acceptDrop);
			addEventListener(DragEvent.DRAG_DROP,handleDrop );	
		}
		
		public function panelCreated(event   : FlexEvent):void{
			var panel:ArgumentPanel = event.target as ArgumentPanel;
			panel.input1.text = panel.savedText;
		}
		
		public function load( event:Event):void{
			var xmlData:XML = new XML(event.target.data);
			var textboxes:XMLList = xmlData.textbox;
			var textbox_map:Object = new Object;
			
			for each (var xml:XML in textboxes)
			{
				textbox_map[xml.attribute("ID")] = xml.attribute("text");
			}
			
			var nodes_map:Object = new Object;
			var nodes:XMLList = xmlData.node;
			
			for each ( xml in nodes)
			{
				var argumentPanel:ArgumentPanel = null;
				if(xml.attribute("Type") == "Inference")
				{
					argumentPanel = new Inference;
					addElement(argumentPanel);
				}
				else{
					argumentPanel = new ArgumentPanel;
					addElement(argumentPanel);//createChildren called
					argumentPanel.input1.text = textbox_map[xml.nodetext.attribute("ID")];
				}
				nodes_map[xml.attribute("ID")] = argumentPanel;
				argumentPanel.gridX = xml.attribute("gridX");
				argumentPanel.gridY = xml.attribute("gridY");				
				layoutManager.panelList.push(argumentPanel);
			}
			
			var connections_map:Object = new Object;
			var connections:XMLList = xmlData.connection;
			for each( xml in connections)
			{
				//find the target node - claim
				var claim:ArgumentPanel = nodes_map[xml.attribute("targetnode")];
				//find the inference node
				var inference:Inference = null;
				var sources:XMLList = xml.sourcenode;
				var panel:ArgumentPanel;
				for each ( var sourcenode:XML in sources )
				{
					panel = nodes_map[sourcenode.attribute("nodeID")];
					if( panel is Inference){
						inference = Inference(panel);
						inference.argType.gridX = xml.attribute("gridX");
						inference.argType.gridY = xml.attribute("gridY");
						layoutManager.addSavedPanel(inference.argType);
					}
				}
				claim.rules.push(inference);
				inference.claim = claim;
				var dta:DynamicTextArea = new DynamicTextArea;
				addElement(dta);
				dta.visible = false;
				dta.panelReference = inference;
				inference.input.push(dta);
				dta.forwardList.push(inference.input1);
				claim.input1.forwardList.push(dta);
				//forward update should be called only after all links are created.
				//That is, wait for the reasons to be added too.
				//Not doing this might result in accessing illegal memory
				
				for each ( sourcenode in sources )
				{
					panel = nodes_map[sourcenode.attribute("nodeID")];
					if(!(panel is Inference)){
						inference.reasons.push(panel);
						panel.inference = inference;
						dta = new DynamicTextArea;
						addElement(dta);
						dta.visible=false;
						dta.panelReference = inference;
						inference.input.push(dta);
						dta.forwardList.push(inference.input1);
						panel.input1.forwardList.push(dta);
						panel.input1.forwardUpdate();
					}
				}
				claim.input1.forwardUpdate();
			}
			layoutManager.layoutComponents();
			
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			drawUtility = new UIComponent();
			addElement(drawUtility);
		}
		public function acceptDrop(d:DragEvent):void
		{
			DragManager.acceptDragDrop(Canvas(d.currentTarget));
		}
		
		public function handleDrop(dragEvent:DragEvent):void
		{	
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
						//currInference.gridY = tmpGridY;
	
						//currInference.argType.gridX = currInference.argType.gridX + diffX;
						//currInference.argType.gridY = currInference.argType.gridY + diffY;
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
				else if(akcdragInitiator1 is DisplayArgType)
				{
	
					var argdisplay:DisplayArgType = akcdragInitiator1 as DisplayArgType;
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
		}
		
		public function connectRelatedPanels():void
		{
			//var panelList:Vector.<ArgumentPanel> = layoutManager.panelList;
			var panelList:Vector.<GridPanel> = layoutManager.panelList;
			drawUtility.graphics.clear();
			drawUtility.graphics.lineStyle(2,0,1);
			
			
			for(var i:int=0; i<panelList.length; i++)
			{
				var tmp1:GridPanel = panelList[i];
				if(tmp1 is ArgumentPanel){
					var tmp:ArgumentPanel = tmp1 as ArgumentPanel;
					var m:int;
					for(m = 0; m < tmp.rules.length; m++)
					{
						var gridy:int = tmp.rules[0].claim.gridY +  layoutManager.getGridSpan(tmp.rules[0].claim.width) + 1;
						drawUtility.graphics.moveTo(gridy * layoutManager.uwidth, tmp.rules[m].argType.y + 30);
						drawUtility.graphics.lineTo(tmp.rules[m].argType.x, tmp.rules[m].argType.y + 30);
						drawUtility.graphics.moveTo(tmp.rules[m].argType.x + tmp.rules[m].argType.width/2, tmp.rules[m].argType.y + tmp.rules[m].argType.height);
						drawUtility.graphics.lineTo(tmp.rules[m].argType.x + tmp.rules[m].argType.width/2, tmp.rules[m].y);
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
					}
					
				}
			}
			

		}
	}
}