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
			//two conditions
			var i:int;
			var claim:ArgumentPanel = reason.inference.claim;
			var inference:Inference = reason.inference;
			var currX:int = inference.claim.gridX;
			
			for(i=0;i< inference.reasons.length;i++)
			{
				var currReason:ArgumentPanel = inference.reasons[i];
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
				
				argumentPanel.x = argumentPanel.gridY * uwidth + yPadding;
				argumentPanel.y = argumentPanel.gridX * uwidth + yPadding;
					
				if(argumentPanel is Inference){
					var inference:Inference = Inference(argumentPanel);
					var argType:DisplayArgType = inference.argType;
					argType.x =  inference.x + inference.width/2 - argType.width/2 ;
					argType.y = inference.claim.y;
				}
			}
			ArgumentPanel.parentMap.connectRelatedPanels();
		}
		
		
		public function moveConnectedPanels(claim:ArgumentPanel,diffX:int, diffY:int):void
		{
			//var inference:Inference = claim.rule;
			if(claim.rules.length > 0)
			{
				var inference:Inference = claim.rules[0];
				inference.gridX = inference.gridX + diffX;
				inference.gridY = inference.gridY + diffY;	
				if(inference.rules.length > 0)
				{
					moveConnectedPanels(inference,diffX,diffY);
				}		
			}
	
			if(claim.rules.length > 0)
			{	
				inference = claim.rules[0];
				for(var i:int = 0; i < inference.reasons.length; i++)
				{
					inference.reasons[i].gridX = inference.reasons[i].gridX + diffX;
					inference.reasons[i].gridY = inference.reasons[i].gridY + diffY;
					if(inference.reasons[i].rules.length > 0){
						moveConnectedPanels(inference.reasons[i],diffX,diffY);
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
				if(panel is Inference)
				{
					var currPanel:Inference = panel as Inference;
					var claim:ArgumentPanel = currPanel.claim;
					currPanel.gridX = claim.gridX;		
					currPanel.gridY = claim.gridY;
					if(currPanel.claim.rules[0] == currPanel){
						var plusGridWidth:int = Math.ceil(claim.width / uwidth ) + 2;
						var plusGridHeight:int = Math.ceil(claim.height / uwidth ) + 2;
						panel.gridY = panel.gridY + plusGridWidth;
						panel.gridX = panel.gridX + plusGridHeight;
						//fix the gird positions of the reasons that use this inference rule to lead to the claim.
						if(currPanel.reasons.length > 0)
						{
							var currX:int = claim.gridX;
							var currY:int = currPanel.gridY+Math.ceil(claim.width/uwidth)+1;
							for(var i:int = 0; i < currPanel.reasons.length; i++)
							{
								currPanel.reasons[i].gridX = currX;
								currPanel.reasons[i].gridY = currY;
								currX = currX + Math.ceil(currPanel.reasons[i].height/uwidth) + 1;
							}	
						}
					}
					else
					{
						var lastInference:Inference = currPanel.claim.rules[currPanel.claim.rules.length - 2];
						var lastInferenceGridX:int  = lastInference.gridX + getGridSpan(lastInference.height);
						var lastReason:ArgumentPanel = lastInference.reasons[lastInference.reasons.length - 1];
						var lastReasonGridX:int = lastReason.gridX + getGridSpan(lastReason.height);
						var max:int;
						if(lastInferenceGridX <= lastReasonGridX){
							max = lastReasonGridX;
						}
						else{
							max = lastInferenceGridX;
						}
						max = max + 3;
						plusGridWidth = getGridSpan(claim.width) + 2;
						currPanel.gridY = currPanel.gridY + plusGridWidth;
						currPanel.gridX = max;
						currX = currPanel.gridX;
						currY = currPanel.gridY + getGridSpan(claim.width) + 1;
			
						for(i = 0; i < currPanel.reasons.length; i++)
						{
							currPanel.reasons[i].gridX = currX;
							currPanel.reasons[i].gridY = currY;
							currX = currX + getGridSpan(currPanel.reasons[i].height);
						}
					}
				
				}
			//This module is for a reason added to an existing argument
				else if(panel is ArgumentPanel)
				{
					//establish it's a reason and not the first claim in the map
					if(panel.inference != null)//will be null for the first claim added
					{
						if(panel.inference.reasons.length > 1)
							var lastReasonInd:int = panel.inference.reasons.length - 2;//last reason that was laid out
							var lReason:ArgumentPanel = panel.inference.reasons[lastReasonInd];
							panel.gridY = lReason.gridY;
							panel.gridX = lReason.gridX + Math.ceil(lReason.height/uwidth) + 1;		
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