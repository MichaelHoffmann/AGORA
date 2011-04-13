//This class is the canvas on which everything will be drawn
package classes
{
	import flash.display.Graphics;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
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
				var akcdragInitiator:ArgumentPanel = ArgumentPanel(dragEvent.dragInitiator);
				var dragSource:DragSource = dragEvent.dragSource;
				var tmpx:int = int(dragSource.dataForFormat("x"));
				var tmpy:int = int(dragSource.dataForFormat("y"));
				tmpx = currentStage.mouseX -  tmpx;
				tmpy = currentStage.mouseY - tmpy;
					
				var tmpGridX:int = layoutManager.getGridPositionX(tmpy);//In the logical co ordinates x and y are along different axes
				var tmpGridY:int = layoutManager.getGridPositionY(tmpx);//Got to change this though ;-)
				
				var diffX:int = tmpGridX - int(dragSource.dataForFormat("gx"));
				var diffY:int = tmpGridY - int(dragSource.dataForFormat("gy"));
				
				
				if(akcdragInitiator is Inference)
				{
					//figure out if it's allowed
					var currInference:Inference = Inference(akcdragInitiator);
					var lLimit:int = currInference.claim.gridY + layoutManager.getGridSpan(currInference.width);
					var uLimit:int = currInference.reasons[0].gridY - layoutManager.getGridSpan(currInference.width) - 1; 
					if(tmpGridY >= lLimit && tmpGridY <= uLimit)
					{
						currInference.gridX = tmpGridX;
						currInference.gridY = tmpGridY;
						if(currInference.rules.length > 0 )
						{
							layoutManager.moveConnectedPanels(currInference, diffX, diffY);
						}
					}
				}
				
				else if(akcdragInitiator is ArgumentPanel)
				{
					if(akcdragInitiator.inference != null)
					{
						lLimit = akcdragInitiator.inference.gridY + layoutManager.getGridSpan(akcdragInitiator.inference.width);
						if( tmpGridY >= lLimit)
						{
							akcdragInitiator.gridY = tmpGridY;
							layoutManager.alignReasons(akcdragInitiator,tmpGridY);
							if(akcdragInitiator.rules.length > 0 )
							{
								layoutManager.moveConnectedPanels(akcdragInitiator, diffX, diffY);
							}
						}
					}
					else if(akcdragInitiator.inference == null)
					{
						
						akcdragInitiator.gridY = tmpGridY;
						akcdragInitiator.gridX = tmpGridX;
						//layoutManager.alignReasons(akcdragInitiator,tmpGridY);
						if(akcdragInitiator.rules.length > 0)
						{
							layoutManager.moveConnectedPanels(akcdragInitiator, diffX, diffY);
						}
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