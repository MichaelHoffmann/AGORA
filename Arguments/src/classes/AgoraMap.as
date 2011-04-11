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
	import mx.controls.Alert;
	
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
			var listOfPanels:Vector.<ArgumentPanel> = layoutManager.listOfPanels;
			drawUtility.graphics.clear();
			drawUtility.graphics.lineStyle(2,0,1);
			
			
			for(var i:int=0; i<listOfPanels.length; i++)
			{
				var tmp:ArgumentPanel = listOfPanels[i];
				//connect claim to the left edge of the grid box before the one in which the first reason is placed
				//has reasons
				if(tmp.rules.length > 0)
				{
					var prevGrid:int = tmp.rules[0].reasons[0].gridY - 1;
					
					//draw a line from the claim to the grid edge before the first reason
					drawUtility.graphics.moveTo(tmp.x + tmp.width, tmp.y + 30);
					drawUtility.graphics.lineTo( prevGrid * layoutManager.uwidth, tmp.y + 30);
					
					for(var it:int=0; it<tmp.rules[0].reasons.length;it++)
					{
						var currReason:ArgumentPanel = tmp.rules[0].reasons[it];
						drawUtility.graphics.moveTo(prevGrid * layoutManager.uwidth, currReason.gridX * layoutManager.uwidth + 30);
						drawUtility.graphics.lineTo(currReason.gridY * layoutManager.uwidth, currReason.gridX * layoutManager.uwidth + 30);
					
					}
					//draw vertical line
					drawUtility.graphics.moveTo(prevGrid * layoutManager.uwidth,tmp.rules[0].reasons[0].gridX * layoutManager.uwidth + 30);
					drawUtility.graphics.lineTo(prevGrid * layoutManager.uwidth,tmp.rules[0].reasons[tmp.rules[0].reasons.length - 1].gridX * layoutManager.uwidth + 30);
					
					//draw inference
					//assumes equal width for claim and inference rule
					drawUtility.graphics.moveTo(tmp.rules[0].gridY * layoutManager.uwidth + Math.floor(tmp.width/2), tmp.y + 30);
					drawUtility.graphics.lineTo(tmp.rules[0].gridY * layoutManager.uwidth + Math.floor(tmp.width/2), tmp.rules[0].gridX * layoutManager.uwidth);	
				}
				
				
			}
		}
	}
}