package logic
{
	import classes.ArgumentPanel;
	
	import mx.controls.Alert;
	
	public class ModusTollens extends ParentArg
	{ 
		public var andOr:String;
		private var _isExp:Boolean;
		
		public function ModusTollens()
		{
			_langTypes = ["If-then","Implies","Whenever","Only if","Provided that","Sufficient condition","Necessary condition"];
			_expLangTypes = ["Only if"];	// Expandable with both And and Or
			myname = MOD_TOL;
			dbName = myname;	
		}
		
		override public function correctUsage():String {
			var output:String = "";
			var reason:Vector.<ArgumentPanel> = inference.reasons;
			var claim:ArgumentPanel = inference.claim;
			
			//Negate the claim if it is the first claim of the argument
			if(inference.claim.inference != null && !inference.claim.statementNegated)
			{
				Alert.show("Error: The claim should not have been a non-negative statement");
			}
			if(!inference.claim.statementNegated)
			{
				inference.claim.statementNegated = true;	
			}
			
			for(var i:int = 0; i < inference.reasons.length; i++)
			{
				if(!inference.reasons[i].statementNegated)
				{
					inference.reasons[i].statementNegated = true;
				}
			}
			//Negate the reason. The reason will not be supported by other
			//arguments. If it were, the argument woud have had 'typed' true,
			//and myArg would not be pointing to a Modus Tollens Object
			
			switch(inference.myschemeSel.selectedType) {
				//negate reason				
				case _langTypes[0]: //If-then. If both claim and reason negated
					//output += "It is not the case that " + reason[0].input1.text + "; therefore, it is not the case that "+claim;
					output += "If " + claim.positiveStmt + ", then "+ reason[0].positiveStmt;
					// if not negated,
					// output += "If " + claim + " then " + reason[0].input1.text
					break;
				case _langTypes[1]: // Implies
					output +=  claim.positiveStmt + " implies " + reason[0].positiveStmt;
					break;
				case _langTypes[2]: //Whenever
					output += "Whenever " + claim.positiveStmt + ", " + reason[0].positiveStmt;
					break;
				case _langTypes[3]: // Only if
					output += claim.positiveStmt + " Only if ";
					if(isLanguageExp==true)
					{
						for(i=0;i<reason.length-1;i++)
							output += reason[i].positiveStmt + " " + andOr + " ";	
					}
					output += reason[reason.length-1].positiveStmt;
					break;
				case _langTypes[4]: // Provided that
					output += reason[0].positiveStmt + " provided that " + claim.positiveStmt;
					break;
				case _langTypes[5]: // Sufficient condition
					output += claim.positiveStmt + " is a sufficient condition for " + reason[0].positiveStmt;
					break;
				case _langTypes[6]: // Necessary condition
					output += reason[0].positiveStmt + " is a necessary condition for " + claim.positiveStmt;
					break;	
			}
			
			return output;
		}
	}
}