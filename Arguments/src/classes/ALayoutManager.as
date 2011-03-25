package classes
{
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.core.INavigatorContent;
	import mx.core.UIComponent;
	
	import spark.components.VGroup;
	import spark.layouts.VerticalLayout;

	public class ALayoutManager
	{
		public var listOfPanels:Vector.<ArgumentPanel>;
		public var heightVector:Vector.<int>;
		public var pixelVector:Vector.<int>;
		public var presentMatrix:Vector.<Vector.<int>>;
		public var numRows:int;
		public var numColumns:int;
		public var uwidth:int;
		public var yPadding:int;
		
		public function ALayoutManager()
		{
			listOfPanels = new Vector.<ArgumentPanel>(0,false);
			//howMany=0;
			heightVector = new Vector.<int>(100);
			presentMatrix = new Vector.<Vector.<int>>(100,false);
			pixelVector = new Vector.<int>(100,false);
			numRows=0;
			numColumns=0;
			uwidth = 25;
			yPadding = 0;
			for( var i:int=0;i<presentMatrix.length;i++)
			{
				presentMatrix[i] = new Vector.<int>(100,false);
			}
			

			
		}
		
		public function alignReasons(reason:ArgumentPanel,tmpY:int):void
		{
			var i:int;
			var claim:ArgumentPanel = reason.claim;
			for(i=0;i<claim.reasons.length;i++)
			{
				var currReason:ArgumentPanel = claim.reasons[i];
				currReason.gridY = tmpY;
				trace(currReason.gridY);
			}
			layoutComponents();
		}
		
		public function layoutComponents():void
		{
			var argumentPanel:ArgumentPanel;
			var i:int;
			
			for( i=0;i<listOfPanels.length;i++)
			{
				argumentPanel = listOfPanels[i];
				//Alert.show("Called");
				//Alert.show(argumentPanel.height.toString());
				try
				{
					if( argumentPanel.height > heightVector[argumentPanel.gridX])
				{
					
					//Alert.show(heightVector[argumentPanel.gridX].toString());
					heightVector[argumentPanel.gridX] = argumentPanel.height + yPadding;
					if(argumentPanel.gridX < (presentMatrix.length - 1))
					{
						pixelVector[argumentPanel.gridX + 1] = pixelVector[argumentPanel.gridX] + heightVector[argumentPanel.gridX];
					}
				}
				}catch(e:Error)
				{
					trace("size increased");
					heightVector.push(0);
					
				}
				
				ArgumentPanel.parentMap.connectRelatedPanels();
				
			}
			
			for(i=0;i<listOfPanels.length;i++)
			{
				argumentPanel = listOfPanels[i];
				argumentPanel.x = argumentPanel.gridY * uwidth + yPadding;
				//argumentPanel.y = pixelVector[argumentPanel.gridX] + yPadding;
				argumentPanel.y = argumentPanel.gridX * uwidth + yPadding;
			}
			
		}
		
		public function moveComponents(listOfComponents:Vector.<ArgumentPanel>,currGridX:int,currGridY:int,direction:int):void{
			//0 - right
			//1 - down
			try{
			var i:int;
			var component:ArgumentPanel;
		 	if(direction == 0)//right
			{
				for(i=0;i< listOfComponents.length;i++)
				{
					component = listOfComponents[i];
					if(component.gridY >= currGridY)
					{
						component.gridY = component.gridY + 1;
					}
				}
			}
			else if(direction == 1)//down
			{
				for(i=0; i < listOfComponents.length;i++)
				{
					component = listOfComponents[i];
					if(component.gridX >= currGridX)
					{
						component.gridX = component.gridX + 1;
						presentMatrix[component.gridX][component.gridY] = 1;
					}
				}
			}
			}catch(error:Error)
			{
				Alert.show(error.toString());
			}
			presentMatrix[currGridX][currGridY] = 0;
		}
		
		
		public function move(argumentPanel:ArgumentPanel, newGridX:int, newGridY:int):void
		{
			
		}
		
		public function moveConnectedPanels(claim:ArgumentPanel,diffX:int, diffY:int):void
		{
			var inference:Inference = claim.rule;
			if(inference != null)
			{
				//var inference:Inference = claim.rule;
				inference.gridX = inference.gridX + diffX;
				inference.gridY = inference.gridY + diffY;	
				moveConnectedPanels(inference,diffX,diffY);
			}
	
			if(claim.reasons.length > 0)
			{
				var currX:int = claim.gridX;
				var currY:int = claim.rule.gridY+Math.ceil(claim.width/uwidth)+1;
				for(var i:int = 0; i < claim.reasons.length; i++)
				{
					claim.reasons[i].gridX = currX;
					claim.reasons[i].gridY = currY;
					currX = currX + Math.ceil(claim.reasons[i].height/uwidth) + 1;
					moveConnectedPanels(claim.reasons[i],diffX,diffY);
					//layoutArgument(claim.reasons[i]);
				}
				layoutComponents();
			}
		}
		
		//initial layout
		public function layoutArgument(claim:ArgumentPanel) : void
		{
			//layout inference rule
			//get inference
			var inference:Inference = claim.rule;
			if(inference != null)
			{
				//var inference:Inference = claim.rule;
				inference.gridX = claim.gridX;
				inference.gridY = claim.gridY;
				var plusGridWidth:int = Math.ceil(claim.width / uwidth ) + 1;
				var plusGridHeight:int = Math.ceil(claim.height / uwidth ) + 2;
				inference.gridY = inference.gridY + plusGridWidth;
				inference.gridX = inference.gridX + plusGridHeight;
				//layoutArgument(inference);
			}
			//layout reasons
		
			if(claim.reasons.length > 0)
			{
				
				var currX:int = claim.gridX;
				var currY:int = claim.rule.gridY+Math.ceil(claim.width/uwidth)+1;
				for(var i:int = 0; i < claim.reasons.length; i++)
				{
					claim.reasons[i].gridX = currX;
					claim.reasons[i].gridY = currY;
					currX = currX + Math.ceil(claim.reasons[i].height/uwidth) + 1;
				}
				
				layoutComponents();
			}
			
			
		}
		
		public function getGridPositionX(tmpY :int):int
		{
				return (Math.floor(tmpY/uwidth));
		}
		
		public function getGridPositionY(tmpX:int):int
		{
			return (Math.floor(tmpX/uwidth));
		}
		
		public function registerPanel(panel:ArgumentPanel):void
		{
			listOfPanels.push(panel);
		}
		
		public function buttonClicked(e:MouseEvent):void
		{
			var tmp:ArgumentPanel = new ArgumentPanel();
			var tgridX:int;
			var tgridY:int;
			try{
				//Alert.show(ustage.toString());
				tmp.gridX=2;
				tmp.gridY=3;
				
				ArgumentPanel.parentMap.addElement(tmp);
				registerPanel(tmp);
				layoutComponents();
				
				//positionArgumentPanel(tmp,2,3);
			}
			catch(e:Error)
			{
				Alert.show(e.toString());
			}
				
		}
		
	}
	
}