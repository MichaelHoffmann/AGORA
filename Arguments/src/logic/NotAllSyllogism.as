
package logic
{
	import classes.ArgumentPanel;
	
	import mx.controls.Alert;

	public class NotAllSyllogism extends ParentArg
	{
		public function NotAllSyllogism()
		{
			myname = NOT_ALL_SYLL;
			dbName = myname;
			_langTypes = ["Not-all"]; 	// the sole language type here is expandable. always with And.
			isLanguageExp = true;
		}
		
		override public function correctUsage():String {
			var output:String = "";
			var reasonStr:String;
			if(inference.claim.inference != null && !inference.claim.statementNegated)
			{
				Alert.show("Error: Statement cannot be positive");
			}
			
			inference.claim.statementNegated = true;
	
			for(var i:int=0; i < inference.reasons.length; i++)
			{
				if(inference.reasons[i].statementNegated)
				{
					inference.reasons[i].statementNegated = false;	
				}
			}
			
			inference.implies = false;
			
			output += "It cannot be the case, at the same time, that ";
			for(i=0;i<inference.reasons.length;i++)
			{
					output += inference.reasons[i].stmt + " and that ";
					inference.inputs[i+1].text = inference.reasons[i].stmt;
					inference.inputs[i+1].forwardUpdate();
			}
			output += inference.claim.positiveStmt;
			inference.inputs[0].text = inference.claim.positiveStmt;
			inference.inputs[0].forwardUpdate();
			return output;
		}
	}
}