package Controller
{
	import components.Map;
	
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.core.FlexGlobals;
	import mx.core.INavigatorContent;
	import mx.core.UIComponent;
	import mx.managers.LayoutManager;
	import mx.messaging.messages.ErrorMessage;
	
	import spark.components.VGroup;
	import spark.layouts.VerticalLayout;
	import components.ArgumentPanel;
	import components.GridPanel;
	import components.Inference;
	
	public class LayoutController
	{
		//public var listOfPanels:Vector.<ArgumentPanel>;
		
		public var panelList:Vector.<GridPanel>;
		public var uwidth:int;
		public var yPadding:int;
		public var yArgDistances:int;
		public var yArgDisplay:int;
		
		public function LayoutController()
		{
			//panelList = new Vector.<ArgumentPanel>(0,false);
			panelList = new Vector.<GridPanel>(0,false);
			uwidth = 25;
			yPadding = 0;
			yArgDistances = 10;
			yArgDisplay  = 7;
		}
		/*
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
		*/
		
		public function unregister(panel:ArgumentPanel):void
		{
			var ind:int = panelList.indexOf(panel);
			panelList.splice(ind,1);
		}
		
		public function moveConnectedPanels(claim:ArgumentPanel,diffX:int, diffY:int):void
		{
			/*
			if(claim is Inference){
				var inference:Inference = claim as Inference;
				alignReasons(inference.reasons[0],inference.reasons[0].gridY + diffY);

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
			*/
		}
		
		public function addSavedPanel(panel:GridPanel):void
		{
			panelList.push(panel);
		}
		
		public function getGridPositionX(tmpY :int):int
		{
				return (Math.floor(tmpY/uwidth));
		}
		
		public function getGridPositionY(tmpX:int):int
		{
			return (Math.floor(tmpX/uwidth));
		}
		
		public function tempArrange(panel1:ArgumentPanel):void {
			var currReason:ArgumentPanel = panel1 as ArgumentPanel;
			
			var currClaim:ArgumentPanel = currReason.inference.claim;
			
			currReason.gridY = currClaim.gridY + Math.ceil(currClaim.width / uwidth ) + 2;
			
			currReason.gridX = currClaim.gridX;	
			
		}
		
		
		public function registerPanel(panel1:GridPanel):void
		{
			try{
				if(panel1 is Inference)
				{
					//registerPanel(Inference(panel1).argType);
				}
			//This module is for a reason added to an existing argument
				else if(panel1 is ArgumentPanel)
				{
					
				}
			}
			catch(e:Error)
			{
				Alert.show(e.toString());
			}
			panelList.push(panel1);
			//components.Map(ArgumentPanel.parentMap.parent.parent.parent.parent.parent).update();
		}
		
		public function getGridSpan(pixels:int):int
		{
			return Math.ceil(pixels/uwidth);
		}		
	}	
}