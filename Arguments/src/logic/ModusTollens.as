package logic
{
	import classes.ArgumentPanel;
	public class ModusTollens extends ParentArg
	{ 
		public var andOr:String;
		public function ModusTollens()
		{
			_langTypes = ["If-then","Implies","Whenever","Only if","Provided that","Sufficient condition","Necessary condition"];
			_expLangTypes = ["Only if"];	// Expandable with both And and Or
			myname = MOD_TOL;
			dbName = myname;
			//_langTypes = ["If-then","Implies","Whenever","Only-if","Only-if-Exp-And","Only-if-Exp-Or","Provided-that","Sufficient-condition","Necessary-condition"];	
		}
		
		override public function correctUsage(index:int,claim:ArgumentPanel,reason:Vector.<ArgumentPanel>,exp:Boolean):String {
			var output:String = "";
			var i:int;
			switch(index) {
				//negate reason				
				case 0: //If-then. If both claim and reason negated
					//output += "It is not the case that " + reason[0].input1.text + "; therefore, it is not the case that "+claim;
					output += "If " + claim.positiveStmt + ", then "+ reason[0].positiveStmt;
					// if not negated,
					// output += "If " + claim + " then " + reason[0].input1.text
					break;
				case 1: // Implies
					output +=  claim.positiveStmt + " implies " + reason[0].positiveStmt;
					break;
				case 2: //Whenever
					output += "Whenever " + claim.positiveStmt + ", " + reason[0].positiveStmt;
					break;
				case 3: // Only if
					output += claim.positiveStmt + " Only if ";
					if(exp==true)
					{
						for(i=0;i<reason.length-1;i++)
							output += reason[i].input1.text + " " + andOr + " ";	
					}
					output += reason[reason.length-1].input1.text;
					break;
				case 4: // Provided that
					output += claim.positiveStmt + " provided that " + reason[0].positiveStmt;
					break;
				case 5: // Sufficient condition
					output += claim.positiveStmt + " is a sufficient condition for " + reason[0].positiveStmt;
					break;
				case 6: // Necessary condition
					output += claim.positiveStmt + " is a Necessary condition for " + reason[0].positiveStmt;
					break;	
			}
			return output;
		}
		
		
	}
}