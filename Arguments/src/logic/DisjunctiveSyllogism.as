
package logic
{
	import classes.ArgumentPanel;
	public class DisjunctiveSyllogism extends ParentArg
	{
		public function DisjunctiveSyllogism()
		{
			_langTypes = ["Either-or","Unless"];
			_expLangTypes =  ["Either-or"];
			myname = DIS_SYLL;
			dbName = myname;
			
		}
		
		override public function correctUsage(index:int,claim: ArgumentPanel,reason:Vector.<ArgumentPanel>,exp:Boolean):String {
			var output:String = "";
			var i:int;
			switch(index) {
				case 0: //Either-or. when both claim and reason are negated
					output += "Either ";
					if(exp==true)
						for(i=0;i<reason.length;i++)
							output += reason[i].input1.text + " or ";
					output += claim;
					break;
				case 1: // Unless
					output +=  reason[0].input1.text + " Unless " + claim;
			}
			return output;
		}
	}
}