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
		//public var listOfPanels:Vector.<ArgumentPanel>;
		
		public var panelList:Vector.<GridPanel>;
		public var uwidth:int;
		public var yPadding:int;
		public var yArgDistances:int;
		public var yArgDisplay:int;
		
		public function ALayoutManager()
		{
			//panelList = new Vector.<ArgumentPanel>(0,false);
			panelList = new Vector.<GridPanel>(0,false);
			uwidth = 25;
			yPadding = 0;
			yArgDistances = 10;
			yArgDisplay  = 7;
		}
		
		public function alignReasons(reason:ArgumentPanel,tmpY:int):void
		{
			//two conditions
			var i:int;
			var claim:ArgumentPanel = reason.inference.claim;
			var inference:Inference = reason.inference;
			var currX:int = inference.argType.gridX;
			
			for(i=0;i< inference.reasons.length;i++)
			{
				
				var currReason:ArgumentPanel = inference.reasons[i];
				var oldGridX:int = currReason.gridX;
				var oldGridY:int = currReason.gridY;
				currReason.gridY = tmpY;
				currReason.gridX = currX;
				currX = currX + getGridSpan(currReason.height) + 1;
				if(currReason.rules.length > 0)
					moveConnectedPanels(currReason,currReason.gridX - oldGridX, currReason.gridY - oldGridY);
			}
			layoutComponents();
		}
		
		public function unregister(panel:ArgumentPanel):void
		{
			var ind:int = panelList.indexOf(panel);
			panelList.splice(ind,1);
		}
		
		public function layoutComponents():void
		{
			var argumentPanel:GridPanel;
			var i:int;
			
			for( i=0;i<panelList.length;i++)
			{
				argumentPanel = panelList[i];
				argumentPanel.x = argumentPanel.gridY * uwidth + yPadding;
				argumentPanel.y = argumentPanel.gridX * uwidth + yPadding;
			}
			ArgumentPanel.parentMap.connectRelatedPanels();
		}
		
		
		public function moveConnectedPanels(claim:ArgumentPanel,diffX:int, diffY:int):void
		{
			if(claim is Inference){
				var inference:Inference = claim as Inference;
				alignReasons(inference.reasons[0],inference.reasons[0].gridY + diffY);
				/*
				for(var n:int=0; n < inference.reasons.length; n++)
				{
					inference.reasons[n].gridX = inference.reasons[n].gridX + diffX;
					inference.reasons[n].gridY = inference.reasons[n].gridY + diffY;
					if(inference.reasons[n].rules.length > 0)
					{
						moveConnectedPanels(inference.reasons[n],diffX,diffY);
					}
				}
				*/
				for( var n:int =0; n < inference.rules.length; n++)
				{
					var currInference:Inference = inference.rules[n];
					currInference.gridX = currInference.gridX + diffX;
					currInference.gridY = currInference.gridY + diffY;
					currInference.argType.gridX = currInference.argType.gridX + diffX;
					currInference.argType.gridY = currInference.argType.gridY + diffY;
					moveConnectedPanels(currInference,diffX,diffY);
				}
	
			}
			else{
				for(var m:int=0; m<claim.rules.length;m++){		
					inference = claim.rules[m];	
					inference.gridX = inference.gridX + diffX;
					inference.gridY = inference.gridY + diffY;	
					inference.argType.gridX = inference.argType.gridX + diffX;
					inference.argType.gridY = inference.argType.gridY + diffY;
						moveConnectedPanels(inference,diffX,diffY);
						
						
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
		
		public function registerPanel(panel1:GridPanel):void
		{
			try{
				if(panel1 is Inference)
				{
					var currPanel:Inference = panel1 as Inference;
					var claim:ArgumentPanel = currPanel.claim;
					currPanel.gridX = claim.gridX;		
					currPanel.gridY = claim.gridY;
					if(currPanel.claim.rules[0] == currPanel){
						var plusGridWidth:int = Math.ceil(claim.width / uwidth ) + 2;
						var plusGridHeight:int = Math.ceil(claim.height / uwidth ) + 2;
						currPanel.gridY = currPanel.gridY + plusGridWidth;
						currPanel.gridX = currPanel.gridX + plusGridHeight;
						//fix the grid positins of the argument class
						currPanel.argType.gridX = currPanel.claim.gridX;
						currPanel.argType.gridY = currPanel.gridY;
						registerPanel(currPanel.argType);
						//fix the gird positions of the reasons that use this inference rule to lead to the claim.
						if(currPanel.reasons.length > 0)
						{
							var currX:int = claim.gridX;
							var currY:int = currPanel.gridY+Math.ceil(claim.width/uwidth) + 1;
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
						max = max + yArgDistances;
						plusGridWidth = getGridSpan(claim.width) + 2;
						currPanel.gridY = currPanel.gridY + plusGridWidth;
						currPanel.gridX = max;
						currPanel.argType.gridX = currPanel.gridX - yArgDisplay;
						currPanel.argType.gridY = currPanel.gridY;
						registerPanel(currPanel.argType);
						
						currX = currPanel.argType.gridX;
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
				else if(panel1 is ArgumentPanel)
				{
					var panelArg:ArgumentPanel = panel1 as ArgumentPanel;
					//establish it's a reason and not the first claim in the map
					if(panelArg.inference != null)//will be null for the first claim added
					{
						//will not hold for argument classes, and must be modified by a function isFirstReasons()
						if(panelArg.inference.reasons.length > 1)
							var lastReasonInd:int = panelArg.inference.reasons.length - 2;//last reason that was laid out
							var lReason:ArgumentPanel = panelArg.inference.reasons[lastReasonInd];
							panelArg.gridY = lReason.gridY;
							panelArg.gridX = lReason.gridX + Math.ceil(lReason.height/uwidth) + 1;		
					}
				}
			}
			catch(e:Error)
			{
				Alert.show(e.toString());
			}
			panelList.push(panel1);
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