package logic
{	
	import classes.ArgumentPanel;
	
	import components.ArgSelector;
	
	import mx.controls.Alert;
	
	public class ModusPonens extends ParentArg
	{
		public function ModusPonens()
		{
			_langTypes = ["If-then","Implies","Whenever","Only if","Provided that","Sufficient condition","Necessary condition","If and only if",
				"Necessary-and-sufficient-condition","Equivalent"];
			_expLangTypes = ["If-then","Whenever","Provided that"];	
			myname = MOD_PON;
			dbName = "MPtherefore";			
			/*_langTypes = ["If-then","If-then-Exp-And","Implies","Whenever","Whenever-Exp-And","Only-if","Provided-that","Provided-that-Exp-And","Sufficient-condition","Necessary-condition","If-and-only-if",
			"Necessary-and-sufficient-condition","Equivalent"];*/
			// Modus Ponens is expandable only with AND
			
		}
		
		override public function correctUsage():String {
			
			var output:String = "";
			var reason:Vector.<ArgumentPanel> = inference.reasons;
			var claim:ArgumentPanel = inference.claim;
			
			if(inference.claim.inference != null && inference.claim.statementNegated)
			{
				Alert.show("Error: Statement cannot be negative");
			}
			
			if(inference.claim.statementNegated)
			{
				inference.claim.statementNegated = false;
			}
			
			for(var i:int=0; i < inference.reasons.length; i++)
			{
				if(inference.reasons[i].statementNegated)
				{
					inference.reasons[i].statementNegated = false;
				}
			}
			
			switch(inference.myschemeSel.selectedType) {
				case _langTypes[0]: 
					output += "If "
					for(i=0; i < reason.length - 1; i++)
					{
						output += reason[i].stmt + " and ";
					}
					output += reason[i].stmt + ", then " + claim.stmt;
					break;
				case _langTypes[1]: // Implies
					output += reason[0].stmt + " implies " + claim.stmt;
					break;
				case _langTypes[2]: //Whenever
					output += "Whenever "
					if(isLanguageExp==true)
						for(i=0;i<reason.length-1;i++)
							output += reason[i].stmt + " and ";
					output += reason[reason.length-1].stmt + ", "+ claim.stmt;
					break;
				case _langTypes[3]: // Only if
					output += reason[0].stmt + " only if " + claim.stmt;
					break;
				case _langTypes[4]: // Provided that
					output += claim.stmt + " provided that ";
					if(isLanguageExp==true)
						for(i=0;i<reason.length-1;i++)
							output += reason[i].stmt + " and ";
					output += reason[reason.length-1].stmt;
					break;
				case _langTypes[5]: // Sufficient condition
					output += reason[0].stmt + " is a sufficient condition for " + claim.stmt;
					break;
				case _langTypes[6]: // Necessary condition
					output += claim.stmt + " is a necessary condition for " + reason[0].stmt;
					break;
				case _langTypes[7]: //If and only if
					output += claim.stmt + " if and only if " + reason[0].stmt; 	// IMP!! TODO: if-and-only-if2 : both claim and reason negated
					break;
				case _langTypes[8]: //Necessary and sufficient condition
					output += claim.stmt + " is a necessary and sufficient condition for " + reason[0].stmt; 	// TODO: Necessary-and-sufficient2 : both claim and reason negated
					break;
				case _langTypes[9]: //Equivalent
					output += claim.stmt + " and " + reason[0].stmt + " are equivalent"; 	// TODO: Equivalent2 : both claim and reason negated		
			}
			return output;
		}
		
	}
}