package logic
{
	import classes.ArgumentPanel;
	public class ConstructiveDilemma extends ParentArg
	{
		
		public function ConstructiveDilemma()
		{
			myname = CONST_DILEM;
			dbName = myname;
			_langTypes = ["ConstrDil-1(with alternative as claim)","ConstrDil-1(with one proposition as claim)"];
		}
		
		override public function correctUsage(index:int,claim:String,reason:Vector.<ArgumentPanel>,exp:Boolean):String {
			var output:String = "";
			var i:int;
			switch(index) {
				case 0: //Either-or with alternative as claim
					output += "Either " + reason[0].input1.text;
					if(exp==true)
						for(i=1;i<reason.length;i++)
							output += " then " + reason[i].input1.text + "; if " + reason[i].input1.text;
					output += " then " + claim + "; therefore if " + reason[0].input1.text + ", then " + claim;
					break;
				case 1: //Either-or with one proposition as claim
			}
			return output;
		}
	}
}