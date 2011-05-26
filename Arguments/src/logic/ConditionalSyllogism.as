package logic
{
	import classes.ArgumentPanel;
	import classes.DynamicTextArea;
	
	import mx.controls.Alert;
	
	public class ConditionalSyllogism extends ParentArg
	{		
		public var built:Boolean;	
		
		public function ConditionalSyllogism()
		{
			_langTypes = ["If-then","Implies"];
			myname = COND_SYLL;
			dbName = "ConSyllogism";
			built = false;
			// Both types here are expandable. like a chain rule
		}
		
		override public function addInitialReasons():void
		{
			if(inference == null)
			{
				//Help for programming. Translation not required. 
				Alert.show("Error: This logic class is not associated with an enabler");
				return;
			}
			var claim:ArgumentPanel = inference.claim;
			var reasons:Vector.<ArgumentPanel> = inference.reasons;
			if(!reasons[0].multiStatement)
			{
				reasons[0].multiStatement = true;
				reasons[0].implies = true;
				reasons[0].inputs[1].editable = false;
				reasons[0].connectingStr = inference.myschemeSel.selectedType;
			}
		}
		
		override public function createLinks():void
		{
			var claim:ArgumentPanel = inference.claim;
			if(claim.inference == null && claim.rules.length)
			{
				claim.multiStatement = true;
				claim.implies = true;
				addInitialReasons();
			}
			
			if(inference.claim.multiStatement)
			{
				//link: claim's premise to first reason's premise
				link(inference.claim.inputs[1],inference.reasons[0].inputs[1]);
				for(var i:int = 0; i < inference.reasons.length - 1; i++)
				{
					//a reson's conclusion is the next reasons premise
					//all of them are implies boxes
					link(inference.reasons[i].inputs[0],inference.reasons[i+1].inputs[1]);
				}
				link(inference.reasons[i].inputs[0],inference.inputs[1]);
				link(inference.reasons[i].inputs[0],inference.input[0]);
				//claim's conclusion to enabler's conclusion
				link(inference.claim.inputs[0],inference.inputs[0]);
				link(inference.claim.inputs[1],inference.input[0]);
				link(inference.input[0],inference.input1);
				inference.claim.inputs[1].forwardUpdate();	
				inference.claim.inputs[0].forwardUpdate();
				inference.reasons[0].inputs[0].forwardUpdate();	
			}
		}
		
		override public function correctUsage():String {
			var output:String = "";
			var i:int;
			
			switch(inference.myschemeSel.selectedType)
			{
				case _langTypes[0]:
					inference.inputs[1].text = inference.reasons[inference.reasons.length - 1].inputs[0].text;
					if(inference.claim.multiStatement)
					{
						inference.inputs[0].text = inference.claim.inputs[0].text;
					}
					output = "If " + inference.inputs[1].text + ", then " +  inference.inputs[0].text;
					inference.inputs[1].forwardUpdate();
					inference.inputs[0].forwardUpdate();
					break;
				case _langTypes[1]:
					inference.inputs[1].text = inference.reasons[inference.reasons.length - 1].inputs[0].text;
					if(inference.claim.multiStatement)
					{
						inference.inputs[0].text = inference.claim.inputs[0].text;
					}
					output = inference.inputs[1].text + " implies " + inference.inputs[0].text;
			}
			return output;
		}
	}
}