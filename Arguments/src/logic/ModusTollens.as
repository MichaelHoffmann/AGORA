package logic
{
<<<<<<< HEAD
	import components.ArgumentPanel;
	
	import mx.controls.Alert;
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
	//TODO: translate this file
	public class ModusTollens extends ParentArg
	{ 
		public var andOr:String;
		private var _isExp:Boolean;
		private static var instance:ModusTollens;
		
		
		public function ModusTollens()
		{
			_langTypes = ["If-then","Implies","Whenever","Only if","Provided that","Sufficient condition","Necessary condition"];
			dbLangTypeNames = ["ifthen","implies","whenever","onlyif","providedthat","sufficient","necessary"];
			_expLangTypes = ["Only if"];	// Expandable with both And and Or
			myname = MOD_TOL;
			_dbType = "MT";
		}
		
		public static function getInstance():ModusTollens{
			if(instance == null){
				instance = new ModusTollens;
			}
			return instance;
		}
		
		/*
		
		override public function getOption(dbString:String):String{
			if(dbString.indexOf("or") >= 0)
			{
				return "or";
			}
			else if(dbString.indexOf("and") >= 0)
			{
				return "and"  ;
			}
			else
			{
				return "";
			}
		}
		
		override public function get dbType():String
		{
			
			for(var i:int=0; i<_langTypes.length; i++)
			{
				if(inference.myschemeSel.selectedType == _langTypes[i]){
					if(_langTypes[i] == "Only if" && inference.hasMultipleReasons){
						
						return _dbType+dbLangTypeNames[i]+andOr;
					}
					else 
					{
						return _dbType+dbLangTypeNames[i];
						
					}
				}
			}
			return "Unset";
		}
		
		override public function createLinks():void
		{
			//Negate the claim if it is the first claim of the argument
			if(inference.claim.inference != null && !inference.claim.statementNegated)
			{
				Alert.show("Error: The claim should not have been a non-negative statement");
			}
			
			//change claim and reason from multistatement to normal
			//statement type
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
				inference.claim.makeUnEditable();
				inference.reasons[0].input1.text = "Q";
				inference.reasons[0].makeUnEditable();
			}
			
			
			if(!inference.claim.statementNegated)
			{
				inference.claim.statementNegated = true;	
			}
			
			for(i = 0; i < inference.reasons.length; i++)
			{
				if(!inference.reasons[i].statementNegated)
				{
					inference.reasons[i].statementNegated = true;
				}	
			}
			
			inference.implies = true;
			
			var	claim:ArgumentPanel = inference.claim;
			var reasons:Vector.<ArgumentPanel> = inference.reasons;
			claim.input1.forwardList.push(inference.input[0]);
			inference.input[0].forwardList.push(inference.inputs[1]);
			for(i=0; i < reasons.length; i++)
			{
				reasons[i].input1.forwardList.push(inference.input[i+1]);
				inference.input[i+1].forwardList.push(inference.inputs[0]);
			}
			inference.implies = true;
		}
		
		override public function correctUsage():String {
			var output:String = "";
			var reason:Vector.<ArgumentPanel> = inference.reasons;
			var claim:ArgumentPanel = inference.claim;
			var i:int;
			
			
			//Negate the reason. The reason will not be supported by other
			//arguments. If it were, the argument woud have had 'typed' true,
			//and myArg would not be pointing to a Modus Tollens Object
			
			switch(inference.myschemeSel.selectedType) {
				//negate reason				
				case _langTypes[0]: //If-then. If both claim and reason negated
					//output += "If " + claim.positiveStmt + ", then "+ reason[0].positiveStmt;
					inference.inputs[0].text = reason[0].positiveStmt;
					
					inference.inputs[1].text = claim.positiveStmt;
					
					output = "If " + inference.inputs[1].text + ", then " + inference.inputs[0].text;
					inference.inputs[0].forwardUpdate();
					inference.inputs[1].forwardUpdate();
					break;
				case _langTypes[1]: // Implies
					output +=  claim.positiveStmt + " implies " + reason[0].positiveStmt;
					inference.inputs[0].text = reason[0].positiveStmt;
					inference.inputs[1].text = claim.positiveStmt;
					inference.inputs[0].forwardUpdate();
					inference.inputs[1].forwardUpdate();
					break;
				case _langTypes[2]: //Whenever
					output += "Whenever " + claim.positiveStmt + ", " + reason[0].positiveStmt;
					inference.inputs[0].text = reason[0].positiveStmt;
					inference.inputs[1].text = claim.positiveStmt;
					inference.inputs[0].forwardUpdate();
					inference.inputs[1].forwardUpdate();
					break;
				case _langTypes[3]: // Only if
					var reasonStr:String = "";
					output += claim.positiveStmt + " only if ";
					for(i=0;i<reason.length-1;i++)
					{
						output += reason[i].positiveStmt + " " + andOr + " ";
						reasonStr = reasonStr + reason[i].positiveStmt + " " + andOr + " ";
					}
					reasonStr = reasonStr + reason[i].positiveStmt;
					output += reason[reason.length-1].positiveStmt;
					inference.inputs[0].text = reasonStr;
					inference.inputs[1].text = claim.positiveStmt;
					inference.inputs[0].forwardUpdate();
					inference.inputs[1].forwardUpdate();
					break;
				case _langTypes[4]: // Provided that
					output += reason[0].positiveStmt + " provided that " + claim.positiveStmt;
					inference.inputs[0].text = reason[0].positiveStmt;
					inference.inputs[1].text = claim.positiveStmt;
					inference.inputs[0].forwardUpdate();
					inference.inputs[1].forwardUpdate();
					break;
				
				case _langTypes[5]: // Sufficient condition
					output += claim.positiveStmt + " is a sufficient condition for " + reason[0].positiveStmt;
					inference.inputs[0].text = reason[0].positiveStmt;
					inference.inputs[1].text = claim.positiveStmt;
					inference.inputs[0].forwardUpdate();
					inference.inputs[1].forwardUpdate();
					break;
				case _langTypes[6]: // Necessary condition
					output += reason[0].positiveStmt + " is a necessary condition for " + claim.positiveStmt;
					inference.inputs[0].text = reason[0].positiveStmt;
					inference.inputs[1].text = claim.positiveStmt;
					inference.inputs[0].forwardUpdate();
					inference.inputs[1].forwardUpdate();
					break;	
			}
			return output;
		}
		*/
	}
}