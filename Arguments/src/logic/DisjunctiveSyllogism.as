
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
			_dbType = "DisjSyl";
		}
/*		
		override public function get dbType():String
		{
			return _dbType;
		}
		
		override public function createLinks():void
		{
			trace("creating links");

			if(inference.claim.inference != null && inference.claim.statementNegated)
			{
				Alert.show("Error: Statement cannot be negative");
			}
			
			if(inference.claim.multiStatement)
			{
				inference.claim.multiStatement = false;
			}
			
			for(var i:int=0; i < inference.reasons.length; i++)
			{
				if(inference.reasons[i].multiStatement)
				{
					inference.reasons[i].multiStatement = false;
				}	
			}
			
			if(inference.claim.userEntered == false && inference.claim.inference == null && inference.claim.rules.length < 2)
			{
				inference.claim.input1.text = "P";
				inference.reasons[0].input1.text = "Q";
				inference.claim.makeUnEditable();
				inference.reasons[0].makeUnEditable();
			}
			
			if(inference.claim.statementNegated)
				inference.claim.statementNegated = false;
			
			for(i=0; i < inference.reasons.length; i++)
			{
				if(!inference.reasons[i].statementNegated)
				{
					inference.reasons[i].statementNegated = true;
				}
			}
			inference.implies = false;
			super.createLinks();
		}
		
		override public function correctUsage():String {
			
			var i:int;
			var output:String = "";
			switch(inference.myschemeSel.selectedType) 
			{
				case _langTypes[0]: 
					output += "Either ";
					for(i=0;i<inference.reasons.length;i++)
					{
						output += inference.reasons[i].positiveStmt + " or ";
						//Required for constructive dillemma
						//inference.inputs[i+1].text = inference.reasons[i].positiveStmt;
						//inference.inputs[i+1].forwardUpdate();
					}
					output += inference.claim.stmt;
					//inference.inputs[0].text = inference.claim.stmt;
					//inference.inputs[0].forwardUpdate();	
					break;
			}
			return output;
		}
		*/
	}
}