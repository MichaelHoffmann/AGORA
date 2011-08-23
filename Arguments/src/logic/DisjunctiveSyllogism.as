
package logic
{
<<<<<<< HEAD
	import components.ArgumentPanel;
=======
	/**
	 AGORA - an interactive and web-based argument mapping tool that stimulates reasoning, 
	 reflection, critique, deliberation, and creativity in individual argument construction 
	 and in collaborative or adversarial settings. 
	 Copyright (C) 2011 Georgia Institute of Technology
	 
	 This program is free software: you can redistribute it and/or modify
	 it under the terms of the GNU Affero General Public License as
	 published by the Free Software Foundation, either version 3 of the
	 License, or (at your option) any later version.
	 
	 This program is distributed in the hope that it will be useful,
	 but WITHOUT ANY WARRANTY; without even the implied warranty of
	 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	 GNU Affero General Public License for more details.
	 
	 You should have received a copy of the GNU Affero General Public License
	 along with this program.  If not, see <http://www.gnu.org/licenses/>.
	 
	 */
	import classes.ArgumentPanel;
	import classes.Language;
>>>>>>> Joshua/master
	
	import mx.controls.Alert;
	
	public class DisjunctiveSyllogism extends ParentArg
	{
		private static var instance:DisjunctiveSyllogism;
		
		public function DisjunctiveSyllogism()
		{
			_langTypes = ["Either-or"];
			_expLangTypes =  ["Either-or"];
			myname = DIS_SYLL;
			_dbType = "DisjSyl";
		}
		
		public static function getInstance():DisjunctiveSyllogism{
			if(instance == null){
				instance = new DisjunctiveSyllogism;
			}
			return instance;
		}
		
/*		
		override public function get dbType():String
		{
			return _dbType;
		}

		override public function getLanguageType(dbString:String):String{
			return _langTypes[0];
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
					output += Language.lookup("ArgEitherCap");
					for(i=0;i<inference.reasons.length;i++)
					{
						output += inference.reasons[i].positiveStmt + Language.lookup("ArgOr");
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