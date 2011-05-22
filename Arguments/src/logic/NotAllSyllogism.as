
package logic
{
	import classes.ArgumentPanel;
	public class NotAllSyllogism extends ParentArg
	{
		public function NotAllSyllogism()
		{
			myname = NOT_ALL_SYLL;
			dbName = myname;
			_langTypes = ["Not-all"]; 	// the sole language type here is expandable. always with And.

		}
		
		override public function correctUsage():String {
			var output:String = "";
		/*
			output += "It cannot be the case, at the same time, that ";
			if(exp==true)
				for(var i:int=0;i<reason.length;i++)
					output += reason[i].input1.text + " and that ";
			output += claim.stmt;
		*/	
			return output;
		}
	}
}