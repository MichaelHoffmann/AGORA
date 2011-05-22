
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
			
			inference.claim.statementNegated = false;
			
			for(var i:int=0; i < inference.reasons.length; i++)
			{
				inference.reasons[i].statementNegated = true;	
			}
			
			
			var output:String = "";
			switch(inference.myschemeSel.selectedType) 
			{
				case _langTypes[0]: //Either-or. when both claim and reason are negated
					output += "Either ";
					if(isLanguageExp==true)
						for(i=0;i<inference.reasons.length;i++)
							output += inference.reasons[i].positiveStmt + " or ";
					output += inference.claim.stmt;
					break;
				/*
				case _langTypes[0]: // Unless
					output +=  reason[0].input1.text + " Unless " + claim.stmt;
				*/
			}
			return output;
		}
	}
}