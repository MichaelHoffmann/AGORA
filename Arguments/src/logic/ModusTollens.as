package logic
{
	import classes.ArgumentPanel;
	public class ModusTollens extends ParentArg
	{
		public function ModusTollens()
		{
			myname = MOD_TOL;
			//_langTypes = ["If-then","Implies","Whenever","Only-if","Only-if-Exp-And","Only-if-Exp-Or","Provided-that","Sufficient-condition","Necessary-condition"];
			_langTypes = ["If-then","Implies","Whenever","Only if","Provided that","Sufficient condition","Necessary condition"];
			_expLangTypes = ["Only if"];	// Expandable with both And and Or

		}
		
		override public function correctUsage(index:int,claim:String,reason:Vector.<ArgumentPanel>,exp:Boolean):String {
			var output:String = "";
			var i:int;
			switch(index) {
				case 0: //If-then. If both claim and reason negated
					output += "It is not the case that " + reason[0].input1.text + "; therefore, it is not the case that "+claim;
					// if not negated,
					// output += "If " + claim + " then " + reason[0].input1.text
					break;
				case 1: // Implies
					output +=  claim + " implies " + reason[0].input1.text;
					break;
				case 2: //Whenever
					output += "Whenever " + claim + ", " + reason[0].input1.text;
					break;
				case 3: // Only if
					output += claim + " Only if ";
					if(exp==true)
						for(i=0;i<reason.length-1;i++)
							output += reason[i].input1.text + " " + "or" + " ";		// "or" is temp. Should be the And/Or connector in its place!
					output += reason[reason.length-1].input1.text;
					break;
				case 4: // Provided that
					output += reason[0].input1.text + " Provided that " + claim;
					break;
				case 5: // Sufficient condition
					output += claim + " is a Sufficient condition for " + reason[0].input1.text;
					break;
				case 6: // Necessary condition
					output += reason[0].input1.text + " is a Necessary condition for " + claim;
					break;	
			}
			return output;
		}
		
		
	}
}