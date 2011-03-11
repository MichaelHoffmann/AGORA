package classes
{
	import mx.controls.Alert;
	import mx.controls.Text;
	
	import spark.layouts.VerticalLayout;

	public class ALayoutManager
	{
		public var heightVector:Vector.<int>;
		public var pixelVector:Vector.<int>;
		public var presentMatrix:Vector.<Vector.<int>>;
		public var numRows:int;
		public var numColumns:int;
		public var uwidth:int;
		public var yPadding:int;
		
		public function ALayoutManager()
		{
			heightVector = new Vector.<int>(100,false);
			presentMatrix = new Vector.<Vector.<int>>(100,false);
			pixelVector = new Vector.<int>(100,false);
			numRows=0;
			numColumns=0;
			uwidth = 250;
			yPadding = 20;
			for( var i:int=0;i<presentMatrix.length;i++)
			{
				presentMatrix[i] = new Vector.<int>(100,false);
			}
		}
		
		
		public function layoutComponents(listOfComponents:Vector.<ArgumentPanel>):void
		{
			var argumentPanel:ArgumentPanel;
			var i:int;
			
			for( i=0;i<listOfComponents.length;i++)
			{
				argumentPanel = listOfComponents[i];
				//Alert.show("Called");
				//Alert.show(argumentPanel.height.toString());
				if( argumentPanel.height > heightVector[argumentPanel.gridX])
				{
					
					//Alert.show(heightVector[argumentPanel.gridX].toString());
					heightVector[argumentPanel.gridX] = argumentPanel.height + yPadding;
					if(argumentPanel.gridX < (presentMatrix.length - 1))
					{
						pixelVector[argumentPanel.gridX + 1] = pixelVector[argumentPanel.gridX] + heightVector[argumentPanel.gridX];
					}
				}
				
			}
			
			for(i=0;i<listOfComponents.length;i++)
			{
				argumentPanel = listOfComponents[i];
				argumentPanel.x = argumentPanel.gridY * uwidth + yPadding;
				argumentPanel.y = pixelVector[argumentPanel.gridX] + yPadding;
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
		
		public function positionArgumentPanel(listOfPanels:Vector.<ArgumentPanel>,component:ArgumentPanel,currGridX:int, currGridY:int):void
		{
			if(presentMatrix[currGridX][currGridY] != 0)
			{
				moveComponents(listOfPanels, currGridX, currGridY,0);
			}
			component.gridX = currGridX;
			component.gridY = currGridY;
			
			presentMatrix[currGridX][currGridY] = 1;
			listOfPanels.push(component);
			layoutComponents(listOfPanels);
			
			
		}
	}
	
}