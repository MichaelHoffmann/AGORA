package logic
{	
	import classes.ArgumentPanel;
	
	import components.ArgSelector;

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
		
		override public function correctUsage(index:int,claim: ArgumentPanel, reason:Vector.<ArgumentPanel>,exp:Boolean):String {
			
			var output:String = "";
			var i:int;
			switch(index) {
				case 0: //If-then
					output += "If "
					if(exp==true)
					for(i=0;i<reason.length-1;i++)
						output += reason[i].input1.text + " and ";
					output += reason[reason.length-1].input1.text + ", then "+claim.stmt;
					break;
				case 1: // Implies
					output += reason[0].input1.text + " implies " + claim.stmt;
					break;
				case 2: //Whenever
					output += "Whenever "
					if(exp==true)
						for(i=0;i<reason.length-1;i++)
							output += reason[i].input1.text + " and ";
					output += reason[reason.length-1].input1.text + ", "+claim.stmt;
					break;
				case 3: // Only if
					output += reason[0].input1.text + " Only if " + claim.stmt;
					break;
				case 4: // Provided that
					output += claim.stmt + " Provided that ";
					if(exp==true)
						for(i=0;i<reason.length-1;i++)
							output += reason[i].input1.text + " and ";
					output += reason[reason.length-1].input1.text;
					break;
				case 5: // Sufficient condition
					output += reason[0].input1.text + " is a Sufficient condition for " + claim.stmt;
					break;
				case 6: // Necessary condition
					output += claim.stmt + " is a Necessary condition for " + reason[0].input1.text;
					break;
				case 7: //If and only if
					output += claim.stmt + " If and only if " + reason[0].input1.text; 	// IMP!! TODO: if-and-only-if2 : both claim and reason negated
					break;
				case 8: //Necessary and sufficient condition
					output += claim.stmt + " is a Necessary and Sufficient condition for " + reason[0].input1.text; 	// TODO: Necessary-and-sufficient2 : both claim and reason negated
					break;
				case 9: //Equivalent
					output += claim.stmt + " and " + reason[0].input1.text + " are Equivalent"; 	// TODO: Equivalent2 : both claim and reason negated		
			}
			return output;
		}
		
	}
}