package logic
{
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
	
	import components.ArgSelector;
	
	import mx.controls.Alert;
	import mx.messaging.channels.StreamingAMFChannel;
	
	public class ModusPonens extends ParentArg
	{
		
		public function ModusPonens()
		{
			_langTypes = ["If-then","Implies","Whenever","Only if","Provided that","Sufficient condition","Necessary condition"];
			dbLangTypeNames = ["ifthen","implies","whenever","onlyif","providedthat","sufficient","necessary"];
			_expLangTypes = ["If-then","Whenever","Provided that"];	
			myname = MOD_PON;
			_dbType = "MP";
		}
		
		override public function getLanguageType(dbString:String):String
		{
			for(var i:int=0;i<dbLangTypeNames.length;i++)
			{
				if(dbString.indexOf(dbLangTypeNames[i]) >= 0)
				{
					return _langTypes[i];
				}
					
			}
			return "";
		}
		
		override public function createLinks():void
		{
			if(inference.claim.inference != null && inference.claim.statementNegated)
			{
				Alert.show("Error: Statement cannot be negative");
			}
			
			//make claim and reason un-multiStatement
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
			
			trace('claim user entered value:'+inference.claim.userEntered);
			if(inference.claim.userEntered == false && inference.claim.inference == null && inference.claim.rules.length < 2)
			{
				inference.claim.input1.text = "P";
				inference.reasons[0].input1.text = "Q";
				//make them uneditable. It automatically
				//sets the displayTxt Text control
				inference.claim.makeUnEditable();
				inference.reasons[0].makeUnEditable();
			}
			
			//claim and reasons should not be negated
			if(inference.claim.statementNegated)
			{
				inference.claim.statementNegated = false;
			}
			
			for(i=0; i < inference.reasons.length; i++)
			{
				if(inference.reasons[i].statementNegated)
				{
					inference.reasons[i].statementNegated = false;
				}
			}
			inference.implies = true;
			super.createLinks();	
		}
		
		override public function correctUsage():String {			
			var output:String = "";
			var reason:Vector.<ArgumentPanel> = inference.reasons;
			var claim:ArgumentPanel = inference.claim;
			var i:int;
			var reasonStr:String;
			switch(inference.myschemeSel.selectedType) {
				case _langTypes[0]:
					reasonStr = "";
					output += "If "
					for(i=0; i < reason.length - 1; i++)
					{
						output += reason[i].stmt + " and if ";
						reasonStr = reasonStr + reason[i].stmt + " and if ";
					}
					output += reason[i].stmt + ", then " + claim.stmt;
					reasonStr = reasonStr + reason[i].stmt;
					inference.inputs[1].text = reasonStr;
					inference.inputs[0].text = claim.stmt;
					inference.inputs[0].forwardUpdate();
					inference.inputs[1].forwardUpdate();
					break;
				case _langTypes[1]: // Implies
					output += reason[0].stmt + " implies " + claim.stmt;
					inference.inputs[1].text = reason[0].stmt;
					inference.inputs[0].text = claim.stmt;
					inference.inputs[0].forwardUpdate();
					inference.inputs[1].forwardUpdate();
					break;
				case _langTypes[2]: //Whenever
					reasonStr = "";
					output += "Whenever "
					for(i=0;i<reason.length-1;i++)
					{
						output += reason[i].stmt + " and ";
						reasonStr += reason[i].stmt + " and ";
					}
					output += reason[i].stmt + ", "+ claim.stmt;
					reasonStr = reasonStr + reason[i].stmt;
					inference.inputs[1].text = reasonStr;
					inference.inputs[0].text = claim.stmt;
					inference.inputs[0].forwardUpdate();
					inference.inputs[1].forwardUpdate();
					break;
				case _langTypes[3]: // Only if
					output += reason[0].stmt + " only if " + claim.stmt;
					inference.inputs[1].text = reason[0].stmt;
					inference.inputs[0].text = claim.stmt;
					inference.inputs[0].forwardUpdate();
					inference.inputs[1].forwardUpdate();
					break;
				case _langTypes[4]: // Provided that
					reasonStr = "";
					output += claim.stmt + " provided that ";
					for(i=0;i<reason.length-1;i++)
					{
						output += reason[i].stmt + " and ";
						reasonStr += reason[i].stmt + " and ";
					}
					output += reason[i].stmt;
					reasonStr = reasonStr + reason[i].stmt;
					inference.inputs[1].text = reasonStr;
					inference.inputs[0].text = claim.stmt;
					inference.inputs[0].forwardUpdate();
					inference.inputs[1].forwardUpdate();
					break;
				case _langTypes[5]: // Sufficient condition
					output += reason[0].stmt + " is a sufficient condition for " + claim.stmt;
					inference.inputs[1].text = reason[0].stmt;
					inference.inputs[0].text = claim.stmt;
					inference.inputs[0].forwardUpdate();
					inference.inputs[1].forwardUpdate();
					break;
				case _langTypes[6]: // Necessary condition
					output += claim.stmt + " is a necessary condition for " + reason[0].stmt;
					inference.inputs[1].text = reason[0].stmt;
					inference.inputs[0].text = claim.stmt;
					inference.inputs[0].forwardUpdate();
					inference.inputs[1].forwardUpdate();
					break;
				case _langTypes[7]: //If and only if
					output += claim.stmt + " if and only if " + reason[0].stmt; 	// IMP!! TODO: if-and-only-if2 : both claim and reason negated
					inference.inputs[1].text = reason[0].stmt;
					inference.inputs[0].text = claim.stmt;
					inference.inputs[0].forwardUpdate();
					inference.inputs[1].forwardUpdate();
					break;
				case _langTypes[8]: //Necessary and sufficient condition
					output += claim.stmt + " is a necessary and sufficient condition for " + reason[0].stmt; 	
					inference.inputs[1].text = reason[0].stmt;
					inference.inputs[0].text = claim.stmt;// TODO: Necessary-and-sufficient2 : both claim and reason negated
					inference.inputs[0].forwardUpdate();
					inference.inputs[1].forwardUpdate();
					break;
				case _langTypes[9]: //Equivalent
					output += claim.stmt + " and " + reason[0].stmt + " are equivalent"; 	// TODO: Equivalent2 : both claim and reason negated		
					inference.inputs[1].text = reason[0].stmt;
					inference.inputs[0].text = claim.stmt;
					inference.inputs[0].forwardUpdate();
					inference.inputs[1].forwardUpdate();
			}
			return output;		
		}		
	}
}