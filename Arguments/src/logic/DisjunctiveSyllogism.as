
package logic
{
	import classes.ArgumentPanel;
	
	import mx.controls.Alert;
	
	public class DisjunctiveSyllogism extends ParentArg
	{
		public function DisjunctiveSyllogism()
		{
			_langTypes = ["Either-or"];
			_expLangTypes =  ["Either-or"];
			myname = DIS_SYLL;
			dbName = myname;
			
		}
		
		override public function correctUsage():String {
			
			if(inference.claim.inference != null && inference.claim.statementNegated)
			{
				Alert.show("Error: Statement cannot be negative");
			}
			if(inference.claim.statementNegated)
				inference.claim.statementNegated = false;
			
			for(var i:int=0; i < inference.reasons.length; i++)
			{
				if(!inference.reasons[i].statementNegated)
				{
					inference.reasons[i].statementNegated = true;
				}
			}
			
			inference.implies = false;
			
			var output:String = "";
			switch(inference.myschemeSel.selectedType) 
			{
				case _langTypes[0]: 
					output += "Either ";
					for(i=0;i<inference.reasons.length;i++)
					{
						output += inference.reasons[i].positiveStmt + " or ";
						inference.inputs[i+1].text = inference.reasons[i].positiveStmt;
					}
					output += inference.claim.stmt;
					inference.inputs[0].text = inference.claim.stmt;
					break;
			}
			return output;
		}
	}
}