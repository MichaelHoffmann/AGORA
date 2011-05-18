package logic
{
	import classes.ArgumentPanel;	
	public class ConditionalSyllogism extends ParentArg
	{		
		public function ConditionalSyllogism()
		{
			myname = COND_SYLL;
			dbName = "ConSyllogism";
			_langTypes = ["If-then","Implies"];		// Both types here are expandable. like a chain rule
		}
		
		override public function correctUsage(index:int,claim:String,reason:Vector.<ArgumentPanel>,exp:Boolean):String {
			var output:String = "";
			var i:int;
			switch(index) {
				case 0: //If-then
					output += "If " + reason[0].input1.text;
					if(exp==true)
						for(i=1;i<reason.length;i++)
							output += " then " + reason[i].input1.text + "; if " + reason[i].input1.text;
					output += " then " + claim + "; therefore if " + reason[0].input1.text + ", then " + claim;
					break;
				case 1: //Implies
					output += reason[0].input1.text + " implies ";
					if(exp==true)
						for(i=1;i<reason.length;i++)
							output += reason[i].input1.text + "; " + reason[i].input1.text + " implies ";
					output += claim + "; therefore " + reason[0].input1.text + " implies " + claim;
					break;			
			}
			return output;
		}
	}
}