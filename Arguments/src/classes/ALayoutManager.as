package classes
{
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.core.INavigatorContent;
	import mx.core.UIComponent;
	import mx.messaging.messages.ErrorMessage;
	
	import spark.components.VGroup;
	import spark.layouts.VerticalLayout;

	public class ALayoutManager
	{
		public var listOfPanels:Vector.<ArgumentPanel>;
		public var uwidth:int;
		public var yPadding:int;
		
		public function ALayoutManager()
		{
			listOfPanels = new Vector.<ArgumentPanel>(0,false);
			uwidth = 25;
			yPadding = 0;
		}
	
		
		public function alignReasons(reason:ArgumentPanel,tmpY:int):void
		{
			var i:int;
			var claim:ArgumentPanel = reason.claim;
			var currX:int = reason.claim.gridX;
			for(i=0;i<claim.reasons.length;i++)
			{
				var currReason:ArgumentPanel = claim.reasons[i];
				currReason.gridY = tmpY;
				currReason.gridX = currX;
				currX = currX + getGridSpan(currReason.height) + 1;
			}
			layoutComponents();
		}
		
		public function unregister(panel:ArgumentPanel):void
		{
			var ind:int = listOfPanels.indexOf(panel);
			listOfPanels.splice(ind,1);
		}
		
		public function layoutComponents():void
		{
			var argumentPanel:ArgumentPanel;
			var i:int;
			
			for( i=0;i<listOfPanels.length;i++)
			{
				argumentPanel = listOfPanels[i];
				argumentPanel = listOfPanels[i];
				argumentPanel.x = argumentPanel.gridY * uwidth + yPadding;
				argumentPanel.y = argumentPanel.gridX * uwidth + yPadding;
			}
			ArgumentPanel.parentMap.connectRelatedPanels();
		}
		
		
		public function moveConnectedPanels(claim:ArgumentPanel,diffX:int, diffY:int):void
		{
			var inference:Inference = claim.rule;
			if(inference != null)
			{
				inference.gridX = inference.gridX + diffX;
				inference.gridY = inference.gridY + diffY;	
				if(inference.rule != null)
				{
					moveConnectedPanels(inference,diffX,diffY);
				}		
			}
	
			if(claim.reasons.length > 0)
			{
				
				for(var i:int = 0; i < claim.reasons.length; i++)
				{
					claim.reasons[i].gridX = claim.reasons[i].gridX + diffX;
					claim.reasons[i].gridY = claim.reasons[i].gridY + diffY;
					if(claim.reasons[i].rule != null){
						moveConnectedPanels(claim.reasons[i],diffX,diffY);
					}
				}
				
			}

			layoutComponents();
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
			try{
			//find out the type and register
			if(panel is Inference)
			{
				var claim:ArgumentPanel = panel.claim;
				panel.gridX = claim.gridX;
				panel.gridY = claim.gridY;
				var plusGridWidth:int = Math.ceil(claim.width / uwidth ) + 1;
				var plusGridHeight:int = Math.ceil(claim.height / uwidth ) + 2;
				panel.gridY = panel.gridY + plusGridWidth;
				panel.gridX = panel.gridX + plusGridHeight;
				
				//fix the gird positions of the reasons that use this inference rule to lead to the claim.
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
				}		
				
			}
			//This module is for a reason added to an existing argument
			else if(panel is ArgumentPanel)
			{
				//establish it's a reason and not the first claim in the map
				if(panel.claim != null)//will be null for the first claim added
				{
					if(panel.claim.rule != null){
						var lastReasonInd:int = panel.claim.reasons.length - 2;//last reason that was laid out
						var lastReason:ArgumentPanel = panel.claim.reasons[lastReasonInd];
						panel.gridY = lastReason.gridY;
						panel.gridX = lastReason.gridX + Math.ceil(lastReason.height/uwidth) + 1;		
					}
				}
			}
			
			
			}
			catch(e:Error)
			{
				Alert.show(e.toString());
			}
			
			listOfPanels.push(panel);
			layoutComponents();
		}
		
		public function getGridSpan(pixels:int):int
		{
			return Math.ceil(pixels/uwidth);
		}
		public function buttonClicked(e:MouseEvent):void
		{
			var tmp:ArgumentPanel = new ArgumentPanel();
			var tgridX:int;
			var tgridY:int;
			try{
				tmp.gridX=2;
				tmp.gridY=3;
				ArgumentPanel.parentMap.addElement(tmp);
				registerPanel(tmp);
				layoutComponents();
			}
			catch(e:Error)
			{
				Alert.show(e.toString());
			}		
		}		
	}	
}